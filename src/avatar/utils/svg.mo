import Text "mo:base/Text";
import Iter "mo:base/Iter";

module {

    let SVG_LEADING_PATTERN = #text("<svg viewBox=\"0 0 800 800\" xmlns=\"http://www.w3.org/2000/svg\">");
    let SVG_TRAILING_PATTERN = #text("</svg>");

    ////////
    //API //
    ////////

    public func unwrap(svg : Text) : Text  {
        Text.trimEnd(Text.trimEnd(svg, SVG_LEADING_PATTERN), SVG_TRAILING_PATTERN);
    };

    public func wrap(component : Text, layerId : Nat, name : Text ) : Text {
        switch(layerId){
             case (5) {
                return (_wrap(component, "Background", name));
            };
            case(10) {
                return(_wrap(component, "Hair-behind" , name ));
            };
            case (20) {
                return(_wrap(component, "Body" , name ));
            };
            case (30) {
                return(_wrap(component, "Ears" , name ));
            };
            case(35) {
                return(_wrap(component, "Head", name ));
            };
            case(45){
                return(_wrap(component, "Mouth", name ));
            };
            case(50) {
                return(_wrap(component, "Eyes", name ));
            };
            case(55) {
                return(_wrap(component, "Nose", name ));
            };
            case(70) {
                return(_wrap(component, "clothing", name ));
            };
            case(75) {
                return(_wrap(component, "Hair", name));
            };
            case(90) {
                return(_wrap(component, "Hair-above", name));
            };
            case(95){
                return(_wrap(component, "Suit", name));
            };
            // For accessories 
            case(_) {
                return(_wrap(component, "", name));
            };
        };
    };

    /////////////////
    // Utilities ///
    ///////////////

    // Returns an array of string where the given string has been split.
    // @ex : "Business-angry-eyes" -> ["Business", "angry", "eyes"]
    func _nameSplit(name : Text) : [Text] {
        Iter.toArray<Text>(Text.split(name, #char('-')));
    };

    // Wrap the component according to its name and its category. Needed for applying the CSS rules.
    // @todo : Clean this mess.
    func _wrap(name : Text, category : Text, content : Text ) : Text {
        let names = _nameSplit(name);
        var component_wrapped =  "<g class='" # category # " ";
        if(category == "clothing") {
            component_wrapped #= " " # category # "-" # name;
        } else {
            for(name in names.vals()){
                component_wrapped #= " " # name;
            };
        };
        component_wrapped #= "" # name # "'>" # content # "</g>";
        return(component_wrapped);
    };


}