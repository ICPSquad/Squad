module {
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
    
    type TokenIdentifier = Text;
    public type Accessory = {
        name : Text;
        wear : Nat8;
        equipped : ?TokenIdentifier; //Token_identifier of the avatar they are equipped on. 
    };

    public type LegendaryAccessory = {
        name : Text;
        date_creation : Int;
    };

    public type Recipe = [Text];

}