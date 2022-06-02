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

    // public query func details(tokenId : TokenIdentifier) : async Result<(AccountIdentifier, ?ExtModule.Listing), CommonError> {
    //     _Ext.details(tokenId);
    // };

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


    // private func _isLocked (token : TokenIndex) : Bool {
    //     switch(_tokenListing.get(token)){
    //         case(?listing){
    //             switch(listing.locked){
    //                 case(?time) {
    //                     if(time > Time.now()){
    //                         return true;
    //                     } else {
    //                         return false;
    //                     }
    //                 };
    //                 case(_) {
    //                     return false;
    //                 };
    //             };
    //         };
    //         case(_) {
    //             return false;
    //         };
    //     };
    // };

    // private func _getPrice(index : TokenIndex) : Result<Nat, ()> {
    //     switch(_tokenListing.get(index)){
    //         case(?listing){
    //             return #ok(Nat64.toNat(listing.price));
    //         };
    //         case(_) {
    //             return #err();
    //         };
    //     };
    // };

    // private func _getFloorPrice(indexs : [TokenIndex]) : ?Nat {
    //     if(indexs.size() == 0){
    //         return null
    //     };
    //     var prices = Buffer.Buffer<Nat>(0);
    //     for(index in indexs.vals()){
    //         switch(_getPrice(index)){
    //             case(#err()){};
    //             case(#ok(value)){
    //                 prices.add(value);
    //             };
    //         };
    //     };
    //     let array_prices = prices.toArray();
    //     if(array_prices.size() == 0){
    //         return null
    //     };
    //     let array_sorted = Array.sort<Nat>(array_prices, Nat.compare);
    //     return ?array_sorted[0];
    // };

    /* Returns the optional last price at which a transaction was made for one of the tokenIdentifier  */
    // private func _getLastPrice(tokenIds : [TokenIdentifier]) : ?Nat {
    //     let transactions : [Transaction] = Array.filter<Transaction>(_transactions, func(x) {Option.isSome(Array.find<TokenIdentifier>(tokenIds, func(a) {a == x.token}))});
    //     if(transactions.size() == 0){
    //         return null
    //     } else {
    //         var last_price = transactions[0].price;
    //         var last_time = transactions[0].time;
    //         for(transaction in transactions.vals()){
    //             if(transaction.time > last_time){
    //                 last_time := transaction.time;
    //                 last_price := transaction.price;
    //             };
    //         };
    //         ?Nat64.toNat(last_price);
    //     };
    // };


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
        if(_Entrepot.isLocked(index)){
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
        if(_Entrepot.isLocked(index)){
            _Logs.logMessage("(IMPOSSIBLE) Trying to dequip this accessory when locked (Entrepot) : " # accessory);
            return #err("Trying to equip this accessory when locked (Entrepot) : " # accessory);
        };
        await _Items.removeAccessory(accessory, avatar, caller)
    };

    public shared ({ caller }) func create_accessory(
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
            not _Entrepot.isLocked(x.0)
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
        for(tokenIndex  in materials_used.toArray().vals()){
            // Save the name to be report event to CAP.
            let name = Option.get(_Items.getName(tokenIndex), "Unknown");
            _Items.burn(tokenIndex);
            _Ext.burn(tokenIndex);
            _Entrepot.burn(tokenIndex);
            // Report burning events to CAP.
            let event : IndefiniteEvent = {
                operation = "burn";
                details = [("token", #Text(Ext.TokenIdentifier.encode(cid,tokenIndex))), ("from", #Text(Principal.toText(caller))), ("name", #Text(name))];
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
                            details = [("token", #Text(tokenIdentifier)), ("to", #Text(Principal.toText(caller))), ("name", #Text(name))];
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
            let name = Option.get(_Items.getName(index), "Unknown");
            let event : IndefiniteEvent = {
                operation = "burn";
                details = [("token", #Text(Ext.TokenIdentifier.encode(cid, index))),("name", #Text(name))];
                caller = caller;
            };
            ignore(_Cap.registerEvent(event));
        };
        _Logs.logMessage("Daily update of accessories : " # Nat.toText(burned.size()) # Nat.toText(decreased.size()) #  Nat.toText(not_found.size()));
        return;
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
    public type Floor = Nat64;
    public type LastSoldPrice = Nat64;

    public query func get_stats_items() : async [(Text, Supply, ?Floor, ?LastSoldPrice)] {
        let items = _Items.getItems();
        let buffer = Buffer.Buffer<(Text, Supply, ?Floor, ?LastSoldPrice)>(items.size());
        for (item in items.vals()){
            buffer.add((item.0, item.1.size(), _Entrepot.getFloorPrice(item.1), _Entrepot.getLastPrice(item.1)));
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
        _Items;
        _Logs;
        _NNS;
        cid;
        cid_ledger;
    });

    public shared ({ caller }) func is_owner_account(
        account : AccountIdentifier,
        token : TokenIndex
    ) : async Bool{
        assert(_Admins.isAdmin(caller));
        return _Ext.isOwnerAccount(account,token);
    };

    public shared ({ caller }) func list(
        request : Entrepot.ListRequest
    ) : async Entrepot.ListResponse {
        _Monitor.collectMetrics();
        await _Entrepot.list(caller, request);
    };

    public shared ({ caller }) func lock(
        token : TokenIdentifier,
        price : Nat64,
        buyer : AccountIdentifier,
        bytes : [Nat8]
    ) : async Entrepot.LockResponse {
        _Monitor.collectMetrics();
        await _Entrepot.lock(caller, token, price, buyer, bytes);
    };

    public shared ({ caller }) func settle (
        token : TokenIdentifier,
    ) : async Result<(), CommonError> {
        _Monitor.collectMetrics();
        await _Entrepot.settle(caller, token);
    };

    public query func stats() : async (
        Nat64,  // Total volumes
        Nat64,  // Highest price sale
        Nat64,  // Lowest price sale
        Nat64,  // Current Floor price
        Nat,    // # Listings
        Nat,    // # Supply
        Nat,    // # Sales
    ) {
        _Entrepot.stats();
    };

    public query func details(token : TokenIdentifier) : async Entrepot.DetailsResponse {
        _Entrepot.details(token);
    };

    public query func listings () : async Entrepot.ListingResponse {
        _Entrepot.getListings();
    };

    public query func transactions() : async [Entrepot.EntrepotTransaction] {
        _Entrepot.readTransactions();
    };

    public query func transactions_new() : async [(Nat,Entrepot.Transaction)] {
        _Entrepot.readTransactionsNew();
    };

    public query ({ caller }) func payments() : async ?[SubAccount] {
        _Entrepot.payments(caller);
    };

    public type Disbursement = Entrepot.Disbursement;

    public query ({caller}) func read_disbursements() : async [Disbursement] {
        assert(_Admins.isAdmin(caller));
        _Entrepot.disbursements();
    };

    public query ({ caller }) func disbursement_queue_size() : async Nat {
        assert(_Admins.isAdmin(caller));
        _Entrepot.disbursementQueueSize();
    };

    public query ({ caller }) func disbursement_pending_count () : async Nat {
        assert(_Admins.isAdmin(caller));
        _Entrepot.disbursementPendingCount();
    };

    //////////////
    // Cronic ///
    /////////////

    /* 
        Process disbursements jobs (send ICPs from fees and sales) 
        @cronic : 5 seconds
    */
    public shared ({ caller }) func cron_disbursements() : async () {
        assert(_Admins.isAdmin(caller) or caller == cid_hub);
        _Monitor.collectMetrics();
        await _Entrepot.cronDisbursements();
    };

    /* 
        Settle all transactions that can be settled (in case settle wasn't called by the buyer but the paiement was processed) 
        @cronic : 10 seconds
    */
    public shared ({ caller }) func cron_settlements() : async () {
        assert(_Admins.isAdmin(caller) or caller == cid_hub);
        _Monitor.collectMetrics();
        await _Entrepot.cronSettlements();
    };

    /* 
        Verify that all events have been reported to the CAP bucket
        @cronic : 1 minute
    */
    public shared ({caller}) func cron_events() : async () {
        assert(_Admins.isAdmin(caller) or caller == cid_hub);
        _Monitor.collectMetrics();
        await _Cap.cronEvents();
    };
    
    /* 
        Report all burned accessories to the Avatar canister so it can automatically desequip them  
        @cronic : 1 minute
    */
    public shared ({ caller }) func cron_burned() : async () {
        assert(_Admins.isAdmin(caller) or caller == cid_hub);
        _Monitor.collectMetrics();
        await _Items.cronBurned();
    };


    /* 
        Decrease the wear value of all equipped accessories by one and burn those reaching 0 
        @cronic : 1 day
    */
    // public shared ({ caller }) func cron_decrease : async () {

    // };

    //////////////
    // UPGRADE //
    /////////////

    system func preupgrade() {
        _Logs.logMessage("Preupgrade (accessory)");
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