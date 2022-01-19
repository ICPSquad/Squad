import Array "mo:base/Array";
import Result "mo:base/Result";
import Iter "mo:base/Iter";

module {

    public type AssetInventoryType = {
        #Accessory;
        #Material;
    };

    public type AssetInventory = {
        category : AssetInventoryType;
        name : Text;
        token_identifier : Text; 
    };

    public type Inventory = [AssetInventory];


    public func buildInventory (token_list : [Text], asset_name : [Text]) : Result.Result<Inventory, Text> {
        let size = token_list.size();
        if(size != asset_name.size()) {
            return #err ("Lists should have the same size to build inventory.");
        };
        var inventory : Inventory = [];
        let iterator = Iter.range(0, size - 1);
        for (i in iterator){
            if(_isMaterial(asset_name[i])){
                let new_asset : AssetInventory = {
                    category = #Material;
                    name = asset_name[i];
                    token_identifier = token_list[i];
                };
                inventory := Array.append<AssetInventory>(inventory, [new_asset]);
            } else {
                let new_asset : AssetInventory = {
                    category = #Accessory;
                    name = asset_name[i];
                    token_identifier = token_list[i];
                };
                inventory := Array.append<AssetInventory>(inventory, [new_asset]);
            };  
        };
        return #ok(inventory);
    };


    private func _isMaterial (name : Text) : Bool {
        if (name == "Wood" or name == "Cloth" or name == "Glass" or name == "Metal" or name == "Circuit" or name == "Dfinity-stone"){
            return true;
        };
        return false;
    };

    public func toArray (inventory : Inventory) : [Text] {
        var array : [Text] = [];
        for(asset in inventory.vals()){
            array := Array.append<Text>(array, [asset.name]);
        };
        return array;
    };
}