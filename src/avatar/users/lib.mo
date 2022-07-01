import Array "mo:base/Array";
import Buffer "mo:base/Buffer";
import Iter "mo:base/Iter";
import Nat64 "mo:base/Nat64";
import Option "mo:base/Option";
import Prim "mo:prim";
import Principal "mo:base/Principal";
import Result "mo:base/Result";
import Text "mo:base/Text";
import TrieMap "mo:base/TrieMap";

import AccountIdentifier "mo:principal/AccountIdentifier";
import Ext "mo:ext/Ext";

import Types "types";

module {

    ////////////
    // Types //
    ///////////

    public type UpgradeData = Types.UpgradeData;
    public type User = Types.User;
    public type Name = Types.Name;
    public type TokenIndex = Ext.TokenIndex;
    public type AccountIdentifier = Ext.AccountIdentifier;
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
        let _Avatar = dependencies._Avatar;
        
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

        public func createUser(
            caller : Principal,
            username : ?Text,
            email : ?Text,
            discord : ?Text,
            twitter : ?Text,
            default_avatar : TokenIdentifier
        ) : Result<(), Text> {
            switch(_users.get(caller)){
                case(null) {
                    let new_user = {
                        name = username;
                        email = email;
                        discord = discord;
                        twitter = twitter;
                        rank = ?Nat64.fromNat(_users.size());
                        height = null;
                        minted = true;
                        account_identifier = ?Text.map(Ext.AccountIdentifier.fromPrincipal(caller, null), Prim.charToLower);
                        invoice_id = null;
                        selected_avatar = ?default_avatar;
                    };
                    _users.put(caller, new_user);
                    return #ok;
                };
                case(? user){
                    return #err("User is already registered : " #Principal.toText(caller));
                };
            };
        };

        public func getDefaultAvatar(
            caller : Principal
        ) : ?TokenIdentifier {
            switch(_users.get(caller)){
                case(null){
                    return null;
                };
                case(? user){
                    return user.selected_avatar;
                };
            };
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

        public func modifyProfile(
            name : ?Text,
            email : ?Text,
            discord : ?Text,
            twitter : ?Text,
            default_avatar : TokenIdentifier,
            caller : Principal
        ) : Result<(), Text> {
            switch(_users.get(caller)){
                case(null) return #err("No user profile detected for : " # Principal.toText(caller));
                case(? user) {
                    switch(_verifyDefaultAvatar(default_avatar, caller)){
                        case(#err(e)){
                            return #err(e);
                        };
                        case(#ok()){};
                    };

                    let new_user = {
                        name = name;
                        email = email;
                        discord = discord;
                        twitter = twitter;
                        rank = user.rank;
                        height = user.height;
                        minted = user.minted;
                        account_identifier = user.account_identifier;
                        invoice_id = user.invoice_id;
                        selected_avatar = ?default_avatar;
                    };
                    _users.put(caller, new_user);
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
                        selected_avatar = user.selected_avatar;
                    };
                    _users.put(p, new_user);
                };
            };
        };

        public func getUsers() : [(Principal, User)] {
            return Iter.toArray(_users.entries());
        };

        public func getNumberUsers() : Nat {
            _users.size();
        };

        public func getInfosLeaderboard() : [(Principal, ?Name, ?TokenIdentifier)] {
            var buffer : Buffer.Buffer<(Principal, ?Name, ?TokenIdentifier)> = Buffer.Buffer<(Principal, ?Name, ?TokenIdentifier)>(0);
            for((p, user) in _users.entries()) {
                let infos = (p, user.name, _getAvatar(p, user));
                buffer.add(infos);
            };
            return buffer.toArray();
        };
        
        /* 
            Returns an array of (Principal, AccountIdentifier, Twitter, Discord, Avatar tokenIdentifier)  
        */
        public func getInfosHolders() : [(Principal, ?AccountIdentifier, ?Text, ?Text, ?TokenIdentifier )] {
            var r : Buffer.Buffer<(Principal, ?AccountIdentifier, ?Text, ?Text, ?TokenIdentifier)> = Buffer.Buffer<(Principal, ?AccountIdentifier, ?Text, ?Text, ?TokenIdentifier)>(0);
            for((p, user) in _users.entries()) {
                let infos = (p, user.account_identifier, user.twitter, user.discord, _getAvatar(p, user));
                r.add(infos);
            };
            return r.toArray();
        };

        public func defaultAvatar(p : Principal) : () {
            switch(_users.get(p)){
                case(null) {};
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
                        invoice_id = user.invoice_id;
                        selected_avatar = _Ext.defaultToken(Option.unwrap(user.account_identifier));
                    };
                    _users.put(p, new_user);
                };
            };
        };

        public func setDefaultAvatar(p : Principal, tokenId : TokenIdentifier) : Result<(), Text> {
            switch(_users.get(p)){
                case(null){
                    return #err("No user found");
                };
                case(? user){
                    let account = switch(user.account_identifier){
                        case(? account) {account};
                        case(null) {
                            Text.map(Ext.AccountIdentifier.fromPrincipal(p, null), Prim.charToLower);
                        };
                    };
                    if(_verifySelectedAvatar(tokenId, account)){
                        let new_user = {
                            name = user.name;
                            email = user.email;
                            discord = user.discord;
                            twitter = user.twitter;
                            rank = user.rank;
                            height = user.height;
                            minted = user.minted;
                            account_identifier = user.account_identifier;
                            invoice_id = user.invoice_id;
                            selected_avatar = ?tokenId;
                        };
                        _users.put(p, new_user);
                        return #ok;
                    };
                    return #err("User doesn't own this avatar. Cannot set as default");
                };
            };
        };

        /* 
            Check all the user and verify that they have a default avatar.
            In case they don't, set the default avatar to the (optional) first one they own.
            In case they have one : verify that they still own it. If they don't : set the default avatar to the (optional) first one they own.
        */
        public func cronDefaultAvatar () : () {
            // Build the ownership map to easily verify if a user owns an avatar
            let _ownerships : TrieMap.TrieMap<AccountIdentifier, [TokenIdentifier]> = TrieMap.TrieMap<AccountIdentifier, [TokenIdentifier]>(Text.equal, Text.hash);
            let registry = _Ext.getRegistryIdentifier();
            for((tokenId, account) in registry.vals()){
                switch(_ownerships.get(account)){
                    case(null){
                        _ownerships.put(account, [tokenId]);
                    };
                    case(? tokens){
                        _ownerships.put(account, Array.append<TokenIdentifier>(tokens, [tokenId]));
                    };
                };
            };
            for((p, user) in _users.entries()){
                let account = switch(user.account_identifier){
                    case(? account) {account};
                    case(null) {
                        _setAccountIdentifier(p);
                        Text.map(Ext.AccountIdentifier.fromPrincipal(p, null), Prim.charToLower);
                    };
                };
                switch(user.selected_avatar){
                    // They don't have a selected avatar : set it to be the (optional) first one they own.
                    case(null) {
                        switch(_ownerships.get(account)){
                            case(null){};
                            case(? tokens){
                                let new_user = {
                                    name = user.name;
                                    email = user.email;
                                    discord = user.discord;
                                    twitter = user.twitter;
                                    rank = user.rank;
                                    height = user.height;
                                    minted = user.minted;
                                    account_identifier = user.account_identifier;
                                    invoice_id = user.invoice_id;
                                    selected_avatar = ?tokens[0];
                                };
                                _users.put(p, new_user);
                            };
                        };
                    };
                    // They do have a selected avatar : verify that they still own it. If they don't : set the default avatar to null.
                    case(? token){
                        switch(_ownerships.get(account)){
                            // They don't own any avatar : set the default avatar to null.
                            case(null){
                                let new_user = {
                                    name = user.name;
                                    email = user.email;
                                    discord = user.discord;
                                    twitter = user.twitter;
                                    rank = user.rank;
                                    height = user.height;
                                    minted = user.minted;
                                    account_identifier = user.account_identifier;
                                    invoice_id = user.invoice_id;
                                    selected_avatar = null;
                                };
                                _users.put(p, new_user);
                            };
                            case(? tokens){
                                if(Option.isSome(Array.find<TokenIdentifier>(tokens, func(x) {x == token}))){
                                    // They still own this avatar. Do nothing.
                                } else {
                                    // They don't own this avatar but they have others. Set the default avatar to the first one in the array.
                                    let new_user = {
                                        name = user.name;
                                        email = user.email;
                                        discord = user.discord;
                                        twitter = user.twitter;
                                        rank = user.rank;
                                        height = user.height;
                                        minted = user.minted;
                                        account_identifier = user.account_identifier;
                                        invoice_id = user.invoice_id;
                                        selected_avatar = ?tokens[0];
                                    };
                                    _users.put(p, new_user);
                                };
                            };
                        }
                    };
                };
            };
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
                selected_avatar = null;
            }
        };

        /* 
            Returns a boolean indicating if the specifiec account is owner of the specified tokenId.
            CONSUMES WAY TOO MUCH CYCLES TO ITERATE OVER THE WHOLE REGISTRY
         */
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
        
        /* 
            Returns the optional token identifier of the avatar of the user.
            If the user has not selected a default avatar, returns null.
            If the user has selected a default avatar, but he doesn't own the token at this moment, returns null.
         */
        func _getAvatar(p : Principal, user : User) : ?TokenIdentifier {
            let account = switch(user.account_identifier){
                case(? some) some;
                case(null){ 
                    _setAccountIdentifier(p);
                    Text.map(Ext.AccountIdentifier.fromPrincipal(p, null), Prim.charToLower);
                };
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

        func _setAccountIdentifier(p : Principal) : () {
            switch(_users.get(p)){
                case(null) {
                    return;
                };
                case(? user){
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
                        selected_avatar = user.selected_avatar;
                    };
                    _users.put(p, new_user);
                };
            };
        };

        func _verifyDefaultAvatar(
            token : TokenIdentifier,
            caller : Principal, 
            ) : Result<(), Text> {
                // Verify that the caller own the token
                let account = Text.map(Ext.AccountIdentifier.fromPrincipal(caller, null), Prim.charToLower);
                switch(_Ext.bearer(token)){
                    case(#err(_)) return #err("The token is not owned by the caller");
                    case(#ok(owner)){
                        if(owner != account) {
                            return #err("The token is not owned by the caller");
                        };
                    };
                };
                // Verify that the token is an avatar and NOT a legendary
                switch(_Avatar.getAvatar(token)){
                    case(null){
                        return #err("No avatar found for this tokenIdentifier : " # token);
                    };
                    case(? avatar){
                        switch(avatar.level){
                            case(#Legendary){
                                return #err("This token is a legendary avatar and cannot be used as a default avatar");
                            };
                            case(_){
                                return #ok;
                            };
                        };
                    };
                };
            };
    };
};