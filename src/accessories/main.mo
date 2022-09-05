import Array "mo:base/Array";
import Blob "mo:base/Blob";
import Buffer "mo:base/Buffer";
import Cycles "mo:base/ExperimentalCycles";
import Float "mo:base/Float";
import Hash "mo:base/Hash";
import HashMap "mo:base/HashMap";
import Int "mo:base/Int";
import Iter "mo:base/Iter";
import Nat "mo:base/Nat";
import Nat32 "mo:base/Nat32";
import Nat64 "mo:base/Nat64";
import Nat8 "mo:base/Nat8";
import Option "mo:base/Option";
import Prim "mo:prim";
import Principal "mo:base/Principal";
import Result "mo:base/Result";
import Text "mo:base/Text";
import Time "mo:base/Time";

import AccountIdentifier "mo:principal/AccountIdentifier";
import Canistergeek "mo:canistergeek/canistergeek";
import Ext "mo:ext/Ext";
import Root "mo:cap/Root";

import Admins "admins";
import Cap "cap";
import Entrepot "entrepot";
import ExtModule "ext";
import Http "http";
import Invoice "invoice";
import Items "items";
import NNS "nns";
import Rewards "reward";
shared ({ caller = creator }) actor class ICPSquadNFT(
  cid : Principal,
  cid_avatar : Principal,
  cid_invoice : Principal,
  cid_ledger : Principal,
  cid_hub : Principal,
) = this {

  ///////////
  // TYPES //
  ///////////

  public type Time = Time.Time;
  public type Result<A, B> = Result.Result<A, B>;
  public type IndefiniteEvent = Cap.IndefiniteEvent;

  ///////////
  // ADMIN //
  ///////////

  stable var master : Principal = creator;

  stable var _AdminsUD : ?Admins.UpgradeData = null;
  let _Admins = Admins.Admins(creator);

  public query func is_admin(p : Principal) : async Bool {
    _Admins.isAdmin(p);
  };

  public shared ({ caller }) func add_admin(p : Principal) : async () {
    _Admins.addAdmin(p, caller);
    _Monitor.collectMetrics();
    _Logs.logMessage("CONFIG :: Added admin : " # Principal.toText(p) # " by " # Principal.toText(caller));
  };

  public shared ({ caller }) func remove_admin(p : Principal) : async () {
    assert (caller == master);
    _Monitor.collectMetrics();
    _Admins.removeAdmin(p, caller);
    _Logs.logMessage("CONFIG :: Removed admin : " # Principal.toText(p) # " by " # Principal.toText(caller));
  };

  //////////////
  // CYCLES  //
  /////////////

  public func acceptCycles() : async () {
    let available = Cycles.available();
    let accepted = Cycles.accept(available);
    assert (accepted == available);
  };

  public query func availableCycles() : async Nat {
    return Cycles.balance();
  };

  ///////////////
  // METRICS ///
  /////////////

  stable var _MonitorUD : ?Canistergeek.UpgradeData = null;
  private let _Monitor : Canistergeek.Monitor = Canistergeek.Monitor();

  public query ({ caller }) func getCanisterMetrics(parameters : Canistergeek.GetMetricsParameters) : async ?Canistergeek.CanisterMetrics {
    assert (_Admins.isAdmin(caller));
    _Monitor.getMetrics(parameters);
  };

  public shared ({ caller }) func collectCanisterMetrics() : async () {
    assert (_Admins.isAdmin(caller));
    _Monitor.collectMetrics();
  };

  ////////////
  // LOGS ///
  //////////

  stable var _LogsUD : ?Canistergeek.LoggerUpgradeData = null;
  private let _Logs : Canistergeek.Logger = Canistergeek.Logger();

  public query ({ caller }) func getCanisterLog(request : ?Canistergeek.CanisterLogRequest) : async ?Canistergeek.CanisterLogResponse {
    assert (_Admins.isAdmin(caller));
    _Logs.getLog(request);
  };

  public shared ({ caller }) func setMaxMessagesCount(n : Nat) : async () {
    assert (_Admins.isAdmin(caller));
    _Logs.setMaxMessagesCount(n);
  };

  ////////////
  // NNS ////
  //////////

  let _NNS = NNS.Factory(
    {
      _Admins;
      _Logs;
      cid_ledger;
    },
  );

  //////////////////
  // EXT - ERC721 //
  /////////////////

  type AccountIdentifier = Ext.AccountIdentifier;
  type SubAccount = Ext.SubAccount;
  type User = Ext.User;
  type Balance = Ext.Balance;
  type TokenIdentifier = Ext.TokenIdentifier;
  type TokenIndex = Ext.TokenIndex;
  type Extension = Ext.Extension;
  type CommonError = Ext.CommonError;
  type BalanceRequest = Ext.Core.BalanceRequest;
  type BalanceResponse = Ext.Core.BalanceResponse;
  type TransferRequest = Ext.Core.TransferRequest;
  type TransferResponse = Ext.Core.TransferResponse;

  stable var _ExtUD : ?ExtModule.UpgradeData = null;
  let _Ext = ExtModule.Factory(
    {
      cid = cid;
      _Logs = _Logs;
    },
  );

  public shared ({ caller }) func transfer(request : TransferRequest) : async TransferResponse {
    _Monitor.collectMetrics();
    switch (_Ext.transfer(caller, request)) {
      case (#err(#Other(e))) return #err(#Other(e));
      case (#err(#InvalidToken(token))) return #err(#InvalidToken(token));
      case (#ok(index)) {
        let from = Text.map(Ext.User.toAccountIdentifier(request.from), Prim.charToLower);
        let to = Text.map(Ext.User.toAccountIdentifier(request.to), Prim.charToLower);
        ignore (
          _Cap.registerEvent(
            {
              operation = "transfer";
              details = [("token", #Text(request.token)), ("from", #Text(from)), ("to", #Text(to))];
              caller = caller;
            },
          ),
        );
        return #ok(index);
      };
      case (#err(_)) return #err(#Other("Unknown error"));
    };
  };

  public func tokenId(index : TokenIndex) : async Text {
    _Monitor.collectMetrics();
    Ext.TokenIdentifier.encode(Principal.fromActor(this), index);
  };

  public query func extensions() : async [Extension] {
    _Ext.extensions();
  };

  public query func getRegistry() : async [(TokenIndex, AccountIdentifier)] {
    _Ext.getRegistry();
  };

  public query func getTokens() : async [(TokenIndex, Ext.Common.Metadata)] {
    _Ext.getTokens();
  };

  public query func metadata(tokenId : TokenIdentifier) : async Result<Ext.Common.Metadata, Ext.CommonError> {
    _Ext.metadata(tokenId);
  };

  public query func tokens(aid : AccountIdentifier) : async Result<[TokenIndex], CommonError> {
    _Ext.tokens(aid);
  };

  public query func tokens_ext(aid : AccountIdentifier) : async Result<[(TokenIndex, ?ExtModule.Listing, ?Blob)], CommonError> {
    _Ext.tokens_ext(aid);
  };

  public query func balance(request : BalanceRequest) : async BalanceResponse {
    _Ext.balance(request);
  };

  public query func bearer(tokenId : TokenIdentifier) : async Result<AccountIdentifier, CommonError> {
    _Ext.bearer(tokenId);
  };

  //////////
  // CAP //
  /////////

  stable var _CapUD : ?Cap.UpgradeData = null;
  let _Cap = Cap.Factory(
    {
      _Logs = _Logs;
      _Admins = _Admins;
      cid = cid;
      overrideRouterId = null;
      provideRootBucketId = ?"qfevy-hqaaa-aaaaj-qanda-cai";
    },
  );

  ////////////////
  // INVOICE ////
  //////////////

  let _Invoice = Invoice.Factory(
    {
      invoice_cid = cid_invoice;
    },
  );

  ////////////
  // ITEMS //
  //////////

  public type Template = Items.Template;
  public type Recipe = Items.Recipe;
  public type Item = Items.Item;
  public type Inventory = Items.Inventory;
  public type ItemInventory = Items.ItemInventory;
  public type MaterialInventory = Items.MaterialInventory;
  public type AccessoryInventory = Items.AccessoryInventory;
  public type BurnedInformation = Items.BurnedInformation;

  stable var _ItemsUD : ?Items.UpgradeData = null;
  let _Items = Items.Factory(
    {
      _Logs = _Logs;
      _Ext = _Ext;
      _Cap = _Cap;
      cid_avatar = cid_avatar;
      cid = cid;
    },
  );

  public shared ({ caller }) func add_template(
    name : Text,
    template : Template,
  ) : async Result<Text, Text> {
    assert (_Admins.isAdmin(caller));
    _Monitor.collectMetrics();
    switch (_Items.addTemplate(name, template)) {
      case (#ok(msg)) {
        _Logs.logMessage("CONFIG :: Template added for : " # name # " by " # Principal.toText(caller));
        return #ok(msg);
      };
      case (#err((msg))) {
        _Logs.logMessage("CONFIG :: Failed to add template: " # name # ": " #msg);
        return #err((msg));
      };
    };
  };

  public query ({ caller }) func get_items() : async [(Text, [TokenIndex])] {
    assert (_Admins.isAdmin(caller));
    _Monitor.collectMetrics();
    _Items.getItems();
  };

  public query func get_templates() : async [(Text, Template)] {
    _Items.getTemplates();
  };

  public query func get_recipes() : async [(Text, Recipe)] {
    _Items.getRecipes();
  };

  public shared ({ caller }) func delete_item(name : Text) : async Result<(), Text> {
    assert (_Admins.isAdmin(caller));
    _Monitor.collectMetrics();
    _Items.deleteItem(name);
  };

  public shared ({ caller }) func wear_accessory(
    accessory : TokenIdentifier,
    avatar : TokenIdentifier,
  ) : async Result<(), Text> {
    _Monitor.collectMetrics();
    switch (_Ext.isOwner(caller, accessory)) {
      case (#err(e)) {
        _Logs.logMessage("ERR :: Caller : " # Principal.toText(caller) # "trying to wear accessory : " # accessory # " but is not owner");
        return #err(e);
      };
      case (#ok()) {};
    };
    let index = switch (Ext.TokenIdentifier.decode(accessory)) {
      case (#err(e)) {
        _Logs.logMessage("ERR :: Failed to decode tokenIdentifier : " # accessory # ". Detail : " # e);
        return #err(e);
      };
      case (#ok(p, index)) {
        if (p != cid) {
          _Logs.logMessage("ERR :: Failed to decode tokenIdentifier : " # accessory # "the canister id is " # Principal.toText(p));
          return #err("Error when decoding the tokenIdentifier : " # accessory);
        };
        index;
      };
    };
    if (_Entrepot.isLocked(index)) {
      _Logs.logMessage("ERR :: Try to this accessory when locked (Entrepot) : " # accessory);
      return #err("Trying to equip this accessory when locked (Entrepot) : " # accessory);
    };
    await _Items.wearAccessory(accessory, avatar, caller);
  };

  public shared ({ caller }) func remove_accessory(
    accessory : TokenIdentifier,
    avatar : TokenIdentifier,
  ) : async Result.Result<(), Text> {
    _Monitor.collectMetrics();
    switch (_Ext.isOwner(caller, accessory)) {
      case (#err(e)) {
        _Logs.logMessage("ERR :: Caller : " # Principal.toText(caller) # "trying to remove accessory : " # accessory # " but is not owner");
        return #err(e);
      };
      case (#ok()) {};
    };
    let index = switch (Ext.TokenIdentifier.decode(accessory)) {
      case (#err(e)) {
        _Logs.logMessage("ERR :: Failed to decode tokenIdentifier : " # accessory # ". Detail : " # e);
        return #err(e);
      };
      case (#ok(p, index)) {
        if (p != cid) {
          _Logs.logMessage("ERR :: Failed to decode tokenIdentifier : " # accessory # "the canister id is " # Principal.toText(p));
          return #err("Error when decoding the tokenIdentifier : " # accessory);
        };
        index;
      };
    };
    if (_Entrepot.isLocked(index)) {
      _Logs.logMessage("CRITICAL :: Trying to dequip this accessory when locked (Entrepot) : " # accessory);
      return #err("Trying to equip this accessory when locked (Entrepot) : " # accessory);
    };
    await _Items.removeAccessory(accessory, avatar, caller);
  };

  public shared ({ caller }) func create_accessory(
    name : Text,
    invoice_id : Nat,
  ) : async Result.Result<TokenIdentifier, Text> {
    _Monitor.collectMetrics();
    let recipe = switch (_Items.getRecipe(name)) {
      case (null) return #err("No recipe found for : " # name);
      case (?recipe) { recipe };
    };
    switch (await _Invoice.verifyInvoice(invoice_id, caller)) {
      case (#ok) {};
      case (#err) {
        _Logs.logMessage("ERR :  Failed to verify invoice : " # Nat.toText(invoice_id) # " by " # Principal.toText(caller));
        return #err("Error during invoice verification");
      };
    };
    let materials = _Items.getMaterials(caller);
    // Filter out all materials that are locked on Entrepot to avoid concurrency issues.
    var materials_available = Array.filter<(TokenIndex, Text)>(
      materials,
      func(x) {
        not _Entrepot.isLocked(x.0);
      },
    );
    // Create the list of materials that will be used for the recipes.
    let materials_used = Buffer.Buffer<(TokenIndex)>(0);
    for (material in recipe.vals()) {
      let material_used = switch (
        Array.find<(TokenIndex, Text)>(
          materials_available,
          func(x) {
            x.1 == material;
          },
        ),
      ) {
        case (null) {
          _Logs.logMessage("ERR :: Caller : " # Principal.toText(caller) # " trying to create accessory : " # name # " but does not have the material : " # material);
          _Logs.logMessage("materials_available :" # debug_show (materials_available));
          _Logs.logMessage("materials_used :" # debug_show (materials_used.toArray()));
          return #err("Error during accessory creation : " # material);
        };
        case (?x) { x };
      };
      // Add the tokenIndex to the actually used materials and remove it from the list of available materials to avoid reusing.
      materials_used.add(material_used.0);
      materials_available := Array.filter<(TokenIndex, Text)>(materials_available, func(x) { x.0 != material_used.0 });
    };
    // Remove the materials from every database (ie they are burned).
    for (tokenIndex in materials_used.toArray().vals()) {
      // Save the name to be report event to CAP.
      let name = Option.get(_Items.getName(tokenIndex), "Unknown");
      _Items.burn(tokenIndex);
      _Ext.burn(tokenIndex);
      _Entrepot.burn(tokenIndex);
      // Report burning events to CAP.
      let event : IndefiniteEvent = {
        operation = "burn";
        details = [("token", #Text(Ext.TokenIdentifier.encode(cid, tokenIndex))), ("from", #Text(Principal.toText(caller))), ("name", #Text(name))];
        caller = caller;
      };
      ignore (_Cap.registerEvent(event));
    };
    // Create the token and the associated accessory.
    let request : Ext.NonFungible.MintRequest = {
      to = #principal(caller);
      metadata = null;
    };
    switch (_Ext.mint(request)) {
      case (#err(_)) {
        assert (false);
        return #err("Error fatal during minting of token");
      };
      case (#ok(tokenIndex)) {
        switch (_Items.mint(name, tokenIndex)) {
          case (#err(_)) {
            assert (false);
            return #err("Error fatal during minting of accessory");
          };
          case (#ok()) {
            let tokenIdentifier = Ext.TokenIdentifier.encode(cid, tokenIndex);
            // Report minting event to CAP.
            let event : IndefiniteEvent = {
              operation = "mint";
              details = [("token", #Text(tokenIdentifier)), ("to", #Text(Principal.toText(caller))), ("name", #Text(name))];
              caller = caller;
            };
            ignore (_Cap.registerEvent(event));
            _Logs.logMessage("EVENT :: Accessory created : " # name # " by " # Principal.toText(caller) # "with identifier " # tokenIdentifier);
            return #ok(tokenIdentifier);
          };
        };
      };
    };
  };

  public shared ({ caller }) func mint(
    name : Text,
    receiver : Principal,
  ) : async Result<(), Text> {
    assert (_Admins.isAdmin(caller));
    _Monitor.collectMetrics();
    switch (_Ext.mint({ to = #principal(receiver); metadata = null })) {
      case (#err(#Other(e))) return #err(e);
      case (#err(#InvalidToken(e))) return #err(e);
      case (#ok(index)) {
        switch (_Items.mint(name, index)) {
          case (#err(e)) {
            //  Revert all state changes since the beggining of this message (ie the token created is reverted).
            assert (false);
            return #err("Unreacheable");
          };
          case (#ok) {
            _Logs.logMessage(name # " has been minted by " # Principal.toText(caller) # " for " # Principal.toText(receiver));
            return #ok;
          };
        };
      };
    };
  };

  public query func get_name(index : TokenIndex) : async ?Text {
    _Items.getName(index);
  };

  /* 
        Returns the optional avatar on which the provided accessory is equipped.
    */
  public query func get_avatar_equipped(tokenId : TokenIdentifier) : async ?TokenIdentifier {
    _Items.getAvatarEquipped(tokenId);
  };

  public shared ({ caller }) func update_accessories() : async () {
    assert (_Admins.isAdmin(caller) or caller == cid_hub);
    _Monitor.collectMetrics();
    let (burned, decreased) = _Items.updateAll();
    _Logs.logMessage("CRON :: update of accessories :: " # "BURNED :: " # Nat.toText(burned.size()) # " DECREASED : " # Nat.toText(decreased.size()));
    return;
  };

  public query ({ caller }) func getInventory() : async Result<Inventory, Text> {
    _Items.getInventory(caller);
  };

  public query func checkInventory(p : Principal) : async Result<Inventory, Text> {
    _Items.getInventory(p);
  };

  let DAY_NANO_RAW = 86400000000 * 1000;

  public query func get_materials(p : Principal, available : Bool) : async [(TokenIndex, Text)] {
    let materials = _Items.getMaterials(p);
    if (available) {
      return (Array.filter<(TokenIndex, Text)>(materials, func(x) { not _Entrepot.isLocked(x.0) }));
    } else {
      return (materials);
    };
  };

  //////////
  // HTTP //
  //////////

  let _HttpHandler = Http.HttpHandler(
    {
      _Admins = _Admins;
      _Items = _Items;
      _Logs = _Logs;
      cid = cid;
    },
  );

  public query func http_request(request : Http.Request) : async Http.Response {
    _HttpHandler.request(request);
  };

  //////////////
  // REWARDS //
  ////////////

  // public type Reward = Rewards.Reward;
  // public type Airdrop = Rewards.Airdrop;

  // stable var _RewardsUD : ?Rewards.UpgradeData = null;
  // let _Rewards = Rewards.Factory(
  //   {
  //     _Logs;
  //     _Ext;
  //     _Items;
  //     _Cap;
  //     cid;
  //   },
  // );

  // public shared ({ caller }) func airdrop_rewards(
  //   data : [(AccountIdentifier, Airdrop)],
  // ) : async () {
  //   assert (_Admins.isAdmin(caller));
  //   _Monitor.collectMetrics();
  //   _Rewards.airdropRewards(data);
  // };

  // public query func get_recorded_rewards(
  //   p : Principal,
  // ) : async ?[Reward] {
  //   _Rewards.getRecordedRewards(p);
  // };

  // public query func get_all_recorded_rewards() : async [(AccountIdentifier, [Reward])] {
  //   _Rewards.getAllRecordedRewards();
  // };

  ////////////
  // STATS //
  //////////

  public type Name = Text;
  public type Supply = Nat;
  public type Floor = Nat64;

  public query func get_stats_items() : async [(Text, Supply, ?Floor)] {
    let items = _Items.getItems();
    let buffer = Buffer.Buffer<(Text, Supply, ?Floor)>(items.size());
    for (item in items.vals()) {
      buffer.add((item.0, item.1. size(), _Entrepot.getFloorPrice(item.1)));
    };
    return buffer.toArray();
  };

  ///////////////
  // Entrepot //
  //////////////

  public type Disbursement = Entrepot.Disbursement;

  stable var _EntrepotUD : ?Entrepot.UpgradeData = null;
  let _Entrepot = Entrepot.Factory(
    {
      _Ext;
      _Admins;
      _Cap;
      _Items;
      _Logs;
      _NNS;
      cid;
      cid_ledger;
    },
  );

  public shared ({ caller }) func is_owner_account(
    account : AccountIdentifier,
    token : TokenIndex,
  ) : async Bool {
    assert (_Admins.isAdmin(caller));
    return _Ext.isOwnerAccount(account, token);
  };

  public shared ({ caller }) func list(
    request : Entrepot.ListRequest,
  ) : async Entrepot.ListResponse {
    _Monitor.collectMetrics();
    await _Entrepot.list(caller, request);
  };

  public shared ({ caller }) func can_settle(
    p : Principal,
    token : Ext.TokenIdentifier,
  ) : async Result.Result<(), Ext.CommonError> {
    assert (_Admins.isAdmin(caller));
    await _Entrepot.canSettle(p, token);
  };

  public shared ({ caller }) func lock(
    token : TokenIdentifier,
    price : Nat64,
    buyer : AccountIdentifier,
    bytes : [Nat8],
  ) : async Entrepot.LockResponse {
    _Monitor.collectMetrics();
    await _Entrepot.lock(caller, token, price, buyer, bytes);
  };

  public shared ({ caller }) func settle(
    token : TokenIdentifier,
  ) : async Result<(), CommonError> {
    _Monitor.collectMetrics();
    await _Entrepot.settle(caller, token);
  };

  public query func stats() : async (
    Nat64,
    // Total volumes
    Nat64,
    // Highest price sale
    Nat64,
    // Lowest price sale
    Nat64,
    // Current Floor price
    Nat,
    // # Listings
    Nat,
    // # Supply
    Nat,
    // # Sales
  ) {
    _Entrepot.stats();
  };

  public query func details(token : TokenIdentifier) : async Entrepot.DetailsResponse {
    _Entrepot.details(token);
  };

  public query func listings() : async Entrepot.ListingResponse {
    _Entrepot.getListings();
  };

  public query func get_pending_transactions() : async [(TokenIndex, Entrepot.Transaction)] {
    _Entrepot.getPendingTransactions();
  };

  public shared ({ caller }) func purge_pending_transactions() : () {
    assert (_Admins.isAdmin(caller));
    _Monitor.collectMetrics();
    _Entrepot.purgePendingTransactions();
  };

  public query func transactions() : async [Entrepot.EntrepotTransaction] {
    _Entrepot.readTransactions();
  };

  public query func transactions_new() : async [(Nat, Entrepot.Transaction)] {
    _Entrepot.readTransactionsNew();
  };

  public query func transactions_new_size() : async Nat {
    _Entrepot.transactionsSize();
  };

  public query ({ caller }) func payments() : async ?[SubAccount] {
    _Entrepot.payments(caller);
  };

  public query ({ caller }) func read_disbursements() : async [Disbursement] {
    assert (_Admins.isAdmin(caller));
    _Entrepot.disbursements();
  };

  public query ({ caller }) func disbursement_queue_size() : async Nat {
    assert (_Admins.isAdmin(caller));
    _Entrepot.disbursementQueueSize();
  };

  public query ({ caller }) func disbursement_pending_count() : async Nat {
    assert (_Admins.isAdmin(caller));
    _Entrepot.disbursementPendingCount();
  };

  //////////////
  // Cronic ///
  /////////////

  public shared ({ caller }) func cron_verification() : async () {
    assert (_Admins.isAdmin(caller));
    _Monitor.collectMetrics();
    await _Entrepot.cronVerification();
  };

  public shared ({ caller }) func cron_disbursements() : async () {
    assert (_Admins.isAdmin(caller) or caller == cid_hub);
    _Monitor.collectMetrics();
    await _Entrepot.cronDisbursements();
  };

  public shared ({ caller }) func cron_settlements() : async () {
    assert (_Admins.isAdmin(caller) or caller == cid_hub);
    _Monitor.collectMetrics();
    await _Entrepot.cronSettlements();
  };

  public shared ({ caller }) func cron_events() : async () {
    assert (_Admins.isAdmin(caller) or caller == cid_hub);
    _Monitor.collectMetrics();
    await _Cap.cronEvents();
  };

  public shared ({ caller }) func cron_burned() : async () {
    assert (_Admins.isAdmin(caller) or caller == cid_hub);
    _Monitor.collectMetrics();
    await _Items.cronBurned();
  };

  //////////////
  // UPGRADE //
  /////////////

  system func preupgrade() {
    _Logs.logMessage("PREUPGRADE :: accessory");
    _MonitorUD := ?_Monitor.preupgrade();
    _LogsUD := ?_Logs.preupgrade();
    _ItemsUD := ?_Items.preupgrade();
    _AdminsUD := ?_Admins.preupgrade();
    _ExtUD := ?_Ext.preupgrade();
    _EntrepotUD := ?_Entrepot.preupgrade();
    _CapUD := ?_Cap.preupgrade();
  };

  system func postupgrade() {
    _Monitor.postupgrade(_MonitorUD);
    _MonitorUD := null;
    _Logs.postupgrade(_LogsUD);
    _LogsUD := null;
    _Admins.postupgrade(_AdminsUD);
    _AdminsUD := null;
    _Items.postupgrade(_ItemsUD);
    _ItemsUD := null;
    _Ext.postupgrade(_ExtUD);
    _ExtUD := null;
    _Cap.postupgrade(_CapUD);
    _CapUD := null;
    _Entrepot.postupgrade(_EntrepotUD);
    _EntrepotUD := null;
    _Logs.logMessage("POSTUPGRADE :: accessory");
  };
};

