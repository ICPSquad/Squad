import Types "types";
import Buffer "mo:base/Buffer";
module {

    ////////////
    // Types //
    //////////
    
    public type UpgradeData = Types.UpgradeData;

    public class Admins() : Types.Interface {

        ////////////
        // State //
        //////////

        private var admins : Buffer.Buffer<Principal> = Buffer.Buffer(0);

        public func preupgrade() : UpgradeData {
            {
                admins = admins.toArray();
            }
        };

        public func postupgrade(ud : ?UpgradeData) {
            switch(ud){
                case(? ud) {
                    for (admin in ud.admins.vals()){
                        admins.add(admin);
                    };
                };
                case _ {};
            };
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

        public func getAdmins() : [Principal] {
            admins.toArray();
        };
    }
}