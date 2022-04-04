import Nat8 "mo:base/Nat8";
import Float "mo:base/Float";

module  {
    public type Color = (Nat8, Nat8, Nat8, Nat8);
    public type Colors = [{spot : Text; color : Color}];

    //////////
    // API //
    ////////
    public type Style = {
        #Old : Text; // To easily convert old avatars to new format.
        #Colors : Colors;
    };
    // Create the <style> tag that we need to add at the top of the svg based on the colors passed as argument.
    public func createStyle (style : Style) :  Text {
        switch(style){
            case(#Old(text)) return text;
            case (#Colors(colors)) {
                var style : Text = "<style> :root {";
                for (val in colors.vals()) {
                    if (val.spot == "Skin") {
                        style := style # "--color_skin :";
                        style := style # _createColorTextual(val.color);
                    };
                    if(val.spot == "Clothes") {
                        style := style # "--color_clothes :";
                        style := style # _createColorTextual(val.color);
                    };
                    if (val.spot == "Hairs") {
                        style := style # "--color_hairs_r:";
                        style := style # Nat8.toText((val.color.0));
                        style := style # ";";
                        style := style # "--color_hairs_g:";
                        style := style # Nat8.toText((val.color.1));
                        style := style # ";";
                        style := style # "--color_hairs_b:";
                        style := style # Nat8.toText((val.color.2));
                        style := style # ";";
                    };
                    if (val.spot == "Eyes") {
                        style := style # "--color_eyes_r:";
                        style := style # Nat8.toText((val.color.0));
                        style := style # ";";
                        style := style # "--color_eyes_g:";
                        style := style # Nat8.toText((val.color.1));
                        style := style # ";";
                        style := style # "--color_eyes_b:";
                        style := style # Nat8.toText((val.color.2));
                        style := style # ";";
                    };
                    if (val.spot == "Eyebrows") {
                        style := style # "--color_eyebrows_r:";
                        style := style # Nat8.toText((val.color.0));
                        style := style # ";";
                        style := style # "--color_eyebrows_g:";
                        style := style # Nat8.toText((val.color.1));
                        style := style # ";";
                        style := style # "--color_eyebrows_b:";
                        style := style # Nat8.toText((val.color.2));
                        style := style # ";";
                    };
                    if (val.spot == "Background") {
                        style := style # "--color_background_r:";
                        style := style # Nat8.toText((val.color.0));
                        style := style # ";";
                        style := style # "--color_background_g:";
                        style := style # Nat8.toText((val.color.1));
                        style := style # ";";
                        style := style # "--color_background_b:";
                        style := style # Nat8.toText((val.color.2));
                        style := style # ";";
                        style := style # "--color_background_a:";
                        style := style # Float.toText((Float.fromInt(Nat8.toNat(val.color.3)) / 100));
                        style := style # ";";
                    };
                    if (val.spot == "Eyeliner") {
                        style := style # "--color_eyeliner_r:";
                        style := style # Nat8.toText((val.color.0));
                        style := style # ";";
                        style := style # "--color_eyeliner_g:";
                        style := style # Nat8.toText((val.color.1));
                        style := style # ";";
                        style := style # "--color_eyeliner_b:";
                        style := style # Nat8.toText((val.color.2));
                        style := style # ";";
            
                    };
            };
            style := style # "} </style>";
            return style;
            };
        };
    };


    ////////////////
    // Utilities //
    ///////////////

    // Retturns the textual representation of color that can be added to the <style> based on the color paramater.
    func _createColorTextual (color : Color) : Text {
        "rgb(" # Nat8.toText(color.0) # "," # Nat8.toText(color.1) # "," # Nat8.toText(color.2) # ");";
    };

};