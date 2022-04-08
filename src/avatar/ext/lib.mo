import Buffer "mo:base/Buffer";
import HashMap "mo:base/HashMap";
import Iter "mo:base/Iter";
import Nat "mo:base/Nat";
import Nat32 "mo:base/Nat32";
import Prim "mo:prim";
import Principal "mo:base/Principal";
import Result "mo:base/Result";
import Text "mo:base/Text";

import AccountIdentifier "mo:principal/AccountIdentifier";
import Ext "mo:ext/Ext";

import Types "types";

module {

    ////////////
    // Types //
    //////////
    
    public type UpgradeData = Types.UpgradeData;
    public type Listing = Types.Listing;

    public class Factory(dependencies : Types.Dependencies) : Types.Interface {

        ////////////
        // State //
        ///////////

        type Result<A,B> = Result.Result<A,B>;
        type TokenIndex = Types.TokenIndex;
        type TokenIdentifier = Types.TokenIdentifier;
        type AccountIdentifier = Types.AccountIdentifier;
        type Extension = Types.Extension;
        type Balance = Types.Balance;
        type CommonError = Types.CommonError;
        type BalanceRequest = Types.BalanceRequest;
        type BalanceResponse = Types.BalanceResponse;
        type TransferRequest = Types.TransferRequest;
        type TransferResponse = Types.TransferResponse;
        type Metadata = Types.Metadata;
        type MintRequest = Types.MintRequest;

        let CANISTER_ID = dependencies.cid;
        private let _registry : HashMap.HashMap<TokenIndex, AccountIdentifier> = HashMap.HashMap<TokenIndex,AccountIdentifier>(0, Ext.TokenIndex.equal, Ext.TokenIndex.hash);

        let _Logs = dependencies._Logs;

        public func preupgrade() : UpgradeData {
            {
                registry = Iter.toArray(_registry.entries());
            }
        };

        public func postupgrade(ud : ?UpgradeData) : () {
            switch(ud){
                case(? ud){
                    for((tokenIndex, accountId) in ud.registry.vals()){
                        _registry.put(tokenIndex, accountId);
                    };
                };
                case _ {};
            };
        };

        ////////////////
        // @ext:core //
        //////////////


        // Returns the balance of an user for a specific token. Returns 1 if the user has the Token. Returns 0 is the user doesn't have the token. Returns an error if the token is invalid.
        // @param request.user : The user to get the balance of can be an AccountIdentifier or a principal (default to subaccount 0).
        // @param request.token : The token identifier to check the balance of. Need to be a valid token.
        public func balance(request : Ext.Core.BalanceRequest) : Ext.Core.BalanceResponse {
            let index = switch(Ext.TokenIdentifier.decode(request.token)){
                case(#err(_)) {
                    _Logs.logMessage("Ext/lib/balance/line78. Token identifier : " # request.token);
                    return #err(#InvalidToken(request.token))
                };
                case(#ok(canisterId, tokenIndex)) {
                    if(canisterId != CANISTER_ID){
                        return #err(#InvalidToken(request.token));
                    };
                    tokenIndex;
                };
            };
            let userId = Ext.User.toAccountIdentifier(request.user);
            switch (_registry.get(index)) {
                case (null) { #err(#InvalidToken(request.token)); };
                case (? owner) {
                    if (Ext.AccountIdentifier.equal(userId, owner)) {
                        #ok(1);
                    } else {
                        #ok(0);
                    };
                };
            };
        };

        // Returns a list of EXT extensions that this canister supports.
        public func extensions() : [Ext.Extension] {
            ["@ext/common", "@ext/nonfungible"];
        };

        // Transfers the ownership of an NFT from one address to another address
        // @params request.from (EXT.User) The current owner of the NFT
        // @params request.to (EXT.User) The new owner
        // @params request.token (EXT.TokenIdentifier) The nft to transfer 
        // @params request.amount (Nat) Number of tokens to transfer (must be 1)
        // @params request.memo (Blob) Additional data with no specified format
        // @params request.notify (Boolean) If true will attempt to notify recipient
        // @params request.subaccount (?[Nat8]) Subaccount of the caller
        // @dev : Throws unless `msg.caller` is the current owner. Throws if `request.from` is not the current owner. Throws if a valid token index cannot be decoded from `request.token`. Throws if `request.token` is not a valid NFT. 
        public func transfer(
            caller : Principal,
            request : Ext.Core.TransferRequest
        ) : Ext.Core.TransferResponse {
            if(request.amount != 1) {
                return #err(#Other("Must use amount of 1"));
            };
            let index = switch(Ext.TokenIdentifier.decode(request.token)){
                case(#err(msg)) {
                    _Logs.logMessage("Ext/lib/transfer/line125. Token identifier : " # request.token);
                    return #err(#Other(msg));
                };
                case(#ok(canisterId, tokenIndex)) {
                    if(canisterId != CANISTER_ID) {
                        _Logs.logMessage("Ext/lib/transfer/line130. Canister id : " # Principal.toText(canisterId) # " and CANISTER_ID : " # Principal.toText(CANISTER_ID));
                        return #err(#InvalidToken(request.token));
                    };
                    tokenIndex
                };
            };
            let owner = switch (_registry.get(index)) {
                case (?t) t;
                case _ return #err(#Other("Token owner doesn't exist."));
            };
            let caller_account = Text.map(Ext.AccountIdentifier.fromPrincipal(caller, request.subaccount), Prim.charToLower);
            let from = Text.map(Ext.User.toAccountIdentifier(request.from), Prim.charToLower);
            let to = Text.map(Ext.User.toAccountIdentifier(request.to), Prim.charToLower);
            if(owner != from) {
                _Logs.logMessage("Ext/lib/transfer/line144. Owner : " # owner # " Caller : " # caller_account);
                return #err(#Unauthorized("This user \"" # from # "\" doesn't own this token \"" # request.token # "\""));
            };
            if(from != caller_account) {
                _Logs.logMessage("Ext/lib/transfer/line148. From : " # from # " Caller : " # caller_account);
                return #err(#Unauthorized("Only the owner can do that."));
            };
            _registry.put(index, to);
            return #ok(Nat32.toNat(index));
        };

        //////////////////
        // @ext:common //
        ////////////////

        public func metadata(
            tokenId : Ext.TokenIdentifier,
        ) : Ext.Common.MetadataResponse {
            let index = switch (Ext.TokenIdentifier.decode(tokenId)) {
                case (#err(_)) { return #err(#InvalidToken(tokenId)); };
                case (#ok(_, tokenIndex)) { tokenIndex; };
            };
            switch (_registry.get(index)) {
                case (null) { #err(#InvalidToken(tokenId)); };
                case (?token) { #ok(#nonfungible({metadata = ?Text.encodeUtf8("ICPSquad")})); };
            };
        };

        public func supply(
            tokenId : Ext.TokenIdentifier,
        ) : Ext.Common.SupplyResponse {
            let index = switch (Ext.TokenIdentifier.decode(tokenId)) {
                case (#err(_)) { return #err(#InvalidToken(tokenId)); };
                case (#ok(_, tokenIndex)) { tokenIndex; };
            };
            switch (_registry.get(index)) {
                case (null) { #ok(0); };
                case (? _)  { #ok(1); };
            };
        };


        ///////////////////////
        // @ext:nonfungible //
        /////////////////////

        public func bearer(
            tokenId : Ext.TokenIdentifier,
        ) : Ext.NonFungible.BearerResponse {
            let index = switch (Ext.TokenIdentifier.decode(tokenId)) {
                case (#err(_)) { return #err(#InvalidToken(tokenId)); };
                case (#ok(_, tokenIndex)) { tokenIndex; };
            };
            switch (_registry.get(index)) {
                case (null)    { #err(#InvalidToken(tokenId)); };
                case (? owner) { #ok(owner); };
            };
        };

        public func mint(
            request : MintRequest
        ) : Ext.NonFungible.MintResponse {
            let account_identifier = Ext.User.toAccountIdentifier(request.to);
            let index = Nat32.fromNat(_registry.size());
            switch(_registry.get(index)) {
                case (null) {
                    _registry.put(index, account_identifier);
                    return #ok(index);
                };
                case (? _) {
                    _Logs.logMessage("Ext/lib/mint/line214. Index : " # Nat.toText(Nat32.toNat(index)));
                    return #err(#Other("Token already exists."));
                };
            };
        };

        public func getRegistry() : [(TokenIndex, AccountIdentifier)] {
            Iter.toArray(_registry.entries());
        };

        /////////////////////////////
        // @ext:stoic integration //
        ///////////////////////////

        public func tokens(
            accountId : Ext.AccountIdentifier
        ) : Result.Result<[Ext.TokenIndex], Ext.CommonError> {
            var tokens : Buffer.Buffer<Ext.TokenIndex> = Buffer.Buffer(0);
            for ((index, owner) in _registry.entries()) {
                if (Text.equal(accountId, owner)) {
                    tokens.add(index);
                };
            };
            #ok(tokens.toArray());
        };

        public func tokens_ext(
            accountId : Ext.AccountIdentifier
        ) : Result.Result<[(Ext.TokenIndex, ?Types.Listing, ?Blob)], CommonError> {
            var tokens : Buffer.Buffer<(Ext.TokenIndex, ?Types.Listing, ?Blob)> = Buffer.Buffer(0);
            for ((index, owner) in _registry.entries()) {
                if (Text.equal(accountId, owner)) {
                    //TODO : use  Asset module to fill the blob field   
                    tokens.add((index, null, ?Text.encodeUtf8("ICPSquad")));
                };
            };
            #ok(tokens.toArray());
        };

        ////////////////////////////////
        // @ext:entrepot integration //
        ///////////////////////////////

        public func details(
            tokenId : TokenIdentifier
        ) : Result.Result<(AccountIdentifier, ?Types.Listing), CommonError> {
            let index = switch (Ext.TokenIdentifier.decode(tokenId)) {
                case (#err(_)) { 
                    _Logs.logMessage("Ext/lib/details/line262. TokenId : " # tokenId);
                    return #err(#InvalidToken(tokenId)); 
                };
                case (#ok(_, tokenIndex)) { tokenIndex; };
            };
            switch (_registry.get(index)) {
                case (null)    { #err(#InvalidToken(tokenId)); };
                case (? owner) { #ok(owner, null)};
            };
        };

        ////////////////////////////////
        // @ext: ?????   integration //
        ///////////////////////////////

        public func getTokens() : [(TokenIndex, Metadata)] {
            let r = Buffer.Buffer<(TokenIndex, Metadata)>(0);
            for(index in _registry.keys()) {
                r.add(index, #nonfungible({metadata = null}));
            };
            r.toArray();
        };
    };    
}