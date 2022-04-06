import Array "mo:base/Array";
import Blob "mo:base/Blob";
import Buffer "mo:base/Buffer";
import Debug "mo:base/Debug";
import HashMap "mo:base/HashMap";
import Iter "mo:base/Iter";
import Nat "mo:base/Nat";
import Option "mo:base/Option";
import Prim "mo:prim";
import Result "mo:base/Result";
import Text "mo:base/Text";

import Ext "mo:ext/Ext";

import Assets "../assets";
import AvatarOld "../types/avatar";
import ColorModule "../utils/color";
import SVG "../utils/svg";
import Types "types";
module {

    ////////////
    // Types //
    //////////
    
    public type UpgradeData = Types.UpgradeData;
    public type Component = Types.Component;
    public type Avatar = Types.Avatar;
    public type MintInformation = Types.MintInformation;
    public type Style = Types.Style;

    public class Factory(dependencies : Types.Dependencies) : Types.Interface {

        ////////////
        // State //
        ///////////

        public type Result<A,B> = Result.Result<A,B>;
        public type Slots = Types.Slots;
        public type Level = Types.Level;
        public type ComponentRequest = Types.ComponentRequest;
        public type Layers = Types.Layers;
        public type Colors = Types.Colors;
        public type Avatar = Types.Avatar;
        public type LayerId = Types.LayerId;
        public type AvatarRequest = Types.AvatarRequest;
        public type TokenIdentifier = Ext.TokenIdentifier;

        private let _avatars : HashMap.HashMap<TokenIdentifier,Avatar> = HashMap.HashMap<TokenIdentifier,Avatar>(0, Text.equal, Text.hash);
        private let _components : HashMap.HashMap<Text, Component> = HashMap.HashMap<Text,Component>(0 , Text.equal, Text.hash);

        private var css_style : Text = "";

        // Dependencies
        let _Assets = dependencies._Assets;
        let _Admins = dependencies._Admins;
        let _Logs = dependencies._Logs;

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

        ////////////
        // API ////
        ///////////

        // Add a component into the state
        public func addComponent(
            name : Text,
            component : Component 
        ) : Result.Result<(), Text> {
            switch(_components.get(name)){
                case(? component) return #err("Component : " # name # " already exists");
                case _  {
                    _components.put(name, component);
                    return #ok(());
                };
            };
        };

        public func changeCSS(style : Text) : () {
            css_style := style;
        };

        // Returns an optional avatar for the given token identifier.
        public func getAvatar(tokenId : TokenIdentifier) : ?Avatar {
            return _avatars.get(tokenId);
        };


        public func switchAvatar(
            tokenId : TokenIdentifier,
            layers : [(LayerId, Text)],
            style : Text,
            slot : Slots
        ) : Result<(), Text> {
                let avatar_without_blob = {
                    background = "background-base";
                    profile = findProfile(layers);
                    ears = findEars(layers);
                    mouth = findMouth(layers);
                    eyes = findEyes(layers);
                    nose = findNose(layers);
                    hair = findHair(layers);
                    cloth = findCloth(layers);
                    style = #Old(style);
                    slots = switchSlot(slot);
                    level = #Level3;
                    blob = Blob.fromArray([0]);
                };
                let blob = _createBlob(avatar_without_blob);
                let avatar = {
                    background = avatar_without_blob.background;
                    profile = avatar_without_blob.profile;
                    ears = avatar_without_blob.ears;
                    mouth = avatar_without_blob.mouth;
                    eyes = avatar_without_blob.eyes;
                    nose = avatar_without_blob.nose;
                    hair = avatar_without_blob.hair;
                    cloth = avatar_without_blob.cloth;
                    style = avatar_without_blob.style;
                    slots = avatar_without_blob.slots;
                    level = #Level3;
                    blob = blob
                };
                _avatars.put(tokenId, avatar);
                return #ok;
        };

        public func createAvatar_old(
            request : AvatarRequest,
            tokenId : TokenIdentifier,
        ) : Result<(), Text> {
            switch(_avatars.get(tokenId)){
                case(? avatar) return #err("There is already an avatar for this tokenIdentifier");
                case(null){

                    let avatar = _createAvatarOld(request);
                    let blob = _createBlob(avatar);
                    _avatars.put(tokenId, avatar);
                    return #ok;
                };
            };
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

        public func wearAccessory(
            tokenId : TokenIdentifier,
            name_accessory : Text,
        ) : Result<(), Text> {
            switch(_avatars.get(tokenId)){
                case(null) return #err("No avatar for this tokenIdentifier : " # tokenId);
                case(? avatar) {
                    switch(_components.get(name_accessory)){
                        case(null) {
                            _Logs.logMessage("Avatar/wearAccessory/line189" # " Component : " # name_accessory # " does not exist");
                            return #err("No component named : " # name_accessory);
                        };
                        case(? component){
                            switch(component.category){
                                case(#Accessory) {
                                    // To get the slot and verify that it is empty. Not easy.
                                    let filePath = component.name # "-" # Nat.toText(component.layers[0]);
                                    switch(_Assets.getFileByName(filePath)){
                                        case(null) {
                                            _Logs.logMessage("Avatar/wearAccessory/line198." # " File : " # filePath # " does not exist");
                                            return #err("No file named : " # filePath);
                                        };
                                        case(? file){
                                            let slot = file.meta.tags[0];
                                            let slots = avatar.slots;
                                            switch(_verifySlot(file.meta.tags[0], avatar.slots)){
                                                case(#err(e)) {
                                                    _Logs.logMessage("Avatar/wearAccessory/line206." # " " # e);
                                                    return #err(e);
                                                };
                                                case(#ok){
                                                    _avatar.put(tokenId, _wearAccessory(avatar, slot, slots));
                                                    switch(_drawAvatar(tokenContractId)){
                                                        case(#err(e)) {
                                                            _Logs.logMessage("Avatar/wearAccessory/line213." # " " # e);
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
                                    _Logs.logMessage("Avatar/wearAccessory" # " Component : " # name_accessory # " is not an accessory");
                                    return #err("Component : " # name_accessory # " is not an accessory");
                                };
                            };
                        };
                    };
                };
            };
        };

        public func removeAccessory(
            tokenId : TokenIdentifier,
            name_accessory : Text,
        ) : Result<(), Text> {
            #ok;
        };

        public func removeAllAccessories(
            tokenId : TokenIdentifier,
        ) : Result<(), Text> {
            #ok;
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
            return(Array.append<(LayerId,Text)>(buffer.toArray(), _getLayersAccessories(avatar)));
        };

        func _getStyleOptionalAccessory(avatar : Avatar) : Text {
            switch(avatar.slots.Body){
                case(null) return "";
                case(?something) return "<style> .clothing {visibility : hidden;} </style>";
            };
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

        func _createBlob(
            avatar : Avatar
            ) : Blob {

                // Create the header and add the profile name for applying the css rules later.
                var svg = "<svg viewBox='0 0 800 800' xmlns='http://www.w3.org/2000/svg' height='800px' width='800px' class='" # _profileToCSSBody(avatar.profile) # "'>";

                // Add style general, style for colors and potentially style for hiding clothes when a body accessory is equipped.
                svg #= css_style # ColorModule.createStyle(avatar.style) # _getStyleOptionalAccessory(avatar);

                // Get the layers and order them, then add components for each layer.
                let layers = _orderLayers(_createLayers(avatar));
                for (layer in layers.vals()){
                    switch(_Assets.getComponent(layer.1, layer.0)){
                        case(#err(message)) {
                            _Logs.logMessage("Avatar/lib/createBlob: " # message);
                            assert(false);
                        };
                        case(#ok(component)) {
                            svg #= SVG.wrap(component, layer.0, SVG.capitalize(layer.1));
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

            let avatar = {
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
                
            };
            return(_modifyAvatarBlob(
                avatar,
                _createBlob(avatar)
            ))
        };

        ////////////
        // OLD ////
        ///////////

        func _createAvatarOld(
            request : AvatarRequest,
        ) : Avatar {
            let background = switch(_findBackground(request)){
                case(?background) Text.map(background , Prim.charToLower);
                case(_) {
                    assert(false);
                    "Unreachable";
                }
            };
            let profile = switch(_findProfile(request)){
                case(?profile) Text.map(profile , Prim.charToLower);
                 case(_) {
                    assert(false);
                    "Unreachable";
                }
            };
            let ears = switch(_findEars(request)){
                case(?ears) Text.map(ears , Prim.charToLower);
                 case(_) {
                    assert(false);
                    "Unreachable";
                }
            };
            let mouth = switch(_findMouth(request)){
                case(?mouth) Text.map(mouth , Prim.charToLower);
                 case(_) {
                    assert(false);
                    "Unreachable";
                }
            };
            let eyes = switch(_findEyes(request)){
                case(?eyes) Text.map(eyes , Prim.charToLower);
                 case(_) {
                    assert(false);
                    "Unreachable";
                }
            };
            let nose = switch(_findNose(request)){
                case(?nose) Text.map(nose , Prim.charToLower);
                 case(_) {
                    assert(false);
                    "Unreachable";
                }
            };
            let hair = switch(_findHair(request)){
                case(?hair) Text.map(hair , Prim.charToLower);
                 case(_) {
                    assert(false);
                    "Unreachable";
                }
            };
            let cloth = switch(_findCloth(request)){
                case(?cloth) cloth;
                 case(_) {
                    assert(false);
                    "Unreachable";
                }
            };
            let avatar_without_blob = {
                background = background;
                profile = profile;
                ears = ears;
                mouth = mouth;
                eyes = eyes;
                nose = nose;
                hair = hair;
                cloth = cloth;
                slots = _createNewSlot();
                style = #Colors(request.colors);
                level = _getLevel();
                blob = Blob.fromArray([0]);
            };
            _modifyAvatarBlob(
                avatar_without_blob,
                _createBlob(avatar_without_blob)
            )
        };

        func _findBackground(request : AvatarRequest) : ?Text {
            for(component in request.components.vals()){
                if(component.layer == 5){
                    return ?component.name;
                };
            };
            null
        };

        func _findProfile(request : AvatarRequest) : ?Text {
            for(component in request.components.vals()){
                if(component.layer == 20){
                    switch(component.name){
                        case("Business-body") return ?"Business-profile";
                        case("Miss-body") return ?"Miss-profile";
                        case("Punk-body") return ?"Punk-profile";
                        case(_) return null 
                    };
                };
            };
            null
        };

        func _findEars(request : AvatarRequest) : ?Text {
            for(component in request.components.vals()){
                if(component.layer == 30){
                    return ?component.name;
                };
            };
            null
        };

        func _findMouth(request : AvatarRequest) : ?Text {
            for(component in request.components.vals()){
                if(component.layer == 45){
                    return ?component.name;
                };
            };
            null
        };

        func _findEyes(request : AvatarRequest) : ?Text {
            for(component in request.components.vals()){
                if(component.layer == 50){
                    return ?component.name;
                };
            };
            null
        };

        func _findNose(request : AvatarRequest) : ?Text {
            for(component in request.components.vals()){
                if(component.layer == 55){
                    return ?component.name;
                };
            };
            null
        };

        func _findHair(request : AvatarRequest) : ?Text {
            for(component in request.components.vals()){
                if(component.layer == 75){
                    return ?component.name;
                };
            };
            null
        };

        func _findCloth(request : AvatarRequest) : ?Text {
            for(component in request.components.vals()){
                if(component.layer == 70){
                    return ?component.name;
                };
            };
            null
        };


        type LayerAvatar = AvatarOld.LayerAvatar;
        // public func fromOld(
        //     token : TokenIdentifier,
        //     layers : [(LayerId, LayerAvatar)],
        //     style : Text,
        //     slots : Slots,
        // ) : () {

        // };

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


        //// OLD TO NEW
        func findProfile(layers : [(LayerId, Text)]) : Text {
            for(layer in layers.vals()){
                if(layer.0 == 35){
                    switch(layer.1){
                        case("Miss-head") return "miss-profile";
                        case("Business-head") return "business-profile";
                        case("Punk-head") return "punk-profile";
                        case(_) {
                            assert(false);
                            return "Unreachable";
                        };
                    }
                };
            };
            "";
        };
            
        func findEars(layers : [(LayerId, Text)]) : Text {
            for(layer in layers.vals()){
                if(layer.0 == 30){
                    return Text.map(layer.1 , Prim.charToLower);
                }
            };
            "";
        };

        func findMouth(layers : [(LayerId, Text)]) : Text {
            for(layer in layers.vals()){
                if(layer.0 == 45){
                    return Text.map(layer.1 , Prim.charToLower);
                }
            };
            "";
        };

        func findEyes(layers : [(LayerId, Text)]) : Text {
            for(layer in layers.vals()){
                if(layer.0 == 50){
                    return Text.map(layer.1 , Prim.charToLower);
                }
            };
            _Logs.logMessage("Avatar " # " findEyes " # " No eyes found");
            "";
        };

        func findNose(layers : [(LayerId, Text)]) : Text {
            for(layer in layers.vals()){
                if(layer.0 == 55){
                    return Text.map(layer.1 , Prim.charToLower);
                }
            };
            "";
        };

        func findHair(layers : [(LayerId, Text)]) : Text {
            for(layer in layers.vals()){
                if(layer.0 == 75){
                    return Text.map(layer.1 , Prim.charToLower);
                }
            };
            "";
        };

        func findCloth(layers : [(LayerId, Text)]) : Text {
            for(layer in layers.vals()){
                if(layer.0 == 70){
                    return layer.1;
                }
            };
            "";
        };

        func switchSlot(slot : Slots) : Slots {
            {
                Hat = switchHat(slot.Hat);
                Eyes = switchEyes(slot.Eyes);
                Face = switchFace(slot.Face);
                Misc = switchMisc(slot.Misc);
                Body = switchBody(slot.Body);
            }
        };

        func switchEyes(name : ?Text) : ?Text {
            switch(name){
                case(null) return null;
                case(?"Matrix-glasses") return ?"sunglasses";
                case(? t) return ?Text.map(t, Prim.charToLower);
            }
        };

        func switchFace(name : ?Text) : ?Text {
            switch(name){
                case(null) return null;
                case(?"Dfinity-face-mask") return ?"facemask";
                case(?"Oni-half-mask") return ?"oni-face-mask";
                case(?t) return ?Text.map(t, Prim.charToLower);
            }
        };

        func switchHat(name : ?Text) : ?Text {
          switch(name){
            case(null) return null;
            case(?t) return ?Text.map(t, Prim.charToLower);
          }
        };

        func switchBody(name : ?Text) : ?Text {
            switch(name){
                case(null) return null;
                case(?t) return ?Text.map(t, Prim.charToLower);
            }
        };

        func switchMisc(name : ?Text) : ?Text {
            switch(name){
                case(null) return null;
                case(?t) return ?Text.map(t, Prim.charToLower);
            }
        };

        func _verifySlot(tag : Text, slot : Slots) : Result<(),Text> {
            switch(tag){
                case("hat") {
                    if(Option.isSome(slot.Hat)){
                        return #err("Hat is alreay equipped : " # Option.get(slot.Hat, ""));
                    };
                    return #ok;
                };
                case("eyes") {
                    if(Option.isSome(slot.Eyes)){
                        return #err("Eyes are alreay equipped : " # Option.get(slot.Eyes, ""));
                    };
                    return #ok;
                };
                case ("body"){
                    if(Option.isSome(slot.Body)){
                        return #err("Body is alreay equipped : " # Option.get(slot.Body, ""));
                    };
                    return #ok;
                };
                case("face"){
                    if(Option.isSome(slot.Face)){
                        return #err("Face is alreay equipped : " # Option.get(slot.Face, ""));
                    };
                    return #ok;
                };
                case("misc"){
                    if(Option.isSome(slot.Misc)){
                        return #err("Misc is alreay equipped : " # Option.get(slot.Misc, ""));
                    };
                    return #ok;
                };
                case (t) {
                    return #err("Unknown slot : " # t);
                };
            };
        };

        //////////////////
        // UTILITIES ////
        /////////////////

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
                slots = _newSlot(
                    name,
                    slot,
                    avatar.slots
                );
                style = avatar.style;
                level = avatar.level;
                blob = avatar.blob;
            }
        };

        func _newSlot(
            name : Text,
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
                        Face = Face;
                    }
                };
                case _ {
                    assert(false);
                };
            };
        };
    };
};