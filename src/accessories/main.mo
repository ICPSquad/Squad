import Array "mo:base/Array";
import Blob "mo:base/Blob";
import Buffer "mo:base/Buffer";
import Cycles "mo:base/ExperimentalCycles";
import Float "mo:base/Float";
import Hash "mo:base/Hash";
import HashMap "mo:base/HashMap";
import Int "mo:base/Int";
import Iter "mo:base/Iter";
import Nat "mo:base/Nat";
import Nat32 "mo:base/Nat32";
import Nat64 "mo:base/Nat64";
import Nat8 "mo:base/Nat8";
import Option "mo:base/Option";
import Prim "mo:prim";
import Principal "mo:base/Principal";
import Result "mo:base/Result";
import Text "mo:base/Text";
import Time "mo:base/Time";

import AccountIdentifier "mo:principal/AccountIdentifier";
import Canistergeek "mo:canistergeek/canistergeek";
import Cap "mo:cap/Cap";
import Ext "mo:ext/Ext";
import Root "mo:cap/Root";

import Accessory "types/accessory";
import Admins "admins";
import Entrepot "entrepot";
import ExtModule "ext";
import Http "http";
import Items "items";

shared({ caller = creator }) actor class ICPSquadNFT(
    cid : Principal,
    cid_avatar : Principal
) = this {

    ///////////
    // TYPES //
    ///////////

    public type Time = Time.Time;
    public type Result<A,B> = Result.Result<A,B>;   

    ///////////
    // ADMIN //
    ///////////

    stable var _AdminsUD : ?Admins.UpgradeData = null;
    let _Admins = Admins.Admins(creator);

    public query func is_admin(p : Principal) : async Bool {
        _Admins.isAdmin(p);
    };

    public shared ({caller}) func add_admin(p : Principal) : async () {
        _Admins.addAdmin(p, caller);
        _Monitor.collectMetrics();
        _Logs.logMessage("Added admin : " # Principal.toText(p) # " by " # Principal.toText(caller));
    };

    //////////////
    // CYCLES  //
    /////////////

    public func acceptCycles() : async () {
        let available = Cycles.available();
        let accepted = Cycles.accept(available);
        assert (accepted == available);
    };

    public query func availableCycles() : async Nat {
        return Cycles.balance();
    };

    ///////////////
    // METRICS ///
    /////////////

    stable var _MonitorUD: ? Canistergeek.UpgradeData = null;
    private let _Monitor : Canistergeek.Monitor = Canistergeek.Monitor();

    /**
    * Returns collected data based on passed parameters.
    * Called from browser.
    * @auth : admin
    */
    public query ({caller}) func getCanisterMetrics(parameters: Canistergeek.GetMetricsParameters): async ?Canistergeek.CanisterMetrics {
        assert(_Admins.isAdmin(caller));
        _Monitor.getMetrics(parameters);
    };

    /**
    * Force collecting the data at current time.
    * Called from browser or any canister "update" method.
    * @auth : admin 
    */
    public shared ({caller}) func collectCanisterMetrics(): async () {
        assert(_Admins.isAdmin(caller));
        _Monitor.collectMetrics();
    };

    ////////////
    // LOGS ///
    //////////

    stable var _LogsUD: ? Canistergeek.LoggerUpgradeData = null;
    private let _Logs : Canistergeek.Logger = Canistergeek.Logger();

    /**
    * Returns collected log messages based on passed parameters.
    * Called from browser.
    * @auth : admin
    */
    public query ({caller}) func getCanisterLog(request: ?Canistergeek.CanisterLogRequest) : async ?Canistergeek.CanisterLogResponse {
        assert(_Admins.isAdmin(caller));
        _Logs.getLog(request);
    };

    //////////////////
    // EXT - ERC721 //
    /////////////////

    type AccountIdentifier = Ext.AccountIdentifier;
    type SubAccount = Ext.SubAccount;
    type User = Ext.User;
    type Balance = Ext.Balance;
    type TokenIdentifier = Ext.TokenIdentifier;
    type TokenIndex  = Ext.TokenIndex ;
    type Extension = Ext.Extension;
    type CommonError = Ext.CommonError;
    type BalanceRequest = Ext.Core.BalanceRequest;
    type BalanceResponse = Ext.Core.BalanceResponse;
    type TransferRequest = Ext.Core.TransferRequest;
    type TransferResponse = Ext.Core.TransferResponse;

    stable var _ExtUD : ?ExtModule.UpgradeData = null;
    let _Ext = ExtModule.Factory({
        cid = cid; 
        _Logs = _Logs;
    });

    public shared ({caller}) func transfer(request : TransferRequest) : async TransferResponse {
        _Monitor.collectMetrics();
        switch(_Ext.transfer(caller, request)){
            case(#err(#Other(e))) return #err(#Other(e));
            case(#err(#InvalidToken(token))) return #err(#InvalidToken(token));
            case(#ok(index)) {
                let from = Text.map(Ext.User.toAccountIdentifier(request.from), Prim.charToLower);
                let to = Text.map(Ext.User.toAccountIdentifier(request.to), Prim.charToLower);
                ignore(_registerEvent({
                    operation = "transfer";
                    details = [("token", #Text(request.token)), ("from", #Text(from)), ("to", #Text(to))];
                    caller = caller;
                }));
                return #ok(index);
            };
            case(#err(_)) return #err(#Other("Unknown error"));
        }
    };

    public func tokenId(index : TokenIndex ) : async Text {
        _Monitor.collectMetrics();
        Ext.TokenIdentifier.encode(Principal.fromActor(this), index)
    };

    public query func extensions() : async [Extension] {
        _Ext.extensions();
    };

    public query func getRegistry() : async [(TokenIndex, AccountIdentifier)] {
        _Ext.getRegistry();
    };

    public query func getTokens() : async [(TokenIndex, Ext.Common.Metadata)] {
        _Ext.getTokens();
    };
      
    public query func metadata(tokenId : TokenIdentifier): async Result<Ext.Common.Metadata, Ext.CommonError> {
       _Ext.metadata(tokenId)
    };

    public query func tokens(aid : AccountIdentifier) : async Result<[TokenIndex], CommonError> {
        _Ext.tokens(aid);
    };

    public query func tokens_ext(aid : AccountIdentifier) : async Result<[(TokenIndex, ?ExtModule.Listing, ?Blob)], CommonError> {
        _Ext.tokens_ext(aid);
    };

    public query func balance(request : BalanceRequest) : async BalanceResponse {
        _Ext.balance(request);
    };

    public query func bearer(tokenId : TokenIdentifier) : async Result<AccountIdentifier, CommonError> {
        _Ext.bearer(tokenId);
    };

    public query func details(tokenId : TokenIdentifier) : async Result<(AccountIdentifier, ?ExtModule.Listing), CommonError> {
        _Ext.details(tokenId);
    };

    //////////
    // CAP //
    /////////

    //Details : https://github.com/Psychedelic/cap-motoko-library

    type DetailValue = Root.DetailValue;
    type Event = Root.Event;
    type IndefiniteEvent = Root.IndefiniteEvent;
    
    //null is passed as argument to not override the router canister id on mainnet : lj532-6iaaa-aaaah-qcc7a-cai
    let cap = Cap.Cap(null); 

    // The number of cycles to use when initialising the handshake process which creates a new canister and install the bucket code into cap service
    let creationCycles : Nat = 1_000_000_000_000;

    // Call the handshake function on CAP which will ask the Router canister to create a new Root canister specifically for this token smart contract.
    // @auth : owner
    public shared ({caller}) func init_cap() : async Result.Result<(), Text> {
        assert(_Admins.isAdmin(caller));
        let tokenContractId = Principal.toText(Principal.fromActor(this));
        try {
            let handshake = await cap.handshake(
                tokenContractId,
                creationCycles
            );
            return #ok();
        } catch e {
            throw e;
        };
    };

    //  This hashmap is used to store events & register them later to avoid any lost event in case of CAP error or message lost.
    private stable var _eventsEntries : [(Time, IndefiniteEvent)] = [];
    let _events : HashMap.HashMap<Time, IndefiniteEvent> = HashMap.fromIter(_eventsEntries.vals(), _eventsEntries.size(), Int.equal, Int.hash);
    
    //  Periodically called through heartbeat to verify that all events have been reported 
    public shared ({caller}) func verificationEvents() : async () {
        assert(caller == Principal.fromActor(this));
        for((time,event) in _events.entries()){
            switch(await cap.insert(event)){
                case(#err(message)){};
                case(#ok(id)){
                    _events.delete(time);
                };
            };
        };
    };

    // It should almost always be 0
    public shared query ({caller}) func eventsSize() : async Nat {
        assert(_Admins.isAdmin(caller));
        _events.size();
    };

    //  Register an event to CAP, store it in _events if registration wasn't successful to process later.
    private func _registerEvent(event : IndefiniteEvent) : async () {
        let time = Time.now();
        _events.put(time, event);
        switch(await cap.insert(event)){
            case(#ok(id)){
                _events.delete(time);
            };
            case(#err(message)){};
        };
    }; 


    ///////////////
    // ENTREPOT //
    /////////////

    type ListRequest = Entrepot.ListRequest;
    type Metadata = {
        #fungible : {
        name : Text;
        symbol : Text;
        decimals : Nat8;
        metadata : ?Blob;
        };
        #nonfungible : {
        metadata : ?Blob;
        };
    };
    type Listing = Entrepot.Listing;
    type Settlement = Entrepot.Settlement;
    type Transaction = Entrepot.Transaction;
    type AccountBalanceArgs = Entrepot.AccountBalanceArgs;
    type ICPTs = Entrepot.ICPTs;

    private var ESCROWDELAY : Time = 10 * 60 * 1_000_000_000;
    let LEDGER_CANISTER = actor "ryjl3-tyaaa-aaaaa-aaaba-cai" : actor { account_balance_dfx : shared query AccountBalanceArgs -> async ICPTs };

    private stable var _usedPaymentAddressess : [(AccountIdentifier, Principal, SubAccount)] = [];
	private stable var _transactions : [Transaction] = [];

    private stable var _tokenListingState : [(TokenIndex, Listing)] = [];
	private stable var _tokenSettlementState : [(TokenIndex, Settlement)] = [];
	private stable var _paymentsState : [(Principal, [SubAccount])] = [];
	private stable var _refundsState : [(Principal, [SubAccount])] = [];

    private var _tokenListing : HashMap.HashMap<TokenIndex, Listing> = HashMap.fromIter(_tokenListingState.vals(), _tokenListingState.size(), Ext.TokenIndex.equal, Ext.TokenIndex.hash);
    private var _tokenSettlement : HashMap.HashMap<TokenIndex, Settlement> = HashMap.fromIter(_tokenSettlementState.vals(), _tokenSettlementState.size(), Ext.TokenIndex.equal, Ext.TokenIndex.hash);
    private var _payments : HashMap.HashMap<Principal, [SubAccount]> = HashMap.fromIter(_paymentsState.vals(), 0, Principal.equal, Principal.hash);
    private var _refunds : HashMap.HashMap<Principal, [SubAccount]> = HashMap.fromIter(_refundsState.vals(), 0, Principal.equal, Principal.hash);

    //Helpers
    private func _isLocked (token : TokenIndex) : Bool {
        switch(_tokenListing.get(token)){
            case(?listing){
                switch(listing.locked){
                    case(?time) {
                        if(time > Time.now()){
                            return true;
                        } else {
                            return false;
                        }
                    };
                    case(_) {
                        return false;
                    };
                };
            };
            case(_) {
                return false;
            };
        };
    };

    private func _isSubaccountIncorrect (subaccount : SubAccount) : Bool {
        var c : Nat = 0;
        var failed : Bool = true;
        while(c < 29){
            if (failed) {
                if (subaccount[c] > 0) { 
                failed := false;
                };
            };
            c += 1;
        };
        failed;
    };

    public shared(msg) func list (request : ListRequest) : async Result.Result<(), CommonError> {
        let token_identifier = request.token;
        let token_index = switch(Ext.TokenIdentifier.decode(token_identifier)){
            case(#err(_)) {
                _Logs.logMessage("Ext/lib/balance/line78. Token identifier : " # request.token);
                return #err(#InvalidToken(request.token))
            };
            case(#ok(canisterId, tokenIndex)) {
                if(canisterId != cid){
                    return #err(#InvalidToken(request.token));
                };
                tokenIndex;
            };
        };
        if(_isLocked(token_index)){
            return #err(#Other("Listing is locked"));
        };
        //TODO
        // if(_isEquipped(token_index)){
        //     return #err(#Other("Cannot list an accessory that is currently equipped. Please remove it from your avatar before."));
        // };
        switch(_tokenSettlement.get(token_index)){
            case(?settlement){
                switch(await settle(token_identifier)){
                    case(#ok) return #err(#Other("Listing as sold"));
                    case(#err(_)) {};
                };
            };
            case(_){};
        };
        switch(_registry.get(token_index)){
            case(null) return #err(#InvalidToken(token_identifier));
            case(?account) {
                if(account != Text.map(Ext.AccountIdentifier.fromPrincipal(msg.caller, request.from_subaccount),Prim.charToLower)){
                    return #err(#Other("Not authorized"));
                };
                switch(request.price){
                    case(?price){
                        _tokenListing.put(token_index, {seller = msg.caller; price = price; locked = null;});
                    };
                    case(_) {
                        _tokenListing.delete(token_index);
                    };
                };
                if(Option.isSome(_tokenSettlement.get(token_index))){
                    _tokenSettlement.delete(token_index);
                };
                return #ok;
            };
        };
    };

    public shared ({caller}) func lock (token_identifier : Text, price : Nat64, address : AccountIdentifier, subaccount : SubAccount) : async Result.Result<AccountIdentifier,CommonError> {
        if(subaccount.size() != 32) {
            return #err(#Other("Wrong subaccount"));
        };
        if(_isSubaccountIncorrect(subaccount)){
            return #err(#Other("Invalid subaccount"));
        };
        let token_index = switch(Ext.TokenIdentifier.decode(token_identifier)){
            case(#err(_)) {
                _Logs.logMessage("Ext/lib/balance/line78. Token identifier : " # token_identifier);
                return #err(#InvalidToken(token_identifier))
            };
            case(#ok(canisterId, tokenIndex)) {
                if(canisterId != cid){
                    return #err(#InvalidToken(token_identifier));
                };
                tokenIndex;
            };
        };
        if(_isLocked(token_index)){
            return #err(#Other("Listing is locked"));
        };
        switch(_tokenListing.get(token_index)){
            case(?listing){
                if(listing.price != price){
                    return #err(#Other("Price has changed"));
                } else {
                    let paymentAddress = Text.map(Ext.AccountIdentifier.fromPrincipal(listing.seller, ?subaccount),Prim.charToLower);
                    if(Option.isSome(Array.find<(AccountIdentifier,Principal,SubAccount)>(_usedPaymentAddressess, func (a : (AccountIdentifier,Principal,SubAccount)) : Bool {a.0 == paymentAddress}))){
                        return #err(#Other("Payment address has been used"));
                    };
                    _tokenListing.put(token_index, {seller = listing.seller;price = listing.price;locked = ?(Time.now() + ESCROWDELAY);});
                    switch(_tokenSettlement.get(token_index)){
                        case(?settlement){
                            let resp : Result.Result<(), CommonError> = await settle(token_identifier);
                            switch(resp){
                                case(#ok) {
                                    return #err(#Other("Listing as sold"));
                                };
                                case(#err(_)){
                                    if(Option.isNull(_tokenListing.get(token_index))) {
                                        return #err(#Other("Listing as sold"));
                                    };
                                };
                            };
                        };
                        case(_){};
                    };
                    _usedPaymentAddressess := Array.append(_usedPaymentAddressess, [(paymentAddress, listing.seller, subaccount)]);
                    _tokenSettlement.put(token_index, {seller = listing.seller;price = listing.price;subaccount = subaccount;buyer = address;});
                    return #ok(paymentAddress);
                };
            };
            case(null) {
                return #err(#Other("No listing!"))
            };
        };
    };

    public shared (msg) func settle (token_identifier : Text) : async Result.Result<(), CommonError> {
        let token_index = switch(Ext.TokenIdentifier.decode(token_identifier)){
            case(#err(_)) {
                _Logs.logMessage("Ext/lib/balance/line78. Token identifier : " # token_identifier);
                return #err(#InvalidToken(token_identifier))
            };
            case(#ok(canisterId, tokenIndex)) {
                if(canisterId != cid){
                    return #err(#InvalidToken(token_identifier));
                };
                tokenIndex;
            };
        };
        switch(_tokenSettlement.get(token_index)){
            case(null) return #err(#Other("Nothing to settle"));
            case(?settlement){
                let account_seller = Text.map(Ext.AccountIdentifier.fromPrincipal(settlement.seller, ?settlement.subaccount),Prim.charToLower);
                let owner = Text.map(Ext.AccountIdentifier.fromPrincipal(settlement.seller, null),Prim.charToLower);
                let response : ICPTs = await LEDGER_CANISTER.account_balance_dfx({account = account_seller});
                switch(_tokenSettlement.get(token_index)){
                    case(null) return #err(#Other("Nothing to settle"));
                    case(?settlement) {
                        if(response.e8s >= settlement.price){
                            _payments.put(settlement.seller, switch(_payments.get(settlement.seller)) {
                            case(?p) Array.append(p, [settlement.subaccount]);
                            case(_) [settlement.subaccount];
                            });
                            _registry.put(token_index, settlement.buyer);
                            _transactions := Array.append(_transactions, [{token = token_identifier; seller = settlement.seller; price = settlement.price; buyer = settlement.buyer; time = Time.now();}]);
                            _tokenListing.delete(token_index);
                            _tokenSettlement.delete(token_index);
                            let event : IndefiniteEvent = {
                                operation = "Sale";
                                details = [("from", #Text(owner)),("to", #Text(settlement.buyer)), ("token", #Text(token_identifier)), ("price_decimals", #U64(8)),("price_currency", #Text("ICP")), ("price", #U64(settlement.price))]; 
                                caller = msg.caller;
                            };
                            ignore(_registerEvent(event));
                            return #ok;
                        } else {
                            return #err(#Other("Insufficient funds sent"));
                        };
                    };
                };
            };
        };
    };

    public shared(msg) func clearPayments(seller : Principal, payments : [SubAccount]) : async () {
        var removedPayments : [SubAccount] = [];
        for (p in payments.vals()){
            let response : ICPTs = await LEDGER_CANISTER.account_balance_dfx({account = Text.map(Ext.AccountIdentifier.fromPrincipal(seller, ?p),Prim.charToLower)});
            if (response.e8s < 10_000){
                removedPayments := Array.append(removedPayments, [p]);
            };
        };
        switch(_payments.get(seller)) {
            case(null){};
            case(?sellerPayments) {
                var newPayments : [SubAccount] = [];
                for (p in sellerPayments.vals()){
                    if (Option.isNull(Array.find(removedPayments, func(a : SubAccount) : Bool {Array.equal(a, p, Nat8.equal);}))) {
                        newPayments := Array.append(newPayments, [p]);
                    };
                };
                _payments.put(seller, newPayments)
            };
        };
    };

    public query func listings() : async [(TokenIndex, Listing, Metadata)] {
        var results : [(TokenIndex, Listing, Metadata)] = [];
        for(a in _tokenListing.entries()) {
            results := Array.append<(TokenIndex, Listing,Metadata)>(results, [(a.0, a.1, #nonfungible({ metadata = null }))]);
        };
        results;
    };

    public query func settlements() : async [(TokenIndex, AccountIdentifier, Nat64)] {
        var result : [(TokenIndex, AccountIdentifier, Nat64)] = [];
        for((token, listing) in _tokenListing.entries()) {
            if(_isLocked(token)){
                switch(_tokenSettlement.get(token)) {
                    case(?settlement) {
                        result := Array.append(result, [(token, Text.map(Ext.AccountIdentifier.fromPrincipal(settlement.seller, ?settlement.subaccount),Prim.charToLower), settlement.price)]);
                    };
                    case(_) {};
                };
            };
        };
        result;
    };

    public query func transactions() : async [Transaction] {
        _transactions;
    };

    public query(msg) func payments() : async ?[SubAccount] {
        _payments.get(msg.caller);
    };

    public query(msg) func allSettlements() : async [(TokenIndex, Settlement)] {
        Iter.toArray(_tokenSettlement.entries())
    };

    public query(msg) func allPayments() : async [(Principal, [SubAccount])] {
        Iter.toArray(_payments.entries())
    };

     public query func stats() : async (Nat64, Nat64, Nat64, Nat64, Nat, Nat, Nat) {
        var res : (Nat64, Nat64, Nat64) = Array.foldLeft<Transaction, (Nat64, Nat64, Nat64)>(_transactions, (0,0,0), func (b : (Nat64, Nat64, Nat64), a : Transaction) : (Nat64, Nat64, Nat64) {
        var total : Nat64 = b.0 + a.price;
        var high : Nat64 = b.1;
        var low : Nat64 = b.2;
        if (high == 0 or a.price > high) {
            high := a.price;
        };
        if (low == 0 or a.price < low) {
            low := a.price;
        }; 
        (total, high, low);
        });
        var floor : Nat64 = 0;
        for (a in _tokenListing.entries()){
            if (floor == 0 or a.1.price < floor) {
                floor := a.1.price;
            };
        };
        (res.0, res.1, res.2, floor, _tokenListing.size(), _registry.size(), _transactions.size());
    };


    ////////////
    // ITEMS //
    //////////

    public type Template = Items.Template;
    public type Item = Items.Item;

    stable var _ItemsUD : ?Items.UpgradeData = null;
    let _Items = Items.Factory({
        _Logs = _Logs;
        _Ext = _Ext;
        cid_avatar = cid_avatar; 
        cid = cid;
    });

    public shared ({ caller }) func addTemplate(
        name : Text,
        template : Template
    ) : async Result<Text,Text>{
        assert(_Admins.isAdmin(caller));
        _Monitor.collectMetrics();
        _Items.addTemplate(name, template);
    };
      
    public shared({caller}) func wearAccessory(
        accessory : TokenIdentifier, 
        avatar : TokenIdentifier
        ) : async Result.Result<(), Text> {
        _Monitor.collectMetrics();
        // TODO : verify that the accessory is not listed!
        switch(_Ext.isOwner(caller, accessory)){
            case(#err(e)) return #err(e);
            case(#ok()){};
        };
        switch(await _Items.wearAccessory(accessory, avatar, caller)){
            case(#ok()) return #ok;
            case(#err(e)) return #err(e);
        };
    };

    public shared ({caller}) func removeAccessory(
        accessory : TokenIdentifier,
        avatar : TokenIdentifier 
        ) : async Result.Result<(), Text> {
        _Monitor.collectMetrics();
        // TODO : verification here ?
        switch(_Ext.isOwner(caller, accessory)){
            case(#err(e)) return #err(e);
            case(#ok()){};
        };
        switch(await _Items.removeAccessory(accessory, avatar, caller)){
            case(#ok()) return #ok;
            case(#err(e)) return #err(e);
        };
    };

    // public shared ({caller}) func createAccessory(

    // ) : () {
    //     //TODO
    // };

    // public shared ({caller}) func updateAccessories(

    // ) : () {
    //     //TODO
    // };

    public shared ({ caller }) func mint(
        name : Text,
        receiver : Principal,
    ) : async Result<(), Text> {
        assert(_Admins.isAdmin(caller));
        _Monitor.collectMetrics();
        switch(_Ext.mint({ to = #principal(receiver); metadata = null; })){
            case(#err(#Other(e))) return #err(e);
            case(#err(#InvalidToken(e))) return #err(e);
            case(#ok(index)){
                switch(_Items.mint(name, index)){
                    case(#err(e)) {
                        //  Revert all state changes since the beggining of this message (the token created is reverted).
                        assert(false);
                        return #err("Unreacheable");
                    };
                    case(#ok){
                        _Logs.logMessage(name # " has been minted by " # Principal.toText(caller) # " for " # Principal.toText(receiver));
                        return #ok;
                    }
                }
            };
        };
    };


    //////////
    // HTTP //
    //////////

    let _HttpHandler = Http.HttpHandler({
        _Admins = _Admins;
        _Items = _Items;
    });

    public query func http_request (request : Http.Request) : async Http.Response {
        _HttpHandler.request(request);  
    };

    ///////////////
    // HEARTBEAT //
    ///////////////

    // A count represents approximately one second (one block in reality but we don't need that precision)
    stable var count = 0;

    system func heartbeat () : async () {
        count += 1;
        //  Every 2 minutes 
        if (count % 120 == 0) {
            await verificationEvents();
        };
        //  Every 5 minutes 
        if( count % 300 == 0){
            await collectCanisterMetrics();
        };
    };

    //////////
    // OLD //
    ////////

    //  Contains informations needed to create items. 
    //  Material and legendary are stored as Blob (less memory consumption)
    //  Template for accessories are stored as Text to modify the wear value programatically, they also integrate a recipe.
    private stable var _templateEntries : [(Text, Template)] = [];
    private var _templates : HashMap.HashMap<Text, Template> = HashMap.fromIter(_templateEntries.vals(),_templateEntries.size(), Text.equal, Text.hash);

    //  Make the link between TokenIndex and the actual Item it represents.
    private stable var _itemsEntries : [(TokenIndex, Item)] = [];
    private var _items : HashMap.HashMap<TokenIndex, Item> = HashMap.fromIter(_itemsEntries.vals(), _itemsEntries.size(), Ext.TokenIndex.equal, Ext.TokenIndex.hash);

    //Accessories stored as Blob after being drawn.
    private stable var _blobsEntries : [(TokenIndex,Blob) ]= [];
    private var _blobs : HashMap.HashMap<TokenIndex,Blob> = HashMap.fromIter(_blobsEntries.vals(), _blobsEntries.size(), Ext.TokenIndex.equal, Ext.TokenIndex.hash);

    ///TOKEN
    private stable var _nextTokenId : TokenIndex  = 0;
    private stable var _registryEntries : [(TokenIndex, AccountIdentifier)] = [];
    private var _registry : HashMap.HashMap<TokenIndex, AccountIdentifier> = HashMap.fromIter(_registryEntries.vals(), 0, Ext.TokenIndex.equal, Ext.TokenIndex.hash);

    private stable var _ownershipsEntries : [(AccountIdentifier, [TokenIndex])] = [];
    private var _ownerships : HashMap.HashMap<AccountIdentifier, [TokenIndex]> = HashMap.fromIter(_ownershipsEntries.vals(), _ownershipsEntries.size(), Text.equal, Text.hash);



    //////////////
    // UPGRADE //
    /////////////

    system func preupgrade() {
        // EXT
        _registryEntries := Iter.toArray(_registry.entries());
        _ownershipsEntries := Iter.toArray(_ownerships.entries());
        // Items
        _itemsEntries := Iter.toArray(_items.entries());
        _templateEntries := Iter.toArray(_templates.entries());
        _blobsEntries := Iter.toArray(_blobs.entries());
        // CAP
        _eventsEntries := Iter.toArray(_events.entries());
        // Entrepot
        _tokenListingState := Iter.toArray(_tokenListing.entries());
        _tokenSettlementState := Iter.toArray(_tokenSettlement.entries());
        _paymentsState := Iter.toArray(_payments.entries());
        _refundsState := Iter.toArray(_refunds.entries());
    };

    system func postupgrade() {
        // EXT
        _registryEntries := [];
        _ownershipsEntries := [];
        _templateEntries := [];
        _itemsEntries := [];
        _blobsEntries := [];
        //  Entrepot
        _tokenListingState := [];
        _tokenSettlementState := [];
        _paymentsState := [];
        _refundsState := [];
    };

};