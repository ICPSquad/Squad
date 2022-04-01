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
        name : Text;
        layers : [Nat];
        category : ComponentCategory;
    };

    public type ComponentCategory = {
        #Avatar ;
        #Accessory;
        #Other;
    };

    public type Slots = {
        Hat :  ?Text;
        Eyes : ?Text;
        Misc : ?Text;
        Body : ?Text;
        Face : ?Text;
    };

    public type Layers = [(LayerId, Text)];
    public type Colors = [{spot : Text; color : Color}];

    public type Avatar = {
        background  : Text;
        profile : Text;
        ears : Text;
        mouth : Text;
        eyes : Text;
        nose : Text;
        hair : Text;
        cloth : Text;
        slots : Slots;
        colors : Colors;
        level : Level;
    };

    public type Level = {
        #Level1;
        #Level2;
        #Level3;
        #Legendary;
    };

    public type UpgradeData = {
        avatars : [(TokenIdentifier, Avatar)]; 
        blobs : [(TokenIdentifier, Blob)];
        components : [(TokenIdentifier, Component)];
        style : Text;
    };

    public type Dependencies = {
        _Admins : Admins.Admins;
        _Assets : Assets.Assets;
    };

    public type State = UpgradeData and Dependencies; 

    ////////////
    // OLD ////
    ///////////

    public type AvatarRequest = {
        components : [ComponentRequest];
        colors : Colors;
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
        preupgrade : () -> UpgradeData;
    };


}