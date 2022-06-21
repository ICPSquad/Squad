import Array "mo:base/Array";
import Blob "mo:base/Blob";
import Buffer "mo:base/Buffer";
import HashMap "mo:base/HashMap";
import Iter "mo:base/Iter";
import Nat "mo:base/Nat";
import Option "mo:base/Option";
import Prim "mo:prim";
import Result "mo:base/Result";
import Text "mo:base/Text";
import TrieMap "mo:base/TrieMap";

import Ext "mo:ext/Ext";

import Assets "../assets";
import Colors "../utils/color";
import SVG "../utils/svg";
import Types "types";
module {

    ////////////
    // Types //
    //////////
    
    public type UpgradeData = Types.UpgradeData;
    public type Component = Types.Component;
    public type Avatar = Types.Avatar;
    public type AvatarRendering = Types.AvatarRendering;
    public type MintInformation = Types.MintInformation;
    public type Style = Types.Style;
    public type Colors = Types.Colors;

    public class Factory(dependencies : Types.Dependencies) : Types.Interface {

        ////////////
        // State //
        ///////////

        public type Result<A,B> = Result.Result<A,B>;
        public type Slots = Types.Slots;
        public type Level = Types.Level;
        public type Layers = Types.Layers;
        public type Colors = Types.Colors;
        public type Avatar = Types.Avatar;
        public type LayerId = Types.LayerId;
        public type TokenIdentifier = Ext.TokenIdentifier;
    
        private let _avatars : TrieMap.TrieMap<TokenIdentifier,Avatar> = TrieMap.TrieMap<TokenIdentifier,Avatar>(Text.equal, Text.hash);
        private let _components : TrieMap.TrieMap<Text, Component> = TrieMap.TrieMap<Text,Component>(Text.equal, Text.hash);

        private var css_style : Text = "";

        public func preupgrade() : UpgradeData {
            return({
                avatars = Iter.toArray(_avatars.entries());
                components = Iter.toArray(_components.entries());
                style = css_style;
            })
        };

        public func postupgrade(ud : ?UpgradeData) : () {
            switch(ud){
                case(? ud){
                    for((tokenId, avatar) in ud.avatars.vals()){
                        _avatars.put(tokenId, avatar);
                    };
                    for ((name, component) in ud.components.vals()){
                        _components.put(name, component);
                    };
                    css_style := ud.style;
                };
                case _ {};
            };
        };


        let _Assets = dependencies._Assets;
        let _Admins = dependencies._Admins;
        let _Logs = dependencies._Logs;

        ////////////
        // API ////
        ///////////


        public func addComponent(
            name : Text,
            component : Component 
        ) : Result.Result<(), Text> {
            _components.put(name, component);
            #ok;
        };

        public func deleteComponent(
            name : Text
        ) : Result.Result<(), Text> {
            switch(_components.get(name)){
                case(null){
                    return #err("Component not found");
                };
                case(? component){
                    _components.delete(name);
                    return #ok;
                };
            };
        };

        public func getComponents() : [(Text, Component)] {
            return Iter.toArray(_components.entries());
        };

        public func changeCSS(style : Text) : () {
            css_style := style;
        };

        public func createAvatar(
            info : MintInformation,
            tokenId : TokenIdentifier,
        ) : Result<(), Text> {
            switch(_avatars.get(tokenId)){
                case(? avatar) return #err("There is already an avatar for this tokenIdentifier");
                case(null){
                    let avatar = _createAvatar(info);
                    _avatars.put(tokenId, avatar);
                    return #ok;
                };
            };
        };

        public func createLegendary(
            name : Text,
            tokenId : TokenIdentifier
        ) : Result<(), Text> {
            switch(_avatars.get(tokenId)){
                case(? avatar) return #err("There is already an avatar for this tokenIdentifier");
                case(null){
                    switch(_createLegendary(name)){
                        case(#err(e)){
                            _Logs.logMessage("Avatar/lib/createLegendary/117. " # e );
                            return #err(e);
                        };
                        case(#ok(avatar)){
                            _avatars.put(tokenId, avatar);
                            return #ok;
                        };
                    };
                };
            };
        };
        // Wear an accessory by name on the specified avatar & redraw this avatar.
        // @dev : Verify that the avatar exists, the component exists & the slot is empty.
        // @note : Accessing the slot shouldn't require using the _Assets module.
        public func wearAccessory(
            tokenId : TokenIdentifier,
            name_accessory : Text,
        ) : Result<(), Text> {
            switch(_avatars.get(tokenId)){
                case(null) return #err("No avatar for this tokenIdentifier : " # tokenId);
                case(? avatar) {
                    switch(_components.get(name_accessory)){
                        case(null) {
                            _Logs.logMessage("Avatar/wearAccessory/140." # " Component : " # name_accessory # " does not exist");
                            return #err("No component named : " # name_accessory);
                        };
                        case(? component){
                            switch(component.category){
                                case(#Accessory) {
                                    let filePath = component.name # "-" # Nat.toText(component.layers[0]);
                                    switch(_Assets.getFile(filePath)){
                                        case(null) {
                                            _Logs.logMessage("Avatar/wearAccessory/149." # " File : " # filePath # " does not exist");
                                            return #err("No file named : " # filePath);
                                        };
                                        case(? file){
                                            let slot = file.meta.tags[0];
                                            let slots = avatar.slots;
                                            switch(_verifySlot(file.meta.tags[0], avatar.slots)){
                                                case(#err(e)) {
                                                    _Logs.logMessage("Avatar/wearAccessory/157." # " " # e);
                                                    return #err(e);
                                                };
                                                case(#ok){
                                                    _avatars.put(tokenId, _wearAccessory(avatar, name_accessory, slot));
                                                    switch(_drawAvatar(tokenId)){
                                                        case(#err(e)) {
                                                            _Logs.logMessage("Avatar/wearAccessory/164." # " " # e);
                                                            return #err(e);
                                                        };
                                                        case(#ok){
                                                            return #ok;
                                                        };
                                                    };
                                                };
                                            };
                                        };
                                    };
                                };
                                case _  {
                                    _Logs.logMessage("Avatar/wearAccessory/177." # " Component : " # name_accessory # " is not an accessory");
                                    return #err("Component : " # name_accessory # " is not an accessory");
                                };
                            };
                        };
                    };
                };
            };
        };

        // Remove an accessory by name for the specified avatar & redraw this avatar.
        // @dev : Verify that the avatar.
        public func removeAccessory(
            tokenId : TokenIdentifier,
            name_accessory : Text,
        ) : Result<(), Text> {
            switch(_avatars.get(tokenId)){
                case(null) return #err("No avatar for this tokenIdentifier : " # tokenId);
                case(? avatar) {
                    switch(_components.get(name_accessory)){
                        case(null) {
                            _Logs.logMessage("Avatar/removeAcessory/198." # " Component : " # name_accessory # " does not exist");
                            return #err("No component named : " # name_accessory);
                        };
                        case (? component) {
                            switch(component.category){
                                case(#Accessory){
                                    let filePath = component.name # "-" # Nat.toText(component.layers[0]);
                                    switch(_Assets.getFile(filePath)){
                                        case(null) {
                                            _Logs.logMessage("Avatar/removeAccesssory/207." # " File : " # filePath # " does not exist");
                                            return #err("No file named : " # filePath);
                                        };
                                        case(? file){
                                            let slot = file.meta.tags[0];
                                            let slots = avatar.slots;
                                            switch(_getSlot(slot,slots)){
                                                case(null){
                                                    _Logs.logMessage("Avatar/removeAccesssory/215." # " Slot : " # slot # " is empty");
                                                    return #err("No accessory in slot " # slot);
                                                };
                                                case(?equipped){
                                                    if(equipped == name_accessory){
                                                        _avatars.put(tokenId, _modifyAvatarSlots(avatar, _newSlots(null, slot, slots)));
                                                        switch(_drawAvatar(tokenId)){
                                                            case(#err(e)) {
                                                                _Logs.logMessage("Avatar/removeAccesssory/223." # " " # e);
                                                                return #err(e);
                                                            };
                                                            case(#ok){
                                                                return #ok;
                                                            };
                                                        };
                                                    } else {
                                                        _Logs.logMessage("Avatar/removeAccesssory/231." # " Trying to desequip : " # name_accessory # " when " # equipped # " is equipped");
                                                        return #err("Trying to desequip : " # name_accessory # " when " # equipped # " is equipped");
                                                    };
                                                };
                                            };
                                        };
                                    };
                                };
                                case _ {
                                    _Logs.logMessage("Avatar/removeAccessory/240" # " Component : " # name_accessory # " is not an accessory");
                                    return #err("Component : " # name_accessory # " is not an accessory");
                                }
                            }
                        };
                    };
                };
            };
        };

        public func drawAvatar(
            tokenId : TokenIdentifier,
        ) : Result<(), Text> {
            switch(_avatars.get(tokenId)){
                case(? avatar) {
                    let blob = _createBlob(avatar);
                    _avatars.put(tokenId, {
                        background = avatar.background;
                        profile = avatar.profile;
                        ears = avatar.ears;
                        mouth = avatar.mouth;
                        eyes = avatar.eyes;
                        nose = avatar.nose;
                        hair = avatar.hair;
                        cloth = avatar.cloth;
                        style = avatar.style;
                        slots = avatar.slots;
                        level = avatar.level;
                        blob = _createBlob(avatar);
                    });
                    return #ok;
                };
                case(null) return #err("No avatar for this tokenIdentifier : " # tokenId);
            };
        };

        /* 
            This function returns the optional blob associated with a tokenIdentifier.
            Normal avatar : Generated blob 'on-the-fly' with the _createBlob method.
            Legendaries : Blob stored as a field in the avatar directly.
        */
        public func getBlob(
            tokenId : TokenIdentifier,
        ) : ?Blob {
            switch(_avatars.get(tokenId)){
                case(? avatar) {
                    switch(avatar.level){
                        case(#Legendary) {
                            return ?avatar.blob;
                        };
                        case(_){
                            return ?_createBlob(avatar);
                        }
                    }
                };
                case(null) return null;
            };
        };

        public func getAvatar(tokenId : TokenIdentifier) : ?Avatar {
            return _avatars.get(tokenId);
        };

        public func getAvatarRendering(tokenId : TokenIdentifier) : ?AvatarRendering {
            switch(_avatars.get(tokenId)){
                case(? avatar) {
                    return ?_createAvatarRendering(avatar);
                };
                case(null) return null;
            };
        };

        public func getStats() : (Nat,Nat) {
            let nb = _numberLegendaries();
            (_avatars.size() - nb,nb);
        };

        public func getSlot(tokenId : TokenIdentifier) : ?Slots {
            switch(_avatars.get(tokenId)){
                case(? avatar) {
                    return ?avatar.slots;
                };
                case(null) return null;
            };
        };

        public func isEquipped(tokenId : TokenIdentifier) : Bool {
            switch(getSlot(tokenId)){
                case(? slots) { 
                    return(_isSlotEquipped(slots));
                };
                case(null) return false;
            };
        };

        public func burn(tokenId : TokenIdentifier) : () {
            _avatars.delete(tokenId);
        };

        /* Used once as a cleanup to save memory. We don't need to store the blob as we can create it on the fly (expect for legendaries) */
        public func cleanBlob() : () {
            for((tokenId, avatar) in _avatars.entries()){
                switch(avatar.level){
                    case(#Legendary){};
                    case _ {
                        _avatars.put(tokenId, {
                            background = avatar.background;
                            profile = avatar.profile;
                            ears = avatar.ears;
                            mouth = avatar.mouth;
                            eyes = avatar.eyes;
                            nose = avatar.nose;
                            hair = avatar.hair;
                            cloth = avatar.cloth;
                            style = avatar.style;
                            slots = avatar.slots;
                            level = avatar.level;
                            blob = Blob.fromArray([0]);
                        });
                    }
                }
            };
        };

        //////////////////
        // UTILITIES ////
        /////////////////

        func _createNewSlot() : Slots {
            {
                Hat = null;
                Eyes = null;
                Misc = null;
                Body = null;
                Face = null;
            }
        };

        func _getLevel() : Level {
            if(_avatars.size() < 5000){
                return(#Level3);
            };
            if(_avatars.size() < 10000){
                return(#Level2);
            };
            return(#Level1);
        };

        func _numberLegendaries() : Nat {
            var nb = 0;
            for(avatar in _avatars.vals()){
                if(avatar.level == #Legendary){
                    nb += 1;
                };
            };
            nb
        };

        func _orderLayers (layers : Layers) : Layers {
            Array.sort<(LayerId, Text)>(layers, func (a,b) {Nat.compare(a.0, b.0)});
        };

        func _createLayers (avatar : Avatar) : Layers {
            var buffer : Buffer.Buffer<(LayerId, Text)> = Buffer.Buffer(0);
            let layers_background : [Nat] = switch(_components.get(avatar.background)){
                case(? component) component.layers;
                case(null) [];
            };
            let layers_profile = switch(_components.get(avatar.profile)){
                case(? component) component.layers;
                case(null) [];
            };
            let layers_ears = switch(_components.get(avatar.ears)){
                case(? component) component.layers;
                case(null) [];
            };
            let layers_mouth = switch(_components.get(avatar.mouth)){
                case(? component)  component.layers;
                case(null) [];
            };
            let layers_eyes = switch(_components.get(avatar.eyes)){
                case(? component)  component.layers;
                case(null) [];
            };
            let layers_nose = switch(_components.get(avatar.nose)){
                case(? component)  component.layers;
                case(null) []
            };
            let layers_hair = switch(_components.get(avatar.hair)){
                case(? component)  component.layers;
                case(null) [];
            };
            let layers_cloth = switch(_components.get(avatar.cloth)){
                case(? component) component.layers;
                case(null) [];
            };
            for(layer in layers_profile.vals()){
                buffer.add((layer, avatar.profile));
            };
            for(layer in layers_ears.vals()){
                buffer.add((layer, avatar.ears));
            };
            for(layer in layers_mouth.vals()){
                buffer.add((layer, avatar.mouth));
            };
            for(layer in layers_eyes.vals()){
                buffer.add((layer, avatar.eyes));
            };
            for(layer in layers_nose.vals()){
                buffer.add((layer, avatar.nose));
            };
            for(layer in layers_hair.vals()){
                buffer.add((layer, avatar.hair));
            };
            for(layer in layers_background.vals()){
                buffer.add((layer, avatar.background));
            };
            for(layer in layers_cloth.vals()){
                buffer.add((layer, avatar.cloth));
            };
            for(layer in _getLayersAccessories(avatar).vals()){
                buffer.add(layer);
            };
            buffer.toArray();
        };

        func _getLayersAccessories(avatar : Avatar) : Layers {
            var buffer : Buffer.Buffer<(LayerId, Text)> = Buffer.Buffer(0);
            switch(avatar.slots.Hat) {
                case(null) {};
                case(? hat){
                    let name = Text.map(hat, Prim.charToLower); 
                    switch(_components.get(name)){
                        case(? component) {
                            for(layer in component.layers.vals()){
                                buffer.add((layer, name));
                            };
                        };
                        case(null) {};
                    };
                };
            };
            switch(avatar.slots.Eyes) {
                case(null) {};
                case(? eyes){
                    let name = Text.map(eyes, Prim.charToLower); 
                    switch(_components.get(name)){
                        case(? component) {
                            for(layer in component.layers.vals()){
                                buffer.add((layer, name));
                            };
                        };
                        case(null) {};
                    };
                };
            };
            switch(avatar.slots.Misc) {
                case(null) {};
                case(? misc){
                    let name = Text.map(misc, Prim.charToLower); 
                    switch(_components.get(name)){
                        case(? component) {
                            for(layer in component.layers.vals()){
                                buffer.add((layer, name));
                            };
                        };
                        case(null) {};
                    };
                };
            };
            switch(avatar.slots.Body) {
                case(null) {};
                case(? body){
                    let name = Text.map(body, Prim.charToLower); 
                    switch(_components.get(name)){
                        case(? component) {
                            for(layer in component.layers.vals()){
                                buffer.add((layer, name));
                            };
                        };
                        case(null) {};
                    };
                };
            };
               switch(avatar.slots.Face) {
                case(null) {};
                case(? face){
                    let name = Text.map(face, Prim.charToLower); 
                    switch(_components.get(name)){
                        case(? component) {
                            for(layer in component.layers.vals()){
                                buffer.add((layer, name));
                            };
                        };
                        case(null) {};
                    };
                };
            };
            return(buffer.toArray());
        };

        /* 
            This function is used to dynamicall add <style> to the avatar depending on the accessory that are equipped 
            See RenderAvatar.svelte for inspiration
        */
        func _getStyleOptionalAccessory(avatar : Avatar) : Text {
            var style : Text = "<style>";
            // List of hats that need to change the hairstyle
            let hats_hairstyle = ["helicap", "marshall-hat", "mortaboard-hat", "shinobi-hat"];
            let potential_hat = Option.get<Text>(avatar.slots.Hat, "null");
            let potential_body = Option.get<Text>(avatar.slots.Body, "null");
            let potential_face = Option.get<Text>(avatar.slots.Face, "null");
            let potential_eyes = Option.get<Text>(avatar.slots.Eyes, "null");
            let potential_misc = Option.get<Text>(avatar.slots.Misc, "null");
            // When the Body slot is taken we add a rule to remove visibility of clothing
            if(Option.isSome(avatar.slots.Body)){
                style #= ".clothing {visibility: hidden;}";
            };
            // When the Hat slot is taken by an accessory that needs to change hairstyle we do so.
            if(Option.isSome(Array.find<Text>(hats_hairstyle, func(x) {x == potential_hat}))){
                style #= "#classic-hair-back {visibility: hidden;}";
                style #= "#classic-hair-front {visibility: hidden;}";
                style #= ".Hair-above {visibility: hidden;}";
                style #= "#top-hair-15 {visibility: hidden;}";
                style #= ".Hair-behind.Hair-13 {visibility: hidden;}";
            } else {
                style #= "#hat-hair-back {visibility: hidden;}";
                style #= "#hat-hair-front {visibility: hidden;}";
            };
            // When the hat is a hood then we hide the hair
            if(potential_hat == "magic-hood" or potential_hat == "assassin-hood"){
                style #= ".Hair {visibility: hidden;}";
            };
            // Deal with magic-cape & magic-hood
            if(potential_hat == "magic-hood" and potential_body == "magic-cape"){
                style #= ".Magic-hood-85,.Magic-hood-9 {visibility: hidden;}";
                style #= ".Magic-cape-85 {visibility: visible;}";
            };
            if(potential_hat == "assassin-hood" and potential_body != "magic-cape"){
                style #= ".Ears {visibility: hidden;}";
            };
            // Deal with assassin-cape & assassin-hood
            if(potential_body == "assassin-cape"){
                if(potential_hat == "assassin-hood"){
                    style #= ".Assassin-hood-85,.Assassin-hood-9 {visibility: hidden;}";
                } else {
                    style #= ".Assassin-cape-9, .Assassin-cape-22, .Assassin-cape-85 {visibility: hidden;}";
                }
            };
            // Add clippath for astro helmet expect with the hair-13
            if(potential_hat == "astro-helmet" and avatar.hair != "hair-13"){
                style #= ".Hair {clip-path: url(#astro-helmet-mask);}";
            };
            // Fix issues caused by the shinobi-suit
            if(potential_body == "shinobi-suit"){
                if(potential_hat == "magic-hood" or potential_hat == "assassin-hood"){
                    style #= ".Business-body .Shinobi-suit-99, .Business-body .Shinobi-suit-15 {transform : scale(1.1) translate(-40px, -40px)";
                    style #= "#business-profile-20 {visibility: hidden;}";
                };
                if(potential_hat == "astro-helmet"){
                    style #= ".Business-body .Shinobi-suit-99, .Business-body .Shinobi-suit-15 {transform : scale(1.1) translate(-40px, -40px)";
                    style #= ".Punk-body .Shinobi-suit-99, .Punk-body .Shinobi-suit-15 {transform : scale(1.1) translate(-40px, -40px)";
                    style #= ".Mission-body .Shinobi-suit-99, .Mission-body .Shinobi-suit-15 {transform : scale(1.1) translate(-40px, -40px)";
                };
            };
            // Hide the horns (evil-mask) and ears (kitsune-mask) when a hat is equipped
            if(Option.isSome(avatar.slots.Hat) and potential_hat != "ninja-headband"){
                style #= "#evil-mask-76 #horns {visibility: hidden;}";
                style #= "#Kitsune-mask-V2 #ears {visibility: hidden;}";
            };
            // Hide the energy eyes when they are conflict with hat
            if(potential_hat == "magic-hood" or potential_hat == "style-hat"){
                style #= "#energy-eyes {visibility: hidden;}";
            };
            style #= "</style>";
            return(style);
        };

        func _createBlob(
            avatar : Avatar
            ) : Blob {

                // Create the header and add the profile name for applying the css rules later.
                var svg = "<svg viewBox='0 0 800 800' xmlns='http://www.w3.org/2000/svg' height='800px' width='800px' class='" # _profileToCSSBody(avatar.profile) # "'>";

                // Add style general, style for colors and potentially style for hiding clothes when a body accessory is equipped.
                svg #= css_style # Colors.createStyle(avatar.style) # _getStyleOptionalAccessory(avatar);

                // Get the layers and order them, then add components for each layer.
                let layers = _orderLayers(_createLayers(avatar));
                for (layer in layers.vals()){
                    switch(_Assets.getComponent(layer.1, layer.0)){
                        case(#err(message)) {
                            _Logs.logMessage("Avatar/lib/createBlob: " # message);
                            assert(false);
                        };
                        case(#ok(component)) {
                            if(_isAccessory(layer.1)) {
                                svg #= SVG.wrapClassAccessory(component, layer.0, layer.1);
                            } else {
                                svg #= SVG.wrapClassAvatar(component, layer.0, layer.1);
                            }
                        };
                    }
                };
                svg #= "</svg>";
                return(Text.encodeUtf8(svg));
        };

        func _createAvatar(
            info : MintInformation
        ) : Avatar {
            let new_level = _getLevel();
            let new_slot = _createNewSlot();

            return({
                background = info.background;
                profile = info.profile;
                ears = info.ears;
                mouth = info.mouth;
                eyes = info.eyes;
                nose = info.nose;
                hair = info.hair;
                cloth = info.cloth;
                slots = new_slot;
                style = #Colors(info.colors);
                level = new_level;
                blob = Blob.fromArray([0]);
                
            });
        };

        func _createLegendary(
            name : Text
        ) : Result<Avatar, Text> {
            switch(_Assets.getFile(name)){
                case(null) {
                    _Logs.logMessage("Avatar/lib/createLegendary/line534. " # name # " file not found.");
                    return (#err("File not found for : " # name));
                };
                case(? file){
                    if(Option.isNull(Array.find<Text>(file.meta.tags, func(tag) { tag == "legendary"} ))){
                        _Logs.logMessage("Avatar/lib/createLegendary/line539. " # name # " is not a legendary avatar.");
                        return #err( name # " doesn't have the legendary tag");
                    };
                    #ok({
                        background = "";
                        profile = "";
                        ears = "";
                        mouth =  "";
                        eyes = "";
                        nose = "";
                        hair = "";
                        cloth = "";
                        slots = _createNewSlot();
                        style = #Colors([]);
                        level = #Legendary;
                        blob = file.asset.payload;
                    })
                };
            };
        };

        /* Returns a boolean indicating if the component is an accessory)^m/+pm/
        
          */        
        func _isAccessory(name : Text) : Bool {
            switch(_components.get(name)){
                case(null) {
                    assert(false);
                    return false;
                };
                case(? component) {
                    switch(component.category){
                        case(#Accessory) {
                            return true;
                        };
                        case _ {
                            return false;
                        };
                    }
                };
            };
        };

        func _profileToCSSBody(profile : Text) : Text {
            switch(profile){
                case("business-profile") return "Business-body";
                case("miss-profile") return "Miss-body";
                case("punk-profile") return "Punk-body";
                case(_) {
                    assert(false);
                    "Unreachable";
                };
            }
        };

        func _verifySlot(tag : Text, slot : Slots) : Result<(),Text> {
            switch(tag){
                case("hat") {
                    if(Option.isSome(slot.Hat)){
                        return #err("Hat already equipped : " # Option.get(slot.Hat, ""));
                    };
                    return #ok;
                };
                case("eyes") {
                    if(Option.isSome(slot.Eyes)){
                        return #err("Eyes already equipped : " # Option.get(slot.Eyes, ""));
                    };
                    return #ok;
                };
                case ("body"){
                    if(Option.isSome(slot.Body)){
                        return #err("Body already equipped : " # Option.get(slot.Body, ""));
                    };
                    return #ok;
                };
                case("face"){
                    if(Option.isSome(slot.Face)){
                        return #err("Face already equipped : " # Option.get(slot.Face, ""));
                    };
                    return #ok;
                };
                case("misc"){
                    if(Option.isSome(slot.Misc)){
                        return #err("Misc already equipped : " # Option.get(slot.Misc, ""));
                    };
                    return #ok;
                };
                case (t) {
                    return #err("Unknown slot : " # t);
                };
            };
        };

        func _getSlot(
            slot : Text,
            slots : Slots
        ) : ?Text {
            switch(slot){
                case("hat") slots.Hat;
                case("eyes") slots.Eyes;
                case("body") slots.Body; 
                case("face") slots.Face;
                case("misc") slots.Misc;
                case(t) {
                    return null;
                };
            };
        };

        func _drawAvatar(
            tokenId : TokenIdentifier,
        ) : Result<(), Text>{
            switch(_avatars.get(tokenId)){
                case(null) return #err("Avatar not found : " # tokenId);
                case(? avatar){
                    _avatars.put(tokenId, _modifyAvatarBlob(
                        avatar,
                        _createBlob(avatar),
                    ));
                    return #ok;
                };
            };
        };

        func _modifyAvatarBlob(
            avatar : Avatar,
            blob : Blob
        ) : Avatar {
            {
                background = avatar.background;
                profile = avatar.profile;
                ears = avatar.ears;
                mouth = avatar.mouth;
                eyes = avatar.eyes;
                nose = avatar.nose;
                hair = avatar.hair;
                cloth = avatar.cloth;
                slots = avatar.slots;
                style = avatar.style;
                level = avatar.level;
                blob = blob;
            }
        };

        func _modifyAvatarSlots(
            avatar : Avatar,
            slots : Slots
        ) : Avatar {
            {
                background = avatar.background;
                profile = avatar.profile;
                ears = avatar.ears;
                mouth = avatar.mouth;
                eyes = avatar.eyes;
                nose = avatar.nose;
                hair = avatar.hair;
                cloth = avatar.cloth;
                slots = slots;
                style = avatar.style;
                level = avatar.level;
                blob = avatar.blob;
            }
        };

        func _wearAccessory(
            avatar : Avatar,
            name : Text,
            slot : Text,
        ) : Avatar {
            {
                background = avatar.background;
                profile = avatar.profile;
                ears = avatar.ears;
                mouth = avatar.mouth;
                eyes = avatar.eyes;
                nose = avatar.nose;
                hair = avatar.hair;
                cloth = avatar.cloth;
                slots = _newSlots(
                    ?name,
                    slot,
                    avatar.slots
                );
                style = avatar.style;
                level = avatar.level;
                blob = avatar.blob;
            }
        };

        func _newSlots(
            name : ?Text,
            slot : Text,
            slots : Slots,
        ) : Slots {
            switch(slot){
                case("body"){
                    {
                        Hat = slots.Hat;
                        Eyes = slots.Eyes;
                        Misc = slots.Misc;
                        Body = name;
                        Face = slots.Face;
                    }
                };
                case("eyes"){
                    {
                        Hat = slots.Hat;
                        Eyes = name;
                        Misc = slots.Misc;
                        Body = slots.Body;
                        Face = slots.Face;
                    }
                };
                case("face"){
                    {
                        Hat = slots.Hat;
                        Eyes = slots.Eyes;
                        Misc = slots.Misc;
                        Body = slots.Body;
                        Face = name;
                    }
                };
                case("hat"){
                    {
                        Hat = name;
                        Eyes = slots.Eyes;
                        Misc = slots.Misc;
                        Body = slots.Body;
                        Face = slots.Face;
                    }
                };
                case("misc"){
                    {
                        Hat = slots.Hat;
                        Eyes = slots.Eyes;
                        Misc = name;
                        Body = slots.Body;
                        Face = slots.Face;
                    }
                };
                case _ {
                    assert(false);
                    {
                        Hat = slots.Hat;
                        Eyes = slots.Eyes;
                        Misc = slots.Misc;
                        Body = slots.Body;
                        Face = slots.Face;
                    }
                };
            };
        };

        func _isSlotEquipped(slot : Slots) : Bool {
            return(Option.isSome(slot.Hat) or Option.isSome(slot.Eyes) or Option.isSome(slot.Body) or Option.isSome(slot.Face) or Option.isSome(slot.Misc));
        };

        func _createAvatarRendering(avatar : Avatar) : AvatarRendering {
            return({
                background = avatar.background;
                profile = avatar.profile;
                ears = avatar.ears;
                mouth = avatar.mouth;
                eyes = avatar.eyes;
                nose = avatar.nose;
                hair = avatar.hair;
                cloth = avatar.cloth;
                slots = avatar.slots;
                style = avatar.style;
            })
        };

    };
};