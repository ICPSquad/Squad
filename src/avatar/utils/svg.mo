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

    public func wrapClassAvatar(content : Text, layerId : Nat , name : Text) : Text {
        switch(layerId){
            case (5) {
                return (_wrapComponent(content, "Background", _capitalizeFirstLetter(name)));
            };
            case(10) {
                return(_wrapComponent(content, "Hair-behind" ,  _capitalizeFirstLetter(name) ));
            };
            case (20) {
                return(_wrapComponent(content, "Body" ,  _capitalizeFirstLetter(name) ));
            };
            case(25) {
                return(_wrapComponent(content, "Neck",  _capitalizeFirstLetter(name) ));
            };
            case (30) {
                return(_wrapComponent(content, "Ears" ,  _capitalizeFirstLetter(name) ));
            };
            case(35) {
                return(_wrapComponent(content, "Head",  _capitalizeFirstLetter(name) ));
            };
            case(45){
                return(_wrapComponent(content, "Mouth",  _capitalizeFirstLetter(name) ));
            };
            case(50) {
                return(_wrapComponent(content, "Eyes",  _capitalizeFirstLetter(name) ));
            };
            case(55) {
                return(_wrapComponent(content, "Nose",  _capitalizeFirstLetter(name) ));
            };
            case(70) {
                return(_wrapComponent(content, "clothing",  _capitalizeFirstLetter(name) ));
            };
            case(75) {
                return(_wrapComponent(content, "Hair",  _capitalizeFirstLetter(name)));
            };
            case(78) {
                return(_wrapComponent(content, "Hair",  _capitalizeFirstLetter(name)));
            };
            case(90) {
                return(_wrapComponent(content, "Hair-above",  _capitalizeFirstLetter(name)));
            };
            case(_) {
                assert(false);
                return(_wrapComponent(content, "Unreacheable",  _capitalizeFirstLetter(name)));
            };
        };
    };


    public func wrapClassAccessory(
        content : Text,
        layerId : Nat,
        name : Text
    ) : Text {
        let class_accessory : Text = _capitalizeFirstLetter(name) # "-" # Nat.toText(layerId);
        return(_wrap(content, class_accessory));
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
    func _wrapComponent(content : Text, category : Text, name : Text ) : Text {
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


    func _wrap(content : Text, title : Text) : Text {
        return("<g class='" # title # "'>" # content # "</g>");
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

    func _capitalizeFirstLetter(t : Text) : Text {
        let cs = t.chars();
        var r = "";
        var count = 0;
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
    

  
}