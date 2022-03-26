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

        public func toStableState() : [Principal] {
            admins.toArray();
        };

        public func fromStableState(state : [Principal]) {
            for (admin in state.vals()){
                admins.add(admin);
            };
        };
        fromStableState(state.admins);

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