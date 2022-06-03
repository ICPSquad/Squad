import Result "mo:base/Result";

import Canistergeek "mo:canistergeek/canistergeek";
import Ext "mo:ext/Ext";

import Admins "../admins";
import Assets "../assets";


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
    public type Style = {
        #Old : Text; // To be compatible with old style of doing avatars.
        #Colors : Colors;
    };

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
        style : Style;
        level : Level;
        blob : Blob;
    };

    public type AvatarRendering = {
        background  : Text;
        profile : Text;
        ears : Text;
        mouth : Text;
        eyes : Text;
        nose : Text;
        hair : Text;
        cloth : Text;
        slots : Slots;
        style : Style;
    };

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

    public type Level = {
        #Level1;
        #Level2;
        #Level3;
        #Legendary;
    };

    public type UpgradeData = {
        avatars : [(TokenIdentifier, Avatar)]; 
        components : [(Text, Component)];
        style : Text;
    };

    public type Dependencies = {
        _Admins : Admins.Admins;
        _Assets : Assets.Assets;
        _Logs : Canistergeek.Logger;
    };

    public type State = UpgradeData and Dependencies; 

    ////////////////////
    // Star system ////
    //////////////////

    public type Stars = Nat;
    public type Name = Text;

    public type Interface = {
        
        // Get the UD before upgrading.
        preupgrade : () -> UpgradeData; 

        // Reinitialize the state of the module after upgrading.
        postupgrade : ?UpgradeData -> ();

        // Add a component into the store (accessory or avatar) for the associated name.
        addComponent : (Text, Component) -> Result<(), Text>;

        // Change the default CSS style for all avatars.Admins
        changeCSS : (Text) -> ();

        // Create a new avatar from the informations for the associated TokenIdentifier.
        createAvatar : (MintInformation,TokenIdentifier) -> Result<(), Text>;

        // Create a new avatar from the name for the associated TokenIdentifier.
        createLegendary : (Text, TokenIdentifier) -> Result<(), Text>;

        // Equip the accessory corresponding to the name for the avatar associated with the TokenIdentifier.
        wearAccessory : (TokenIdentifier, Text) -> Result<(), Text>;

        // Desequip the accessory corresponding to the name for the avatar associated with the TokenIdentifier.
        removeAccessory : (TokenIdentifier, Text) -> Result<(), Text>;

        // Draw the avatar associated with the TokenIdentifier.
        drawAvatar : TokenIdentifier -> Result<(), Text>;

        // Get the optional avatar associated with the TokenIdentifier.
        getAvatar : TokenIdentifier -> ?Avatar;

        // Get the optional blob associated with the TokenIdentifier.
        getBlob : TokenIdentifier -> ?Blob;

        // Get the optional slot associated with the TokenIdentifier.
        getSlot : (TokenIdentifier) -> ?Slots;

        // Get the number of (normal) avatars & (legendaries) avatars created.
        getStats : () -> (Nat,Nat);
    };
};