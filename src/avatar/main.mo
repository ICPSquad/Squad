import Array "mo:base/Array";
import Blob "mo:base/Blob";
import Buffer "mo:base/Buffer";
import Cycles "mo:base/ExperimentalCycles";
import Debug "mo:base/Debug";
import Hash "mo:base/Hash";
import HashMap "mo:base/HashMap";
import Int "mo:base/Int";
import Iter "mo:base/Iter";
import Nat "mo:base/Nat";
import Nat32 "mo:base/Nat32";
import Nat8 "mo:base/Nat8";
import Option "mo:base/Option";
import Prim "mo:prim";
import Principal "mo:base/Principal";
import Result "mo:base/Result";
import Text "mo:base/Text";
import Time "mo:base/Time";
import _Admins "mo:base/Char";
import _Ext "mo:base/List";

import AccountIdentifier "mo:principal/AccountIdentifier";
import Canistergeek "mo:canistergeek/canistergeek";
import Cap "mo:cap/Cap";
import Ext "mo:ext/Ext";
import Hex "mo:encoding/Hex";
import PrincipalBlob "mo:principal/Principal";
import Root "mo:cap/Root";
import _Monitor "mo:canistergeek/typesModule";

import Admins "admins";
import Assets "assets";
import AvatarModule "types/avatar";
import AvatarNewModule "avatar";
import ColorModule "types/color";
import ExtModule "ext";
import Http "http";
import SVG "utils/svg";
import Utils "../dependencies/helpers/Array";

shared ({ caller = creator }) actor class ICPSquadNFT(
    cid : Principal,
) = this {

    ///////////
    // TYPES //
    ///////////

    public type Time = Time.Time;
    public type Result<A,B> = Result.Result<A,B>;   

    ///////////////
    // METRICS ///
    /////////////

    stable var _MonitorUD: ? Canistergeek.UpgradeData = null;
    private let _Monitor : Canistergeek.Monitor = Canistergeek.Monitor();

    /**
    * Returns collected data based on passed parameters.
    * Called from browser.
    * @auth : admin
    */
    public query ({caller}) func getCanisterMetrics(parameters: Canistergeek.GetMetricsParameters): async ?Canistergeek.CanisterMetrics {
        assert(_Admins.isAdmin(caller));
        _Monitor.getMetrics(parameters);
    };

    /**
    * Force collecting the data at current time.
    * Called from browser or any canister "update" method.
    * @auth : admin 
    */
    public shared ({caller}) func collectCanisterMetrics(): async () {
        assert(_Admins.isAdmin(caller));
        _Monitor.collectMetrics();
    };

    ////////////
    // LOGS ///
    //////////

    stable var _LogsUD: ? Canistergeek.LoggerUpgradeData = null;
    private let _Logs : Canistergeek.Logger = Canistergeek.Logger();

    /**
    * Returns collected log messages based on passed parameters.
    * Called from browser.
    * @auth : admin
    */
    public query ({caller}) func getCanisterLog(request: ?Canistergeek.CanisterLogRequest) : async ?Canistergeek.CanisterLogResponse {
        assert(_Admins.isAdmin(caller));
        _Logs.getLog(request);
    };

    ///////////////
    // AVATAR ////
    /////////////

    ////////////////
    // Component //
    //////////////

    // Component are stored as raw <g> textual element.
    public type Component = AvatarModule.Component;
    stable var componentsEntries : [(Text,Component)] = [];
    let components : HashMap.HashMap<Text,Component> = HashMap.fromIter(componentsEntries.vals(), 0, Text.equal, Text.hash);    
    
    private func _isKnownComponent (name : Text) : Bool {
        switch(components.get(name)) {
            case (null) return false;
            case (?component) return true;
        }
    };

    /////////////////
    // Accessory ///
    ////////////////
    
    public type Accessory = AvatarModule.Accessory;
    stable var accessoriesEntries : [(Text,Accessory)] = [];
    let accessories : HashMap.HashMap<Text,Accessory> = HashMap.fromIter(accessoriesEntries.vals(), 0, Text.equal, Text.hash);

    //////////////////
    // Avatar class //
    /////////////////
   
    // This class cannot be defined as an external module because it depends on the component store.
    // Needs a textual style, a list of layers and a Slots object to be instantiated.
    // LayerId and LayerName are used for each avatars so we just store the names and not the content of each layer.
   
    type LayerId = AvatarModule.LayerId;
    type LayerAvatar = AvatarModule.LayerAvatar;
    type Slots = AvatarModule.Slots;
    type AvatarRequest = AvatarModule.AvatarRequest;
    type AvatarInformations = AvatarModule.AvatarInformations;
    type AvatarResponse = AvatarModule.AvatarResponse;
    type ComponentRequest = AvatarModule.ComponentRequest;
    type Colors = ColorModule.Colors;
    public type MintRequest = {
        to : Ext.User;
        metadata : AvatarRequest;
    };

    //Style that will be added to all avatars (to ajust components to the right body)
    stable var style_to_add : Text = "";
    public shared ({caller}) func modify_style (text : Text) : async Text {
        assert(_Admins.isAdmin(caller));
        style_to_add := text;
        return (style_to_add);
    };

    //Avatar are regenerated at each upgrade.
    let avatars : HashMap.HashMap<TokenIdentifier, Avatar> = HashMap.HashMap<TokenIdentifier,Avatar>(0 , Text.equal, Text.hash);
    stable var tokenStorage : [TokenIdentifier] = [];
    stable var layerStorage : [[(LayerId,LayerAvatar)]] = [];
    stable var styleStorage : [Text] = [];
    stable var slotsStorage : [Slots] = [];

    public shared func allTokens() : async [TokenIdentifier]  {
        var buffer : Buffer.Buffer<Text> =  Buffer.Buffer(0);
        for(token in avatars.keys()){
            buffer.add(token);
        };
        buffer.toArray();
    };

    private class Avatar ( layersEntries : [(LayerId, LayerAvatar)], style : Text, slots : Slots) {

        var slots_in_memory : Slots = slots; 
        var style_in_memory : Text = style;
        var svg : Text = "";

        public let layers : HashMap.HashMap<LayerId,LayerAvatar> = HashMap.fromIter(layersEntries.vals(), 0 , Nat.equal, Hash.hash);
        
        public func addLayer (id : LayerId , layer : LayerAvatar) : () {
            layers.put(id, layer);
            return;
        };

        public func removeLayer (id : LayerId) : () {
          ignore(layers.remove(id));
          return;  
        };


        public func changeSlots(slots : Slots) : () {
            slots_in_memory := slots;
        };

        public func getSlots () : Slots  {
            return slots_in_memory;
        };

        public func getRawStyle () : Text {
            return style_in_memory;
        };

        public func getLayers () : [(LayerId, LayerAvatar)] {
            Iter.toArray(layers.entries());
        };

        public func getLayersName() : [(LayerId, Text)] {
            var buffer : Buffer.Buffer<(LayerId, Text)> = Buffer.Buffer(0);
            for(layer in layers.entries()){
                switch(layer.1){
                    case(#Component(name)) {
                        buffer.add((layer.0, name));
                    };
                    case(#Accessory(name)) {
                        buffer.add((layer.0, name));
                    };

                }
            };
            buffer.toArray();
        };

        
        //  Get the body name to add as class to the final svg so the css style can target and modify elements.
        private func _getNameBody () : Text {
            let layer_head = layers.get(20);
            switch(layer_head){
                case(?#Component(text)){
                    return text;
                };
                case(_){
                    return "null";
                };
            };
        };

        public func getNameBody () : Text {
            let layer_head = layers.get(20);
            switch(layer_head){
                case(?#Component(text)){
                    return text;
                };
                case(_){
                    return "null";
                };
            };
        };

        public func getFullSvg () : Text {
            var content : Text = "<svg viewBox='0 0 800 800' xmlns='http://www.w3.org/2000/svg' class='";
            content #= _getNameBody(); // We add class "Punk-body" / "Miss-body" / "Business-body" to the svg to apply the style.
            content #= "'>";
            content #= style_to_add; // This style allow for all components to fit on the 3 different body types
            content #= style_in_memory; //  This style contains information about colors for eyes,hair,skin ...

            //  This style allow us to hide some layers when accessory are equipped!
            switch(get_style_optional_accessory()){
                case(?style) {
                    content #= style;
                };
                case(null){};
            };

            content #= svg;
            content #= "</svg>";
            return content;
        };

        //  Return a list of all layers that are populated associated with their wrapped <g> element.
        public func getLayersText() : [(LayerId, Text)]{
            var buffer = Buffer.Buffer<(LayerId,Text)>(0);
            for(i in Iter.range(0,100)){
                switch(layers.get(i)) {
                    case (null) {};
                    case (?layer) {
                        switch(layer) {
                            case(#Accessory(name)){
                               switch(accessories.get(name)){
                                   case(null) {};
                                   case(?accessory){
                                       buffer.add(i, AvatarModule.wrapAccessory(accessory.slot, accessory.content));
                                   };
                               };
                            };
                            case(#Component(name)){
                                switch(components.get(name)) {
                                   case(null) {};
                                    case (?compo) {
                                        buffer.add(i, AvatarModule.wrapComponent(compo.content, i, name));
                                    };
                                };
                            };
                        };
                    };
                };
           };
           return(buffer.toArray());
        };

        public func getLayer (id : LayerId) : ?LayerAvatar {
            switch(layers.get(id)) {
                case(null) return null;
                case(?layer) return ?layer;
            };
        };

        public func buildSvg () : () {
            svg := "";
            // svg := svg # style_in_memory; TODO arrange the way the style is created
            let iterator : Iter.Iter<Nat> = Iter.range(0,100);
            for (i in iterator) {
                switch(layers.get(i)) {
                    case (null) {};
                    case (?layer) {
                        switch(layer) {
                            case(#Accessory(name)){
                               switch(accessories.get(name)){
                                   case(null){};
                                   case(?accessory){
                                       svg #= AvatarModule.wrapAccessory(name, accessory.content);
                                   };
                               };
                            };
                            case(#Component(name)){
                                switch(components.get(name)) {
                                    case(null) {};
                                    case (?compo) {
                                        svg #= AvatarModule.wrapComponent(compo.content, i, name);
                                    }
                                }
                            };
                        };
                    };
                };
            };
        };

        public func addToSlot (accessory : Accessory) : Result<(), Text> {
            let slots_object = slots_in_memory;
            let accessory_name = accessory.name;
            let slot_name = accessory.slot;

            switch(AvatarModule.putAccessoryInSlot(slot_name, slots_object, accessory_name)){
                case (#err(msg)) return #err(msg);
                case (#ok(new_slots)) {
                    slots_in_memory := new_slots;
                    return #ok;
                };
            };
        };

        public func removeFromSlot (slot_name : Text) : Result<(), Text> {
            let slots_object = slots_in_memory;
            switch(AvatarModule.removeFromSlot(slot_name, slots_in_memory)){
                case(#err(msg)) return #err(msg);
                case(#ok(new_slots)) {
                    slots_in_memory := new_slots;
                    return #ok
                };
            };
        };

        private func get_style_optional_accessory() : ?Text {
            switch(slots_in_memory.Body){
                case(?something) {
                    return ?"<style> .clothing {visibility : hidden;} </style>";
                };
                case(null) return null;
            };
        };
    };
         
    public shared ({caller}) func mint (request : MintRequest) : async Result<AvatarInformations,Text> {
        assert(caller == Principal.fromText("p4y2d-yyaaa-aaaaj-qaixa-cai")); 
        // Create the avatar and returns it (see _createAvatar)
        switch(_createAvatar(request.metadata)){
            case(#err(message)) return #err(message);
            case(#ok(avatar)) {

                // Create the nft for the receiver.
                let receiver = Text.map(Ext.User.toAccountIdentifier(request.to), Prim.charToLower);
                let token = _nextTokenId;
                _registry.put(token, receiver);

                // Generate the next TokenIdentifier from the internal TokenId then associate the Avatar with this TokenIdentifier.
                let token_identifier : TokenIdentifier = Ext.TokenIdentifier.encode(cid, token);
                avatars.put(token_identifier, avatar);

                // Generate svg and blob from Avatar and also associate the TokenIdentifier with them.
                avatar.buildSvg();
                let final_svg = avatar.getFullSvg();
                let final_blob = Text.encodeUtf8(final_svg);
                _blobs.put(token_identifier, final_blob);

                // Increase parameters of the minter for the next NFT. 
                _supply := _supply + 1;
                _nextTokenId := _nextTokenId + 1;

                //  Register to CAP
                let event : IndefiniteEvent = {
                    operation = "mint";
                    details = [("token", #Text(token_identifier)), ("to", #Text(receiver))];
                    caller = caller;
                };
                ignore(_registerEvent(event));

                let avatar_infos : AvatarInformations = {tokenIdentifier = token_identifier; svg = final_svg;};
                return #ok (avatar_infos);
            };
        };
    };

    

    public shared ({caller}) func wearAccessory (token_avatar : TokenIdentifier, name : Text, principal_caller : Principal) : async Result<(), Text> {
        assert(caller == Principal.fromText ("po6n2-uiaaa-aaaaj-qaiua-cai")); 
        switch(_accessoryVerification(token_avatar, name, principal_caller)){
            case (#err(msg)) return #err(msg);
            case (#ok) {
                switch(accessories.get(name)){
                    case(null) return #err ("Impossible 1 : " # name);
                    case (?accessory){
                        switch(avatars.get(token_avatar)){
                            case(null) return #err ("Impossible 2 : " #token_avatar);
                            case(?avatar){
                                switch(avatar.addToSlot(accessory)){
                                    case(#err(msg)) return #err(msg);
                                    case(#ok){
                                        let layer_id : Nat8 = accessory.layer;
                                        let layer : LayerAvatar = #Accessory(accessory.name);
                                        avatar.addLayer(Nat8.toNat(layer_id), layer);
                                        // TODO : multi layers accessories (layer)
                                        switch(_draw(token_avatar)){
                                            case(#err(msg)) {
                                                ignore(avatar.removeFromSlot(accessory.slot));
                                                avatar.removeLayer(Nat8.toNat(accessory.layer));
                                                return #err(msg);
                                            };
                                            case(#ok) return #ok;
                                        };
                                    };
                                };
                            };
                        };
                    };
                };
            };
        };
    };

    public shared ({caller}) func wearAccessory_new(
        tokenId : TokenIdentifier,
        name : Text,
        caller : Principal
    ) : async Result<(), Text> {
        // assert(caller == Principal.fromText("po6n2-uiaaa-aaaaj-qaiua-cai"));
        _Monitor.collectMetrics();
        switch(_Ext.balance({ user = #principal(caller); token = tokenId})){
            case(#err(_)){
                return #err("Error trying to access EXT balance : " # tokenId);
            };
            case(#ok(n)){
                switch(n){
                    case(0){
                        _Logs.logMessage("Main/wearAccessory/502." # " Caller :  " #Principal.toText(caller) # " doesnt own : " # tokenId);
                        return #err("Caller :  " #Principal.toText(caller) # " doesn't own : " # tokenId);
                    };
                    case(1){
                        _Avatar.wearAccessory(tokenId, name)
                    };
                    case _ {
                        _Logs.logMessage("Main/wearAccessory/502." # " Caller :  " #Principal.toText(caller) # " doesnt own : " # tokenId);
                        return #err("Unexpected value for balance : " # Nat.toText(n));
                    }
                };
            };
        }
    };


    public shared ({caller}) func removeAccessory (token_avatar : TokenIdentifier, name : Text, principal_caller : Principal) : async Result<(), Text> {
        assert(caller == Principal.fromText ("po6n2-uiaaa-aaaaj-qaiua-cai")); 
        //  Check the avatar is owned by the principal_caller.
        switch(avatars.get(token_avatar)){
            case (null) return #err("No avatar found for this token identifier : " # token_avatar);
            case (?avatar) {
                if(not (_isOwner(principal_caller, token_avatar))){
                    let principal_caller_textual : Text = Principal.toText(principal_caller);
                    var message : Text = "This avatar : " # token_avatar # " .";
                    message #=  "Does not belong to this principal : " # principal_caller_textual # " .";
                    return #err(message);
                };
                // Check the accessory exists
                switch(accessories.get(name)){
                    case(null) return #err("No accessory found for name : " #name);
                    case(?accessory){
                        // Check the accessory is equipped
                        let slot = accessory.slot;
                        let slots_avatar = avatar.getSlots();
                        if(not(_verifySlot(slots_avatar, slot, name))){
                            return #err("This accessory is not equipped on this avatar... (strange)");
                        };
                        //  Remove from slots & layers 
                        switch(avatar.removeFromSlot(slot)){
                            case(#err(msg)) return #err(msg);
                            case(#ok){
                                avatar.removeLayer(Nat8.toNat(accessory.layer));
                                //  Redraw the avatar 
                                switch(_draw(token_avatar)){
                                    case(#err(msg)) return #err(msg);
                                    case(#ok){
                                        return #ok;
                                    };
                                };
                            };
                        };
                    };
                };
            };
        };
    };

    public shared ({caller}) func removeAccessory_new(
        tokenId : TokenIdentifier,
        name : Text,
        caller : Principal
    ) : async Result<(), Text> {
        // assert(caller == Principal.fromText("po6n2-uiaaa-aaaaj-qaiua-cai"));
        _Monitor.collectMetrics();
         switch(_Ext.balance({ user = #principal(caller); token = tokenId})){
            case(#err(_)){
                return #err("Error trying to access EXT balance : " # tokenId);
            };
            case(#ok(n)){
                switch(n){
                    case(0){
                        _Logs.logMessage("Main/wearAccessory/502." # " Caller :  " #Principal.toText(caller) # " doesnt own : " # tokenId);
                        return #err("Caller :  " #Principal.toText(caller) # " doesn't own : " # tokenId);
                    };
                    case(1){
                        _Avatar.removeAccessory(tokenId, name)
                    };
                    case _ {
                        _Logs.logMessage("Main/wearAccessory/502." # " Caller :  " #Principal.toText(caller) # " doesnt own : " # tokenId);
                        return #err("Unexpected value for balance : " # Nat.toText(n));
                    }
                };
            };
        };
    };



    // Verify that the accessory is already equipped in the slot. Returns a boolean.
    private func _verifySlot(slots : Slots, slot_to_check : Text, name_accessory : Text) : Bool {
        switch(slot_to_check){
            case("Hat"){
                switch(slots.Hat){
                    case(null) return false;
                    case(?something) {
                        return (Text.equal(something, name_accessory));
                    };
                };
            };
            case("Eyes"){
                switch(slots.Eyes){
                    case(null) return false;
                    case(?something) {
                        return (Text.equal(something, name_accessory));
                    };
                };
            };
            case("Face"){
                switch(slots.Face){
                    case(null) return false;
                    case(?something) {
                        return (Text.equal(something, name_accessory));
                    };
                };
            };
            case("Body"){
                switch(slots.Body){
                    case(null) return false;
                    case(?something) {
                        return (Text.equal(something, name_accessory));
                    };
                };
            };
            case("Misc"){
                switch(slots.Misc){
                    case(null) return false;
                    case(?something) {
                        return (Text.equal(something, name_accessory));
                    };
                };
            };
            case(_) {
                return false;
            };
        };
    };


    //////////////////
    // Avatar query //
    /////////////////
    
    private stable var _blobsEntries : [(TokenIdentifier, Blob)] = [];
    private var _blobs : HashMap.HashMap<TokenIdentifier, Blob> = HashMap.fromIter(_blobsEntries.vals(), 0 , Text.equal, Text.hash);
  
    public shared ({caller}) func draw(token : TokenIdentifier) : async Result<(), Text> {
        assert(_Admins.isAdmin(caller));
        switch(avatars.get(token)) {
            case (null) return #err ("Avatar not found");
            case (?avatar) {
                ignore(_draw(token));
                return #ok;
            };
        };
    };

    type AvatarPreview = {
        token_identifier : TokenIdentifier;
        layers : [(LayerId, Text)];
        style : Text;
        slots : Slots;
        body_name : Text;
    };

    //  Used to get all the informations to construct the room on the frontend where users can equip accessories. If caller owns an avatar, returns it's token identifier/layersText/style/slots/body-type.
    public shared query ({caller}) func getAvatarInfos_new() : async Result<AvatarPreview, Text> {
        let tokens = switch(_Ext.tokens(Text.map(Ext.AccountIdentifier.fromPrincipal(caller, null), Prim.charToLower))) {
            case(#err(_)) {
                _Logs.logMessage("Main/getAvatarInfos_new/672." # " Error trying to access EXT tokens : " # Principal.toText(caller));
                return #err("Error trying to access EXT tokens : " # Principal.toText(caller));
            };
            case(#ok(list)) list;
        };
        if(tokens.size() == 0){
            return #err("You don't own any avatar.");
        };
        let tokenId = Ext.TokenIdentifier.encode(cid, tokens[0]);
        switch(avatars.get(tokenId)){
            case(null) {
                _Logs.logMessage("Main/getAvatarInfos_new/683." # " No avatar associated with tokenIdentifier " # Ext.TokenIdentifier.encode(cid, tokens[0]));
                return #err("Error trying to access EXT tokens : " # Principal.toText(caller));
            };
            case(?avatar) { 
                return #ok({token_identifier = tokenId; layers = avatar.getLayersText(); style = avatar.getRawStyle(); slots = avatar.getSlots(); body_name = avatar.getNameBody()});
            };
        };
    };

  
    ////////////////////
    // Avatar private //
    ///////////////////

    private func _createAvatar (request : AvatarRequest) :  Result<Avatar,Text> {
        var layersEntrie : [(LayerId, LayerAvatar)] = [];
        let components_list : [ComponentRequest] = request.components;
        
        for (component in components_list.vals()) {
            if(not (_isKnownComponent(component.name))) {
                let text : Text = "You have specified a component that doesn't exist :" # component.name;
                return #err(text);
            };

            let layer_name : Text = component.name;
            let layer_avatar : LayerAvatar = #Component(layer_name); //During the initial mint there is no accessory involved!
            layersEntrie := Array.append<(LayerId, LayerAvatar)>(layersEntrie, [(Nat8.toNat(component.layer), layer_avatar)]); 
        };

        let style : Text = ColorModule.createStyle(request.colors);
        let slot : Slots = AvatarModule.generateNewSlots();
        var avatar = Avatar(layersEntrie, style, slot);
        return #ok (avatar);
    };

    private func _draw (token : TokenIdentifier) : Result<(), Text> {
        switch(avatars.get(token)) {
            case (null) return #err ("Avatar not found");
            case (?avatar) {
                // Redraw the avatar
                avatar.buildSvg();

                //Rebuilds and stores the blob
               let new_blob = Text.encodeUtf8(avatar.getFullSvg());
               _blobs.put(token, new_blob);

               return #ok;
            };
        };
    };



    private func _accessoryVerification (token_avatar: TokenIdentifier, name : Text, principal_caller : Principal) : Result<(), Text> {
         switch(avatars.get(token_avatar)){
            case (null) return #err("No avatar found for this token identifier : " # token_avatar);
            case (?avatar) {
                if(not (_isOwner(principal_caller, token_avatar))){
                    let principal_caller_textual : Text = Principal.toText(principal_caller);
                    var message : Text = "This avatar : " # token_avatar # " .";
                    message #=  "Does not belong to this principal : " # principal_caller_textual # " .";
                    return #err(message);
                };
                switch(accessories.get(name)){
                    case(null) return #err("No accessory found for this name : " # name);
                    case (?accessory) {
                        let slot_name : Text = accessory.slot;
                        let slots_object : Slots = avatar.getSlots();
                        if(not(AvatarModule.isSlotEmpty(slot_name,slots_object))){
                            return #err("This slot is already taken : " # slot_name);
                        };

                        let layer_accessory = accessory.layer;
                        switch(avatar.getLayer(Nat8.toNat(layer_accessory))){
                            case(?layer){
                                return #err ("This layer is already taken : " # Nat8.toText(layer_accessory));
                            };
                            case (null) {
                                return #ok;
                            }
                        };
                    };
                };
            };
        };
    };


    private func _isOwner (
        p : Principal, 
        tokenId : TokenIdentifier
    ) : Bool {
        let aid = Text.map(Ext.AccountIdentifier.fromPrincipal(p, null), Prim.charToLower);
        switch(_Ext.tokens(aid)){
            case(#err(_)) {
                _Logs.logMessage("Main/_isOwner/821." # " Error trying to access EXT tokens : " # Principal.toText(p));
                return false;
            };
            case(#ok(list)) {
                for (token in list.vals()) {
                    if(Ext.TokenIdentifier.encode(cid, token) == tokenId){
                        return true;
                    };
                };
                return false;
            };
        };
    };
    
    
    //////////////////
    // EXT - ERC721 //
    /////////////////

    type AccountIdentifier = Ext.AccountIdentifier;
    type SubAccount = Ext.SubAccount;
    type User = Ext.User;
    type Balance = Ext.Balance;
    type TokenIdentifier = Ext.TokenIdentifier;
    type TokenIndex  = Ext.TokenIndex ;
    type Extension = Ext.Extension;
    type CommonError = Ext.CommonError;
    type BalanceRequest = Ext.Core.BalanceRequest;
    type BalanceResponse = Ext.Core.BalanceResponse;
    type TransferRequest = Ext.Core.TransferRequest;
    type TransferResponse = Ext.Core.TransferResponse;
    

    private let EXTENSIONS : [Extension] = [];
    private stable var _supply : Balance  = 0;
    private stable var _minter : [Principal]  = [];
    private stable var _nextTokenId : TokenIndex  = 0;

     
    private stable var _registryState : [(TokenIndex, AccountIdentifier)] = [];
    private var _registry : HashMap.HashMap<TokenIndex, AccountIdentifier> = HashMap.fromIter(_registryState.vals(), 0, Ext.TokenIndex.equal, Ext.TokenIndex.hash);

    public shared ({caller}) func transfer(request : TransferRequest) : async TransferResponse {
        _Monitor.collectMetrics();
        switch(_Ext.transfer(caller, request)){
            case(#err(#Other(e))) return #err(#Other(e));
            case(#err(#InvalidToken(token))) return #err(#InvalidToken(token));
            case(#ok(index)) {
                let from = Text.map(Ext.User.toAccountIdentifier(request.from), Prim.charToLower);
                let to = Text.map(Ext.User.toAccountIdentifier(request.to), Prim.charToLower);
                ignore(_registerEvent({
                    operation = "transfer";
                    details = [("token", #Text(request.token)), ("from", #Text(from)), ("to", #Text(to))];
                    caller = caller;
                }));
                return #ok(index);
            };
            case(#err(_)) return #err(#Other("Unknown error"));
        }
    };

    public query func getRegistry() : async [(TokenIndex, AccountIdentifier)] {
        _Ext.getRegistry();
    };

    public query func getTokens() : async [(TokenIndex, Ext.Common.Metadata)] {
        var buffer = Buffer.Buffer<(TokenIndex,Ext.Common.Metadata)>(0);
        let registry = _Ext.getRegistry();
        for((token_index, account_identifier) in registry.vals()){
            let token_identifier = Ext.TokenIdentifier.encode(cid, token_index);
            let element = (token_index, #nonfungible{metadata =_blobs.get(token_identifier)});
            buffer.add(element);
        };
        buffer.toArray();
    };
      
    public query func metadata(token : TokenIdentifier): async Result<Ext.Common.Metadata, Ext.CommonError> {
        switch(_blobs.get(token)){
            case(null) {
                return #err(#InvalidToken(token));
            };
            case(?blob){
                let a = #nonfungible({metadata  = ?blob});
                return #ok(a);
            };
        };
    };

    public query func tokens(aid : AccountIdentifier) : async Result<[TokenIndex], CommonError> {
        _Ext.tokens(aid);
    };

    public query func tokens_ext(aid : AccountIdentifier) : async Result<[(TokenIndex, ?ExtModule.Listing, ?Blob)], CommonError> {
        _Ext.tokens_ext(aid);
    };

    public query func tokens_id(aid : AccountIdentifier) : async Result<[TokenIdentifier], CommonError> {
        switch(_Ext.tokens(aid)){
            case(#err(#Other(e))) return #err(#Other(e));
            case(#err(#InvalidToken(token))) return #err(#InvalidToken(token));
            case(#ok(tokens)) {
                return(#ok(Array.map<TokenIndex,TokenIdentifier>(tokens, func(x) { Ext.TokenIdentifier.encode(cid, x) })));
            };
        }
    };

    public query func balance(request : BalanceRequest) : async BalanceResponse {
        _Ext.balance(request);
    };

    public query func bearer(tokenId : TokenIdentifier) : async Result<AccountIdentifier, CommonError> {
        _Ext.bearer(tokenId);
    };

    public query func details(tokenId : TokenIdentifier) : async Result<(AccountIdentifier, ?ExtModule.Listing), CommonError> {
        _Ext.details(tokenId);
    };

    //////////
    // CAP //
    /////////

    //Details : https://github.com/Psychedelic/cap-motoko-library

    type DetailValue = Root.DetailValue;
    type Event = Root.Event;
    type IndefiniteEvent = Root.IndefiniteEvent;
    
    //null is passed as argument to not override the router canister id on mainnet : lj532-6iaaa-aaaah-qcc7a-cai
    let cap = Cap.Cap(null); 

    // The number of cycles to use when initialising the handshake process which creates a new canister and install the bucket code into cap service
    let creationCycles : Nat = 1_000_000_000_000;

    // Call the handshake function on CAP which will ask the Router canister to create a new Root canister specifically for this token smart contract.
    // @auth : owner
    public shared ({caller}) func init_cap() : async Result<(), Text> {
        assert(_Admins.isAdmin(caller));
        let tokenContractId = Principal.toText(cid);
        try {
            let handshake = await cap.handshake(
                tokenContractId,
                creationCycles
            );
            return #ok();
        } catch e {
            throw e;
        };
    };

    //  This hashmap is used to store events & register them later to avoid any lost event in case of CAP error or message lost.
    private stable var _eventsEntries : [(Time, IndefiniteEvent)] = [];
    let _events : HashMap.HashMap<Time, IndefiniteEvent> = HashMap.fromIter(_eventsEntries.vals(), _eventsEntries.size(), Int.equal, Int.hash);
    
    //  Periodically called through heartbeat to verify that all events have been reported 
    public shared ({caller}) func verificationEvents() : async () {
        assert(caller == cid or _Admins.isAdmin(caller));
        for((time,event) in _events.entries()){
            switch(await cap.insert(event)){
                case(#err(message)){};
                case(#ok(id)){
                    _events.delete(time);
                };
            };
        };
    };

    // It should almost always be 0
    public shared query ({caller}) func eventsSize() : async Nat {
        assert(_Admins.isAdmin(caller));
        _events.size();
    };

    //  Register an event to CAP, store it in _events if registration wasn't successful to process later.
    private func _registerEvent(event : IndefiniteEvent) : async () {
        let time = Time.now();
        _events.put(time, event);
        switch(await cap.insert(event)){
            case(#ok(id)){
                _events.delete(time);
            };
            case(#err(message)){};
        };
    };



    /////////////
    // UPGRADE //
    /////////////

    system func preupgrade() {
        _Logs.logMessage("Pre-upgrade");

        _MonitorUD := ? _Monitor.preupgrade();
        _LogsUD := ? _Logs.preupgrade();
        _AdminsUD := ? _Admins.preupgrade();
        _AssetsUD := ? _Assets.preupgrade();
        _AvatarUD := ? _Avatar.preupgrade();
        _ExtUD := ? _Ext.preupgrade();

        // Avatar deserialization
        let buffer_token = Buffer.Buffer<TokenIdentifier>(0);
        let buffer_layer = Buffer.Buffer<[(LayerId,LayerAvatar)]>(0);
        let buffer_style = Buffer.Buffer<Text>(0);
        let buffer_slots = Buffer.Buffer<Slots>(0);

        for((k,v) in avatars.entries()){
            buffer_token.add(k);
            let variable = Iter.toArray(v.layers.entries());
            buffer_layer.add(variable);
            buffer_style.add(v.getRawStyle());
            buffer_slots.add(v.getSlots());
        };

        tokenStorage := buffer_token.toArray();
        layerStorage  := buffer_layer.toArray();
        styleStorage  := buffer_style.toArray();
        slotsStorage := buffer_slots.toArray();

        //  Components & legenndary 
        componentsEntries := Iter.toArray(components.entries());
        accessoriesEntries := Iter.toArray(accessories.entries());

        _registryState := Iter.toArray(_registry.entries());
        _blobsEntries := Iter.toArray(_blobs.entries());
        //  CAP
        _eventsEntries := Iter.toArray(_events.entries());

    };

    system func postupgrade() {

        // CanisterGeek
        _Logs.postupgrade(_LogsUD);
        _LogsUD := null;

        _Monitor.postupgrade(_MonitorUD);
        _MonitorUD := null;

        _Admins.postupgrade(_AdminsUD);
        _AdminsUD := null;

        _Assets.postupgrade(_AssetsUD);
        _AssetsUD := null;

        _Avatar.postupgrade(_AvatarUD);
        _AvatarUD := null;

        _Ext.postupgrade(_ExtUD);
        _ExtUD := null;


        let iterator = Iter.range(0, layerStorage.size() - 1);
        for (i in iterator) {
            let layersEntries : [(LayerId, LayerAvatar)] = layerStorage[i];
            let style : Text = styleStorage[i];
            let tokenIdentifier : TokenIdentifier = tokenStorage[i];
            let slots : Slots = slotsStorage[i];
            let avatar : Avatar = Avatar(layersEntries, style, slots);
            avatars.put(tokenIdentifier, avatar);
        };

        componentsEntries := [];
        accessoriesEntries := [];
        _registryState := [];
        _blobsEntries := [];
        layerStorage := [];
        tokenStorage := [];
        styleStorage := [];
        slotsStorage := [];

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

    ///////////
    // ADMIN //
    ///////////

    stable var _AdminsUD : ?Admins.UpgradeData = null;
    let _Admins = Admins.Admins(creator);

    public query func is_admin(p : Principal) : async Bool {
        _Admins.isAdmin(p);
    };

    public shared ({caller}) func add_admin(p : Principal) : async () {
        _Admins.addAdmin(p, caller);
        _Monitor.collectMetrics();
        _Logs.logMessage("Added admin : " # Principal.toText(p) # " by " # Principal.toText(caller));
    };

    ////////////
    // ASSET //
    ///////////

    public type FilePath = Assets.FilePath;
    public type Record = Assets.Record;

    stable var _AssetsUD : ?Assets.UpgradeData = null;
    let _Assets = Assets.Assets();

    public shared ({caller}) func upload(
        bytes : [Nat8]
    ) : async () {
        assert(_Admins.isAdmin(caller));
        _Monitor.collectMetrics();
        _Assets.upload(bytes);
    };

    public shared ({caller}) func uploadFinalize (
        contentType : Text,
        meta : Assets.Meta,
        filePath : Text,
    ) : async Result<(), Text> {
        assert(_Admins.isAdmin(caller));
        _Monitor.collectMetrics();
        switch(_Assets.uploadFinalize(contentType,meta,filePath)){
            case(#ok(())){
                _Logs.logMessage("Uploaded file: " # filePath);
                return #ok(());
            };
            case(#err(message)){
                _Logs.logMessage("Failed to upload file: " # filePath);
                return #err(message);
            };
        }
    };

    public shared ({caller}) func uploadClear() : async () {
        assert(_Admins.isAdmin(caller));
        _Monitor.collectMetrics();
        _Assets.uploadClear();
    };


    ///////////////
    // Avatar ////
    /////////////

    type Avatar_New = AvatarNewModule.Avatar;
    type Component_New = AvatarNewModule.Component;

    stable var _AvatarUD : ?AvatarNewModule.UpgradeData = null;
    let _Avatar = AvatarNewModule.Factory({
        _Admins = _Admins;
        _Assets = _Assets;
        _Logs = _Logs;
    });

    public shared ({caller}) func addComponent_new(
        name : Text,
        component : AvatarNewModule.Component
    ) : async Result<(), Text> {
        assert(_Admins.isAdmin(caller));
        _Monitor.collectMetrics();
        switch(_Avatar.addComponent(name, component)){
            case(#ok(())){
                _Logs.logMessage("Added component: " # name);
                return #ok(());
            };
            case(#err(message)){
                _Logs.logMessage("Failed to add component: " # name);
                return #err(message);
            };
        };
    };

    public shared ({caller}) func changeCSS(
        style : Text 
    ) : async () {
        assert(_Admins.isAdmin(caller));
        _Monitor.collectMetrics();
        _Avatar.changeCSS(style);
        _Logs.logMessage("Changed CSS");
    };

    public shared ({caller}) func drawAvatar(
        tokenId : TokenIdentifier
    ) : async Result<(), Text> {
        assert(_Admins.isAdmin(caller));
        _Monitor.collectMetrics();
        _Avatar.drawAvatar(tokenId);
    };

    // TODO
    // Create the avatar and the blob
    // Get the right tokenIdentifier and put the request user as owner
    // Log
    // More errors
    // public shared ({caller}) func mint_old(request : MintRequest) : async Result<TokenIdentifier,Text> {
    //     assert(_Admins.isAdmin(caller));
    //     _Monitor.collectMetrics();
    //     let token_identifier : TokenIdentifier = Ext.TokenIdentifier.encode(cid,_nextTokenId);
    //     _nextTokenId := _nextTokenId + 1;
    //     switch(_Avatar.createAvatar_old(request.metadata, token_identifier)){
    //         case(#ok) return #ok(token_identifier);
    //         case(#err(message)) return #err(message);
    //     }
    // };

    type MintInformation = AvatarNewModule.MintInformation;
    public shared ({caller}) func mint_new(
        info : MintInformation
    ) : async Result<TokenIdentifier, Text> {
        assert(_Admins.isAdmin(caller));
        _Monitor.collectMetrics();
        switch(_Ext.mint({ to = #principal(info.user); metadata = null; })){
            case(#err(#Other(e))) return #err(e);
            case(#err(#InvalidToken(e))) return #err(e);
            case(#ok(index)){
                let tokenId = Ext.TokenIdentifier.encode(cid, index);
                switch(_Avatar.createAvatar(info, tokenId)){
                    case(#ok) return #ok(tokenId);
                    case(#err(e)) return #err(e);
                };
            };
        };
    };

    ///////////
    // HTTP //
    //////////

    let _HttpHandler = Http.HttpHandler({
        _Admins = _Admins;
        _Assets = _Assets;
        _Avatar = _Avatar;
    });

    public query func http_request (request : Http.Request) : async Http.Response {
        if(Text.contains(request.url, #text("tokenid"))) {
            let iterator = Text.split(request.url, #text("tokenid="));
            let array = Iter.toArray(iterator);
            let token = array[array.size() - 1];
            switch(_blobs.get(token)){
                case(null) {
                    return(
                        {
                            body = Text.encodeUtf8("Avatar not found");
                            headers = [("Content-Type", "text/html; charset=UTF-8")];
                            streaming_strategy = null;
                            status_code = 200;
                        }
                    );
                };
                case(?blob) {
                    return(
                        {
                            body = blob;
                            headers = [("Content-Type", "image/svg+xml")];
                            streaming_strategy = null;
                            status_code = 200;
                        }
                    );
                };
            };
        }  else {
            _HttpHandler.request(request);
        }  
        
    };


    stable var _ExtUD : ?ExtModule.UpgradeData = null;
    let _Ext = ExtModule.Factory({
        cid = cid; 
        _Logs = _Logs;
        _Avatar = _Avatar;
    });

    public query func extensions() : async [Extension] {
        _Monitor.collectMetrics();
        _Ext.extensions();
    };

    /////////////
    // BACKUP //
    ////////////


    public shared ({caller}) func draw_avatar(tokenId : TokenIdentifier) : async Result<(), Text> {
        assert(_Admins.isAdmin(caller));
        _Avatar.drawAvatar(tokenId);
    };

    public shared ({ caller }) func draw_patch(n : Nat, m : Nat) : async Result<(), Text> {
        assert(_Admins.isAdmin(caller));
        let tokenIds = Iter.toArray(avatars.keys());
        for (i in Iter.range(n,m)) {
            switch(_Avatar.drawAvatar(tokenIds[i])){
                case(#err(e)) return #err(e);
                case(#ok){};
            };
        };
        #ok;
    };

    public shared ({caller}) func get_stats_verification() : async [(Text,Nat)] {
        assert(_Admins.isAdmin(caller));
        var buffer : Buffer.Buffer<(Text,Nat)> = Buffer.Buffer(0);
        let old_registry_size = _registry.size();
        buffer.add("old_registry_size", old_registry_size);
        let new_registry_size = _Ext.getRegistry().size();
        buffer.add("new_registry_size", new_registry_size);
        let old_avatars_size = avatars.size();
        buffer.add("old_avatars_size", old_avatars_size);
        let old_blob_size = _blobs.size();
        buffer.add("old_blob_size", old_blob_size);
        let a = _Avatar.getStats();
        buffer.add("new_avatar_size", a.0);
        buffer.add("new_legendaries", a.1);
        buffer.add("new_blob_size", a.0 + a.1);
        return(buffer.toArray());
    };


};