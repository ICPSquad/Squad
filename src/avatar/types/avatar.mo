import Nat8 "mo:base/Nat8";
import Nat16 "mo:base/Nat16";
import Nat32 "mo:base/Nat32";
import Nat "mo:base/Nat";
import HashMap "mo:base/HashMap";
import Hash "mo:base/Hash";
import Result "mo:base/Result";
import Char "mo:base/Char";
import Iter "mo:base/Iter";
import Text "mo:base/Text";
import Option "mo:base/Option";
import Color "./color";


module  {
  
    type Color = (Nat8, Nat8, Nat8, Nat8);

    // Same type as TokenIdentifier from EXT standard.
    public type TokenIdentifier = Text; 
    
    // Layers represent the order of <g> elements when put in the DOM (to create an equivalent of the z-index property)
    // Value from 0 to 99 

    public type LayerId = Nat;

    // LayerAvatar just references the name of the layer so to gain storage and not store the content for each layer. 
    public type LayerAvatar = {
      #Accessory : Text;  
      #Component : Text;
    };

    public type Accessory = {
      name : Text;
      content : Text;
      slot : Text;
      layer : Nat8;
    };

    public type Slots = {
        Hat : ?Text;
        Eyes : ?Text;
        Face : ?Text;
        Body : ?Text;
        Misc : ?Text;
    };

    // Used to load the avatar in the preview room!
    public type AvatarPreview = {
        token_identifier : TokenIdentifier;
        avatar_svg : Text;
        slots : Slots;
    };

    public func generateNewSlots () : Slots {
        let slots : Slots = {
            Hat = null;
            Eyes = null;
            Face = null;
            Body = null;
            Misc = null;
        };
        return (slots);
    };

    public func isSlotEmpty (slot_name : Text, slots_object : Slots) : Bool {
        switch(slot_name) {
            case("Hat") {
                switch(slots_object.Hat){
                    case(null) return true;
                    case(?text) return false;
                };
            };
            case("Eyes"){
                switch(slots_object.Eyes){
                    case(null) return true;
                    case(?text) return false;
                };
            };
            case("Face"){
                switch(slots_object.Face){
                    case(null) return true;
                    case(?text) return false;
                };
            };
            case("Body"){
                switch(slots_object.Body){
                    case(null) return true;
                    case(?text) return false;
                };
            };
            case("Misc"){
                switch(slots_object.Misc){
                    case(null) return true;
                    case(?text) return false;
                };
            };
            case(_) {
                return false;
            };
        };
    };

    public func isEmpty (slots : Slots) : Bool {
        return(Option.isNull(slots.Hat) and Option.isNull(slots.Eyes) and Option.isNull(slots.Face) and Option.isNull(slots.Body) and Option.isNull(slots.Misc));
    };

    public func putAccessoryInSlot (slot_name : Text, slots_object : Slots, accessory_name : Text) : Result.Result<Slots, Text> {
         switch(slot_name){
            case("Hat") {
                let new_slots : Slots = {
                    Hat = ?accessory_name;
                    Eyes = slots_object.Eyes;
                    Face = slots_object.Face;
                    Body = slots_object.Body;
                    Misc = slots_object.Misc;
                };
                return #ok(new_slots);
            };
            case("Eyes"){
                let new_slots : Slots = {
                    Hat = slots_object.Hat;
                    Eyes = ?accessory_name;
                    Face = slots_object.Face;
                    Body = slots_object.Body;
                    Misc = slots_object.Misc;
                };
                return #ok(new_slots);
            };
            case("Face"){
               let new_slots : Slots = {
                    Hat = slots_object.Hat;
                    Eyes = slots_object.Eyes;
                    Face = ?accessory_name;
                    Body = slots_object.Body;
                    Misc = slots_object.Misc;
                };
                return #ok(new_slots);
            };
            case("Body"){
                let new_slots : Slots = {
                    Hat = slots_object.Hat;
                    Eyes = slots_object.Eyes;
                    Face = slots_object.Face;
                    Body = ?accessory_name;
                    Misc = slots_object.Misc;
                };
                return #ok(new_slots);
            };
            case("Misc"){
               let new_slots : Slots = {
                    Hat = slots_object.Hat;
                    Eyes = slots_object.Eyes;
                    Face = slots_object.Face;
                    Body = slots_object.Body;
                    Misc = ?accessory_name;
                };
                return #ok(new_slots);
            };
            case(_) {
                return #err ("Required slot doesn't exist : " # slot_name);
            };
        };
    };

    public func removeFromSlot (slot_name : Text, slots_object : Slots) : Result.Result<Slots, Text> {
         switch(slot_name){
            case("Hat") {
                let new_slots : Slots = {
                    Hat = null;
                    Eyes = slots_object.Eyes;
                    Face = slots_object.Face;
                    Body = slots_object.Body;
                    Misc = slots_object.Misc;
                };
                return #ok(new_slots);
            };
            case("Eyes"){
                let new_slots : Slots = {
                    Hat = slots_object.Hat;
                    Eyes = null;
                    Face = slots_object.Face;
                    Body = slots_object.Body;
                    Misc = slots_object.Misc;
                };
                return #ok(new_slots);
            };
            case("Face"){
               let new_slots : Slots = {
                    Hat = slots_object.Hat;
                    Eyes = slots_object.Eyes;
                    Face = null;
                    Body = slots_object.Body;
                    Misc = slots_object.Misc;
                };
                return #ok(new_slots);
            };
            case("Body"){
                let new_slots : Slots = {
                    Hat = slots_object.Hat;
                    Eyes = slots_object.Eyes;
                    Face = slots_object.Face;
                    Body = null;
                    Misc = slots_object.Misc;
                };
                return #ok(new_slots);
            };
            case("Misc"){
               let new_slots : Slots = {
                    Hat = slots_object.Hat;
                    Eyes = slots_object.Eyes;
                    Face = slots_object.Face;
                    Body = slots_object.Body;
                    Misc = null;
                };
                return #ok(new_slots);
            };
            case(_) {
                return #err ("Required slot doesn't exist : " # slot_name);
            };
        };
    };


    public type Component = {
        content : Text;
        name : Text;
        layer : Nat8; // Recommended layer for the element
    };

    public type ComponentRequest = {
        name : Text;
        layer : Nat8; // Layer where we actually put it
    };
    
    public type AvatarRequest = {
        components : [ComponentRequest];
        colors : [{spot : Text; color : Color}];
    };

    public type AvatarInformations = {
      tokenIdentifier : Text;
      svg : Text;
    };

    public type AvatarResponse = Result.Result<AvatarInformations, Text>;

    
    public func wrapComponent (component : Text, layer : LayerId, name : Text) : Text {
        switch(layer) {
            case (5) {
                return (_wrapClass(component, "Background", name));
            };
            case(10) {
                return(_wrapClass(component, "Hair-behind" , name ));
            };
            case (20) {
                return(_wrapClass(component, "Body" , name ));
            };
            case (30) {
                return(_wrapClass(component, "Ears" , name ));
            };
            case(35) {
                return(_wrapClass(component, "Head", name ));
            };
            case(45){
                return(_wrapClass(component, "Mouth", name ));
            };
            case(50) {
                return(_wrapClass(component, "Eyes", name ));
            };
            case(55) {
                return(_wrapClass(component, "Nose", name ));
            };
            case(70) {
                return(_wrapClass(component, "clothing", name ));
            };
            case(75) {
                return(_wrapClass(component, "Hair", name));
            };
            case(90) {
                return(_wrapClass(component, "Hair-above", name));
            };
            case(95){
                return(_wrapClass(component, "Suit", name));
            };
            case(_) {
                return(component);
            };
        } ;
    };

    public func wrapAccessory (name : Text, accessory_content : Text) : Text {
        var accessory_wrapped = "<g class='";
        accessory_wrapped #= name;
        accessory_wrapped #= "'>";
        accessory_wrapped #= accessory_content;
        accessory_wrapped #= "</g>";
        return accessory_wrapped;
    };

    private func _wrapClass (component : Text , _class : Text, name : Text) : Text {
        let names : [Text] = _trimName(name);
        var component_wrapped = "<g class='";
        component_wrapped #= _class;
        if(_class == "clothing") {
            component_wrapped #= " ";
            component_wrapped #= _class;
            component_wrapped #= "-";
            component_wrapped #= name;
        } else {
            for (name in names.vals()) {
            component_wrapped #= " ";
            component_wrapped #= name;
            };
        };
        component_wrapped #= " ";
        component_wrapped #= name;
        component_wrapped #= "'>";
        component_wrapped #= component;
        component_wrapped #= "</g>";
        return component_wrapped;
    };


    // This function should transform the text as in the following example : "Business-angry-eyes" -> ["Business", "angry", "eyes"]
    private func _trimName (name : Text) : [Text] {
        let character = Char.fromNat32(45); //This represents the character "-"  
        let pattern = #char(character);
        let array = Iter.toArray<Text>(Text.split(name, pattern));
        return array;
    };

    


   

    

}