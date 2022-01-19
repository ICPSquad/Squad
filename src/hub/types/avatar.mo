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

module  {
  
    public type Color = (Nat8, Nat8, Nat8, Nat8);

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
    };

    public type Component = {
        content : Text;
        name : Text;
        layer : Nat8; // Recommended layer for the element
    };


    
    public type AvatarRequest = {
        components : [{name : Text; layer : Nat8}];
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
                return(_wrapClass(component, "Clothes", name ));
            };
            case(75) {
                return(_wrapClass(component, "Hair", name));
            };
            case(90) {
                return(_wrapClass(component, "Hair-above", name));
            };
            case(_) {
                return(component);
            };
        } ;
    };

    private func _wrapClass (component : Text , _class : Text, name : Text) : Text {
        let names : [Text] = _trimName(name);
        var component_wrapped = "<g class='";
        component_wrapped #= _class;
        for (name in names.vals()) {
            component_wrapped #= " ";
            component_wrapped #= name;
        };
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