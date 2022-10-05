import Array "mo:base/Array";
import Buffer "mo:base/Buffer";
import Error "mo:base/Error";
import HashMap "mo:base/HashMap";
import Iter "mo:base/Iter";
import List "mo:base/List";
import Nat "mo:base/Nat";
import Nat32 "mo:base/Nat32";
import Nat8 "mo:base/Nat8";
import Option "mo:base/Option";
import Prim "mo:prim";
import Principal "mo:base/Principal";
import Result "mo:base/Result";
import Text "mo:base/Text";
import Time "mo:base/Time";
import TrieMap "mo:base/TrieMap";

import Ext "mo:ext/Ext";

import Cap "../cap";
import Types "types";

module {

  ////////////
  // Types //
  //////////

  public type Template = Types.Template;
  public type Item = Types.Item;
  public type Accessory = Types.Accessory;
  public type LegendaryAccessory = Types.LegendaryAccessory;
  public type Recipe = Types.Recipe;
  public type Inventory = Types.Inventory;
  public type ItemInventory = Types.ItemInventory;
  public type MaterialInventory = Types.MaterialInventory;
  public type AccessoryInventory = Types.AccessoryInventory;
  public type AccessoryUpdate = Types.AccessoryUpdate;
  public type UpgradeDataOld = Types.UpgradeDataOld;
  public type UpgradeData = Types.UpgradeData;
  public type BurnedInformation = Types.BurnedInformation;
  public type BurnedAccessory = Types.BurnedAccessory;
  type TokenIndex = Ext.TokenIndex;
  type TokenIdentifier = Ext.TokenIdentifier;
  type AccountIdentifier = Ext.AccountIdentifier;
  type Result<A, B> = Result.Result<A, B>;
  type Time = Time.Time;

  public class Factory(dependencies : Types.Dependencies) : Types.Interface {

    ////////////
    // State //
    ///////////

    let _items : HashMap.HashMap<TokenIndex, Item> = HashMap.HashMap(0, Ext.TokenIndex.equal, Ext.TokenIndex.hash);
    let _templates : HashMap.HashMap<Text, Template> = HashMap.HashMap(0, Text.equal, Text.hash);
    let _recipes : TrieMap.TrieMap<Text, Recipe> = TrieMap.TrieMap(Text.equal, Text.hash);

    var _pendingBurned : List.List<BurnedAccessory> = null;

    let AVATAR_ACTOR = actor (Principal.toText(dependencies.cid_avatar)) : actor {
      wearAccessory : shared (tokeniId : TokenIdentifier, name : Text, p : Principal) -> async Result<(), Text>;
      removeAccessory : shared (tokeniId : TokenIdentifier, name : Text, p : Principal) -> async Result<(), Text>;
      report_burned_accessory : shared (name : Text, avatar : TokenIdentifier, accessory : TokenIndex) -> async Result<(), ()>;
    };

    let _Logs = dependencies._Logs;
    let _Ext = dependencies._Ext;
    let _Cap = dependencies._Cap;

    public func preupgrade() : UpgradeData {
      return (
        {
          items = Iter.toArray(_items.entries());
          templates = Iter.toArray(_templates.entries());
          recipes = Iter.toArray(_recipes.entries());
          pendingBurned = List.toArray(_pendingBurned);
        },
      );
    };

    public func postupgrade(ud : ?UpgradeData) : () {
      switch (ud) {
        case (?ud) {
          for ((index, item) in ud.items.vals()) {
            _items.put(index, item);
          };
          for ((name, template) in ud.templates.vals()) {
            _templates.put(name, template);
          };
          for ((name, recipe) in ud.recipes.vals()) {
            _recipes.put(name, recipe);
          };
          _pendingBurned := List.fromArray(ud.pendingBurned);
        };
        case (null) {};
      };
    };

    /////////////
    // API /////
    ///////////

    public func removeItems(n : TokenIndex) : () {
      for ((tokenIndex, item) in _items.entries()) {
        if (tokenIndex > n) {
          _items.delete(tokenIndex);
        };
      };
    };

    public func addTemplate(name : Text, template : Template) : Result<Text, Text> {
      switch (template) {
        case (#Accessory(template)) {
          _recipes.put(name, template.recipe);
          _Logs.logMessage("TASK :: recipe added for accessory: " # name);
        };
        case _ {};
      };
      _templates.put(name, template);
      return #ok("Template added for : " # name);
    };

    public func getTemplates() : [(Text, Template)] {
      return Iter.toArray(_templates.entries());
    };

    public func addRecipe(name : Text, recipe : Recipe) : Result<Text, Text> {
      _recipes.put(name, recipe);
      return #ok("Recipe added for : " # name);
    };

    public func getRecipes() : [(Text, Recipe)] {
      return Iter.toArray(_recipes.entries());
    };

    public func wearAccessory(
      accessory : TokenIdentifier,
      avatar : TokenIdentifier,
      caller : Principal,
    ) : async Result<(), Text> {
      let index = switch (Ext.TokenIdentifier.decode(accessory)) {
        case (#ok(p, i)) {
          if (p != dependencies.cid) {
            _Logs.logMessage("ERR :: decoding of tokenIdentifier : " # accessory # "the canister id is " # Principal.toText(p));
            return #err("Error when decoding of tokenIdentifier : " # accessory);
          };
          i;
        };
        case (#err(e)) {
          _Logs.logMessage("ERR :: decoding of tokenIdentifier : " # accessory # ". Detail : " # e);
          return #err(e);
        };
      };
      switch (_items.get(index)) {
        case (?#Accessory(item)) {
          switch (item.equipped) {
            case (?avatar) {
              if (avatar == "InProgress") {
                _Logs.logMessage("WARNING :: reentrancy attack detected from " # Principal.toText(caller));
                return #err("Accessory" # accessory # " is being equipped");
              };
              _Logs.logMessage("ERR :: accessory " # accessory # " is already equipped on " # avatar);
              return #err("Accessory" # accessory # " is already equipped on " # avatar);
            };
            case (null) {
              // Verify the wear value
              if (item.wear <= 1) {
                _Logs.logMessage("ERR :: accessory " # accessory # " cannot be equipped (wear value too low)");
                return #err("Accessory" # accessory # " cannot be equipped (wear value too low)");
              };
              _items.put(index, _createAccessoryEquippedOn(item, ?"InProgress"));
              try {
                // 🎯 Commit point for the state of the canister.
                switch (await AVATAR_ACTOR.wearAccessory(avatar, Text.map(item.name, Prim.charToLower), caller)) {
                  case (#ok(())) {
                    _Logs.logMessage("EVENT :: Accessory " # accessory # " equipped on " # avatar);
                    _items.put(index, _createAccessoryEquippedOn(item, ?avatar));
                    return #ok;
                  };
                  case (#err(e)) {
                    _Logs.logMessage("ERR :: wearAccessory : " # e);
                    _items.put(index, _createAccessoryEquippedOn(item, null));
                    return #err(e);
                  };
                };
              } catch e {
                _Logs.logMessage("ERR :: wearAccessory : " # Error.message(e));
                _items.put(index, _createAccessoryEquippedOn(item, null));
                throw e;
              };
            };
          };
        };
        case _ {
          _Logs.logMessage("ERR :: accessory not found for index : " # Nat32.toText(index));
          return #err("Accessory not found for tokenIdentifier : " # accessory);
        };
      };
    };

    public func removeAccessory(
      accessory : TokenIdentifier,
      avatar : TokenIdentifier,
      caller : Principal,
    ) : async Result<(), Text> {
      let index = switch (Ext.TokenIdentifier.decode(accessory)) {
        case (#ok(p, i)) {
          if (p != dependencies.cid) {
            _Logs.logMessage("Error when decoding the tokenIdentifier : " # accessory # "the canister id is " # Principal.toText(p));
            return #err("Error when decoding the tokenIdentifier : " # accessory);
          };
          i;
        };
        case (#err(e)) {
          _Logs.logMessage("Error during decode of tokenIdentifier : " # accessory # ". Detail : " # e);
          return #err(e);
        };
      };
      switch (_items.get(index)) {
        case (?#Accessory(item)) {
          switch (item.equipped) {
            case (?avatar) {
              if (item.wear <= 2) {
                _Logs.logMessage("Accessory " # accessory # " cannot be removed (wear value too low)");
                return #err("Accessory" # accessory # " cannot be removed (wear value too low)");
              };
              try {
                // 🎯 Commit point for the state of the canister.
                switch (await AVATAR_ACTOR.removeAccessory(avatar, Text.map(item.name, Prim.charToLower), caller)) {
                  case (#ok(())) {
                    _items.put(index, _createAccessoryEquippedOn(item, null));
                    return #ok;
                  };
                  case (#err(e)) {
                    _Logs.logMessage("Error during wearAccessory : " # e);
                    return #err(e);
                  };
                };
              } catch e {
                _Logs.logMessage("Error during wearAccessory : " # Error.message(e));
                throw e;
              };
            };
            case (null) {
              _Logs.logMessage("Accessory " # accessory # " is not equipped");
              return #err("Accessory " # accessory # " is not equipped");
            };
          };
        };
        case _ {
          _Logs.logMessage("Accessory not found for tokenIndex : " # Nat32.toText(index));
          return #err("Accessory not found for tokenIdentifier : " # accessory);
        };
      };
    };

    public func mint(
      name : Text,
      index : TokenIndex,
    ) : Result<(), Text> {
      switch (_templates.get(name)) {
        case (?#Material(blob)) {
          _items.put(index, #Material(name));
          return #ok;
        };
        case (?#Accessory(item)) {
          _items.put(index, #Accessory({ name = name; wear = 100; equipped = null }));
          return #ok;
        };
        case (_) return #err("No template found");
      };
    };

    public func getRecipe(
      name : Text,
    ) : ?Recipe {
      _recipes.get(name);
    };

    public func getMaterials(
      caller : Principal,
    ) : [(TokenIndex, Text)] {
      let account = Text.map(Ext.AccountIdentifier.fromPrincipal(caller, null), Prim.charToLower);
      let tokens = switch (_Ext.tokens(account)) {
        case (#err(e)) {
          return [];
        };
        case (#ok(list)) { list };
      };
      let materials = Buffer.Buffer<(TokenIndex, Text)>(0);
      for (token in tokens.vals()) {
        switch (_items.get(token)) {
          case (?#Material(name)) {
            materials.add((token, name));
          };
          case (_) {};
        };
      };
      return materials.toArray();
    };

    public func getBlob(
      index : TokenIndex,
    ) : ?Blob {
      switch (_items.get(index)) {
        case (?#Material(name)) {
          switch (_templates.get(name)) {
            case (?#Material(blob)) {
              _Logs.logMessage("CRITICAL ERROR : template not found for : " # name);
              return ?blob;
            };
            case (_) return null;
          };
        };
        case (?#Accessory(item)) {
          return _getBlobAccessory(index);
        };
        case (_) return null;
      };
    };

    public func isEquipped(
      index : TokenIndex,
    ) : Bool {
      switch (_items.get(index)) {
        case (?#Material(name)) {
          return false;
        };
        case (?#Accessory(item)) {
          return (Option.isSome(item.equipped));
        };
        case (_) {
          _Logs.logMessage("Strange error : item not found for tokenIndex : " # Nat32.toText(index));
          assert (false);
          return false;
        };
      };
    };

    public func getTemplate(
      name : Text,
    ) : ?Blob {
      switch (_templates.get(name)) {
        case (?#Material(blob)) {
          return ?blob;
        };
        case (?#Accessory(item)) {
          return ?Text.encodeUtf8(item.before_wear # item.after_wear);
        };
        case (_) return null;
      };
    };

    public func getName(
      index : TokenIndex,
    ) : ?Text {
      switch (_items.get(index)) {
        case (?#Material(name)) {
          return ?name;
        };
        case (?#Accessory(item)) {
          return ?item.name;
        };
        case (_) return null;
      };
    };

    public func getInventory(
      caller : Principal,
    ) : Result<Inventory, Text> {
      let account = Text.map(Ext.AccountIdentifier.fromPrincipal(caller, null), Prim.charToLower);
      switch (_Ext.tokens(account)) {
        case (#err(_)) {
          _Logs.logMessage("Error trying to retrieve tokens");
          return #err("Error trying to retrieve tokens");
        };
        case (#ok(list)) {
          return (#ok(Array.map<TokenIndex, ItemInventory>(list, _tokenIndexToInventoryItem)));
        };
      };
    };

    public func getItems() : [(Text, [TokenIndex])] {
      let map = TrieMap.TrieMap<Text, Buffer.Buffer<TokenIndex>>(Text.equal, Text.hash);
      for ((index, item) in _items.entries()) {
        let name = _itemToName(item);
        switch (map.get(name)) {
          case (?buffer) {
            buffer.add(index);
          };
          case (null) {
            let buffer = Buffer.Buffer<TokenIndex>(0);
            buffer.add(index);
            map.put(name, buffer);
          };
        };
      };
      // Add items with 0 supply!
      for ((name) in _templates.keys()) {
        switch (map.get(name)) {
          case (?buffer) {};
          case (null) {
            let buffer = Buffer.Buffer<TokenIndex>(0);
            map.put(name, buffer);
          };
        };
      };
      let buffer = Buffer.Buffer<(Text, [TokenIndex])>(0);
      for ((name, list) in map.entries()) {
        buffer.add((name, list.toArray()));
      };
      return buffer.toArray();
    };

    public func burn(
      index : TokenIndex,
    ) : () {
      _items.delete(index);
    };

    /* 
            Decreases the wear value of all equipped accessories by one and returns a tupple of lists.
            List 1 : Burned accessories
            List 2: Decreased accessories
            @Cronic : Called once per day
        */
    public func updateAll() : ([TokenIndex], [TokenIndex]) {
      let list_accessory_to_update = _getListEquippedAccessory();

      var buffer_burned : Buffer.Buffer<TokenIndex> = Buffer.Buffer<TokenIndex>(0);
      var buffer_decreased : Buffer.Buffer<TokenIndex> = Buffer.Buffer<TokenIndex>(0);

      for (index in list_accessory_to_update.vals()) {
        switch (_updateAccessory(index)) {
          case (#err(e)) {
            _Logs.logMessage("ERR :: updating accessory : " # Nat32.toText(index));
          };
          case (#ok(event)) {
            switch (event) {
              case (#Burned) {
                buffer_burned.add(index);
              };
              case (#Decreased) {
                buffer_decreased.add(index);
              };
            };
          };
        };
      };
      return (buffer_burned.toArray(), buffer_decreased.toArray());
    };

    var pendingCount : Nat = 0;
    public func cronBurned() : async () {
      if (List.size<BurnedAccessory>(_pendingBurned) == 0) {
        return;
      };

      var completed : List.List<BurnedAccessory> = null;
      var failed : List.List<BurnedAccessory> = null;
      let (burned, remaining) = List.pop(_pendingBurned);
      var job = burned;
      _pendingBurned := remaining;

      label queue while (Option.isSome(job)) ignore do ?{
        pendingCount += 1;
        try {
          switch (await AVATAR_ACTOR.report_burned_accessory(job!.name, job!.tokenIdentifier, job!.tokenIndex)) {
            case (#ok(_)) {
              completed := List.push(job!, completed);
              pendingCount -= 1;
            };
            case (#err(_)) {
              _Logs.logMessage("ERR :: reporting burned accessory : " # Nat32.toText(job!.tokenIndex));
              failed := List.push(job!, failed);
              pendingCount -= 1;
            };
          };
        } catch (e) {
          _Logs.logMessage("ERR :: CATCH :: " # Error.message(e));
          failed := List.push(job!, failed);
          pendingCount -= 1;
        };
        let (burned, remaining) = List.pop(_pendingBurned);
        job := burned;
        _pendingBurned := remaining;
      };

      if (List.size(failed) > 0) {
        _pendingBurned := List.append(failed, _pendingBurned);
      };
    };

    public func deleteItem(name : Text) : Result<(), Text> {
      //Verify that the item doesn't exist live
      for (item in _items.vals()) {
        if (_itemToName(item) == name) {
          return #err("Item still exists, please burn it first");
        };
      };
      switch (_templates.get(name)) {
        case (null) {
          return #err("Item not found in _templates");
        };
        case (?item) {
          switch (_recipes.get(name)) {
            case (null) {
              return #err("Item not found in _recipes");
            };
            case (?recipe) {
              _recipes.delete(name);
              _templates.delete(name);
              return #ok();
            };
          };
        };
      };
    };

    public func getAvatarEquipped(tokenId : TokenIdentifier) : ?TokenIdentifier {
      let index = switch (Ext.TokenIdentifier.decode(tokenId)) {
        case (#ok(p, index)) {
          index;
        };
        case (#err(e)) {
          return null;
        };
      };
      switch (_items.get(index)) {
        case (?#Accessory(item)) {
          return item.equipped;
        };
        case (_) {
          return null;
        };
      };
    };

    ////////////////
    // HELPERS /////
    ////////////////

    /* 
            Associate an item with a name. 
            Returns an empty string if the item is not a material nor an accessory.
        */
    func _itemToName(item : Item) : Text {
      switch (item) {
        case (#Material(name)) {
          return name;
        };
        case (#Accessory(item)) {
          return item.name;
        };
        case (_) {
          assert (false);
          return "";
        };
      };
    };

    /* 
            Return the optional UTF-8 encoded blob corresponding to the given TokenIndex 
            Dynamically generated with the current wear value of the accessory
        */
    func _getBlobAccessory(index : TokenIndex) : ?Blob {
      switch (_items.get(index)) {
        case (?#Accessory(item)) {
          switch (_templates.get(item.name)) {
            case (?#Accessory(template)) {
              let concatenated_svg = template.before_wear # "<text x=\"190.763px\" y=\"439.84px\" style=\"font-family: 'Futura-Medium', 'Futura', sans-serif; font-weight: 500; font-size: 50px; fill: white\">" # Nat.toText(
                Nat8.toNat(item.wear),
              ) # "</text>" # template.after_wear;
              return (?Text.encodeUtf8(concatenated_svg));
            };
            case (_) { return null };
          };
        };
        case (_) { return null };
      };
    };

    func _isEquipped(token_index : TokenIndex) : Bool {
      switch (_items.get(token_index)) {
        case (?#Accessory(accessory)) {
          if (Option.isSome(accessory.equipped)) {
            return true;
          };
        };
        case (_) {};
      };
      return false;
    };

    func _createAccessoryEquippedOn(
      accessory : Accessory,
      avatar : ?TokenIdentifier,
    ) : Item {
      #Accessory(
        {
          name = accessory.name;
          wear = accessory.wear - 1;
          equipped = avatar;
        },
      );
    };

    func _createAccessoryWear(
      accessory : Accessory,
      wear : Nat8,
    ) : Item {
      #Accessory(
        {
          name = accessory.name;
          wear = wear;
          equipped = accessory.equipped;
        },
      );
    };

    func _tokenIndexToInventoryItem(
      tokenIndex : TokenIndex,
    ) : ItemInventory {
      switch (_items.get(tokenIndex)) {
        case (?#Material(name)) {
          return #Material(
            {
              name = name;
              tokenIdentifier = Ext.TokenIdentifier.encode(dependencies.cid, tokenIndex);
            },
          );
        };
        case (?#Accessory(accessory)) {
          return #Accessory(
            {
              name = accessory.name;
              tokenIdentifier = Ext.TokenIdentifier.encode(dependencies.cid, tokenIndex);
              equipped = Option.isSome(accessory.equipped);
            },
          );
        };
        case (_) {
          _Logs.logMessage("Item not found for tokenIndex : " # Nat32.toText(tokenIndex));
          assert (false);
          return #Material(
            {
              name = "Unreacheable";
              tokenIdentifier = Ext.TokenIdentifier.encode(dependencies.cid, tokenIndex);
            },
          );
        };
      };
    };

    /* 
            This function decreases the wear value of the specified accessory (if found).
            If the wear value reaches 0, the accessory is burned.
        */
    func _updateAccessory(
      index : TokenIndex,
    ) : Result<AccessoryUpdate, Text> {
      switch (_items.get(index)) {
        case (?#Accessory(item)) {
          if (item.wear <= 1) {
            // Report burn event to CAP.
            let name = Option.get(getName(index), "Unknown");
            let owner = Option.get(_Ext.getOwner(index), "Unknown");
            let event : Cap.IndefiniteEvent = {
              operation = "burn";
              details = [("token", #Text(Ext.TokenIdentifier.encode(dependencies.cid, index))), ("name", #Text(name)), ("from", #Text(owner))];
              //Put the owner of the accessory for keeping track of burned accessories per user, for missions.
              caller = dependencies.cid;
            };
            _Cap.insertEvent(event);
            _Ext.burn(index);
            _items.delete(index);
            let burned : BurnedAccessory = {
              name;
              tokenIndex = index;
              tokenIdentifier = Option.get<Text>(item.equipped, "ngedt-bakor-uwiaa-aaaaa-cmaca-uaqca-aaaaa-a");
            };
            _pendingBurned := List.push(burned, _pendingBurned);
            _Logs.logMessage("EVENT :: accessory : " # Nat.toText(Nat32.toNat(index)) # " has been burned");
            return #ok(#Burned);
          };
          _items.put(index, _createAccessoryWear(item, item.wear - 1));
          return #ok(#Decreased);
        };
        case _ {
          _Logs.logMessage("ERR :: accessory not found for index : " # Nat32.toText(index));
          return #err("Accessory not found");
        };
      };
    };

    func _getListEquippedAccessory() : [TokenIndex] {
      var buffer = Buffer.Buffer<TokenIndex>(0);
      for ((index, item) in _items.entries()) {
        switch (item) {
          case (#Accessory(accessory)) {
            if (Option.isSome(accessory.equipped)) {
              buffer.add(index);
            };
          };
          case (_) {};
        };
      };
      return buffer.toArray();
    };

    func _isAccessory(index : TokenIndex) : Bool {
      switch (_items.get(index)) {
        case (?#Accessory(_)) {
          return true;
        };
        case (_) {
          return false;
        };
      };
    };

  };
};
