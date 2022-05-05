import Result "mo:base/Result";
module {

    public type Color = (Nat8, Nat8, Nat8, Nat8);
    public type Colors = [{spot : Text; color : Color}];
    public type MintInformation = {
        background : Text;
        profile : Text;
        ears : Text;
        mouth : Text;
        eyes : Text;
        nose : Text;
        hair : Text;
        cloth : Text;
        colors : Colors;
    };

}