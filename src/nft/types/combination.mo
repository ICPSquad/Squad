import Hash "mo:base/Hash";
import Text "mo:base/Text";

module {
    // Accessory sometimes needs to have side-effect when they are wear.
    // We store globally for each combination a modification to apply (or not if there is nothing to do). 
    
    public type Combination = (Text, Text); // e.g ("Helicap", "Hair-13") 
    
    public type Modification = {
        #Remove;
        #Change : Text; // e.g #Change("Hair-hait")
        #Transform : Transformation; 
    };
    public type Transformation =  (transform_X : Nat8 , transform_Y : Nat8, scale_X : Nat8, scale_Y : Nat8);  

    public func equal (a : Combination, b : Combination) : Bool {
        if ((a.0 == b.0) and (a.1 == b.1)) {
            return true;
        } else {
            return false;
        };
    };

    public func hash (a : Combination) : Hash.Hash {
        let sum : Text = a.0 # a.1;
        return (Text.hash(sum));
    };


}