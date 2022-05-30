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
import Ext "mo:ext/Ext";
import Root "mo:cap/Root";

import Admins "admins";
import Cap "cap";
import Entrepot "entrepot";
import ExtModule "ext";
import Http "http";
import Invoice "invoice";
import Items "items";
import NNS "nns";
shared({ caller = creator }) actor class ICPSquadNFT(
    cid : Principal,
    cid_avatar : Principal,
    cid_invoice : Principal,
    cid_ledger : Principal,
    cid_hub : Principal
) = this {

    ///////////
    // TYPES //
    ///////////

    public type Time = Time.Time;
    public type Result<A,B> = Result.Result<A,B>;
    public type IndefiniteEvent = Cap.IndefiniteEvent; 

    ///////////
    // ADMIN //
    ///////////

    stable var master : Principal = creator;

    stable var _AdminsUD : ?Admins.UpgradeData = null;
    let _Admins = Admins.Admins(creator);

    public query func is_admin(p : Principal) : async Bool {
        _Admins.isAdmin(p);
    };

    public shared ({ caller }) func add_admin(p : Principal) : async () {
        _Admins.addAdmin(p, caller);
        _Monitor.collectMetrics();
        _Logs.logMessage("Added admin : " # Principal.toText(p) # " by " # Principal.toText(caller));
    };

    public shared ({ caller }) func remove_admin(p : Principal) : async () {
        assert(caller == master);
        _Monitor.collectMetrics();
        _Admins.removeAdmin(p, caller);
        _Logs.logMessage("Removed admin : " # Principal.toText(p) # " by " # Principal.toText(caller));
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

    ////////////
    // NNS ////
    //////////

    let _NNS = NNS.Factory({
        _Admins;
        _Logs;
        cid_ledger
    });

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
                ignore(_Cap.registerEvent({
                    operation = "transfer";
                    details = [("token", #Text(request.token)), ("from", #Text(from)), ("to", #Text(to))];
                    caller = caller;
                }));
                return #ok(index);
            };
            case(#err(_)) return #err(#Other("Unknown error"));
        }
    };

    public func tokenId(index : TokenIndex) : async Text {
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

    stable var _CapUD : ?Cap.UpgradeData = null;
    let _Cap = Cap.Factory({
        _Logs = _Logs;
        _Admins = _Admins;
        cid = cid;
        overrideRouterId = null;
        provideRootBucketId = ?"qfevy-hqaaa-aaaaj-qanda-cai";
    });
    
    /* Regularly called by the hub canister in case some events haven't been processed to the CAP bucket */
    public shared ({caller}) func cron_events() : async () {
        assert(caller == cid_hub);
        _Monitor.collectMetrics();
        await _Cap.cronEvents();
    };

    ///////////////
    // ENTREPOT //
    /////////////

    public type AccountBalanceArgs = { account : AccountIdentifier };
    public type ICPTs = { e8s : Nat64 };

    public type Transaction = {
        token : TokenIdentifier;
        seller : Principal;
        price : Nat64;
        buyer : AccountIdentifier;
        time : Time;
    };

    public type Settlement = {
        seller : Principal;
        price : Nat64;
        subaccount : SubAccount;
        buyer : AccountIdentifier;
    };

    public type Listing = {
        seller : Principal;
        price : Nat64;
        locked : ?Time;
    };

    public type ListRequest = {
        token : TokenIdentifier;
        from_subaccount : ?SubAccount;
        price : ?Nat64;
    };

    public type Metadata = {
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

    private func _getPrice(index : TokenIndex) : Result<Nat, ()> {
        switch(_tokenListing.get(index)){
            case(?listing){
                return #ok(Nat64.toNat(listing.price));
            };
            case(_) {
                return #err();
            };
        };
    };

    private func _getFloorPrice(indexs : [TokenIndex]) : ?Nat {
        if(indexs.size() == 0){
            return null
        };
        var prices = Buffer.Buffer<Nat>(0);
        for(index in indexs.vals()){
            switch(_getPrice(index)){
                case(#err()){};
                case(#ok(value)){
                    prices.add(value);
                };
            };
        };
        let array_prices = prices.toArray();
        if(array_prices.size() == 0){
            return null
        };
        let array_sorted = Array.sort<Nat>(array_prices, Nat.compare);
        return ?array_sorted[0];
    };

    /* Returns the optional last price at which a transaction was made for one of the tokenIdentifier  */
    private func _getLastPrice(tokenIds : [TokenIdentifier]) : ?Nat {
        let transactions : [Transaction] = Array.filter<Transaction>(_transactions, func(x) {Option.isSome(Array.find<TokenIdentifier>(tokenIds, func(a) {a == x.token}))});
        if(transactions.size() == 0){
            return null
        } else {
            var last_price = transactions[0].price;
            var last_time = transactions[0].time;
            for(transaction in transactions.vals()){
                if(transaction.time > last_time){
                    last_time := transaction.time;
                    last_price := transaction.price;
                };
            };
            ?Nat64.toNat(last_price);
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
                _Logs.logMessage("Failed decoding this tokenIdentifier : " # request.token);
                return #err(#InvalidToken(request.token))
            };
            case(#ok(canisterId, tokenIndex)) {
                if(canisterId != cid){
                    _Logs.logMessage("This token is not owned by this canister : " # request.token);   
                    return #err(#InvalidToken(request.token));
                };
                tokenIndex;
            };
        };
        if(_isLocked(token_index)){
            return #err(#Other("Listing is locked"));
        };
        if(_Items.isEquipped(token_index)){
            return #err(#Other("Cannot list an accessory that is currently equipped. Please remove it from your avatar before."));
        };
        switch(_tokenSettlement.get(token_index)){
            case(?settlement){
                switch(await settle(token_identifier)){
                    case(#ok) return #err(#Other("Listing as sold"));
                    case(#err(_)) {};
                };
            };
            case(_){};
        };
        switch(_Ext.getOwner(token_index)){
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
                            _Ext.putOwner(token_index, settlement.buyer);
                            _transactions := Array.append(_transactions, [{token = token_identifier; seller = settlement.seller; price = settlement.price; buyer = settlement.buyer; time = Time.now();}]);
                            _tokenListing.delete(token_index);
                            _tokenSettlement.delete(token_index);
                            let event : IndefiniteEvent = {
                                operation = "Sale";
                                details = [("from", #Text(owner)),("to", #Text(settlement.buyer)), ("token", #Text(token_identifier)), ("price_decimals", #U64(8)),("price_currency", #Text("ICP")), ("price", #U64(settlement.price))]; 
                                caller = msg.caller;
                            };
                            ignore(_Cap.registerEvent(event));
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
        (res.0, res.1, res.2, floor, _tokenListing.size(), _Ext.size(), _transactions.size());
    };

    ////////////////
    // INVOICE ////
    //////////////

    let _Invoice = Invoice.Factory({
        invoice_cid = cid_invoice;
    });


    ////////////
    // ITEMS //
    //////////

    public type Template = Items.Template;
    public type Recipe = Items.Recipe;
    public type Item = Items.Item;
    public type Inventory = Items.Inventory;
    public type ItemInventory = Items.ItemInventory;
    public type MaterialInventory = Items.MaterialInventory;
    public type AccessoryInventory = Items.AccessoryInventory;

    stable var _ItemsUD : ?Items.UpgradeData = null;
    let _Items = Items.Factory({
        _Logs = _Logs;
        _Ext = _Ext;
        cid_avatar = cid_avatar; 
        cid = cid;
    });

    public shared ({ caller }) func add_template(
        name : Text,
        template : Template
    ) : async Result<Text,Text>{
        assert(_Admins.isAdmin(caller));
        _Monitor.collectMetrics();
        switch(_Items.addTemplate(name, template)){
            case(#ok(msg)) {
                _Logs.logMessage("Template added for : " # name # " by " # Principal.toText(caller) );
                return #ok(msg);
            };
            case(#err((msg))) {
                _Logs.logMessage("Failed to add template: " # name # ": " #msg);
                return #err((msg));
            };
        }
    };

    public query func get_templates() : async [(Text, Template)] {
        _Items.getTemplates();
    };

    public query func get_recipes() : async [(Text, Recipe)] {
        _Items.getRecipes();
    };
      
    public shared({caller}) func wear_accessory(
        accessory : TokenIdentifier, 
        avatar : TokenIdentifier
        ) : async Result<(), Text> {
        _Monitor.collectMetrics();
        switch(_Ext.isOwner(caller, accessory)){
            case(#err(e)) {
                _Logs.logMessage("Caller : " # Principal.toText(caller) # "trying to wear accessory : " # accessory # " but is not owner");
                return #err(e);
            };
            case(#ok()){};
        };
        let index = switch(Ext.TokenIdentifier.decode(accessory)){
            case(#err(e)){ 
                _Logs.logMessage("Error during decode of tokenIdentifier : " # accessory # ". Detail : " # e);
                return #err(e);
            };
            case(#ok(p, index)){
                if(p != cid){
                    _Logs.logMessage("Error when decoding the tokenIdentifier : " # accessory # "the canister id is " # Principal.toText(p));
                    return #err("Error when decoding the tokenIdentifier : " # accessory);
                };
                index;
            };
        };
        if(_isLocked(index)){
            _Logs.logMessage("Trying to equip this accessory when locked (Entrepot) : " # accessory);
            return #err("Trying to equip this accessory when locked (Entrepot) : " # accessory);
        };
        await _Items.wearAccessory(accessory, avatar, caller);
    };

    public shared ({caller}) func remove_accessory(
        accessory : TokenIdentifier,
        avatar : TokenIdentifier 
        ) : async Result.Result<(), Text> {
        // assert(false);
        _Monitor.collectMetrics();
        switch(_Ext.isOwner(caller, accessory)){
            case(#err(e)) {
                _Logs.logMessage("Caller : " # Principal.toText(caller) # "trying to remove accessory : " # accessory # " but is not owner");
                return #err(e);
            };
            case(#ok()){};
        };
        let index = switch(Ext.TokenIdentifier.decode(accessory)){
            case(#err(e)){
                _Logs.logMessage("Error during decode of tokenIdentifier : " # accessory # ". Detail : " # e);
                return #err(e);
            };
            case(#ok(p, index)){
                if(p != cid){
                    _Logs.logMessage("Error when decoding the tokenIdentifier : " # accessory # "the canister id is " # Principal.toText(p));
                    return #err("Error when decoding the tokenIdentifier : " # accessory);
                };
                index;
            };
        };
        if(_isLocked(index)){
            _Logs.logMessage("(IMPOSSIBLE) Trying to dequip this accessory when locked (Entrepot) : " # accessory);
            return #err("Trying to equip this accessory when locked (Entrepot) : " # accessory);
        };
        await _Items.removeAccessory(accessory, avatar, caller)
    };

    public shared ({caller}) func create_accessory(
        name : Text,
        invoice_id : Nat
    ) : async Result.Result<TokenIdentifier, Text> {
        _Monitor.collectMetrics();
        let recipe = switch(_Items.getRecipe(name)){
            case(null) return #err("No recipe found for : " # name);
            case(?recipe){recipe};
        };
        switch(await _Invoice.verifyInvoice(invoice_id, caller)){
            case(#ok){};
            case(#err) {
                _Logs.logMessage("Error during invoice verification for invoice : " # Nat.toText(invoice_id) # " by " # Principal.toText(caller));
                return #err("Error during invoice verification");
            };
        };
        let materials = _Items.getMaterials(caller);
        // Filter out all materials that are locked on Entrepot to avoid concurrency issues.
        var materials_available = Array.filter<(TokenIndex, Text)>(materials, func(x) {
            not _isLocked(x.0)
        });
        // Create the list of materials that will be used for the recipes.
        let materials_used = Buffer.Buffer<(TokenIndex)>(0);
        for (material in recipe.vals()){
            let material_used = switch(Array.find<(TokenIndex,Text)>(materials_available, func(x) {
                x.1 == material
            })){
                case(null) return #err("Not enough : " # material);
                case(?x){ x };
            };
            // Add the tokenIndex to the actually used materials and remove it from the list of available materials to avoid reusing.
            materials_used.add(material_used.0);
            materials_available := Array.filter<(TokenIndex,Text)>(materials, func(x) { x.0 == material_used.0 });
        };
        // Remove the materials from every database (they are burned).
        for(tokenIndex in materials_used.toArray().vals()){
            _Items.burn(tokenIndex);
            _Ext.burn(tokenIndex);
            _tokenListing.delete(tokenIndex);
            _tokenSettlement.delete(tokenIndex);
            
            // Report burning events to CAP.
            let event : IndefiniteEvent = {
                operation = "burn";
                details = [("token", #Text(Ext.TokenIdentifier.encode(cid,tokenIndex))), ("from", #Text(Principal.toText(caller)))];
                caller = caller;
            };
            ignore(_Cap.registerEvent(event));
        };
        // Create the token and the associated accessory.
        let request : Ext.NonFungible.MintRequest = {
            to = #principal(caller);
            metadata = null;
        };
        switch(_Ext.mint(request)){
              case(#err(_)) {
                  assert(false);
                  return #err("Error fatal during minting of token");
              };
              case(#ok(tokenIndex)){
                  switch(_Items.mint(name, tokenIndex)){
                      case(#err(_)){
                          assert(false);
                          return #err("Error fatal during minting of accessory");
                      };
                      case(#ok()){
                        let tokenIdentifier = Ext.TokenIdentifier.encode(cid, tokenIndex);
                        // Report minting event to CAP.
                        let event : IndefiniteEvent = {
                            operation = "mint";
                            details = [("token", #Text(tokenIdentifier)), ("to", #Text(Principal.toText(caller)))];
                            caller = caller;
                        };
                        ignore(_Cap.registerEvent(event));
                        _Logs.logMessage("Accessory created : " # name # " by " # Principal.toText(caller) # "with identifier " # tokenIdentifier);
                        return #ok(tokenIdentifier);
                      };
                  };
              };
        };
    };

    public shared ({ caller }) func burn(
        token : TokenIdentifier
    ) : async Result<(), Text> {
        assert(_Admins.isAdmin(caller));
        _Monitor.collectMetrics();
        let tindex = switch(Ext.TokenIdentifier.decode(token)){
            case(#err(_)) {
                return #err("Invalid token identifier");
            };
            case(#ok(cid, index)){ index };
        };
        if(_Items.isEquipped(tindex)){
            return #err("Cannot burn equipped item. Please desequip first.");
        };
        // Todo add Entrepot verification
        _Ext.burn(tindex);
        _Items.burn(tindex);
        _tokenListing.delete(tindex);
        _tokenSettlement.delete(tindex);
        // Report burning to CAP.
        let event : IndefiniteEvent = {
                operation = "burn";
                details = [("token", #Text(Ext.TokenIdentifier.encode(cid,tindex))), ("from", #Text(Principal.toText(caller)))];
                caller = caller;
        };
        ignore(_Cap.registerEvent(event));
        _Logs.logMessage("Accessory burned : " # token # " by " # Principal.toText(caller));
        return #ok;
    };

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
                        //  Revert all state changes since the beggining of this message (ie the token created is reverted).
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

    public query func get_name(index : TokenIndex) : async ?Text {
        _Items.getName(index);
    };


    public shared ({ caller }) func confirmed_burned_accessory(
        index : TokenIndex
    ) : async () {
        assert(_Admins.isAdmin(caller) or caller == cid_avatar);
        _Monitor.collectMetrics();
        _Items.confirmBurnedAccessory(index);
    };

    public shared ({ caller }) func update_accessories() : async () {
        assert(_Admins.isAdmin(caller));
        _Monitor.collectMetrics();
        let (burned, decreased, not_found ) = _Items.updateAll();
        // Report all burned accessories to CAP
        for(index in burned.vals()){
            let event : IndefiniteEvent = {
                operation = "burn";
                details = [("token", #Text(Ext.TokenIdentifier.encode(cid, index)))];
                caller = caller;
            };
            ignore(_Cap.registerEvent(event));
        };
        _Logs.logMessage("Daily update of accessories : " # Nat.toText(burned.size()) # Nat.toText(decreased.size()) #  Nat.toText(not_found.size()));
        return;
    };

    /* Called every 2 minutes by heartbeat to verify that recently burned accessories have been reported to the avatar canister */
    public shared ({ caller }) func verification_burned() : async () {
        assert(caller == cid);
        _Monitor.collectMetrics();
        await _Items.verificationBurned();
    };

    public shared ({ caller }) func update_accessory(index : TokenIndex) : async () {
        assert(_Admins.isAdmin(caller));
        _Monitor.collectMetrics();
        ignore(_Items.updateAccessory(index));
        return;
    };



    public query ({ caller }) func getInventory() : async Result<Inventory, Text> {
        _Items.getInventory(caller);
    };

    //////////
    // HTTP //
    //////////

    let _HttpHandler = Http.HttpHandler({
        _Admins = _Admins;
        _Items = _Items;
        _Logs = _Logs;
        cid = cid;
    });

    public query func http_request (request : Http.Request) : async Http.Response {
        _HttpHandler.request(request);  
    };


    ////////////
    // STATS //
    //////////

    public type Name = Text;
    public type Supply = Nat;
    public type Floor = Nat;
    public type LastSoldPrice = Nat;

    public query func get_stats_items() : async [(Text, Supply, ?Floor, ?LastSoldPrice)] {
        let items = _Items.getItems();
        let buffer = Buffer.Buffer<(Text, Supply, ?Floor, ?LastSoldPrice)>(items.size());
        for (item in items.vals()){
            let tokenIds = Array.map<TokenIndex, TokenIdentifier>(item.1, func(index : TokenIndex) {Ext.TokenIdentifier.encode(cid, index)});
            buffer.add((item.0, item.1.size(), _getFloorPrice(item.1), _getLastPrice(tokenIds)));
        };
        return buffer.toArray();
    };

    ///////////////
    // Entrepot //
    //////////////

    stable var _EntrepotUD : ?Entrepot.UpgradeData = null;
    let _Entrepot = Entrepot.Factory({
        _Ext;
        _Admins;
        _Cap;
        _Logs;
        _NNS;
        cid;
        cid_ledger;
    });

    // public shared ({ caller }) func list(
    //     request : Entrepot.ListRequest
    // ) : async Entrepot.ListResponse {
    //     _Monitor.collectMetrics();
    //     return _Entrepot.list(caller, request);
    // };

    // public shared ({ caller }) func lock(
    //     token : TokenIdentifier,
    //     price : Nat64,
    //     buyer : AccountIdentifier,
    //     bytes : [Nat8]
    // ) : async Entrepot.LockResponse {
    //     _Monitor.collectMetrics();
    //     return _Entrepot.lock(caller, token, price, buyer, bytes);
    // };

    // public shared ({ caller }) func settle (
    //     token : EXT.TokenIdentifier,
    // ) : async Result<(), EXT.CommonError> {
    //     _Monitor.collectMetrics();
    //     await _Entrepot.settle(caller, token);
    // };

    // public query func stats() : async (
    //     Nat64,  // Total volumes
    //     Nat64,  // Highest price sale
    //     Nat64,  // Lowest price sale
    //     Nat64,  // Current Floor price
    //     Nat,    // # Listings
    //     Nat,    // # Supply
    //     Nat,    // # Sales
    // ) {
    //     _Entrepot.stats();
    // };

    // public query func details(token : TokenIdentifier) : async Entrepot.DetailsResponse {
    //     _Entrepot.details(token);
    // };

    // public query func listings () : async Entrepot.ListingsResponse {
    //     _Entrepot.getListings();
    // };

    public type Disbursement = Entrepot.Disbursement;

    public query ({caller}) func read_disbursements() : async [Disbursement] {
        assert(_Admins.isAdmin(caller));
        _Entrepot.disbursements();
    };

    public query ({ caller }) func disbursement_queue_size() : async Nat {
        assert(_Admins.isAdmin(caller));
        _Entrepot.disbursementQueueSize();
    };

    public query ({ caller }) func disbursementPendingCount () : async Nat {
        assert(_Admins.isAdmin(caller));
        _Entrepot.disbursementPendingCount();
    };

    public shared ({ caller }) func deleteDisbursementJob (
        token : TokenIndex,
        address: AccountIdentifier,
        amount: Nat64,
    ) : async () {
        assert(_Admins.isAdmin(caller));
        _Monitor.collectMetrics();
        _Entrepot.deleteDisbursementJob(token, address, amount);
    };

    //////////////
    // UPGRADE //
    /////////////

    system func preupgrade() {
        _Logs.logMessage("Preupgrade (accessory)");
        // Entrepot
        _tokenListingState := Iter.toArray(_tokenListing.entries());
        _tokenSettlementState := Iter.toArray(_tokenSettlement.entries());
        _paymentsState := Iter.toArray(_payments.entries());
        _refundsState := Iter.toArray(_refunds.entries());
        // Modules
        _MonitorUD := ? _Monitor.preupgrade();
        _LogsUD := ? _Logs.preupgrade();
        _ItemsUD := ? _Items.preupgrade();
        _AdminsUD := ? _Admins.preupgrade();
        _ExtUD := ? _Ext.preupgrade();
        _EntrepotUD := ? _Entrepot.preupgrade();
        _CapUD := ? _Cap.preupgrade();
    };

    system func postupgrade() {
        // Entrepot
        _tokenListingState := [];
        _tokenSettlementState := [];
        _paymentsState := [];
        _refundsState := [];
        // Modules
        _Monitor.postupgrade(_MonitorUD);
        _MonitorUD := null;
        _Logs.postupgrade(_LogsUD);
        _LogsUD := null;
        _Admins.postupgrade(_AdminsUD);
        _AdminsUD := null;
        _Items.postupgrade(_ItemsUD);
        _ItemsUD := null;
        _Ext.postupgrade(_ExtUD);
        _ExtUD := null;
        _Cap.postupgrade(_CapUD);
        _CapUD := null;
        _Entrepot.postupgrade(_EntrepotUD);
        _EntrepotUD := null;
        _Logs.logMessage("Postupgrade (accessory)");
    };
};