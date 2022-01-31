module {
    
    //  For the filter to get the detail field
    public func nameToDetailsMaterial (name : Text) : Text {
        switch(name){
            case("Cloth") { return "cloth"};
            case("Wood") {return "wood"};
            case("Glass") {return "glass"};
            case("Metal") {return "metal"};
            case("Circuit"){return "circuit"};
            case("Dfinity-stone"){return "dfinity-stone"};
            case("Cronic-essence") {return "essence"};
            case("Punk-essence") {return "essence"};
            case(_) {return ""};
        };
    };

    public func nameToDetailsAccessory (name : Text) : Text {
        switch(name){
            case("Helicap") {return "hat"};
            case("Ninja-headband") {return "hat"};
            case("Santa-hat") {return "hat"};
            case("Shinobi-hat") {return "hat"};
            case("Dfinity-eyemask") {return "eyes"};
            case("Lab-glasses") {return "eyes"};
            case("Matrix-glasses") {return "eyes"};
            case("Monocle") {return "eyes"};
            case("Dfinity-face-mask") {return "face"};
            case("Oni-half-mask") {return "face"};
            case("Punk-mask") {return "face"};
            case("Assassin-cap") {return "body"};
            case("Astro-cap") {return "body"};
            case("Dark-magic-cap") {return "body"};
            case("Devil-jacket") {return "body"};
            case("Dystopian-jacket") {return "body"};
            case("Helicap-shirt") {return "body"};
            case("Lab-coat") {return "body"};
            case("Shinobi-jacket") {return "body"};
            case("Yakuza-jacket") {return "body"};
            case(_) {return ""};
        };
    };

}