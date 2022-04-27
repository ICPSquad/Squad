import Error "mo:base/Error";
import HashMap "mo:base/HashMap";
import Iter "mo:base/Iter";
import Nat "mo:base/Nat";
import Nat32 "mo:base/Nat32";
import Nat8 "mo:base/Nat8";
import Option "mo:base/Option";
import Prim "mo:prim";
import Principal "mo:base/Principal";
import Result "mo:base/Result";
import Text "mo:base/Text";
import _blobs "mo:base/TrieSet";
import _items "mo:base/TrieSet";

import Ext "mo:ext/Ext";

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
    public type AccessoryUpdate = Types.AccessoryUpdate;
    public type UpgradeData = Types.UpgradeData;
    type TokenIndex = Ext.TokenIndex;
    type TokenIdentifier = Ext.TokenIdentifier;
    type Result<A,B> = Result.Result<A,B>;

    public class Factory(dependencies : Types.Dependencies) : Types.Interface {

        ////////////
        // State //
        ///////////
        
        let _items : HashMap.HashMap<TokenIndex,Item> = HashMap.HashMap(0, Ext.TokenIndex.equal, Ext.TokenIndex.hash);
        let _templates : HashMap.HashMap<Text,Template> = HashMap.HashMap(0, Text.equal, Text.hash);
        let _blobs : HashMap.HashMap<TokenIndex,Blob> = HashMap.HashMap(0, Ext.TokenIndex.equal, Ext.TokenIndex.hash);

        let AVATAR_ACTOR = actor(Principal.toText(dependencies.cid_avatar)) : actor {
            wearAccessory : shared (tokeniId : TokenIdentifier, name : Text, p : Principal) -> async Result<(), Text>;
            removeAccessory : shared (tokeniId : TokenIdentifier, name : Text, p : Principal) -> async Result<(), Text>;
        };

        let _Logs = dependencies._Logs;
        let _Ext = dependencies._Ext;

        public func preupgrade() : UpgradeData {
            return({
                items = Iter.toArray(_items.entries());
                templates = Iter.toArray(_templates.entries());
                blobs = Iter.toArray(_blobs.entries());
            })
        };

        public func postupgrade(ud : ?UpgradeData) : () {
            switch(ud){
                case(? ud){
                    for((index, item) in ud.items.vals()){
                        _items.put(index, item);
                    };
                    for((name, template) in ud.templates.vals()){
                        _templates.put(name, template);
                    };
                    for((index, blob) in ud.blobs.vals()){
                        _blobs.put(index, blob);
                    };
                };
                case _ {};
            };
        };

        /////////////
        // API /////
        ///////////

        public func addTemplate(name : Text, template : Template) : Result<Text,Text> {
           _templates.put(name, template);
           return #ok("Template added for : "  # name);
        };

        public func wearAccessory(
            accessory : TokenIdentifier,
            avatar : TokenIdentifier,
            caller : Principal
        ) : async Result<(), Text> {
            let account = Text.map(Ext.AccountIdentifier.fromPrincipal(caller, null), Prim.charToLower);
            let index = switch(Ext.TokenIdentifier.decode(accessory)){
                case(#ok(p, i)) {
                    if(p != dependencies.cid){
                    _Logs.logMessage("Error when decoding the tokenIdentifier : " # accessory # "the canister id is " # Principal.toText(p));
                    return #err("Error when decoding the tokenIdentifier : " # accessory);
                    };
                    i;
                };
                case(#err(e)) {
                    _Logs.logMessage("Error during decode of tokenIdentifier : " # accessory # ". Detail : " # e);
                    return #err(e);
                };
            };
            switch(_items.get(index)){
                case(?#Accessory(item)){
                    switch(item.equipped){
                        case(? avatar){
                            if(avatar == "InProgress"){
                                _Logs.logMessage("Reentrancy attack detected from " # Principal.toText(caller));
                                return #err("Accessory" # accessory # " is already equipped");
                            };
                            _Logs.logMessage("Accessory " # accessory # " is already equipped on " # avatar);
                            return #err("Accessory" # accessory # " is already equipped on " # avatar);
                        };
                        case(null) {
                            _items.put(index, _createAccessoryEquippedOn(item, ?"InProgress"));
                            try {
                                // 🎯 Commit point for the state of the canister.
                                switch(await AVATAR_ACTOR.wearAccessory(avatar, Text.map(item.name, Prim.charToLower), caller)){
                                    case(#ok(())) {
                                        _items.put(index, _createAccessoryEquippedOn(item, ?avatar));
                                        return #ok;
                                    };
                                    case(#err(e)) {
                                        _Logs.logMessage("Error during wearAccessory : " # e);
                                        _items.put(index, _createAccessoryEquippedOn(item, null));
                                        return #err(e);
                                    };
                                };
                            } catch e {
                                _Logs.logMessage("Error during wearAccessory : " # Error.message(e));
                                _items.put(index, _createAccessoryEquippedOn(item, null));
                                throw e;
                            };
                        };
                    };
                };
                case _ {
                    _Logs.logMessage("Accessory not found for tokenIndex : " # Nat32.toText(index));
                    return #err("Accessory not found for tokenIdentifier : " # accessory);
                };
            };
        };

        public func removeAccessory(
            accessory : TokenIdentifier,
            avatar : TokenIdentifier,
            caller : Principal
        ) : async Result<(), Text> {
            let account = Text.map(Ext.AccountIdentifier.fromPrincipal(caller, null), Prim.charToLower);
            let index = switch(Ext.TokenIdentifier.decode(accessory)){
                case(#ok(p, i)) {
                    if(p != dependencies.cid){
                    _Logs.logMessage("Error when decoding the tokenIdentifier : " # accessory # "the canister id is " # Principal.toText(p));
                    return #err("Error when decoding the tokenIdentifier : " # accessory);
                    };
                    i;
                };
                case(#err(e)) {
                    _Logs.logMessage("Error during decode of tokenIdentifier : " # accessory # ". Detail : " # e);
                    return #err(e);
                };
            };
            switch(_items.get(index)){
                case(?#Accessory(item)){
                switch(item.equipped){
                    case(? avatar) {
                        try {
                            // 🎯 Commit point for the state of the canister.
                            switch(await AVATAR_ACTOR.removeAccessory(avatar, Text.map(item.name, Prim.charToLower), caller)){
                                case(#ok(())) {
                                    _items.put(index, _createAccessoryEquippedOn(item, null));
                                    return #ok;
                                };
                                case(#err(e)) {
                                    _Logs.logMessage("Error during wearAccessory : " # e);
                                    return #err(e);
                                };
                            };
                        } catch e {
                            _Logs.logMessage("Error during wearAccessory : " # Error.message(e));
                            throw e;
                        };
                    };
                    case(null) {
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

        public func updateAccessory(
            accessory : TokenIdentifier
        ) : Result<AccessoryUpdate, Text> {
            let index = switch(Ext.TokenIdentifier.decode(accessory)){
                case(#ok(p, i)) {
                    if(p != dependencies.cid){
                    _Logs.logMessage("Error when decoding the tokenIdentifier : " # accessory # "the canister id is " # Principal.toText(p));
                    return #err("Error when decoding the tokenIdentifier : " # accessory);
                    };
                    i;
                };
                case(#err(e)) {
                    _Logs.logMessage("Error during decode of tokenIdentifier : " # accessory # ". Detail : " # e);
                    return #err(e);
                };
            };
            switch(_items.get(index)){
                case(?#Accessory(item)){
                    if(item.wear <= 1){
                        switch(_Ext.burn(accessory)){
                            case(#ok(())) {
                                _items.delete(index);
                                _blobs.delete(index);
                                _Logs.logMessage("Accessory " # accessory # " has been burned");
                                return #ok(#Burned);
                            };
                            case(#err(e)) {
                                _Logs.logMessage("CRITICAL ERROR during burn : " # e);
                                return #err(e);
                            };
                        };
                    };
                    _items.put(index, _createAccessoryWear(item, item.wear - 1));
                    return #ok(#Decreased);
                };
                case _ {
                    _Logs.logMessage("Accessory not found for tokenIndex : " # Nat32.toText(index));
                    return #err("Accessory not found for tokenIdentifier : " # accessory);
                };
            };
        };

        // public func createAccessory()

        public func mint(
            name : Text,
            index : TokenIndex,
        ) : Result<(), Text> {
            switch(_templates.get(name)){
                case(?#Material(blob)){
                    _items.put(index, #Material(name));
                    return #ok;
                };
                case(?#Accessory(item)){
                    _items.put(index, #Accessory({ name = name; wear = 100; equipped = null}));
                    _drawAccessory(index);
                    return #ok;
                };
                case(_) return #err("No template found");
            };
        };

        public func getBlob(
            index : TokenIndex
        ) : ?Blob {
            switch(_items.get(index)){
                case(?#Material(name)){
                    switch(_templates.get(name)){
                        case(?#Material(blob)){
                            _Logs.logMessage("CRITICAL ERROR : template not found for : " # name);
                            return ?blob;
                        };
                        case(_) return null;
                    };
                };
                case(?#Accessory(item)){
                    return _blobs.get(index);
                };
                case(_) return null;
            };
        };

        public func isEquipped(
            index : TokenIndex
        ) : Bool {
            switch(_items.get(index)){
                case(?#Material(name)){
                    return false;
                };
                case(?#Accessory(item)){
                    return(Option.isSome(item.equipped));
                };
                case(_) {
                    _Logs.logMessage("Strange error : item not found for tokenIndex : " # Nat32.toText(index));
                    assert(false);
                    return false;
                }
            };
        };

        public func getTemplate(
            name : Text
        ) : ?Blob {
            switch(_templates.get(name)){
                case(?#Material(blob)){
                    return ?blob;
                };
                case(?#Accessory(item)){
                    return ? Text.encodeUtf8(item.before_wear # item.after_wear);
                };
                case(_) return null;
            };
        };

        ////////////////
        // HELPERS /////
        ////////////////

        func _drawAccessory (token_index : TokenIndex) : () {
            switch(_items.get(token_index)){
                case(?#Accessory(item)){
                    switch(_templates.get(item.name)){
                            case(?#Accessory(template)){
                                let concatenated_svg = template.before_wear # "<text x=\"190.763px\" y=\"439.84px\" style=\"font-family: 'Futura-Medium', 'Futura', sans-serif; font-weight: 500; font-size: 50px; fill: white\">" # Nat.toText(Nat8.toNat(item.wear)) # "</text>" # template.after_wear;
                                let blob = Text.encodeUtf8(concatenated_svg);
                                _blobs.put(token_index, blob);
                            };
                            case(_) assert(false);
                        };
                };
                case(_){assert(false)};
            };
        };

        func _isEquipped(token_index : TokenIndex) : Bool {
            switch(_items.get(token_index)){
                case(?#Accessory(accessory)){
                    if(Option.isSome(accessory.equipped)){
                        return true;
                    };
                };
                case(_){};
            };
            return false;
        };

        func _createAccessoryEquippedOn(
            accessory : Accessory,
            avatar : ?TokenIdentifier
        ) : Item {
            #Accessory({
                name = accessory.name;
                wear = accessory.wear;
                equipped = avatar;
            })
        };

        func _createAccessoryWear(
            accessory : Accessory,
            wear : Nat8
        ) : Item {
            #Accessory({
                name = accessory.name;
                wear = wear;
                equipped = accessory.equipped;
            })
        };
    };
};