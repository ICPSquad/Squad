import AID "../dependencies/util/AccountIdentifier";
import Admins "admins";
import Array "mo:base/Array";
import AvatarModule "types/avatar";
import Blob "mo:base/Blob";
import Buffer "mo:base/Buffer";
import ColorModule "types/color";
import CombinationModule "types/combination";
import CAPTypes "mo:cap/Types";
import Cap "mo:cap/Cap";
import Cycles "mo:base/ExperimentalCycles";
import Debug "mo:base/Debug";
import ExtAllowance "../dependencies/ext/Allowance";
import ExtCommon "../dependencies/ext/Common";
import ExtCore "../dependencies/ext/Core";
import Hash "mo:base/Hash";
import HashMap "mo:base/HashMap";
import Http "types/http";
import Iter "mo:base/Iter";
import Int "mo:base/Int";
import Nat "mo:base/Nat";
import Nat32 "mo:base/Nat32";
import Nat8 "mo:base/Nat8";
import Option "mo:base/Option";
import Principal "mo:base/Principal";
import PrincipalImproved "../dependencies/util/Principal";
import Result "mo:base/Result";
import Root "mo:cap/Root";
import Text "mo:base/Text";
import Time "mo:base/Time";
import Utils "../dependencies/helpers/Array";

// Entrepot integration
import Entrepot "../dependencies/entrepot";
//Canister geek
import Canistergeek "mo:canistergeek/canistergeek";


shared (install) actor class erc721_token(upgradeMode : {#verify; #commit}) = this {

    ///////////
    // TYPES //
    ///////////

    public type Time = Time.Time;
    public type Metadata = Entrepot.Metadata;
    public type Listing = Entrepot.Listing;


    ///////////
    // ADMIN //
    ///////////

    let SQUAD_IDENTITY_DFX : Principal = Principal.fromText("dv5tj-vdzwm-iyemu-m6gvp-p4t5y-ec7qa-r2u54-naak4-mkcsf-azfkv-cae");
    stable var stableAdmins : [Principal] = [SQUAD_IDENTITY_DFX];

    let _admins = Admins.Admins({
        admins = stableAdmins;
    });

    public query func is_admin(p : Principal) : async Bool {
        _admins.isAdmin(p);
    };

    public shared ({caller}) func add_admin(p : Principal) : async () {
        _admins.addAdmin(p, caller);
    };

    ///////////////
    // METRICS ///
    /////////////

    stable var _canistergeekMonitorUD: ? Canistergeek.UpgradeData = null;
    private let canistergeekMonitor = Canistergeek.Monitor();

    /**
    * Returns collected data based on passed parameters.
    * Called from browser.
    * @auth : admin
    */
    public query ({caller}) func getCanisterMetrics(parameters: Canistergeek.GetMetricsParameters): async ?Canistergeek.CanisterMetrics {
        assert(_admins.isAdmin(caller));

        canistergeekMonitor.getMetrics(parameters);
    };

    /**
    * Force collecting the data at current time.
    * Called from browser or any canister "update" method.
    * @auth : admin 
    */
    public shared ({caller}) func collectCanisterMetrics(): async () {
        assert(_admins.isAdmin(caller));
        canistergeekMonitor.collectMetrics();
    };

    ////////////
    // LOGS ///
    //////////

    stable var _canistergeekLoggerUD: ? Canistergeek.LoggerUpgradeData = null;
    private let canistergeekLogger = Canistergeek.Logger();

    /**
    * Returns collected log messages based on passed parameters.
    * Called from browser.
    * @auth : admin
    */
    public query ({caller}) func getCanisterLog(request: ?Canistergeek.CanisterLogRequest) : async ?Canistergeek.CanisterLogResponse {
        assert(_admins.isAdmin(caller));
        canistergeekLogger.getLog(request);
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
    
    public shared ({caller}) func addListComponent (list : [(Text,Component)]) : async Result.Result<Text,Text> {
        assert(_admins.isAdmin(caller));
        for (val in list.vals()) {
            components.put(val.0, val.1);
        };
        return #ok ("Components have been added");
    };

    // Might broke if payload is heavier than 2 MB !
    public query ({caller}) func getAllComponents () : async [(Text,Component)] {
        assert(_admins.isAdmin(caller));
        var allComponent : [(Text,Component)] = Iter.toArray(components.entries());
        return allComponent;
    };

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

    public shared ({caller}) func addAccessory (name : Text, accessory : Accessory) : async Result.Result<Text, Text> {
        assert(_admins.isAdmin(caller));
        switch(accessories.get(name)){
            case(?something) {
                accessories.put(name, accessory);
                return #ok("This accessory has been updated : " #name);
            };
            case(null) {
                accessories.put(name, accessory);
                return #ok ("This accessory has been added : " #name);
            };
        };
    };

    public shared ({caller}) func addListAccessory (list : [Accessory]) : async Result.Result<Text,Text> {
        assert(_admins.isAdmin(caller));
        for (accessory in list.vals()){
            let name = accessory.name;
            accessories.put(name, accessory);
        };
        return #ok ("All accessories have been added.");
    };

    public shared query ({caller}) func getAllAccessories () : async [(Text,Accessory)] {
        assert(_admins.isAdmin(caller));
        let list : [(Text,Accessory)] = Iter.toArray(accessories.entries());
        return list;
    };

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
    type AvatarPreview = AvatarModule.AvatarPreview;
    type ComponentRequest = AvatarModule.ComponentRequest;
    type ColorList = ColorModule.ColorList;
    public type MintRequest = {
        to : ExtCore.User;
        metadata : AvatarRequest;
    };

    //Style that will be added to all avatars (to ajust components to the right body)
    stable var style_to_add : Text = "";
    public shared ({caller}) func modify_style (text : Text) : async Text {
        assert(_admins.isAdmin(caller));
        style_to_add := text;
        return (style_to_add);
    };

    //Avatar are regenerated at each upgrade.
    let avatars : HashMap.HashMap<TokenIdentifier, Avatar> = HashMap.HashMap<TokenIdentifier,Avatar>(0 , Text.equal, Text.hash);
    stable var tokenStorage : [TokenIdentifier] = [];
    stable var layerStorage : [[(LayerId,LayerAvatar)]] = [];
    stable var styleStorage : [Text] = [];
    stable var slotsStorage : [Slots] = [];

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

        public func isLayer (id : LayerId) : Bool {
            return(Option.isSome(layers.get(id)));
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

        public func getRawSvg (): Text {
            svg;
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

        //  Return a list of all layers that are populated associated with their layer object (see Avatar.mo).
        public func getLayers () : [(LayerId,LayerAvatar)] {
            return Iter.toArray(layers.entries());
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

        public func addToSlot (accessory : Accessory) : Result.Result<(), Text> {
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

        public func removeFromSlot (slot_name : Text) : Result.Result<(), Text> {
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
         
    public shared ({caller}) func mint (request : MintRequest) : async Result.Result<AvatarInformations,Text> {
        assert(caller == Principal.fromText("p4y2d-yyaaa-aaaaj-qaixa-cai")); 
        // Create the avatar and returns it (see _createAvatar)
        switch(_createAvatar(request.metadata)){
            case(#err(message)) return #err(message);
            case(#ok(avatar)) {

                // Create the nft for the receiver.
                let receiver = ExtCore.User.toAID(request.to);
                let token = _nextTokenId;
                _registry.put(token, receiver);

                // Generate the next TokenIdentifier from the internal TokenId then associate the Avatar with this TokenIdentifier.
                let token_identifier : TokenIdentifier = _getTokenIdentifier(_nextTokenId);
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

    public shared ({caller}) func wearAccessory (token_avatar : TokenIdentifier, name : Text, principal_caller : Principal) : async Result.Result<(), Text> {
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


    public shared ({caller}) func removeAccessory (token_avatar : TokenIdentifier, name : Text, principal_caller : Principal) : async Result.Result<(), Text> {
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


    public shared ({caller}) func burn(token_identifier : TokenIdentifier) : async () {
        assert(_admins.isAdmin(caller));
        _blobs.delete(token_identifier);
        avatars.delete(token_identifier);
        let index = ExtCore.TokenIdentifier.getIndex(token_identifier);
        _registry.delete(index);
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
  
    public shared ({caller}) func draw(token : TokenIdentifier) : async Result.Result<(), Text> {
        assert(_admins.isAdmin(caller));
        switch(avatars.get(token)) {
            case (null) return #err ("Avatar not found");
            case (?avatar) {
                ignore(_draw(token));
                return #ok;
            };
        };
    };

    public query func showFullSvg (token_identifier : TokenIdentifier) : async ?Text {
          switch(avatars.get(token_identifier)){
            case(null) return null;
            case(?avatar) {
                return ?avatar.getFullSvg();
            };
        };
    };

    public shared query (msg) func getAvatarInfos () : async Result.Result<AvatarPreview, Text> {
        switch(_myTokenIdentifier(msg.caller)){
            case (null) return #err ("You dont own any avatar.");
            case (?token) {
                switch(avatars.get(token)){
                    case(null) return #err ("There is no avatar associated for this tokenIdentifier (strange) " # token);
                    case(?avatar) { 
                        avatar.buildSvg();
                        let preview : AvatarPreview = {
                            token_identifier = token;
                            avatar_svg = avatar.getFullSvg();
                            slots = avatar.getSlots();
                        };
                        return #ok(preview);
                    };
                };
            };
        };
    };

    type AvatarPreviewNew = {
        token_identifier : TokenIdentifier;
        layers : [(LayerId, Text)];
        style : Text;
        slots : Slots;
        body_name : Text;
    };

    //  Used to get all the informations to construct the room on the frontend where users can equip accessories. If caller owns an avatar, returns it's token identifier/layersText/style/slots/body-type.
    public shared query ({caller}) func getAvatarInfos_new() : async Result.Result<AvatarPreviewNew, Text> {
        switch(_myTokenIdentifier(caller)){
            case(null) return #err("You don't own any avatar.");
            case(?token){
                switch(avatars.get(token)){
                    case(null) return #err ("There is no avatar associated for this tokenIdentifier (strange) " # token);
                    case(?avatar) { 
                        return #ok({token_identifier = token; layers = avatar.getLayersText(); style = avatar.getRawStyle(); slots = avatar.getSlots(); body_name = avatar.getNameBody()});
                    };
                };
            };
        };
    };

  
    ////////////////////
    // Avatar private //
    ///////////////////

    private func _createAvatar (request : AvatarRequest) :  Result.Result<Avatar,Text> {
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

    private func _draw (token : TokenIdentifier) : Result.Result<(), Text> {
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

    private func _accessoryVerification (token_avatar: TokenIdentifier, name : Text, principal_caller : Principal) : Result.Result<(), Text> {
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

 
    ///////////////////////////////////
    // TOKEN ID <-> TOKEN IDENTIFIER //
    //////////////////////////////////
    //TODO : Can be cleaned and moduled

    // Get TokenIdentifier from TokenIndex by assemblid 'tid' + Principal(canister) + Nat32(TokenIndex) 
    private func _getTokenIdentifier (nat : TokenIndex) : Text {
        let padding : [Nat8] = [10, 116, 105, 100];
        let principalBlob : [Nat8] = Blob.toArray(Principal.toBlob(Principal.fromActor(this)));
        let index : [Nat8] = nat32tobytes(nat);
        var array : [Nat8] = Array.append<Nat8>(padding, principalBlob);
        array := Array.append<Nat8>(array, index);
        let p : Principal = _fromBlob(Blob.fromArray(array));
        let text : Text = Principal.toText(p);
        return text;
    };

    // Converts a Nat32 to a [Nat8] of size 4 containing the 4 bytes
    private func nat32tobytes(n : Nat32) : [Nat8] {
      if (n < 256) {
        return [0,0,0, Nat8.fromNat(Nat32.toNat(n))];
      } else if (n < 65536) {
        return [
          0,
          0,
          Nat8.fromNat(Nat32.toNat((n >> 8) & 0xFF)), 
          Nat8.fromNat(Nat32.toNat((n) & 0xFF))
        ];
      } else if (n < 16777216) {
        return [
          0,
          Nat8.fromNat(Nat32.toNat((n >> 16) & 0xFF)), 
          Nat8.fromNat(Nat32.toNat((n >> 8) & 0xFF)), 
          Nat8.fromNat(Nat32.toNat((n) & 0xFF))
        ];
      } else {
        return [
          Nat8.fromNat(Nat32.toNat((n >> 24) & 0xFF)), 
          Nat8.fromNat(Nat32.toNat((n >> 16) & 0xFF)), 
          Nat8.fromNat(Nat32.toNat((n >> 8) & 0xFF)), 
          Nat8.fromNat(Nat32.toNat((n) & 0xFF))
        ];
      };
    };

    //////////////////////////////////////
    // ACCOUNT IDENTIFIER <-> PRINCIPAL //
    /////////////////////////////////////

    private stable var _principalToAccountsIdentifierState : [(Principal,[AccountIdentifier])] = [];
    private var _principalToAccountsIdentifier : HashMap.HashMap<Principal, [AccountIdentifier]> = HashMap.fromIter(_principalToAccountsIdentifierState.vals(), 0 , Principal.equal, Principal.hash);
    
    //////////////
    // Private //
    /////////////

    private func _isPrincipalKnown(p : Principal) : Bool {
        switch(_principalToAccountsIdentifier.get(p)){
            case (null) return false;
            case(?accounts){
                return true
            };
        };
    };

    private func _myTokenIdentifier (p : Principal) : ?TokenIdentifier {
        // Creates and stores the 10 first subaccounts if it's the first time this principal is calling.
        if(not (_isPrincipalKnown(p))) {
            let accounts : [AccountIdentifier] = _generateAccounts(p);
            _principalToAccountsIdentifier.put(p, accounts);
        };

        let tokens : [TokenIdentifier] = _generateTokens(p);
        if (tokens.size() == 0) {
            return null;
        } else {
            return ?tokens[0];
        }
    };

    private func _isOwner (p : Principal , token_identifier : TokenIdentifier) : Bool {
        if(not (_isPrincipalKnown(p))){
            let accounts : [TokenIdentifier] = _generateAccounts(p);
            _principalToAccountsIdentifier.put(p, accounts);
        };

        let tokens : [TokenIdentifier] = _generateTokens(p);

        if(Utils.contains<TokenIdentifier>(tokens, token_identifier, Text.equal)){
            return true;
        } else {
            return false;
        };
    };
    
    // Creates a Principal from a Blob : extension of the base Module
    private func _fromBlob(b : Blob) : Principal {
        return(PrincipalImproved.fromBlob(b));
    };
    
    // Only valid for the first 256 subaccount (more than enough)
    private func _nat8ToSubaccount (n : Nat8) : [Nat8] {
        var subaccount : [Nat8] = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,n];
        return subaccount;
    };

    // Generate the 10 first subaccounts for a principal 
    private func _generateAccounts (p : Principal) :  [AccountIdentifier] {
        var accounts = Buffer.Buffer<AccountIdentifier>(0);
        let iterator = Iter.range(0,10);
        for (i in iterator) {
            if(i == 0) {
                let new_account = AID.fromPrincipal(p, null);
                accounts.add(new_account);
            } else {
                let new_account = AID.fromPrincipal(p, ?_nat8ToSubaccount(Nat8.fromNat(i)));
                accounts.add(new_account);
            };
        };
        let array = accounts.toArray();
        return array;
    };

    // This function must be run after the previous one has generated the list of subaccounts for the principal
    private func _generateTokens (p : Principal) : [TokenIdentifier] {
        var tokens = Buffer.Buffer<TokenIdentifier>(0);
        switch(_principalToAccountsIdentifier.get(p)){
            case(null) return [];
            case(?accounts) {
                for((index,account) in _registry.entries()){
                    if(Utils.contains<AccountIdentifier>(accounts, account, Text.equal)) {
                        let identifier = _getTokenIdentifier(index);
                        tokens.add(identifier);
                    };
                };
            let array = tokens.toArray();
            return array;
            };
        };
    };


    ///////////
    // HTTP //
    //////////

    public query func http_request (request : Http.HttpRequest) : async Http.HttpResponse {
        let iterator = Text.split(request.url, #text("tokenid="));
        let array = Iter.toArray(iterator);
        let token = array[array.size() - 1];
        switch(_blobs.get(token)){
            case(null) {
                {
                    body = Blob.toArray(Text.encodeUtf8("Not found"));
                    headers = [("Content-Type", "text/html; charset=UTF-8")];
                    streaming_strategy = null;
                    status_code = 200;
                }
            };
            case(?blob) {
                {
                    body = Blob.toArray(blob);
                    headers = [("Content-Type", "image/svg+xml")];
                    streaming_strategy = null;
                    status_code = 200;
                };
            };
        };
    };


    ///////////////
    // LEGENDARY //
    //////////////

    stable var legendaryEntries : [(Text, Text)] = [];
    let legendaries : HashMap.HashMap<Text,Text> = HashMap.fromIter(legendaryEntries.vals(), 0, Text.equal, Text.hash);

    // Add an asset for a legendary avatar, each asset is a svg file stored as string and is identified a unique name.
    // @auth : admin
    public shared ({caller}) func addLegendary (name : Text, asset : Text) : async Result.Result<Text, Text> {
        assert(_admins.isAdmin(caller));
        switch(legendaries.get(name)){
            case(?avatar){
                return #err("An avatar already exists for : " # name);
            };
            case(null){
                legendaries.put(name,asset);
                return #ok("An avatar has been added for legendary : " # name);
            };
        };
    };

    //Mint a legendary avatar for a specified wallet 
    // @auth : admin
    public shared ({caller}) func mintLegendary (name : Text, address_receiver : AccountIdentifier) : async Result.Result <Text, Text> {
        assert(_admins.isAdmin(caller));
        switch(legendaries.get(name)){
            case(null) return #err ("No legendary avatar found for name : " # name);
            case(?avatar) {
                let token = _nextTokenId;
                _registry.put(token, address_receiver);

                let token_identifier : TokenIdentifier = _getTokenIdentifier(_nextTokenId);
                
                _blobs.put(token_identifier, Text.encodeUtf8(avatar));

                _supply := _supply + 1;
                _nextTokenId := _nextTokenId + 1;
                
                let event : IndefiniteEvent = {
                    operation = "mint";
                    details = [("token", #Text(token_identifier)), ("name", #Text(name)), ("to", #Text(address_receiver))];
                    caller = caller;
                };
                ignore(_registerEvent(event));

                return #ok ("Legendary avatar : " # name # " minted with token identifier : " #token_identifier);
            };
        };
    };




  



    //////////////////
    // EXT - ERC721 //
    /////////////////

    type AccountIdentifier = ExtCore.AccountIdentifier;
    type SubAccount = ExtCore.SubAccount;
    type User = ExtCore.User;
    type Balance = ExtCore.Balance;
    type TokenIdentifier = ExtCore.TokenIdentifier;
    type TokenIndex  = ExtCore.TokenIndex ;
    type Extension = ExtCore.Extension;
    type CommonError = ExtCore.CommonError;
    type BalanceRequest = ExtCore.BalanceRequest;
    type BalanceResponse = ExtCore.BalanceResponse;
    type TransferRequest = ExtCore.TransferRequest;
    type TransferResponse = ExtCore.TransferResponse;
    type AllowanceRequest = ExtAllowance.AllowanceRequest;
    type ApproveRequest = ExtAllowance.ApproveRequest;
    

    private let EXTENSIONS : [Extension] = [];
    private stable var _supply : Balance  = 0;
    private stable var _minter : [Principal]  = [];
    private stable var _nextTokenId : TokenIndex  = 0;

     
    private stable var _registryState : [(TokenIndex, AccountIdentifier)] = [];
    private var _registry : HashMap.HashMap<TokenIndex, AccountIdentifier> = HashMap.fromIter(_registryState.vals(), 0, ExtCore.TokenIndex.equal, ExtCore.TokenIndex.hash);

        
    public shared(msg) func transfer(request: TransferRequest) : async TransferResponse {
        if (request.amount != 1) {
                return #err(#Other("Must use amount of 1"));
        };
        if (ExtCore.TokenIdentifier.isPrincipal(request.token, Principal.fromActor(this)) == false) {
            return #err(#InvalidToken(request.token));
        };

        let token = ExtCore.TokenIdentifier.getIndex(request.token);
        let owner = ExtCore.User.toAID(request.from);
        let spender = AID.fromPrincipal(msg.caller, request.subaccount);
        let receiver = ExtCore.User.toAID(request.to);
            
        switch (_registry.get(token)) {
            case (?token_owner) {
                        if(AID.equal(owner, token_owner) == false) {
                            return #err(#Unauthorized(owner));
                        };
                        if (AID.equal(owner, spender) == false) {
                                return #err(#Unauthorized(spender));
                        };
                        _registry.put(token, receiver);
                        //  Report event to CAP
                        let event : IndefiniteEvent = {
                            operation = "transfer";
                            details = [("token", #Text(request.token)), ("from", #Text(token_owner)), ("to", #Text(receiver))];
                            caller = msg.caller;
                        };
                        ignore(_registerEvent(event));
                        return #ok(request.amount);
            };
            case (_) {
                return #err(#InvalidToken(request.token));
            };
        };
    };


    ////////////////
    // Ext-query //
    //////////////

    public query func getMinter() : async [Principal] {
        _minter;
    };

    public query func getRegistry() : async [(TokenIndex, AccountIdentifier)] {
        Iter.toArray(_registry.entries());
    };

    public query func getTokens() : async [(TokenIndex, Metadata)]{
        var buffer = Buffer.Buffer<(TokenIndex,Metadata)>(0);
        for (token_index in _registry.keys()){
            let token_identifier = _getTokenIdentifier(token_index);
            let element = (token_index, #nonfungible{metadata =_blobs.get(token_identifier)});
            buffer.add(element);
        };
        buffer.toArray();
    };
    
    public query func supply(token : TokenIdentifier) : async Result.Result<Balance,CommonError> {
        #ok(_supply);
    };

    public query func extensions() : async [Extension] {
        EXTENSIONS;
    };
      
    public query func metadata(token : TokenIdentifier): async Result.Result<ExtCommon.Metadata, ExtCore.CommonError> {
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

    //  Method used by Entrepot to query the tokens of an account.
    public query func tokens(aid : AccountIdentifier) : async Result.Result<[TokenIndex], CommonError> {
        var buffer = Buffer.Buffer<(TokenIndex)>(0);
        for((token_index, account) in _registry.entries()){
            if (Text.equal(account, aid)){
                buffer.add(token_index);
            };
        };
        if(buffer.size() == 0){
            return #err(#Other("No tokens"));
        } else {
            return #ok(buffer.toArray());
        };
    };


    public shared query (msg) func tokens_ext (account : AccountIdentifier) : async Result.Result<[(TokenIndex, ?Listing, ?Blob)], CommonError> {
        let tokens = _generateTokensExt(account);
        if (tokens.size() == 0) {
            return #err(#Other ("No token detected for this user."));
        } else {
            let answer = #ok(tokens);
            return answer;
        }
    };

    
    private func _generateTokensExt (a : AccountIdentifier) : [(TokenIndex, ?Listing, ?Blob)] {
        var tokens = Buffer.Buffer<(TokenIndex, ?Listing, ?Blob)>(0);
        for ((token_index,account) in _registry.entries()){
            if(a == account) {
                let token_identifier = _getTokenIdentifier(token_index);
                let new_element = (token_index, null, _blobs.get(token_identifier));
                tokens.add(new_element);
            };
        };
        let array = tokens.toArray();
        return array;
    };

    public query func balance(request : BalanceRequest) : async BalanceResponse {
            if (ExtCore.TokenIdentifier.isPrincipal(request.token, Principal.fromActor(this)) == false) {
                return #err(#InvalidToken(request.token));
            };
            let token = ExtCore.TokenIdentifier.getIndex(request.token);
            let aid = ExtCore.User.toAID(request.user);
            switch (_registry.get(token)) {
            case (?token_owner) {
                        if (AID.equal(aid, token_owner) == true) {
                            return #ok(1);
                        } else {					
                            return #ok(0);
                        };
            };
            case (_) {
                return #err(#InvalidToken(request.token));
            };
        };
    };
    
    public query func bearer(token : TokenIdentifier) : async Result.Result<AccountIdentifier, CommonError> {
        if (ExtCore.TokenIdentifier.isPrincipal(token, Principal.fromActor(this)) == false) {
            return #err(#InvalidToken(token));
        };
        let tokenind = ExtCore.TokenIdentifier.getIndex(token);
        switch (_registry.get(tokenind)) {
            case (?token_owner) {
                        return #ok(token_owner);
            };
            case (_) {
                return #err(#InvalidToken(token));
            };
        };
    };

    public query func tokenIdentifier (tindex : TokenIndex) : async TokenIdentifier {
        let token_identifier = _getTokenIdentifier(tindex);
        return token_identifier;
    };

    public query func details(token : TokenIdentifier) : async Result.Result<(AccountIdentifier, ?Listing), CommonError> {
		if (ExtCore.TokenIdentifier.isPrincipal(token, Principal.fromActor(this)) == false) {
			return #err(#InvalidToken(token));
		};
		let tokenind = ExtCore.TokenIdentifier.getIndex(token);
        switch (_getBearer(tokenind)) {
            case (?token_owner) {
                        return #ok((token_owner, null));
            };
            case (_) {
                return #err(#InvalidToken(token));
            };
        };
	};

    private func _getBearer(token : TokenIndex) : ?AccountIdentifier {
        _registry.get(token);
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
    public shared ({caller}) func init_cap() : async Result.Result<(), Text> {
        assert(_admins.isAdmin(caller));
        let tokenContractId = Principal.toText(Principal.fromActor(this));
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
        assert(caller == Principal.fromActor(this));
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
        assert(_admins.isAdmin(caller));
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

    stable var version = 1;

    // Returns size of data strucutres as a simple way to check state of the canister after upgrade.
    private func read() : (Nat, Nat, Nat, Nat) {
        (version, _registry.size(), avatars.size(), _blobs.size());
    };

    system func preupgrade() {
        _canistergeekMonitorUD := ? canistergeekMonitor.preupgrade();
        _canistergeekLoggerUD := ? canistergeekLogger.preupgrade();

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
        legendaryEntries := Iter.toArray(legendaries.entries());

        //  NFT 
        _principalToAccountsIdentifierState := Iter.toArray(_principalToAccountsIdentifier.entries());
        _registryState := Iter.toArray(_registry.entries());
        _blobsEntries := Iter.toArray(_blobs.entries());
        //  CAP
        _eventsEntries := Iter.toArray(_events.entries());

    };

    system func postupgrade() {

        canistergeekMonitor.postupgrade(_canistergeekMonitorUD);
        _canistergeekMonitorUD := null;

        canistergeekLogger.postupgrade(_canistergeekLoggerUD);
        _canistergeekLoggerUD := null;

        let iterator = Iter.range(0, layerStorage.size() - 1);
        for (i in iterator) {
            let layersEntries : [(LayerId, LayerAvatar)] = layerStorage[i];
            let style : Text = styleStorage[i];
            let tokenIdentifier : TokenIdentifier = tokenStorage[i];
            let slots : Slots = slotsStorage[i];
            let avatar : Avatar = Avatar(layersEntries, style, slots);
            avatars.put(tokenIdentifier, avatar);
        };

        if (upgradeMode == #verify){
            Debug.trap(debug_show(#verify(read())));
        };

        componentsEntries := [];
        accessoriesEntries := [];
        legendaryEntries := [];
        _registryState := [];
        _principalToAccountsIdentifierState := [];
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
    
};