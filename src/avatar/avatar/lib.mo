import Types "types"
import HashMap "mo:base/HashMap";
import Text "mo:base/Text";
import Result "mo:base/Result";
import Buffer "mo:base/Buffer";
import Array "mo:base/Array";
import ColorModule "../utils/Color";
module {
    public class Avatar(params : Types.Parameters) : Types.Interface {

        ////////////
        // State //
        ///////////

        public type Result<A,B> = Result.Result<A,B>;
        public type Slots = Types.Slots;
        public type Level = Types.Level;
        public type Component = Types.Component;
        public type ComponentRequest = Types.ComponentRequest;
        public type Layers = Types.Layers;
        public type Colors = Types.Colors;

        private let _components : HashMap.HashMap<Text, Component> = HashMap.fromIter(params.components.entries(), params.components.size(), Text.equal, Text.hash);
        private let _avatars : HashMap.HashMap<TokenIdentifier,Avatar> = HashMap.fromIter(params.avatars.entries(), params.avatars.size(), Text.equal, Text.hash);
        private let _blobs : HashMap.HashMap<TokenIdentifier, Blob> = HashMap.fromIter(params.blobs.entries(), params.blobs.size(), Text.equal, Text.hash);


        private let CSS_STYLE : Text = params.style;

        public func toStableState() : Types.State {
            return({
                avatars = Iter.toArray(_avatars.entries());
                components = Iter.toArray(_components.entries());
                blobs = Iter.toArray(_blobs.entries());
            })
        };

        ////////////
        // API ////
        ///////////

        // Returns an optional avatar for the given token identifier.
        public func getAvatar(tokenId : TokenIdentifier) : Avatar? {
            return _avatars.get(token);
        };

        public func createAvatarOld(
            request : AvatarRequest,
            tokenId : TokenIdentifier,
        ) : Result<(), Text> {
            switch(_avatars.get(tokenId)){
                case(? avatar) return #err("There is already an avatar for this tokenIdentifier");
                case(null){

                };
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
                #Level3;
            };
            if(_avatars.size()< 10000){
                #Level2;
            }
            #Level1;
        };

        func _orderLayers (layers : Layers) : Layers {
            Array.sort<(LayerId, Text)>(layers, func (a,b) {Nat.compare(a.layerId, b.layerId)});
        };

        func _createLayers (avatar : Avatar) : Layers {
            var buffer = Buffer.Buffer<(LayerId, Name)> = Buffer.Buffer(0);
            let layers_background = switch(_components.get(avatar.background)){
                case(? component) return component.layers;
                case(null) throw "No background component found for this avatar : " # avatar.background;
            };
            for(layer in layers_body){
                buffer.add((layer, avatar.background));
            };
            let layers_profile = switch(_components.get(avatar.profile)){
                case(? component) return component.layers;
                case(null) throw "No profile component found for this avatar : " # avatar.profile;
            };
            for(layer in layers_profile){
                buffer.add((layer, avatar.profile));
            };
            let layers_ears = switch(_components.get(avatar.ears)){
                case(? component) return component.layers;
                case(null) throw "No ears component found for this avatar : " # avatar.ears;
            };
            for(layer in layers_ears){
                buffer.add((layer, avatar.ears));
            };
            let layers_mouth = switch(_components.get(avatar.mouth)){
                case(? component) return component.layers;
                case(null) throw "No mouth component found for this avatar : " # avatar.mouth;
            };
            for(layer in layers_mouth){
                buffer.add((layer, avatar.mouth));
            };
            let layers_eyes = switch(_components.get(avatar.eyes)){
                case(? component) return component.layers;
                case(null) throw "No eyes component found for this avatar : " # avatar.eyes;
            };
            for(layer in layers_eyes){
                buffer.add((layer, avatar.eyes));
            };
            let layers_nose = switch(_components.get(avatar.nose)){
                case(? component) return component.layers;
                case(null) throw "No nose component found for this avatar : " # avatar.nose;
            };
            for(layer in layers_nose){
                buffer.add((layer, avatar.nose));
            };
            let layers_hair = switch(_components.get(avatar.hair)){
                case(? component) return component.layers;
                case(null) throw "No hair component found for this avatar : " # avatar.hair;
            };
            for(layer in layers_hair){
                buffer.add((layer, avatar.hair));
            };
            let layers_cloth = switch(_components.get(avatar.cloth)){
                case(? component) return component.layers;
                case(null) throw "No cloth component found for this avatar : " # avatar.cloth;
            };
            for(layer in layers_cloth){
                buffer.add((layer, avatar.cloth));
            };
            return(Array.append<(LayerId,Text)>(buffer.toArray(), _getLayersAccessories(avatar)));
        };

        func _getStyleOptionalAccessory(avatar : Avatar) : Text {
            switch(avatar.slots.Body){
                case(null) return "";
                case(?something) return ?"<style> .clothing {visibility : hidden;} </style>";
            };
        };

        func _getLayersAccessories(avatar : Avatar) : Layers {
            var buffer = Buffer.Buffer<(LayerId, Name)> = Buffer.Buffer(0);
            switch(avatar.slots.Hat) {
                case(null) {};
                case(? hat){
                    let layers_hat = switch(_components.get(hat)){
                        case(? component) return component.layers;
                        case(null) throw "No hat component found for this avatar : " # avatar.hat;
                    };
                    for(layer in layers_hat){
                        buffer.add((layer, avatar.slots.Hat));
                    };
                };
            };
            switch(avatar.slots.Eyes) {
                case(null) {};
                case(? eyes){
                     let layers_eyes = switch(_components.get(eyes)){
                        case(? component) return component.layers;
                        case(null) throw "No hat component found for this avatar : " # avatar.hat;
                    };
                    for(layer in layers_eyes){
                        buffer.add((layer, avatar.slots.Eyes));
                    };
                };
            };
            switch(avatar.slots.Misc) {
                case(null) {};
                case(? misc){
                     let layers_misc = switch(_components.get(misc)){
                        case(? component) return component.layers;
                        case(null) throw "No misc component found for this avatar : " # avatar.hat;
                    };
                    for(layer in layers_misc){
                        buffer.add((layer, avatar.slots.Misc));
                    };
                };
            };
            switch(avatar.slots.Body) {
                case(null) {};
                case(? body){
                     let layers_body = switch(_components.get(body)){
                        case(? component) return component.layers;
                        case(null) throw "No body component found for this avatar : " # avatar.hat;
                    };
                    for(layer in layers_body){
                        buffer.add((layer, avatar.slots.Body));
                    };
                };
            };
            switch(avatar.slots.Face) {
                case(null) {};
                case(? face){
                     let layers_face = switch(_components.get(face)){
                        case(? component) return component.layers;
                        case(null) throw "No face component found for this avatar : " # avatar.hat;
                    };
                    for(layer in layers_face){
                        buffer.add((layer, avatar.slots.Face));
                    };
                };
            };
            return(buffer.toArray());
        };

        func _createBlob(
            avatar : Avatar
            ) : Blob {

                // Create the header and add the profile name for applying the css rules later.
                var svg = "<svg viewBox='0 0 800 800' xmlns='http://www.w3.org/2000/svg' class='" # avatar.profile # "'>";

                // Add style general, style for colors and potentially style for hiding clothes when a body accessory is equipped.
                svg #= CSS_STYLE # ColorModule.createStyle(avatar.colors) # _getStyleOptionalAccessory(avatar);

                // Get the layers and order them.
                let layers = _orderLayers(_createLayers(avatar));
                for (layer in layers.vals()){
                    svg #= Assets.getLayer(layer.0, layer.1);
                }; 

                // Close the <svg>
                // Convert to blob 
            };
        };

        ////////////
        // OLD ////
        ///////////

        func _createAvatarOld(
            request : AvatarRequest,
        ) : Avatar {
            let background = switch(_findBackground(request)){
                case(?background) background;
                case(_) throw("No background found");
            };
            let profile = switch(_findProfile(request)){
                case(?profile) profile;
                case(_) throw("No profile found");
            };
            let ears = switch(_findEars(request)){
                case(?ears) ears;
                case(_) throw("No ears found");
            };
            let mouth = switch(_findMouth(request)){
                case(?mouth) mouth;
                case(_) throw("No mouth found");
            };
            let eyes = switch(_findEyes(request)){
                case(?eyes) eyes;
                case(_) throw("No eyes found");
            };
            let nose = switch(_findNose(request)){
                case(?nose) nose;
                case(_) throw("No nose found");
            };
            let hair = switch(_findHair(request)){
                case(?hair) hair;
                case(_) throw("No hair found");
            };
            let cloth = switch(_findCloth(request)){
                case(?cloth) cloth;
                case(_) throw("No cloth found");
            };
            let avatar = {
                background = background;
                profile = profile;
                ears = ears;
                mouth = mouth;
                eyes = eyes;
                nose = nose;
                hair = hair;
                cloth = cloth;
                slots = _createNewSlot();
                colors = request.colors;
                level = _getLevel();
            };
            avatar;
        };

        func _findBackground(request : AvatarRequest) : ?Text {
            for(component in request.components.vals()){
                if(component.layer == 5){
                    return component.name;
                };
            };
            null
        };

        func _findProfile(request : AvatarRequest) : ?Text {
            for(component in request.components.vals()){
                if(component.layer == 20){
                    switch(component.name){
                        case("Business-body") return "Business-profile";
                        case("Miss-body") return "Miss-profile";
                        case("Punk-body") return "Punk-profile";
                        case(_) throw "No corresponding profile found";
                };
            };
        };

        func _findEars(request : AvatarRequest) : ?Text {
            for(component in request.components.vals()){
                if(component.layer == 30){
                    return component.name;
                };
            };
            null
        };

        func _findMouth(request : AvatarRequest) : ?Text {
            for(component in request.components.vals()){
                if(component.layer == 45){
                    return component.name;
                };
            };
            null
        };

        func _findEyes(request : AvatarRequest) : ?Text {
            for(component in request.components.vals()){
                if(component.layer == 50){
                    return component.name;
                };
            };
            null
        }

        func _findNose(request : AvatarRequest) : ?Text {
            for(component in request.components.vals()){
                if(component.layer == 55){
                    return component.name;
                };
            };
            null
        };

        func _findHair(request : AvatarRequest) : ?Text {
            for(component in request.components.vals()){
                if(component.layer == 75){
                    return component.name;
                };
            };
            null
        };

        func _findCloth(request : AvatarRequest) : ?Text {
            for(component in request.components.vals()){
                if(component.layer == 70){
                    return component.name;
                };
            };
            null
        };









        

    };
}