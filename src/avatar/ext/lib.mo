import HashMap "mo:base/HashMap";
import Iter "mo:base/Iter";
import Nat32 "mo:base/Nat32";
import Text "mo:base/Text";
import Types "types";
import Ext "mo:ext/Ext";
import AccountIdentifier "mo:principal/AccountIdentifier";
import Result "mo:base/Result";

module {
    public class make(state : Types.State) : Types.Interface {

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

        let CANISTER_ID = state.cid;
        private let _registry_module : HashMap.HashMap<TokenIndex, AccountIdentifier> = HashMap.fromIter<TokenIndex,AccountIdentifier>(state.registry.vals(), state.registry.size(), Ext.TokenIndex.equal, Ext.TokenIndex.hash);

        public func toStableState() : [(TokenIndex,AccountIdentifier)] {
            Iter.toArray(_registry_module.entries());
        };

        ////////////////
        // @ext:core //
        //////////////


        // Returns the balance of an user for a specific token. Returns 1 if the user has the Token. Returns 0 is the user doesn't have the token. Returns an error if the token is invalid.
        // @param request.user : The user to get the balance of can be an AccountIdentifier or a principal (default to subaccount 0).
        // @param request.token : The token identifier to check the balance of. Need to be a valid token.
        public func balance(request : Ext.Core.BalanceRequest) : Ext.Core.BalanceResponse {
            let index = switch(Ext.TokenIdentifier.decode(request.token)){
                case(#err(_)) {return #err(#InvalidToken(request.token))};
                case(#ok(canisterId, tokenIndex)) {
                    if(canisterId != CANISTER_ID){
                        return #err(#InvalidToken(request.token));
                    };
                    tokenIndex;
                };
            };
            let userId = Ext.User.toAccountIdentifier(request.user);
            switch (_registry_module.get(index)) {
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
                case(#err(_)) return #err(#InvalidToken(request.token));
                case(#ok(canisterId, tokenIndex)) {
                    if(canisterId != CANISTER_ID) {
                        return #err(#InvalidToken(request.token));
                    };
                    tokenIndex
                };
            };
            let owner = switch (_registry_module.get(index)) {
                case (?t) t;
                case _ return #err(#Other("Token owner doesn't exist."));
            };
            let callerAccount = AccountIdentifier.fromPrincipal(caller, request.subaccount);
            let from = Ext.User.toAccountIdentifier(request.from);
            let to = Ext.User.toAccountIdentifier(request.to);
            if(owner != from) {
                return #err(#Unauthorized("Owner \"" # owner # "\" is not caller \"" # from # "\""));
            };
            if(from != callerAccount) {
                return #err(#Unauthorized("Only the owner can do that."));
            };
            _registry_module.put(index, to);
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
            switch (_registry_module.get(index)) {
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
            switch (_registry_module.get(index)) {
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
            switch (_registry_module.get(index)) {
                case (null)    { #err(#InvalidToken(tokenId)); };
                case (? owner) { #ok(owner); };
            };
        };

        public func mint(
            request : MintRequest
        ) : () {
            return;
        };

        public func getRegistry() : [(TokenIndex, AccountIdentifier)] {
            Iter.toArray(_registry_module.entries());
        };

        /////////////////////////////
        // @ext:stoic integration //
        ///////////////////////////

        // public func tokens(
        //     caller  : Principal,
        //     accountId : Ext.AccountIdentifier
        // ) : Result.Result<[Ext.TokenIndex], Ext.CommonError> {
        //     var tokens : [Ext.TokenIndex] = [];
        //     var i : Nat32 = 0;
        //     for ((token, owner) in _registry_module.entries()) {
        //                 if (Ext.AccountIdentifier.equal(accountId, t.owner)) {
        //                     tokens := Array.append(tokens, [i]);
        //                 };
        //             };
        //             case _ ();
        //         };
        //         i += 1;
        //     };
        //     #ok(tokens);
        // };




    }
}