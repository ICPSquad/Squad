import Types "types"
import HashMap "mo:base/HashMap";
import Text "mo:base/Text";
import Result "mo:base/Result";
import Buffer "mo:base/Buffer";

module {
    public class Avatar(params : Types.Parameters) : Types.Interface {

        ////////////
        // State //
        ///////////
        public type Result<A,B> = Result.Result<A,B>;
        public type Slots = Types.Slots;
        public type Level = Types.Level;
        public type Component = Types.Component;

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
                case(? avatar) return #err("There is already an avatar for this tokenIddentifier");
                case(null){

                    var buffer_components : Buffer.Buffer<Component> = Buffer.Buffer(0);
                    for(component in request.components) {
                        switch(_components.get(component.name)){
                            case(? component) buffer_components.add(component);
                            case(null) return #err("Component not found: " + component);
                        };
                    };


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

        func _createBlob(components : [Component]) : Blob {
            // Order the components
            // Get the assets everytime
            // Get the <g> 
            // Add them on top of each other
            // Convert to a blob
        };



        func _orderComponents(components : [Component]) : [Component] {

        };

        func _createLayers (components : [Component]) : [(LayerId, Text)] {

        };






        

    };
}