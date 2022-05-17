import TrieMap "mo:base/TrieMap";
import Iter "mo:base/Iter";
import Principal "mo:base/Principal";
import Result "mo:base/Result";
import Option "mo:base/Option";
import Nat64 "mo:base/Nat64";
import Prim "mo:prim";
import Text "mo:base/Text";
import Buffer "mo:base/Buffer";
import Ext "mo:ext/Ext";

import Types "types";

module {

    ////////////
    // Types //
    ///////////

    public type UpgradeData = Types.UpgradeData;
    public type User = Types.User;
    public type Name = Types.Name;
    public type Message = Types.Message;
    public type TokenIndex = Ext.TokenIndex;
    type Result<A,B> = Result.Result<A,B>;
    type TokenIdentifier = Text;

    public class Users(dependencies : Types.Dependencies) {

        //////////////
        /// State ///
        ////////////

        private let _users : TrieMap.TrieMap<Principal,User> = TrieMap.TrieMap<Principal,User>(Principal.equal, Principal.hash);

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

        let _Ext = dependencies._Ext;
        
        ////////////
        // API ////
        ///////////


        public func whitelist(
            caller : Principal
        ) : Result<(), Text> {
            switch(_users.get(caller)){
                case(? some) return #err("User is already registered : " #Principal.toText(caller));
                case(null) {
                    _users.put(caller, _newUser());
                    return #ok;
                };
            };
        };

        public func register(
            caller : Principal,
        ) : Result<(), Text> {
            switch(_users.get(caller)){
                case(? some) return #err("User is already registered : " #Principal.toText(caller));
                case(null) {
                    _users.put(caller, _newUser());
                    return #ok;
                };
            };
        };

        public func welcome(
            caller : Principal,
            invoice_id : ?Nat,
            avatar : TokenIdentifier
        ) : () {
            switch(_users.get(caller)){
                case(null) {
                    let new_user = {
                        name = null;
                        email = null;
                        discord = null;
                        twitter = null;
                        rank = ?Nat64.fromNat(_users.size());
                        height = null;
                        minted = true;
                        account_identifier = ?Text.map(Ext.AccountIdentifier.fromPrincipal(caller, null), Prim.charToLower);
                        invoice_id = invoice_id;
                        message_leaderboard = null;
                        selected_avatar = ?avatar;
                    };
                    _users.put(caller, new_user);
                };
                case(? user){
                    let new_user = {
                        name = user.name;
                        email = user.email;
                        discord = user.discord;
                        twitter = user.twitter;
                        rank = user.rank;
                        height = user.height;
                        minted = user.minted;
                        account_identifier = user.account_identifier;
                        invoice_id = invoice_id;
                        message_leaderboard = user.message_leaderboard;
                        selected_avatar = ?avatar;
                    };
                    _users.put(caller, new_user);
                };
            };
        };

        public func getUser(
            caller : Principal
        ) : ?User {
            _users.get(caller);
        };

        public func modifyUser(
            caller : Principal,
            user : User
        ) : Result<(), Text> {
            switch(_users.get(caller)){
                case(null) return #err("No user profile detected for : " # Principal.toText(caller));
                case(? some) {
                    _users.put(caller, user);
                    return #ok;
                };
            };
        };

        public func calculateAccounts() : () {
            for((p, user) in _users.entries()){
                if(Option.isNull(user.account_identifier)){
                    let account = Text.map(Ext.AccountIdentifier.fromPrincipal(p, null), Prim.charToLower);
                    let new_user = {
                        name = user.name;
                        email = user.email;
                        discord = user.discord;
                        twitter = user.twitter;
                        rank = user.rank;
                        height = user.height;
                        minted = user.minted;
                        account_identifier = ?account;
                        invoice_id = user.invoice_id;
                        message_leaderboard = user.message_leaderboard;
                        selected_avatar = user.selected_avatar;
                    };
                    _users.put(p, new_user);
                };
            };
        };

        public func getUsers() : [(Principal, User)] {
            return Iter.toArray(_users.entries());
        };

        public func getInfosLeaderboard() : [(Principal, ?Name, ?Message, ?TokenIdentifier)] {
            var buffer : Buffer.Buffer<(Principal, ?Name, ?Message, ?TokenIdentifier)> = Buffer.Buffer<(Principal, ?Name, ?Message, ?TokenIdentifier)>(0);
            for((p, user) in _users.entries()) {
                let infos = (p, user.name, user.message_leaderboard, _getAvatar(p, user));
                buffer.add(infos);
            };
            return buffer.toArray();
        };

        /////////////////
        // UTILITIES ////
        ////////////////

        func _newUser() : User {
            {
                name = null;
                email = null;
                discord = null;
                twitter = null;
                rank = ?(Nat64.fromNat(_users.size()));
                height = null;
                minted = false;
                account_identifier = null;
                invoice_id = null;
                message_leaderboard = null;
                selected_avatar = null;
            }
        };

        func _verifySelectedAvatar(tokenId : TokenIdentifier, account : Text) : Bool {
            switch(_Ext.bearer(tokenId)){
                case(#err(_)) return false;
                case(#ok(owner)){
                    if(owner == account) {
                        return true;
                    };
                    return false;
                };
            };
        };

        func _getAvatar(p : Principal, user : User) : ?TokenIdentifier {
            let account = switch(user.account_identifier){
                case(? some) some;
                case(null) Text.map(Ext.AccountIdentifier.fromPrincipal(p, null), Prim.charToLower);
            };
            switch(user.selected_avatar){
                case(null) return null;
                case(? token){
                    if(_verifySelectedAvatar(token, account)){
                        return ?token;
                    };
                    return null;
                };
            };
        };

    };
};