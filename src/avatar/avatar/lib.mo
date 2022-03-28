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

        private let _components : HashMap.HashMap<Text, Component> = HashMap.fromIter(params.avatars.entries(), params.avatars.size(), Text.equal, Text.hash)
        private let _avatars : HashMap.HashMap<TokenIdentifier,Avatar> = HashMap.fromIter(params.avatars.entries(), params.avatars.size(), Text.equal, Text.hash);

        public func toStableState() : Types.State {
            return({
                avatars = Iter.toArray(_avatars.entries());
                components = Iter.toArray(_components.entries());
            })
        };

        ////////////
        // API ////
        ///////////

        // Returns an optional avatar for the given token identifier.
        public func getAvatar(tokenId : TokenIdentifier) : Avatar? {
            return _avatars.get(token);
        };

        public func createAvatar(
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

        func _createLayers (components : [ComponentRequest]) : Layers {
            var layers : Buffer.Buffer<(LayerId,Text)> = Buffer.Buffer(0);
            for(component in components.vals()){
                layers.add((Nat8.toNat(component.layer), component.name)); 
            };
            layers.toArray();
        };

        func _getBodyName(layers : Layers) : Text {
            switch(Array.find<(LayerId, Text)>(layers, func(layer) {layer.layerId == 20})){
                case(?(layerId, name)) return name;
                case(_) throw ("No body found") return("Unreachable");
            };
        };

        func _createBlob(components : [ComponentRequest], colors : [{spot : Text, color : Color}]]) : Blob {
            let layers = _orderLayers(_createLayers(components));
            let body_name = _getBodyName(layers);
            var svg = "<svg viewBox='0 0 800 800' xmlns='http://www.w3.org/2000/svg' class='" # body_name # "'>";
            // Add style general and style for colors
            svg #= css_global # ColorModule.createColor(colors);

        };







        

    };
}