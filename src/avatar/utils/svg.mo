import Text "mo:base/Text";

module {

    let SVG_LEADING_PATTERN : Pattern = #text("<svg xmlns=\"http://www.w3.org/2000/svg\">");
    let SVG_TRAILING_PATTERN : Pattern = #text("</svg>");

    public func getTextualComponent(svg : Blob) ->  {
        switch(Text.decodeUtf8(svg)){
            case(null) return #err;
            case(? svg_textual){
                return(Text.trimEnd(Text.trimEnd(svg_textual, SVG_LEADING_PATTERN), SVG_TRAILING_PATTERN));
            };
        };
    };

    ////////////////////////////
    // Wrappers for CSS class //
    ///////////////////////////

    public func wrapComponent(component : Text, layerId : LayerId, name : Text ) : Text {
        switch(layer){
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
        }:
    };

    public func wrapAccessory(name : Text, content : Text ) : Text {
        "<g class='" + name + "'>" + content + "</g>";
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
    func _wrapClass(name : Text, category : Text, content : Text ) : Text {
        let names = _nameSplit(name);
        var component_wrapped =  "<g class='" # category # " ";
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


}