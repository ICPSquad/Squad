import HashMap "mo:base/HashMap";
import Iter "mo:base/Iter";
import Principal "mo:base/Principal";
import Result "mo:base/Result";

import Types "types";

module {

    ////////////
    // Types //
    ///////////

    public type UpgradeData = Types.UpgradeData;
    public type User = Types.User;
    public type Status = Types.Status;
    type Result<A,B> = Result.Result<A,B>;

    public class Users(dependencies : Types.Dependencies) : Types.Interface {

        
        //////////////
        /// State ///
        ////////////

        private let _users : HashMap.HashMap<Principal,User> = HashMap.HashMap<Principal,User>(0, Principal.equal, Principal.hash);

        //TODO : actors declaration

        public func preupgrade() : UpgradeData {
            return ({
                users = Iter.toArray(_users.entries());
            })
        };

        public func postupgrade(ud : ?UpgradeData) {
            switch(ud) {
                case(null) {};
                case(? ud) {
                    for((principal, users) in ud.users.vals()){
                        _users.put(principal, users);
                    };
                };
            };
        };

        private let _Invoice = dependencies._Invoice;

        ////////////
        // API ////
        ///////////

        public func register(
            caller : Principal,
            user : User
        ) : Result<(), Text> {
            switch(_users.get(caller)){
                case(? some) return #err("User is already registered : " #Principal.toText(caller));
                case(null) {
                    _users.put(caller, user);
                    return #ok;
                };
            };
        };

        public func confirm(
            caller : Principal
        ) : Result<(), Text> {
            //TODO
            #ok;
        };

        public func mint(
            caller : Principal
        ) : Result<(), Text> {
            //TODO
            #ok;
        };

        public func getSize() : Nat {
            var count = 0;
            for(user in _users.vals()){
                switch(user.status){
                    case(#Member(_)) {
                        count += 1;
                    };
                    case _ {};
                };
            };
            count;
        };

        public func getStatus(
            caller : Principal
        ) : Status {
            if(Principal.isAnonymous(caller)) return #NotAuthenticated;
            switch(_users.get(caller)){
                case(null) return #NotRegistered;
                case (? some){
                    return some.status;
                };
            };
        };

        public func getUser(
            caller : Principal
        ) : Result<User,Text> {
            switch(_users.get(caller)){
                case(null) return #err("Caller is not registered : "  #Principal.toText(caller));
                case(? some) return #ok(some);
            };
        };

    };
};