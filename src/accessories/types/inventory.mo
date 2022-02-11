import Array "mo:base/Array";
import Result "mo:base/Result";
import Iter "mo:base/Iter";

module {

    public type AssetInventoryType = {
        #Accessory : Bool; //   Boolean represents the fact that the accessory can be equipped or not!
        #Material;
        #LegendaryAccessory;
    };

    public type AssetInventory = {
        category : AssetInventoryType;
        name : Text;
        token_identifier : Text; 
    };

    public type Inventory = [AssetInventory];

    private func _isMaterial (name : Text) : Bool {
        if (name == "Wood" or name == "Cloth" or name == "Glass" or name == "Metal" or name == "Circuit" or name == "Dfinity-stone"){
            return true;
        };
        return false;
    };
}