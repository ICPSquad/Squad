import Char "mo:base/Char";
import Debug "mo:base/Debug";
import Iter "mo:base/Iter";
import Nat "mo:base/Nat";
import Option "mo:base/Option";
import Prim "mo:prim";
import Text "mo:base/Text";

module {

    let SVG_LEADING_PATTERN : Text = "<svg viewBox=\"0 0 800 800\" xmlns=\"http://www.w3.org/2000/svg\">";
    let SVG_TRAILING_PATTERN : Text = "</svg>";

    ////////
    //API //
    ////////

    public func capitalize(text : Text) : Text {
        var r = "";
        let cs = text.chars();
        switch(cs.next()){
            case(? c){
                r := Text.fromChar(Prim.charToUpper(c));
            };
            case(null) {
                return("")
            };
        };
        r #= Text.fromIter(cs);
        return(r);
    };

    public func unwrap(svg : Text) : Text {
        _extract(svg, SVG_LEADING_PATTERN.size(), svg.size()  - SVG_LEADING_PATTERN.size() - SVG_TRAILING_PATTERN.size())
    };

    public func addHeader(svg : Text) : Text {
        return SVG_LEADING_PATTERN # svg # SVG_TRAILING_PATTERN;
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
    func _wrap(content : Text, category : Text, name : Text ) : Text {
        let names = _nameSplit(name);
        var component_wrapped =  "<g class='" # category # "";
        if(category == "clothing") {
            component_wrapped #= " " # category # "-" # name;
        } else {
            for(name in names.vals()){
                component_wrapped #= " " # name;
            };
        };
        component_wrapped #= " " # name # "'>" # content # "</g>";
        return(component_wrapped);
    };
    
    // Extract a substring from the given string.
    func _extract(t : Text, i : Nat, j : Nat) : Text {
        let size = t.size();
        if (i == 0 and j == size) return t;
        assert (j <= size);
        let cs = t.chars();
        var r = "";
        var n = i;
        while (n > 0) {
            ignore (cs.next());
            n -= 1;
        };
        n := j;
        while (n > 0) {
        switch (cs.next()){
            case (?c) { r #= Prim.charToText(c) };
            case null { assert false };
        };
        n -= 1;
        };
        return r;
    };
}