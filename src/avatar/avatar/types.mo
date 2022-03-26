import Ext "mo:ext/Ext";
import Admins "../admins";
import Assets "../assets";
import Result "mo:base/Result";

module {

    public type Result<A,B> = Result.Result<A,B>;
    public type Color = (Nat8, Nat8, Nat8, Nat8);
    public type LayerId = Nat;
    public type TokenIdentifier = Ext.TokenIdentifier;

    public type Component = {
        layers : [Nat],
        category : ComponentCategory;
    };

    public type ComponentCategory = {
        #Accessory : Accessory;
        #Background;
        #Body;
        #Clothing;
        #Ears;
        #Eyes;
        #Nose;
        #Mouth;
        #Hair;
        #Profile;
        #Other;
    };

    public type Accessory = {
        #Hat;
        #Eyes;
        #Misc;
        #Body;
        #Face;
        #Other;
    };

    public type Slots = {
        Hat :  ?Text;
        Eyes : ?Text;
        Misc : ?Text;
        Body : ?Text;
        Face : ?Text;
    };

    public type Avatar = {
        layers : [(LayerId, Text)];
        color : [{spot : Text, color : Color}];
        slots : Slots;
        level : Level;
        blob : Blob;
    };

    public type Level = {
        #Level1;
        #Level2;
        #Level3;
        #Legendary;
    };

    public type State = {
        avatars : [(TokenIdentifier, Avatar)]; 
        components : [(TokenIdentifier, Component)];
    };

    public type Dependencies = {
        _Admins = Admins.Admins;
        _Assets = Assets.Assets;
    };

    public type Parameters = State and Dependencies;

    ////////////
    // OLD ////
    ///////////

    public type AvatarRequest = {
        components : [ComponentRequest];
        colors : [{spot : Text; color : Color}];
    };

    public type ComponentRequest = {
        name : Text;
        layer : Nat8; 
    };

    public type Interface = {
        getAvatar : TokenIdentifier -> ?Avatar;
        createAvatar : (AvatarRequest,TokenIdentifier) -> Result<(), Text>;
        wearAccessory : (TokenIdentifier, Text) -> Result<(), Text>;
        removeAccessory : (TokenIdentifier, Text) -> Result<(), Text>;
        removeAllAccessories : TokenIdentifier -> Result<(), Text>;
        toStableState : () -> State;
    };

}