import Text "mo:base/Text";
import Int "mo:base/Int";
import Time "mo:base/Time";
import Array "mo:base/Array";

module {

    public type AirdropObject = {
        recipient : Principal;
        material : Text;
        accessory1 : ?Text;
        accessory2 : ?Text;
    };

    public func randomMaterial () : Text {
        let time = Time.now(); 
        let modulo = Int.rem(time, 21);
        switch(modulo) {
            case(0) return "Cloth";
            case(1) return "Cloth";
            case(2) return "Cloth";
            case(3) return "Cloth";
            case(4) return "Cloth";
            case(5) return "Cloth";
            case(6) return "Wood";
            case(7) return "Wood";
            case(8) return "Wood";
            case(9) return "Wood";
            case(10) return "Wood";
            case(11) return "Glass";
            case(12) return "Glass";
            case(13) return "Glass";
            case(14) return "Glass";
            case(15) return "Metal";
            case(16) return "Metal";
            case(17) return "Metal";
            case(18) return "Circuit";
            case(19) return "Circuit";
            case(20) return "Dfinity-stone";
            case(_) return "Cloth";
        };
    };

    public func randomAccessory1 () : Text {
        let time = Time.now();
        let modulo = Int.rem(time,7);
        switch(modulo) {
            case(0) return "Dfinity-face-mask";
            case(1) return "Monocle";
            case(2) return "Lab-glasses";
            case(3) return "Matrix-glasses";
            case(4) return "Monocle";
            case(5) return "Oni-half-mask";
            case(6) return "Dfinity-eyemask";
            case(_) return "Lab-glasses";
        };
    };

    public func randomAccessory2 () : Text {
        let time = Time.now();
        let modulo = Int.rem(time,3);
        switch(modulo){
            case(0) return "Helicap";
            case(1) return "Marshall-hat";
            case(2) return "Ninja-headband";
            case(_) return "Helicap";
        };
    };

    public func airdropObjectFromRank (rank : Nat, recipient : Principal) : AirdropObject {
        
        if(rank <=1000){
            let airdrop_object : AirdropObject = {
                recipient = recipient;
                material = randomMaterial();
                accessory1 = ?randomAccessory1();
                accessory2 = ?randomAccessory2();
            };
            return airdrop_object;
        };
        if(rank <= 2500) {
            let airdrop_object = {
                recipient = recipient;
                material = randomMaterial();
                accessory1 = ?randomAccessory1();
                accessory2 = null;
            };
            return airdrop_object;
        };

        let airdrop_object = {
            recipient = recipient;
            material = randomMaterial();
            accessory1 = null;
            accessory2 = null;
        };
        return airdrop_object;
    };

    public func aidropObjectToList (airdrop_object : AirdropObject) : [Text] {
        var array : [Text] = [airdrop_object.material];
        switch(airdrop_object.accessory1){
            case(null) return array;
            case(?accessory1){
                array := Array.append<Text>(array, [accessory1]);
                switch(airdrop_object.accessory2){
                    case(null) return array;
                    case(?accessory2){
                        array := Array.append<Text>(array,[accessory2]);
                        return array;
                    };
                };
            };
        };
    };



}