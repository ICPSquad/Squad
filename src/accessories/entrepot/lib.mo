import Array "mo:base/Array";
import Blob "mo:base/Blob";
import Buffer "mo:base/Buffer";
import Error "mo:base/Error";
import Iter "mo:base/Iter";
import List "mo:base/List";
import Nat "mo:base/Nat";
import Nat16 "mo:base/Nat16";
import Nat32 "mo:base/Nat32";
import Nat64 "mo:base/Nat64";
import Nat8 "mo:base/Nat8";
import Option "mo:base/Option";
import Prim "mo:prim";
import Principal "mo:base/Principal";
import Result "mo:base/Result";
import Text "mo:base/Text";
import Time "mo:base/Time";
import TrieMap "mo:base/TrieMap";

import AccountBlob "mo:principal/blob/AccountIdentifier";
import Ext "mo:ext/Ext";
import Hex "mo:encoding/Hex";
import TokenIdentifier "mo:encoding/Base32";

import NNS "../nns";
import Types "types";
module {

    ////////////
    // Types //
    //////////

    public type UpgradeData = Types.UpgradeData;
    public type Listing = Types.Listing;
    public type Transaction = Types.Transaction;
    public type EntrepotTransaction = Types.EntrepotTransaction;
    public type Disbursement = Types.Disbursement;
    public type ListRequest = Types.ListRequest;
    public type ListResponse = Types.ListResponse;
    public type LockResponse = Types.LockResponse;
    public type DetailsResponse = Types.DetailsResponse;
    public type ListingResponse = Types.ListingsResponse;
    public type ExtListing = Types.ExtListing;
    public type Metadata = Types.Metadata;

    // Time for a transaction to complete (2 mins)
    private let transactionTtl = 120_000_000_000;

    // Fees to be deducted from all marketplace sales
    private let fees : [(Ext.AccountIdentifier, Nat64)] = [
        ("e52dd08a3a35cad591e55d0174be0b85ad1bd8395b9ace29bc1c232c06f1e656", 5000), // 5% Royalty fee
        ("c7e461041c0c5800a56b64bb7cefc247abc0bbbb99bd46ff71c64e92d9f5c2f9", 1000), // 1% Entrepot marketplace fee
    ];

    public class Factory (dependencies : Types.Dependencies) {

        //////////////////
        // Dependencies //
        /////////////////

        let _Admins = dependencies._Admins;
        let _Ext = dependencies._Ext;
        let _Logs = dependencies._Logs;
        let _Cap = dependencies._Cap;
        let _Items = dependencies._Items;

        let _nnsActor : NNS.NNS = actor(Principal.toText(dependencies.cid_ledger));
                
        ////////////
        // State //
        //////////

        // DO NOT DELETE (DEPRECATED : Only kept for the records)
        private var oldTransactions : [EntrepotTransaction] = [];

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
        
        // Marketplace stats
        var totalVolume : Nat64 = 0;
        var lowestPriceSales : Nat64 = 0;
        var highestPriceSales : Nat64 = 0;

        //Incrementing subbaccount for handling marketplace payments.
        private var nextSubAccount : Nat = 0;
        //Incrementing transaction id.
        private var nextTxId = 0;

        //Pending ICP disbursements from this canister.
        var pendingDisbursements : List.List<Types.Disbursement> = null; 

        public func preupgrade() : UpgradeData {
            return ({
                listings = Iter.toArray(listings.entries());
                pendingTransactions = Iter.toArray(pendingTransactions.entries());
                transactions = Iter.toArray(transactions.entries());
                totalVolume;
                lowestPriceSales;
                highestPriceSales;
                nextSubAccount;
                pendingDisbursements = List.toArray(pendingDisbursements);
                oldTransactions;
            })
        };

        public func postupgrade(ud : ?UpgradeData) : () {
            switch(ud){
                case(null){};
                case(? ud){
                    for((tokenIndex, listing) in ud.listings.vals()){
                        listings.put(tokenIndex, listing);
                    };
                    for((txId, tx) in ud.transactions.vals()){
                        transactions.put(txId, tx);
                    };
                    for((tokenIndex, tx) in ud.pendingTransactions.vals()){
                        pendingTransactions.put(tokenIndex, tx);
                    };
                    totalVolume := ud.totalVolume;
                    lowestPriceSales := ud.lowestPriceSales;
                    highestPriceSales := ud.highestPriceSales;
                    nextSubAccount := ud.nextSubAccount;
                    pendingDisbursements := List.fromArray(ud.pendingDisbursements);
                    oldTransactions := ud.oldTransactions;
                };
            };
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
                    if (principal != dependencies.cid) {
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

        // Initialize the stats.
        public func initStats(
            volume : Nat64,
            highest : Nat64,
            lowest : Nat64,
            transaction: [EntrepotTransaction]
        ) : () {
            totalVolume := volume;
            highestPriceSales := highest;
            lowestPriceSales := lowest;
            oldTransactions := transaction;
        };

        // List all current NFT's for sale.
        public func getListings() : Types.ListingsResponse {
            let r = Buffer.Buffer<(Ext.TokenIndex, ExtListing, Metadata)>(0);
            for((index,listing) in listings.entries()){
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

            // Ensure this item is not equipped.AccountBlob
            if(_Items.isEquipped(index)){
                return #err(#Other("Item is equipped."));
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
                   _Logs.logMessage(Principal.toText(caller) # " :: lock " # token # " :: ERR :: Invalid token");
                    return #err(e);
                };
            };

            // Ensure token is not already locked.
            if (_isLocked(index)) {
                _Logs.logMessage(Principal.toText(caller) # " :: lock " # token # " :: ERR :: Already locked");
                return #err(#Other("Already locked."));
            };

            // Retrieve the token's listing.
            switch (listings.get(index)) {
                case (null) {
                    _Logs.logMessage(Principal.toText(caller) # " :: lock " # token # " :: ERR :: No such listing");
                    #err(#Other("No such listing."));
                };

                case (?listing) {

                    // Double check listing price
                    if (price != listing.price) {
                       _Logs.logMessage(Principal.toText(caller) # " :: lock " # token # " :: ERR :: Wrong price");
                        return #err(#Other("Incorrect listing price."));
                    };

                    let subaccount = _getNextSubAccount();
                    let paymentAddress : Ext.AccountIdentifier = Text.map(Ext.AccountIdentifier.fromPrincipal(dependencies.cid, ?subaccount), Prim.charToLower);

                    // Lock the listing
                    listings.put(index, {
                        subaccount  = listing.subaccount;
                        price       = listing.price;
                        seller      = listing.seller;
                        locked      = ?(Time.now() + transactionTtl);
                    });

                    // Ensure there isn't a pending transaction which can be settled.
                    switch (await _canSettle(caller,token)) {
                        case (#err(e)) {
                       _Logs.logMessage(Principal.toText(caller) # " :: lock " # token # " :: ERR :: Pending settlement completed");
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
                        from        = Text.map(AccountBlob.toText(AccountBlob.fromPrincipal(listing.seller, listing.subaccount)), Prim.charToLower);
                        to          = Text.map(buyer, Prim.charToLower);
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
                   _Logs.logMessage(Principal.toText(caller) # " :: lock " # token # " :: ERR :: Invalid token");
                    return #err(e);
                };
            };

            // Retrieve the pending transaction.
            let transaction = switch (pendingTransactions.get(index)) {
                case (?t) t;
                case _ {
                   _Logs.logMessage(Principal.toText(caller) # " :: lock " # token # " :: ERR :: No such transaction");
                    return #err(#Other("No such pending transaction."));
                }
            };

            // Check the transaction account on the ledger.
            let account_as_blob = AccountBlob.fromPrincipal(dependencies.cid, ?transaction.bytes);
            let balance = await _nnsActor.account_balance({account = account_as_blob});

            // Confirm enough funds have been sent.
            if (balance.e8s < transaction.price) {
                if (not _isLocked(index)) {
                    // This pending transaction is past its lock, so we delete it to save compute in our cron that iterates pending transactions.
                    pendingTransactions.delete(index);
                };
                _Logs.logMessage(Principal.toText(caller) # " :: lock " # token # " :: ERR :: Insufficient funds");
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
            lowestPriceSales := switch (transaction.price < lowestPriceSales) {
                case (true) transaction.price;
                case (false) lowestPriceSales;
            };
            highestPriceSales := switch (transaction.price > highestPriceSales) {
                case (true) transaction.price;
                case (false) highestPriceSales;
            };

            //Transfer the NFT from seller to the buyer
            _Ext.transferSale(index, transaction.from, transaction.to);

            // Remove the listing
            listings.delete(index);

            // Insert transaction into CAP history.
            ignore(_Cap.registerEvent({
                caller = dependencies.cid;
                operation = "sale";
                details = [
                    ("to", #Text(transaction.to)),
                    ("from", #Text(transaction.from)),
                    ("price", #U64(transaction.price)),
                    ("price_decimals", #U64(8)),
                    ("price_currency", #Text("ICP")),
                    ("token", #Text(Ext.TokenIdentifier.encode(dependencies.cid, index))),
                ]
            }));
            #ok();
        };

        // Get market details for an NFT (i.e. is it for sale, how much)
        public func details (token : Ext.TokenIdentifier) : Types.DetailsResponse {
            let index = switch (Ext.TokenIdentifier.decode(token)) {
                case (#err(_)) { return #err(#InvalidToken(token)); };
                case (#ok(_, tokenIndex)) { tokenIndex; };
            };
            switch (listings.get(index)) {
                case (?listing) #ok(Text.map(Ext.AccountIdentifier.fromPrincipal(listing.seller, listing.subaccount),Prim.charToLower), ?listing);
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
                highestPriceSales,
                lowestPriceSales,
                floor,
                listings.size(),
                _Ext.size(),
                transactions.size() + oldTransactions.size(), // Need to take into account the old transactions otherwise the average price is screwed up.
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

        // Return completed transactions.
        public func readTransactions () : [Types.EntrepotTransaction] {
            // Convert new types to old types.
            var r = Array.map<(Nat, Types.Transaction), Types.EntrepotTransaction>(Iter.toArray(transactions.entries()), func ((k, v)) {
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
            // Add the old transactions.
            return(Array.append<EntrepotTransaction>(r, oldTransactions));
        };

        public func readTransactionsNew () : [(Nat,Transaction)] {
            Iter.toArray(transactions.entries());
        };

        /* 
            Indicates if a token is locked and not subject to concurrency issues 
            (i.e. it is in the process of being sold).
        */

        public func isLocked(index : Ext.TokenIndex) : Bool {
            Option.isSome(pendingTransactions.get(index));
        };
        
        /* 
            Get the latest price for a transaction involving one of those tokens  
        */
        public func getLastPrice(indexs : [Ext.TokenIndex]) : ?Nat64 {
            let price = _getLatestPrice(_getTransactions(indexs));
            if(price == 0) {
                return null
            } else {
                return ?price
            }
        };

        /* 
            Get the minimum price for a transaction involving one of the token in the list
        */
        public func getFloorPrice(indexs : [Ext.TokenIndex]) : ?Nat64 {
            let transactionIndex : TrieMap.TrieMap<Ext.TokenIndex, Nat64> = TrieMap.TrieMap<Ext.TokenIndex, Nat64>(Ext.TokenIndex.equal, Ext.TokenIndex.hash);
            for((index, transaction) in transactions.entries()){
                let tokenIndex : Ext.TokenIndex = switch(Ext.TokenIdentifier.decode(transaction.token)){
                    case(#err(_)) {
                        assert(false);
                        42 : Ext.TokenIndex;
                    };
                    case(#ok(_, tokenIndex)) {
                        tokenIndex : Ext.TokenIndex;
                    };
                };
                transactionIndex.put(tokenIndex, transaction.price);
            };
            var minimum : ?Nat64 = null;
            for(tokenIndex in indexs.vals()){
                switch(transactionIndex.get(tokenIndex)){
                    case(null){};
                    case(? price){
                        switch(minimum){
                            case(null) {
                                minimum := ?price;
                            };
                            case(? min){
                                if(price < min){
                                    minimum := ?price;
                                };
                            };
                        };
                    };
                };
            };
            return minimum;
        };

        public func burn(index : Ext.TokenIndex) : () {
            listings.delete(index);
            pendingTransactions.delete(index);
        };

        ////////////////////
        // Disbursements //
        //////////////////

        // Process the queue of disbursements.
        var lastDisburseCron : Int = 0;
        var disburseInterval : Int = 5_000_000_000;
        var pendingCount : Nat = 0;
        public func cronDisbursements () : async () {
            if (List.size(pendingDisbursements) == 0) return;

            let now = Time.now();
            if (now - lastDisburseCron < disburseInterval) return;
            lastDisburseCron := now;

            // Keep track of completed and failed jobs.
            var completed   : List.List<Types.Disbursement> = null;
            var failed      : List.List<Types.Disbursement> = null;

            let (disbursement, remaining) = List.pop(pendingDisbursements);
            var job = disbursement;
            pendingDisbursements := remaining;

            label queue while (Option.isSome(job)) ignore do ? {
                pendingCount += 1;
                try {
                    switch (
                        await _nnsActor.transfer({
                            fee = { e8s = 10_000; };
                            amount = { e8s = job!.3 };
                            memo = Nat64.fromNat(Nat32.toNat(job!.0));
                            from_subaccount = ?Blob.fromArray(job!.2);
                            created_at_time = null;
                            to = switch (Hex.decode(job!.1)) {
                                case(#ok(b)) Blob.fromArray(b);
                                case(#err(e)) {
                                    _Logs.logMessage("cronDisbursements " # " ERR :: Hex decode failure: " # e);
                                    failed := List.push(job!, failed);
                                    let (disbursement, remaining) = List.pop(pendingDisbursements);
                                    job := disbursement;
                                    pendingDisbursements := remaining;
                                    pendingCount -= 1;
                                    continue queue;
                                };
                            };
                        })
                    ) {
                        case(#Ok(r)) {
                            completed := List.push(job!, completed);
                            pendingCount -= 1;
                        };
                        case(#Err(e)) switch (e) {
                            case (#InsufficientFunds(m)){
                                _Logs.logMessage("cronDisbursements " # " ERR :: NNS Failure: " # "Insufficient funds " # Nat64.toText(job!.3) # " " # Nat64.toText(m.balance.e8s) # ". Dropping task.");
                                pendingCount -= 1;
                            };
                            case (#TxDuplicate(m)){
                                _Logs.logMessage("cronDisbursements " # " ERR :: NNS Failure: " # " Tx duplicate " # Nat64.toText(job!.3) # ". Dropping task.");
                                pendingCount -= 1;
                            };
                            case (#TxTooOld(m)){
                                _Logs.logMessage("cronDisbursements " # " ERR :: NNS Failure: " # " Tx too old " # Nat64.toText(job!.3) # ". Dropping task.");
                                pendingCount -= 1;
                            };
                            case (#BadFee(m)){
                                failed := List.push(job!, failed);
                                pendingCount -= 1;
                            };
                            case (#TxCreatedInFuture(m)){
                                failed := List.push(job!, failed);
                                pendingCount -= 1;
                            };
                        };
                    };
                } catch (e) {
                    _Logs.logMessage("cronDisbursements " # " ERR :: Unexpected NNS Failure: " # Error.message(e));
                    failed := List.push(job!, failed);
                    pendingCount -= 1;
                };
                
                let (disbursement, remaining) = List.pop(pendingDisbursements);
                job := disbursement;
                pendingDisbursements := remaining;
            };

            // Put failed mints back in the queue.
            pendingDisbursements := List.append(failed, pendingDisbursements);
        };

        public func deleteDisbursementJob (
            token : Ext.TokenIndex,
            address: Ext.AccountIdentifier,
            amount: Nat64,
        ) : () {
            pendingDisbursements := List.filter<Types.Disbursement>(pendingDisbursements, func ((t, u, _, v)) {
                token != t or address != u or amount != v
            });
        };

        public func disbursements () : [Types.Disbursement] {
            List.toArray(pendingDisbursements);
        };

        public func disbursementQueueSize () : Nat {
            List.size(pendingDisbursements);
        };

        public func disbursementPendingCount () : Nat {
            pendingCount;
        };

        // Cron for pending transactions that we can settle.
        var lastSettleCron : Int = 0;
        var settleInterval : Int = 15_000_000_000;
        public func cronSettlements () : async () {
            let now = Time.now();
            if (now - lastSettleCron < settleInterval) return;
            lastSettleCron := now;
            label queue for ((index, tx) in pendingTransactions.entries()) {
                ignore settle(dependencies.cid, tx.token);
            };
        };

        //////////////////////
        // Utility/Helpers //
        ////////////////////

        /* 
            Takes a transaction and a Token index and returns a boolean indicating if the transaction involved the Token index.
        */
        func _isYourTransaction(
            index : Ext.TokenIndex,
            transaction : Transaction
        ) : Bool {
            let token = Ext.TokenIdentifier.encode(dependencies.cid, index);
            if(transaction.token == token) {
                return true;
            };
            return false;
        };

        func _getTransactions(indexs : [Ext.TokenIndex]) : [Transaction] {
            let r = Buffer.Buffer<Transaction>(0);
            for(transaction in transactions.vals()){
                for(index in indexs.vals()){
                    if(_isYourTransaction(index, transaction)){
                        r.add(transaction);
                    };
                };
            };
            return r.toArray();
        };

        /* 
            Returns the price of the most recent transaction.
        */
        func _getLatestPrice(transactions : [Transaction]) : Nat64 {
            if(transactions.size() == 0) {
                return 0;
            };
            var latest_transaction = transactions[0];
            for(transaction in transactions.vals()) {
                if(transaction.initiated > latest_transaction.initiated) {
                    latest_transaction := transaction;
                };
            };
            return latest_transaction.price;
        };

        /* 
            Returns the minimum price among the transactions.
        */
        func _getFloorPrice(transactions : [Transaction]) : Nat64 {
            if(transactions.size() == 0) {
                return 0;
            };
            var minimum = transactions[0].price;
            for(transaction in transactions.vals()) {
                if(transaction.price < minimum) {
                    minimum := transaction.price;
                };
            };
            return minimum;
        };


    };
};