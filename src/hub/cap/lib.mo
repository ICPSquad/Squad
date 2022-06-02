import Principal "mo:base/Principal";

import Types "types";
module {
    public class Factory(dependencies : Types.Dependencies) : Types.Interface {

        let bucket_accessory : Types.Bucket = actor(Principal.toText(dependencies.cid_bucket_accessory));
        let bucket_avatar : Types.Bucket = actor(Principal.toText(dependencies.cid_bucket_avatar));

        //////////
        // API //
        ////////

        public func numberMint(caller : Principal, name : ?Text) : async Nat {
            // Query the list of events for this user from the CAP bucket.
            let result = await bucket_accessory.get_user_transactions({
                page = null;
                user = caller;
                witness = false;
            });
            let events = result.data;
            // Count the number of mint events (corresponding to the eventual accessories or to all).
            var count : Nat = 0;
            switch(name){
                case(null) {
                    // Count all the mint events.
                    for(event in events.vals()){
                        if(event.operation == "mint"){
                            count += 1;
                        };
                    };
                };
                case(? name){
                    // Count only the mint events corresponding to the given name.
                    for(event in events.vals()){
                        if(event.operation == "burn"){
                            if(_isEventAbout(name, event)){
                                count += 1;
                            };
                        };
                    };
                };
            };
            return count;
        };
        
        public func numberBurn(caller : Principal, name : ?Text) : async Nat {
            // Query the list of events for this user from the CAP bucket.
            let result = await bucket_accessory.get_user_transactions({
                page = null;
                user = caller;
                witness = false;
            });
            let events = result.data;
            // Count the number of burn events (corresponding to the eventual accessories or to all).
            var count : Nat = 0;
            switch(name){
                case(null) {
                    // Count all the burn events.
                    for(event in events.vals()){
                        if(event.operation == "burn"){
                            count += 1;
                        };
                    };
                };
                case(? name){
                    // Count only the burn events corresponding to the given name.
                     for(event in events.vals()){
                        if(event.operation == "burn"){
                            if(_isEventAbout(name, event)){
                                count += 1;
                            };
                        };
                    };
                };
            };
            return count;
        };

        //////////////
        // Helpers //
        ////////////

        /*
            Returns a boolean indicating if an event is related to an accessory by looking trough the available details and finding the name.  
        */
        func _isEventAbout(
            name : Text,
            event : Types.Event
            ) : Bool {
            let details = event.details;
            for((key, value) in details.vals()){
                if(key == "name"){
                    switch(value){
                        case(#Text(message)){
                            return (message == name);
                        };
                        case _ {
                            return false;
                        };
                    };
                };
            };
            return false;
        };



    };
}