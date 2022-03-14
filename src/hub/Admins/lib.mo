import Types "types";
import Buffer "mo:base/Buffer";
module {
    public class Admins(state : Types.State) : Types.Interface {
        //  Make sure that there is always at least one admin at initialization.
        assert(state.admins.size() != 0);

        ////////////
        // State //
        //////////

        private var admins : Buffer.Buffer<Principal> = Buffer.Buffer(0);
        for (admin in state.admins.vals()){
            admins.add(admin);
        };

        public func getStateStable() : [Principal] {
            admins.toArray();
        };


        //////////
        // API //
        ////////

        public func isAdmin(p : Principal) : Bool {
            for(principal in admins.vals()){
                if (principal == p) return true;
            };
            false;
        };

        public func addAdmin(p : Principal, caller : Principal) : () {
            assert(isAdmin(caller));
            admins.add(p);
        };

        public func removeAdmin(p : Principal, caller : Principal) : () {
            assert(isAdmin(caller));
            let newAdmins : Buffer.Buffer<Principal> = Buffer.Buffer(0);
            for (principal in admins.vals()){
                if(principal != p){
                    newAdmins.add(principal);
                };
            };
            //  Make sure we never have 0 admins left
            assert(newAdmins.size() != 0);
            admins.clear();
            for (principal in newAdmins.vals()){
                admins.add(principal);
            };
        };
    }
}