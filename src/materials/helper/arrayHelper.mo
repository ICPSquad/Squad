import AssocList "mo:base/AssocList";
import HashMap "mo:base/HashMap";
import Text "mo:base/Text";

module {

    // Checks whether an array contains a given value.
    public func contains<T>(xs : [T], y : T, equal : (T, T) -> Bool) :  Bool {
        for (x in xs.vals()) {
            if (equal(x, y)) return true;
        }; false;
    };



    // Check whether if blueprint is a subset of user_materials   
    // Can be used to check if a list of materials is enough to build an accessory!

    // Example 1 
    // blueprint = ["Wood", "Wood"] (Blueprint of an accesory) 
    // user_materials = ["Wood", "Glass", "Glass", "Gemstone", "Wood"] 
    // -> true 

    // Example 2 
    // blueprint = ["Dfinity-circuit", "Wood"]
    // user_materials = ["Wood", "Glass", "Glass", "Gemstone", "Wood"]
    // -> false


    public func isSubset (blueprint : [Text], user_materials  : [Text]) : Bool {

        let name_to_number_blueprint : HashMap.HashMap<Text,Nat> = HashMap.HashMap(10, Text.equal, Text.hash);
        let name_to_number_user_materials : HashMap.HashMap<Text,Nat> = HashMap.HashMap(10, Text.equal, Text.hash);

        // Build AssocList for A and B
        for (name in blueprint.vals()) {
            switch(name_to_number_blueprint.get(name)) {
                case (null) {ignore(name_to_number_blueprint.replace(name,1))};
                case (?value) {ignore(name_to_number_blueprint.replace(name,value+1))};
            };
        };

        for (name in user_materials.vals()) {
            switch(name_to_number_user_materials.get(name)) {
                case (null) {ignore(name_to_number_user_materials.replace(name,1))};
                case (?value) {ignore(name_to_number_user_materials.replace(name,value+1))};
            };
        };

        // Compare the value for each name to check if everything in blueprint is available
        for ((k,v) in name_to_number_blueprint.entries()) {
            switch (name_to_number_user_materials.get(k)) {
                case (null) return false;
                case (?value) {
                    if (value < v) {
                        return false;
                    }
                };
            };
        };

        return true;
    };

    // Check whether an array is composed of single appearance value only or not 
    // Example 1 
    // array = ["1" , "25" , "55"]
    // -> false

    // Example 2 
    // array = ["1" , "25" , "1"]
    // -> true

    public func isArrayRedundant (array : [Text]) :  Bool {    
        let stockage : HashMap.HashMap<Text,Bool> = HashMap.HashMap(0, Text.equal, Text.hash);
        for (value in array.vals()) {
            switch(stockage.get(value)) {
                case (null) {stockage.put(value, true)};
                case (?value) {return true};
            };
        };
        return false;
    };

}