import Nat8 "mo:base/Nat8";
import Float "mo:base/Float";

module {
    public type Color = (Nat8, Nat8, Nat8, Nat8);
    public type ColorList = [{spot : Text; color : Color}];


    private func _createColorTextual (color : Color) : Text {
        var text : Text = "";
        text := text # "rgb(";
        text := text # Nat8.toText(color.0) # ",";
        text := text # Nat8.toText(color.1) # ",";
        text := text # Nat8.toText(color.2) # ");";

        return text;
    };

    public func createStyle (colors : ColorList) :  Text {
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