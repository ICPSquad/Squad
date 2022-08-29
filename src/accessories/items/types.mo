import Result "mo:base/Result";
import Time "mo:base/Time";

import Canistergeek "mo:canistergeek/canistergeek";

import Cap "../cap";
import Ext "../ext";

module {
    type TokenIndex = Ext.TokenIndex;
    type TokenIdentifier = Ext.TokenIdentifier;
    type Time = Time.Time;
    type Result<A,B> = Result.Result<A,B>;

    public type Template = {
        #Material : Blob; 
        #Accessory : {before_wear : Text; after_wear : Text; recipe : Recipe};
        #LegendaryAccessory : Blob;
    };

    public type Item = {
        #Material : Text; 
        #Accessory : Accessory; 
        #LegendaryAccessory : LegendaryAccessory;
    };
    
    public type Accessory = {
        name : Text;
        wear : Nat8;
        equipped : ?TokenIdentifier; //Token_identifier of the avatar they are equipped on. 
    };

    public type AccessoryUpdate = {
        #Burned;
        #Decreased ;
    };

    public type Inventory = [ItemInventory];
    public type ItemInventory = {
        #Material : MaterialInventory;
        #Accessory : AccessoryInventory;
    };

    public type MaterialInventory = {
        name : Text;
        tokenIdentifier : Text;
    };

    public type AccessoryInventory = {
        name : Text;
        tokenIdentifier : Text;
        equipped : Bool;
    };

    public type LegendaryAccessory = {
        name : Text;
        date_creation : Int;
    };

    public type Recipe = [Text];

    public type BurnedInformation = {
        time_card_burned : Time; // The moment the accessory (card) was burned
        time_avatar_burned : ?Time; // The (optional) moment the avatar canister reported it removed the accessory from the avatar. 
        name : Text; // The name of the accessory
        tokenIdentifier : TokenIdentifier; // The avatar this accessory was equipped on  
    };

    public type BurnedAccessory = {
        name : Text;
        tokenIndex : TokenIndex;
        tokenIdentifier : TokenIdentifier;
    };


    public type UpgradeDataOld = {
        items : [(TokenIndex, Item)];
        templates : [(Text, Template)];
        recipes : [(Text, Recipe)];
        burned : [(TokenIndex, BurnedInformation)];
    };

    public type UpgradeData = {
        items : [(TokenIndex, Item)];
        templates : [(Text, Template)];
        recipes : [(Text, Recipe)];
        pendingBurned : [BurnedAccessory];
    };

    public type Dependencies = {
        _Logs : Canistergeek.Logger;
        _Ext : Ext.Factory;
        _Cap : Cap.Factory;
        cid : Principal;
        cid_avatar : Principal;
    };

    public type Interface = {

        addTemplate(name : Text, template : Template) : Result<Text,Text>;

        wearAccessory(accessory : TokenIdentifier, avatar : TokenIdentifier, caller : Principal) : async Result<(),Text>;

        removeAccessory(accessory : TokenIdentifier, avatar : TokenIdentifier, caller: Principal) : async Result<(),Text>;

        mint(name : Text, index : TokenIndex) : Result<(), Text>;

        getBlob(index : TokenIndex) : ?Blob;

        getTemplate(name : Text) : ?Blob;

        isEquipped : (index : TokenIndex) -> Bool;
 
    };

}