import Result "mo:base/Result";

import Canistergeek "mo:canistergeek/canistergeek";

import Ext "../ext";

module {
    type TokenIndex = Ext.TokenIndex;
    type TokenIdentifier = Ext.TokenIdentifier;
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

    public type LegendaryAccessory = {
        name : Text;
        date_creation : Int;
    };

    public type Recipe = [Text];

    public type UpgradeData = {
        items : [(TokenIndex, Item)];
        templates : [(Text, Template)];
        blobs : [(TokenIndex, Blob)];
    };

    public type Dependencies = {
        _Logs : Canistergeek.Logger;
        _Ext : Ext.Factory;
        cid : Principal;
        cid_avatar : Principal;
    };

    public type Interface = {

        // Add a template for an item (material or accessory with recipe)
        addTemplate(name : Text, template : Template) : Result<Text,Text>;

        //
        wearAccessory(accessory : TokenIdentifier, avatar : TokenIdentifier, caller : Principal) : async Result<(),Text>;

        //
        removeAccessory(accessory : TokenIdentifier, avatar : TokenIdentifier, caller: Principal) : async Result<(),Text>;

        //
        updateAccessory(accessory : TokenIdentifier) : Result<AccessoryUpdate, Text>;

        //
        mint(name : Text, index : TokenIndex) : Result<(), Text>;

        //
        getBlob(index : TokenIndex) : ?Blob;

        getTemplate(name : Text) : ?Blob;

        //
        isEquipped : (index : TokenIndex) -> Bool;
 
    };

}