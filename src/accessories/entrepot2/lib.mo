import Array "mo:base/Array";
import Blob "mo:base/Blob";
import Buffer "mo:base/Buffer";
import Error "mo:base/Error";
import HashMap "mo:base/HashMap";
import Iter "mo:base/Iter";
import List "mo:base/List";
import Nat "mo:base/Nat";
import Nat16 "mo:base/Nat16";
import Nat32 "mo:base/Nat32";
import Nat64 "mo:base/Nat64";
import Nat8 "mo:base/Nat8";
import Option "mo:base/Option";
import Prim "mo:prim";
import Result "mo:base/Result";
import Text "mo:base/Text";
import Time "mo:base/Time";

import AccountBlob "mo:principal/blob/AccountIdentifier";
import Ext "mo:ext/Ext";
import Hex "mo:encoding/Hex";

import NNS "../nns";
import Types "types";
module {
    
    // Time for a transaction to complete (2 mins in nanoseconds)
    private let transactionTtl = 120_000_000_000;

    // Fees to be deducted from all marketplace sales
    private let fees : [(Ext.AccountIdentifier, Nat64)] = [
        ("e52dd08a3a35cad591e55d0174be0b85ad1bd8395b9ace29bc1c232c06f1e656", 5000), // 5% Royalty fee
        ("c7e461041c0c5800a56b64bb7cefc247abc0bbbb99bd46ff71c64e92d9f5c2f9", 1000), // 1% Entrepot marketplace fee
    ];

    //TODO : Declare the ledger actor

    public class Factory (dependencies : Types.Dependencies) {

        //////////////////
        // Dependencies //
        /////////////////

        let _Admins = dependencies._Admins;
        let _Ext = dependencies._Ext;
        let _Logs = dependencies._Logs;
        let _Cap = dependencies._Cap;
        let _NNS = dependencies._NNS;
                
        ////////////
        // State //
        //////////

        //Incrementing transaction id.
        private var nextTxId = 0;

        //NFTs listed for sale
        private var listings = TrieMap.TrieMap<Ext.TokenIndex, Types.Listing>(
            Ext.TokenIndex.equal,
            Ext.TokenIndex.hash,
        );

        //Unfinalized transactions.
        private var pendingTransactions = TrieMap.TrieMap<Ext.TokenIndex, Types.Transaction>(
            Ext.TokenIndex.equal,
            Ext.TokenIndex.hash,
        );

        //Finalized transactions.
        private var transactions = TrieMap.TrieMap<Nat, Types.Transaction>(
            Nat.equal,
            Nat32.fromNat,
        );
        
        // Used payment addresses.
        // DEPRECATED
        // NOTE: Payment addresses are generated at transaction time by combining random subaccount bytes (determined in secret by the buyer,) with the seller's address. The transaction protocol relies on a unique address for each transaction, so these payment addresses can never be used again.
        private var _usedPaymentAddresses : Buffer.Buffer<(
            Ext.AccountIdentifier, Principal, Ext.SubAccount
        )> = Buffer.Buffer(0);

        //Incrementing subbaccount for handling marketplace payments.
        private nextSubAccount : Nat = dependencies.nextSubAccount;

        // Marketplace stats
        var totalVolume : Nat64 = 0;
        var lowestPriceSales : Nat64 = 0;
        var highestPriceSales : Nat64 = 0;

        //Pending ICP disbursements from this canister.
        var pendingDisbursements = List.List<Types.Disbursement> = null; 

        public func preupgrade() : UpgradeData {
            //TODO
        };

        public func postupgrade(ud : ?UpgradeData) : () {
            //TODO
        };

        ///////////////////////
        // Internal / Utils //
        /////////////////////

        // Get index from EXT token identifier.
        func _unpackTokenIdentifier (
            token : Ext.TokenIdentifier,
        ) : Result.Result<Ext.TokenIndex, Ext.CommonError> {
            switch (Ext.TokenIdentifier.decode(token)) {
                case (#ok(principal, tokenIndex)) {
                    // Validate token identifier's canister.
                    if (principal != state.cid) {
                        #err(#InvalidToken(token));
                    } else {
                        #ok(tokenIndex);
                    };
                };
                case (#err(_)) { return #err(#InvalidToken(token)); };
            };
        };

        func _listingToExtListing(listing : Types.Listing) : Types.ExtListing {
            return ({
                locked = listing.locked;
                price = listing.price;
                seller = listing.seller;
            })
        };

        func _nftMetadata() : Types.Metadata {
            return(#nonfungible({ metadata = null }));
        };

        func _isLocked(
            index : Ext.TokenIndex
        ) : Bool {
            switch (listings.get(index)) {
                case (?listing) {
                    switch (listing.locked) {
                        case (?locked) {
                            if (Time.now() <= locked) {
                                true;
                            } else {
                                false;
                            }
                        };
                        case _ false;
                    };
                };
                case _ false;
            };
        };

        func _canSettle(
            caller : Principal,
            token : Ext.TokenIdentifier,
        ) : async Result.Result<(), Ext.CommonError> {

            // Decode token index.
            let index = switch (Ext.TokenIdentifier.decode(token)) {
                case (#err(_)) { return #err(#InvalidToken(token)); };
                case (#ok(_, tokenIndex)) { tokenIndex; };
            };

            switch (pendingTransactions.get(index)) {
                case (?tx) {
                    // Attempt to settle the pending transaction.
                    switch (await settle(caller, token)) {
                        case (#ok) {
                            // The old transaction was able to be settled.
                            return #err(#Other("Listing has been sold."));
                        };
                        case(#err _) {
                            if (Option.isNull(listings.get(index))) {
                                // The transaction was settled from under our feet.
                                // NOTE: This is such a weird deep use case 😵‍💫
                                return #err(#Other("Listing as sold"));
                            };
                        };
                    };
                };
                case _ ();
            };
            #ok();
        };

        // Convert incrementing sub account to a proper Blob.
        func _natToSubAccount(n : Nat) : Ext.SubAccount {
            let n_byte = func(i : Nat) : Nat8 {
                assert(i < 32);
                let shift : Nat = 8 * (32 - 1 - i);
                Nat8.fromIntWrap(n / 2**shift)
            };
            Array.tabulate<Nat8>(32, n_byte)
        };

        // Get and increment next subaccount.
        func _getNextSubAccount() : Ext.SubAccount {
            var _saOffset = 4294967296;
            nextSubAccount += 1;
            return _natToSubAccount(_saOffset + nextSubAccount);
        };

        // Queue a disbursement
        func _addDisbursement(d : Types.Disbursement) : () {
            pendingDisbursements := List.push(d, pendingDisbursements);
        };

        /////////////////
        // Public API //
        ///////////////

        // List all current NFT's for sale.
        public func getListings() : Types.ListingResponse {
            let r = Buffer.Buffer<(Ext.TokenIndex, ExtListing, Metadata)>(0);
            for((index,listing) in listing.entries()){
                r.add((index, _listingToExtListing(listing), _nftMetadata()));
            };
            return r.toArray();
        };

        // Put an NFT up for sale
        public func list(
            caller : Principal,
            request : Types.ListRequest
        ) : async Types.ListResponse {
            let index = switch (Ext.TokenIdentifier.decode(request.token)) {
                case (#err(_)) {
                    _Logs.logMessage("Failed to decode token : " # request.token);
                    return #err(#InvalidToken(request.token));
                };
                case (#ok(_, tokenIndex)) { tokenIndex; };
            };

            // Verify that the caller owns the token.
            let account = Text.map(Ext.AccountIdentifier.fromPrincipal(caller, request.from_subaccount),Prim.charToLower); 
            if(not _Ext.isOwnerAccount(account, index)){
                return #err(#Other("Unauthorized"));
            };

            // Ensure token is not already locked.
            if(_isLocked(index)){
                return #err(#Other("Token is locked."));
            };

            // Ensure there isn't a pending transaction which can be settled.
            switch(await _canSettle(caller, request.token)){
                case (#err(e)) {
                    return #err(e);
                };
                case _ ();
            };

            // NOTE: The interface to delete a listing is not explicit enough for my taste.
            switch (request.price) {
                // Create the listing.
                case (?price) {
                    listings.put(index, {
                        locked      = null;
                        seller      = caller;
                        subaccount  = request.from_subaccount;
                        price       = price;
                    });
                };
                // If price is null, delete the listing.
                case _ {
                    listings.delete(index);
                };
            };
            #ok();
        };

        // Execute a lock on an NFT so that we can safely conduct a transaction.
        public func lock(
            caller  : Principal,
            token   : Ext.TokenIdentifier,
            price   : Nat64,
            buyer   : Ext.AccountIdentifier,
            deprecated : [Nat8],
        ) : async Types.LockResponse {

            // Decode token index from token identifier.
            let index : Ext.TokenIndex = switch (_unpackTokenIdentifier(token)) {
                case (#ok(i)) i;
                case (#err(e)) {
                    _Log.logMessage(Principal.toText(caller) # " :: lock ", token # " :: ERR :: Invalid token");
                    return #err(e);
                };
            };

            // Ensure token is not already locked.
            if (_isLocked(index)) {
                 _Log.logMessage(Principal.toText(caller) # " :: lock ", token # " :: ERR :: Already locked");
                return #err(#Other("Already locked."));
            };

            // Retrieve the token's listing.
            switch (listings.get(index)) {
                case (null) {
                     _Log.logMessage(Principal.toText(caller) # " :: lock ", token # " :: ERR :: No such listing");
                    #err(#Other("No such listing."));
                };

                case (?listing) {

                    // Double check listing price
                    if (price != listing.price) {
                        _Log.logMessage(Principal.toText(caller) # " :: lock ", token # " :: ERR :: Wrong price");
                        return #err(#Other("Incorrect listing price."));
                    };

                    let subaccount = _getNextSubAccount();
                    let paymentAddress : Ext.AccountIdentifier = Text.map(Ext.AccountIdentifier.fromPrincipal(state.cid, ?subaccount), Prim.charToLower);

                    // Lock the listing
                    listings.put(index, {
                        subaccount  = listing.subaccount;
                        price       = listing.price;
                        seller      = listing.seller;
                        locked      = ?(Time.now() + transactionTtl);
                    });

                    // Ensure there isn't a pending transaction which can be settled.
                    switch (await _canSettle(caller, token)) {
                        case (#err(e)) {
                        _Log.logMessage(Principal.toText(caller) # " :: lock ", token # " :: ERR :: Pending settlement completed");
                            return #err(e);
                        };
                        case _ ();
                    };

                    // Create a pending transaction
                    // NOTE: Keys in this map are TOKEN INDECES. Upon settlement, a transaction is moved to the "finalized transactions" map, which used a generic transaction ID as a key. Effectively, the key type changes during a settlement. This is at best an unclear thing to do, so perhaps worthy of a refactor.
                    pendingTransactions.put(index, {
                        id          = nextTxId;
                        token       = token;
                        memo        = null;
                        seller      = listing.seller;
                        from        = AccountBlob.toText(AccountBlob.fromPrincipal(listing.seller, listing.subaccount));
                        to          = buyer;
                        price       = listing.price;
                        initiated   = Time.now();
                        closed      = null;
                        bytes       = subaccount;
                    });
                    nextTxId += 1;  // Don't forget this 😬

                    #ok(paymentAddress);
                };
            };
        };

        // As a final step, after transfering ICP, we can settle the transaction.
        public func settle(
            caller : Principal,
            token : Ext.TokenIdentifier,
        ) : async Result.Result<(), Ext.CommonError>{
            // Decode token index from token identifier.
            let index : Ext.TokenIndex = switch (_unpackTokenIdentifier(token)) {
                case (#ok(i)) i;
                case (#err(e)) {
                    _Log.logMessage(Principal.toText(caller) # " :: lock ", token # " :: ERR :: Invalid token");
                    return #err(e);
                };
            };

            // Retrieve the pending transaction.
            let transaction = switch (pendingTransactions.get(index)) {
                case (?t) t;
                case _ {
                    _Log.logMessage(Principal.toText(caller) # " :: lock ", token # " :: ERR :: No such transaction");
                    return #err(#Other("No such pending transaction."));
                }
            };

            // Check the transaction account on the ledger.
            let account_as_blob = AccountBlob.fromPrincipal(dependencies.cid, ?transaction.bytes);
            let balance = await _NNS.balance(account_as_blob);

            // Confirm enough funds have been sent.
            if (balance.e8s < transaction.price) {
                if (not _isLocked(index)) {
                    // This pending transaction is past its lock, so we delete it to save compute in our cron that iterates pending transactions.
                    pendingTransactions.delete(index);
                };
                _Log.logMessage(Principal.toText(caller) # " :: lock ", token # " :: ERR :: Insufficient funds");
                return #err(#Other("Insufficient funds sent."));
            };

            // Schedule disbursements for the proceeds from this sale.
            let funds = balance.e8s - (10_000 * (1 + Nat64.fromNat(fees.size())));
            // Remove the money to pay the fees
            var remaining = funds;
            for((recipient, pct) in fees.vals()){
                let amount : Nat64 = funds * pct / 100_000;
                _addDisbursement(index, recipient, transaction.bytes, amount);
                remaining -= amount;
            };
            // Pay the seller with the rest.
            _addDisbursement(index, transaction.from, transaction.bytes, remaining);

            // Update the transaction.
            // NOTE: We use the id of the pending transaction as the key. The pending transaction map uses TOKEN INDECES for keys, but this is an intentional change.
            transactions.put(transaction.id, {
                id          = transaction.id;
                memo        = transaction.memo;
                from        = transaction.from;
                to          = transaction.to;
                price       = transaction.price;
                initiated   = transaction.initiated;
                closed      = ?Time.now();
                bytes       = transaction.bytes;
                seller      = transaction.seller;
                token       = transaction.token;
            });
            pendingTransactions.delete(index);

            // Update stats.
            totalVolume += transaction.price;
            lowestPriceSale := switch (transaction.price < lowestPriceSale) {
                case (true) transaction.price;
                case (false) lowestPriceSale;
            };
            highestPriceSale := switch (transaction.price > highestPriceSale) {
                case (true) transaction.price;
                case (false) highestPriceSale;
            };

            //Transfer the NFT from seller to the buyer
            _Ext.transferSale(index, transaction.from, transaction.to);

            // Remove the listing
            listings.delete(index);

            // Insert transaction into CAP history.
            //TODO
            #ok();
        };

        // Get market details for an NFT (i.e. is it for sale, how much)
        public func details (token : Ext.TokenIdentifier) : Types.DetailsResponse {
            let index = switch (Ext.TokenIdentifier.decode(token)) {
                case (#err(_)) { return #err(#InvalidToken(token)); };
                case (#ok(_, tokenIndex)) { tokenIndex; };
            };
            switch (listings.get(index)) {
                case (?listing) #ok(Text.map(Ext.AccountIdentifier.fromPrincipal(caller, request.from_subaccount),Prim.charToLower), ?listing);
                case _ #err(#Other("No such listing."));
            };
        };

        // Get market stats for this collection
        public func stats () : Types.StatsResponse {
            var floor : Nat64 = 0;
            for (a in listings.entries()){
                if (floor == 0 or a.1.price < floor) floor := a.1.price;
            };
            (
                totalVolume,
                highestPriceSale,
                lowestPriceSale,
                floor,
                listings.size(),
                Nat16.toNat(state.supply),
                transactions.size(),
            );
        };

        public func payments (
            caller  : Principal,
        ) : ?[Ext.SubAccount] {
            ?Array.mapFilter<(Nat, Types.Transaction), Ext.SubAccount>(Iter.toArray(transactions.entries()), func ((index, transaction)) {
                if (transaction.seller == caller) {
                    ?transaction.bytes;
                } else {
                    null;
                };
            });
        };

        // Used by stoic wallet
        public func tokens_ext(
            caller  : Principal,
            accountId : Ext.AccountIdentifier,
        ) : Result.Result<[(Ext.TokenIndex, ?Types.Listing, ?[Nat8])], Ext.CommonError> {
            let tokens = Buffer.Buffer<(Ext.TokenIndex, ?Types.Listing, ?[Nat8])>(0);
            var i : Nat32 = 0;
            for (token in Iter.fromArray(state._Tokens.read(null))) {
                switch (token) {
                    case (?t) {
                        if (Ext.AccountIdentifier.equal(accountId, t.owner)) {
                            tokens.add((
                                i,
                                listings.get(i),
                                null,
                            ));
                        };
                    };
                    case _ ();
                };
                i += 1;
            };
            #ok(tokens.toArray());
        };


        // Return completed transactions.
        public func readTransactions () : [Types.EntrepotTransaction] {
            Array.map<(Nat, Types.Transaction), Types.EntrepotTransaction>(Iter.toArray(transactions.entries()), func ((k, v)) {
                {
                    buyer   = v.to;
                    price   = v.price;
                    seller  = v.seller;
                    time    = switch(v.closed) {
                        case (?t) t;
                        case _ v.initiated;
                    };
                    token   = v.token;
                }
            });
        };

    };
};