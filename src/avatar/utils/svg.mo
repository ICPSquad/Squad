import Text "mo:base/Text";
import Iter "mo:base/Iter";
import Debug "mo:base/Debug";
module {

    let SVG_LEADING_PATTERN = #text("<svg viewBox=\"0 0 800 800\" xmlns=\"http://www.w3.org/2000/svg\">");
    let SVG_TRAILING_PATTERN = #text("</svg>");

    ////////
    //API //
    ////////

    public func unwrap(svg : Text) : Text  {
        let a_opt = Text.stripStart(svg, SVG_LEADING_PATTERN);
        switch(a_opt){
            case(null) {
                Debug.print("SVG.unwrap: no leading pattern found");
                assert(false);
                return "Unreachable";

            };
            case(? a){
                let b_opt = Text.stripEnd(a, SVG_TRAILING_PATTERN);
                switch(b_opt){
                    case(null) {
                        Debug.print("SVG.unwrap: no trailing pattern found");
                        assert(false);
                        return "Unreachable";
                    };
                    case(? b){
                        return b;
                    };
                };
            };
        };
    };

    public func wrap(content : Text, layerId : Nat, name : Text ) : Text {
        switch(layerId){
            case (5) {
                return (_wrap(content, "Background", name));
            };
            case(10) {
                return(_wrap(content, "Hair-behind" , name ));
            };
            case (20) {
                return(_wrap(content, "Body" , name ));
            };
            case (30) {
                return(_wrap(content, "Ears" , name ));
            };
            case(35) {
                return(_wrap(content, "Head", name ));
            };
            case(45){
                return(_wrap(content, "Mouth", name ));
            };
            case(50) {
                return(_wrap(content, "Eyes", name ));
            };
            case(55) {
                return(_wrap(content, "Nose", name ));
            };
            case(70) {
                return(_wrap(content, "clothing", name ));
            };
            case(75) {
                return(_wrap(content, "Hair", name));
            };
            case(90) {
                return(_wrap(content, "Hair-above", name));
            };
            case(95){
                return(_wrap(content, "Suit", name));
            };
            // For accessories 
            case(_) {
                return(_wrap(content, "", name));
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
    func _wrap(content : Text, category : Text, name : Text ) : Text {
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