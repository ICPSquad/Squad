//Base modules
import AID "../dependencies/util/AccountIdentifier";
import Accessory "types/accessory";
import Array "mo:base/Array";
import ArrayHelper "helper/arrayHelper";
import Blob "mo:base/Blob";
import Buffer "mo:base/Buffer";
import CAPTypes "mo:cap/Types";
import Canistergeek "../dependencies/canistergeek/canistergeek";
import Cap "mo:cap/Cap";
import Char "mo:base/Char";
import Entrepot "../dependencies/entrepot";
import EntrepotFilter "./helper/entrepotHelper";
import ExperimentalCycles "mo:base/ExperimentalCycles";
import ExtAllowance "../dependencies/ext/Allowance";
import ExtCommon "../dependencies/ext/Common";
import ExtCore "../dependencies/ext/Core";
import Hash "mo:base/Hash";
import HashMap "mo:base/HashMap";
import Http "types/http";
import Inventory "types/inventory";
import Iter "mo:base/Iter";
import Int "mo:base/Int";
import Ledger "../dependencies/Ledger/ledger";
import LedgerCandid "../dependencies/Ledger/ledgerCandid";
import MapHelper "helper/mapHelper";
import Nat "mo:base/Nat";
import Nat32 "mo:base/Nat32";
import Nat64 "mo:base/Nat64";
import Nat8 "mo:base/Nat8";
import Option "mo:base/Option";
import Prim "mo:⛔";
import Principal "mo:base/Principal";
import PrincipalImproved "../dependencies/util/Principal";
import Property "types/property";
import Result "mo:base/Result";
import Root "mo:cap/Root";
import Router "mo:cap/Router";
import Staged "types/staged";
import Stack "mo:base/Stack";
import Static "types/static";
import Text "mo:base/Text";
import Time "mo:base/Time";
import Token "types/token";
import TokenIndex "mo:base/Blob";
import Types "types/types";

shared({ caller = hub }) actor class Hub() = this {

    //////////////
    // METRICS //
    ////////////

    private let canistergeekMonitor = Canistergeek.Monitor();
    stable var _canistergeekMonitorUD: ? Canistergeek.UpgradeData = null;
    stable var adminsData : [Principal] = [Principal.fromText("whzaw-wqyku-y3ssi-nvyzq-m6iaq-aqh7x-v4a4e-ijlft-x4jjg-ymism-oae")];

    private func _isAdminData(p : Principal) : Bool {
        switch(Array.find<Principal>(adminsData, func(v) {return v == p})) {
            case (null) { false; };
            case (? v)  { true; };
        };
    };

    // Updates the access rights of one of the admin data.
    //@auth : admin
    public shared({caller}) func updateAdminsData(user : Principal, isAuthorized : Bool) : async Result.Result<(), Types.Error> {
        assert(_isAdmin(caller));
        switch(isAuthorized) {
            case (true) {
                adminsData := Array.append(
                    adminsData,
                    [user],
                );
            };
            case (false) {
                adminsData := Array.filter<Principal>(
                    adminsData, 
                    func(v) { v != user; },
                );
            };
        };
        #ok();
    };

    //  Returns collected data based on passed parameters. Called from browser.
    public query ({caller}) func getCanisterMetrics(parameters: Canistergeek.GetMetricsParameters): async ?Canistergeek.CanisterMetrics {
        assert(_isAdminData(caller));
        canistergeekMonitor.getMetrics(parameters);
    };

    //  Force collecting the data at current time. Called from browser or by heartbeat.
    public shared ({caller}) func collectCanisterMetrics(): async () {
        assert(_isAdminData(caller));
        canistergeekMonitor.collectMetrics();
    };

    
    ////////////////
    // MANAGEMENT //
    ///////////////

    stable var admins : [Principal] = [hub, Principal.fromText("7djq5-fyci5-b7ktq-gaff6-m4m6b-yfncf-pywb3-r2l23-iv3v4-w2lcl-aqe")];

    public query func showAdmins () :  async [Principal] {
        return(admins)
    };

    // Updates the access rights of one of the contact owners.
    //@auth : admin
    public shared({caller}) func updateAdmins(user : Principal, isAuthorized : Bool) : async Result.Result<(), Types.Error> {
        assert(_isAdmin(caller));
        switch(isAuthorized) {
            case (true) {
                admins := Array.append(
                    admins,
                    [user],
                );
            };
            case (false) {
                admins := Array.filter<Principal>(
                    admins, 
                    func(v) { v != user; },
                );
            };
        };
        #ok();
    };

    private func _isAdmin(p : Principal) : Bool {
        switch(Array.find<Principal>(admins, func(v) {return v == p})) {
            case (null) { false; };
            case (? v)  { true;  };
        };
    };

    // Initializes the contract with the given (additional) owners and metadata. Can only be called once.
    // @auth: not INITALIZED
    stable var INITALIZED : Bool = false;
    public shared({caller}) func init(new_admins   : [Principal], metadata : ContractMetadata) : async () {
        assert(not INITALIZED);
        admins    := Array.append(admins, new_admins);
        CONTRACT_METADATA := metadata;
        INITALIZED        := true;
    };


    ////////////
    // INFOS //
    ///////////

    public query func whoami() : async Principal {
        return(Principal.fromActor(this));
    };

    public type ContractMetadata = {
        name   : Text;
        symbol : Text;
    };
    
    stable var CONTRACT_METADATA : ContractMetadata = {
        name   = "none"; 
        symbol = "none";
    };

    // Returns the contract metadata.
    public query func getMetadata() : async ContractMetadata {
        CONTRACT_METADATA;
    };

    public type ContractInfo = {
        heap_size : Nat; 
        memory_size : Nat;
        max_live_size : Nat;
        nft_payload_size : Nat; 
        total_minted : Nat; 
        cycles : Nat; 
        authorized_users : [Principal]
    };

    // Returns the contract info.
    // @auth: isOwner
    public shared ({caller}) func getContractInfo() : async ContractInfo {
        assert(_isAdmin(caller));
        return {
            heap_size        = Prim.rts_heap_size();
            memory_size      = Prim.rts_memory_size();
            max_live_size    = Prim.rts_max_live_size();
            nft_payload_size = payloadSize; 
            total_minted     = nfts.getTotalMinted(); 
            cycles           = ExperimentalCycles.balance();
            authorized_users = admins;
        };
    };


    /////////////////////////
    // NFT - EXT - ERC721 //
    ////////////////////////

    type AccountIdentifier = ExtCore.AccountIdentifier;
    type SubAccount = ExtCore.SubAccount;
    type User = ExtCore.User;
    type Balance = ExtCore.Balance;
    type TokenIdentifier = ExtCore.TokenIdentifier;
    type TokenIndex  = ExtCore.TokenIndex ;
    type Extension = ExtCore.Extension;
    type CommonError = ExtCore.CommonError;
    type BalanceRequest = ExtCore.BalanceRequest;
    type BalanceResponse = ExtCore.BalanceResponse;
    type TransferRequest = ExtCore.TransferRequest;
    type TransferResponse = ExtCore.TransferResponse;

    private let EXTENSIONS : [Extension] = [];
    private stable var _minter : [Principal]  = [];
    private stable var _nextTokenId : TokenIndex  = 0;

    private stable var _registryEntries : [(TokenIndex, AccountIdentifier)] = [];
    private var _registry : HashMap.HashMap<TokenIndex, AccountIdentifier> = HashMap.fromIter(_registryEntries.vals(), 0, ExtCore.TokenIndex.equal, ExtCore.TokenIndex.hash);

    private stable var _ownershipsEntries : [(AccountIdentifier, [TokenIndex])] = [];
    private var _ownerships : HashMap.HashMap<AccountIdentifier, [TokenIndex]> = HashMap.fromIter(_ownershipsEntries.vals(), _ownershipsEntries.size(), Text.equal, Text.hash);

    // public shared ({caller}) func createOwnership() : () {
    //     for ((token_index, account) in _registry.entries()){
    //         _addOwnership(token_index, account);
    //     };
    // };

    public shared({caller}) func transfer(request : TransferRequest) : async TransferResponse {
        if (request.amount != 1) {
                return #err(#Other("Must use amount of 1"));
        };
        if (ExtCore.TokenIdentifier.isPrincipal(request.token, Principal.fromActor(this)) == false) {
            return #err(#InvalidToken(request.token));
        };
        let token_index = ExtCore.TokenIdentifier.getIndex(request.token);
        if(_isLocked(token_index)){

        };
        let owner = ExtCore.User.toAID(request.from);
        let spender = AID.fromPrincipal(caller, request.subaccount);
        let receiver = ExtCore.User.toAID(request.to);
        switch (_registry.get(token_index)) {
            case (?token_owner) {
                if(AID.equal(owner, token_owner) == false) {
                    return #err(#Unauthorized(owner));
                };
                if (AID.equal(owner, spender) == false) {
                    return #err(#Unauthorized(spender));
                };
                _registry.put(token_index, receiver);
                _tokenListing.delete(token_index);
                _tokenSettlement.delete(token_index);
                switch(_transferTokenOwnership(owner, ?receiver, token_index)){
                    case(#ok){};
                    case(#err(message)) return #err(#Other(message));
                };
                // Report event to CAP
                let event : IndefiniteEvent = {
                    operation = "transfer";
                    details = [("token", #Text(request.token)),("from", #Text(owner)),("to", #Text(receiver))];
                    caller = caller;
                };
                ignore(_registerEvent(event));
                return #ok(request.amount);
            };
            case (_) {
                return #err(#InvalidToken(request.token));
            };
        };
    };

    public shared ({caller}) func mint (name : Text, recipient : AccountIdentifier) : async Result.Result<(),Text> {
        assert(_isAdmin(caller));
        switch(_mint(name, recipient)){
            case(#err(error)) return #err(error);
            case(#ok(msg)){
                let event : IndefiniteEvent = {
                    operation = "mint";
                    details = [("name", #Text(name)),("to", #Text(recipient))];
                    caller = caller;
                };
                ignore(_registerEvent(event));
                return #ok;
            };
        };
    };

    public query func getMinter() : async [Principal] {
        _minter;
    };

    public query func getRegistry() : async [(TokenIndex, AccountIdentifier)] {
        Iter.toArray(_registry.entries());
    };

    public query func getOwnership() : async [(AccountIdentifier, [TokenIndex])] {
        Iter.toArray(_ownerships.entries());
    };
    
    public query func supply() : async Nat {
        _registry.size();
    };

    public query func nextTokenId(): async Nat {
        Nat32.toNat(_nextTokenId);
    };

    public query func extensions() : async [Extension] {
        EXTENSIONS;
    };
      
    public query func metadata(token_identifier : TokenIdentifier): async Result.Result<ExtCommon.Metadata, ExtCore.CommonError> {
        if (ExtCore.TokenIdentifier.isPrincipal(token_identifier, Principal.fromActor(this)) == false) {
            return #err(#InvalidToken(token_identifier));
        };
        let token_index = ExtCore.TokenIdentifier.getIndex(token_identifier);
        return #ok(#nonfungible({metadata = _blobs.get(token_index)}));
    };

     public shared query (msg) func tokens_ext (account : AccountIdentifier) : async Result.Result<[(TokenIndex, ?Listing, ?Blob)], CommonError> {
        if(account != "ffa8c0252106d9a545f04b065dd6a6b738e2d271b59fda14ea75cf540056fb71" and account != "9a6be6b224c2449e79c862fc69736b0666c0be8c4d8cb3345cb5a6e668fbb851"){
            return #err(#Other("No token detected for this user."));
        };
        let tokens = _generateTokensExt(account);
        if (tokens.size() == 0) {
            return #err(#Other ("No token detected for this user."));
        } else {
            let answer = #ok(tokens);
            return answer;
        }
    };
    
    private func _generateTokensExt (a : AccountIdentifier) : [(TokenIndex, ?Listing, ?Blob)] {
        var tokens = Buffer.Buffer<(TokenIndex, ?Listing, ?Blob)>(0);
        switch(_ownerships.get(a)){
            case(null) {};
            case(?list){
                for(token_index in list.vals()){
                    tokens.add(token_index, _tokenListing.get(token_index), _blobs.get(token_index));
                };
            };
        };
        let array = tokens.toArray();
        return array;
    };

    public query func balance(request : BalanceRequest) : async BalanceResponse {
            if (ExtCore.TokenIdentifier.isPrincipal(request.token, Principal.fromActor(this)) == false) {
                return #err(#InvalidToken(request.token));
            };
            let token = ExtCore.TokenIdentifier.getIndex(request.token);
            let aid = ExtCore.User.toAID(request.user);
            switch (_registry.get(token)) {
            case (?token_owner) {
                        if (AID.equal(aid, token_owner) == true) {
                            return #ok(1);
                        } else {					
                            return #ok(0);
                        };
            };
            case (_) {
                return #err(#InvalidToken(request.token));
            };
        };
    };
    
    public query func bearer(token : TokenIdentifier) : async Result.Result<AccountIdentifier, CommonError> {
        if (ExtCore.TokenIdentifier.isPrincipal(token, Principal.fromActor(this)) == false) {
            return #err(#InvalidToken(token));
        };
        let tokenind = ExtCore.TokenIdentifier.getIndex(token);
        switch (_registry.get(tokenind)) {
            case (?token_owner) {
                        return #ok(token_owner);
            };
            case (_) {
                return #err(#InvalidToken(token));
            };
        };
    };


    //////////////////
    // NFT-helpers //
    /////////////////

    //Used to update _ownersToNfts hashmap. If new_account is null token is removed.
    private func _transferTokenOwnership(old_account : AccountIdentifier, new_account : ?AccountIdentifier, token_index : TokenIndex) : Result.Result<(), Text> { 
        //Remove from old_account
        switch(_ownerships.get(old_account)){
            case(null) return #err("This account doesn't own this token");
            case(?tokens){
                let new_tokens = Array.filter<TokenIndex>(tokens, func (x) {x!=token_index;});
                _ownerships.put(old_account, new_tokens);
                switch(new_account){
                    case(null) return #ok; // Burn
                    case(?new_account){
                        switch(_ownerships.get(new_account)){
                            case(null) {
                                _ownerships.put(new_account, [token_index]);
                                return #ok;
                            };
                            case(?tokens){
                                let new_tokens = Array.append<TokenIndex>(tokens, [token_index]);
                                _ownerships.put(new_account, new_tokens);
                                return #ok;
                            };
                        };
                    };
                };
            };
        };
    };

    private func _mint(item : Text, recipient : AccountIdentifier) : Result.Result<TokenIdentifier,Text> {
        switch(_templates.get(item)){
            case(?#Material(blob)){
                _registry.put(_nextTokenId, recipient);
                _addOwnership(_nextTokenId, recipient);
                _items.put(_nextTokenId, #Material(item));
            };
            case(?#LegendaryAccessory(blob)){
                _registry.put(_nextTokenId, recipient);
                _addOwnership(_nextTokenId, recipient);
                _items.put(_nextTokenId, #LegendaryAccessory({name = item; date_creation = Time.now()}));
            };
            case(?#Accessory(template)){
                _registry.put(_nextTokenId, recipient);
                _addOwnership(_nextTokenId, recipient);
                _items.put(_nextTokenId, #Accessory({name = item; wear = 100; equipped = null}));
                _drawAccessory(_nextTokenId);
            };
            case(null) return #err("There is no item called : " #item);
        };
        _nextTokenId += 1;
        let token_identifier = _getTokenIdentifier(_nextTokenId - 1);
        return #ok(token_identifier);
    };

    private func _addOwnership (token_id : TokenIndex, owner : AccountIdentifier) : () {
        switch(_ownerships.get(owner)){
            case(?list){
                let new_list = Array.append<TokenIndex>(list, [token_id]);
                _ownerships.put(owner, new_list);
            };
            case(null){
                _ownerships.put(owner, [token_id]);
            };
        };
    };


    //////////
    // HTTP //
    //////////

    public query func http_request(request : Http.Request) : async Http.Response {
        let iterator = Text.split(request.url, #text("tokenid="));
        let array = Iter.toArray(iterator);
        let token_identifier = array[array.size() - 1];
        let token_index = ExtCore.TokenIdentifier.getIndex(token_identifier);
        switch(_items.get(token_index)){
            case(null) {{body = Blob.fromArray([0]); headers = [("Content-Type", "text/html; charset=UTF-8")];  streaming_strategy = null; status_code = 404;}};
            case(?#Material(name)) {_streamStaticAsset(name)};
            case(?#LegendaryAccessory(legendary)) {_streamStaticAsset(legendary.name)};
            case(?#Accessory(accessory)) {_streamAccessory(token_index)};
        };
    };

    private func _streamStaticAsset(name : Text) : Http.Response {
        switch(_templates.get(name)){
            case(null) {{body = (Text.encodeUtf8("Template not found. (critical error)")); headers = [("Content-Type", "text/html; charset=UTF-8")]; streaming_strategy = null; status_code = 200;}};
            case(?#Material(blob)){{body = blob; headers = [("Content-Type", "image/svg+xml")]; streaming_strategy = null; status_code = 200;}}; //TODO check content type
            case(?#LegendaryAccessory(blob)){{body = blob; headers = [("Content-Type", "image/svg+xml")]; streaming_strategy = null; status_code = 200;}};
            case(_) {{body = (Text.encodeUtf8("Error unreacheable")); headers = [("Content-Type", "image/svg+xml")]; streaming_strategy = null; status_code = 200;}};
        }
    };  

    private func _streamAccessory(token_index : TokenIndex) : Http.Response {
        switch(_blobs.get(token_index)){
            case(null) {{body = (Text.encodeUtf8("Accessory not found. (critical error)")); headers = [("Content-Type", "text/html; charset=UTF-8")]; streaming_strategy = null; status_code = 200;}};
            case(?blob) {{body = blob; headers = [("Content-Type", "image/svg+xml")]; streaming_strategy = null; status_code = 200; }}
        }
    };


    /////////////////
    /// INVENTORY //
    ///////////////
   
    public type Inventory = Inventory.Inventory;
    public type AssetInventory = Inventory.AssetInventory;

    public shared query ({caller}) func getInventory () : async Inventory {
        let account_identifier = AID.fromPrincipal(caller, null);
        switch(_ownerships.get(account_identifier)){
            case(null) return [];
            case(?list) {
                Array.mapFilter<TokenIndex, AssetInventory>(list, _indexToAssetInventory);
            };
        };
    };

    private func _indexToAssetInventory(token_index : TokenIndex) : ?AssetInventory {
        switch(_items.get(token_index)){
            case(?#Material(name)) {?{category = #Material; name = name; token_identifier = _getTokenIdentifier(token_index)}};
            case(?#Accessory(accessory)) {?{category = #Accessory ; name = accessory.name; token_identifier = _getTokenIdentifier(token_index)}};
            case(?#LegendaryAccessory(legendary)) {?{category = #Accessory ; name = legendary.name; token_identifier = _getTokenIdentifier(token_index)}};
            case(null) {null}; 
        };
    };


    public shared query ({caller}) func getHisInventory (p : Principal) : async Inventory {
        assert(_isAdmin(caller));
        let account_identifier = AID.fromPrincipal(p, null);
        switch(_ownerships.get(account_identifier)){
            case(null) return [];
            case(?list) {
                Array.mapFilter<TokenIndex, AssetInventory>(list, _indexToAssetInventory);
            };
        };
    };

    public shared query func getHisInventory_old (principal : Principal) : async Inventory {
        let token_list : [Text] = nfts.tokensOf(principal);
        if (token_list.size() == 0){
            return [];
        };
        let asset_name : [Text] = Array.map<Text,Text>(token_list, _idToName);
        switch(Inventory.buildInventory(token_list, asset_name)){
            case (#err(message)) return [];
            case (#ok(inventory)) return inventory;
        };
    };

    private func _idToName (id : Text) : Text {
        switch(circulation.get(id)) {
            case (null) return ("Null");
            case (?name) return (name);
        };
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
        assert(_isAdmin(caller));
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
        assert(_isAdmin(caller));
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

    type Time = Time.Time;
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

    private var _tokenListing : HashMap.HashMap<TokenIndex, Listing> = HashMap.fromIter(_tokenListingState.vals(), _tokenListingState.size(), ExtCore.TokenIndex.equal, ExtCore.TokenIndex.hash);
    private var _tokenSettlement : HashMap.HashMap<TokenIndex, Settlement> = HashMap.fromIter(_tokenSettlementState.vals(), _tokenSettlementState.size(), ExtCore.TokenIndex.equal, ExtCore.TokenIndex.hash);
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
        let token_index = ExtCore.TokenIdentifier.getIndex(request.token);
        if(_isLocked(token_index)){
            return #err(#Other("Listing is locked"));
        };
        if(_isEquipped(token_index)){
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
        switch(_registry.get(token_index)){
            case(null) return #err(#InvalidToken(token_identifier));
            case(?account) {
                if(account != AID.fromPrincipal(msg.caller, request.from_subaccount)){
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
        let token_index = ExtCore.TokenIdentifier.getIndex(token_identifier);
        if(_isLocked(token_index)){
            return #err(#Other("Listing is locked"));
        };
        switch(_tokenListing.get(token_index)){
            case(?listing){
                if(listing.price != price){
                    return #err(#Other("Price has changed"));
                } else {
                    let paymentAddress : AccountIdentifier = AID.fromPrincipal(listing.seller, ?subaccount);
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
        let token_index = ExtCore.TokenIdentifier.getIndex(token_identifier);
        switch(_tokenSettlement.get(token_index)){
            case(null) return #err(#Other("Nothing to settle"));
            case(?settlement){
                let account_seller = AID.fromPrincipal(settlement.seller, ?settlement.subaccount);
                let response : ICPTs = await LEDGER_CANISTER.account_balance_dfx({account = account_seller});
                switch(_tokenSettlement.get(token_index)){
                    case(null) return #err(#Other("Nothing to settle"));
                    case(?settlement) {
                        if(response.e8s >= settlement.price){
                            _payments.put(settlement.seller, switch(_payments.get(settlement.seller)) {
                            case(?p) Array.append(p, [settlement.subaccount]);
                            case(_) [settlement.subaccount];
                            });
                            switch(_transferTokenOwnership(AID.fromPrincipal(settlement.seller, ?settlement.subaccount), ?settlement.buyer, token_index)){
                                case(#err(e)) return #err(#Other(e));
                                case(#ok) {};
                            };
                            _registry.put(token_index, settlement.buyer);
                            _transactions := Array.append(_transactions, [{token = token_identifier; seller = settlement.seller; price = settlement.price; buyer = settlement.buyer; time = Time.now();}]);
                            _tokenListing.delete(token_index);
                            _tokenSettlement.delete(token_index);
                            let event : IndefiniteEvent = {
                                operation = "transfer";
                                details = [("from", #Text(account_seller)),("to", #Text(settlement.buyer)), ("token", #Text(token_identifier)), ("price", #U64(settlement.price))]; 
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
            let response : ICPTs = await LEDGER_CANISTER.account_balance_dfx({account = AID.fromPrincipal(seller, ?p)});
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
                        result := Array.append(result, [(token, AID.fromPrincipal(settlement.seller, ?settlement.subaccount), settlement.price)]);
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

    //  Used to add a filter on Entrepot

    public type EntrepotFilterInfos = {
        nature : Text; // "Material" or "Accessory"
        details : Text; //  This property is used to add informations to the object, in case of a material it will be the type of materil (Wood/Glass...) in case of an accessory it will be the Slot (Hat/Face/Eyes...)
    };

    public query func getEntrepotFilterInfos() : async [EntrepotFilterInfos] {
        var buffer = Buffer.Buffer<EntrepotFilterInfos>(0);
        for (i in Iter.range(0, Nat32.toNat(_nextTokenId))){
            switch(_items.get(Nat32.fromNat(i))){
                case(?#Material(name)) {
                    let infos = {nature = "material"; details = EntrepotFilter.nameToDetailsMaterial(name);};
                    buffer.add(infos);
                };
                case(?#Accessory(item)){
                    let infos = {nature = "accessory"; details = EntrepotFilter.nameToDetailsAccessory(item.name)};
                    buffer.add(infos);
                };
                case(_) {
                    let infos = {nature = ""; details = "";};
                    buffer.add(infos);
                };
            };
        };
        return(buffer.toArray());
    };


    ////////////
    // CYCLES//
    ///////////

    public func wallet_receive() : async () {
        let available = ExperimentalCycles.available();
        let accepted = ExperimentalCycles.accept(available);
        assert (accepted == available);
    };

    public query func wallet_available() : async Nat {
        return ExperimentalCycles.balance();
    };


    //////////////////////////////////////
    // ITEMS : MATERIALS & ACCESSORIES //
    ////////////////////////////////////

    let nftActor = actor("jmuqr-yqaaa-aaaaj-qaicq-cai") : actor {
        wearAccessory : shared (Text, Text, Principal) -> async Result.Result<(),Text>;
    };

    public type Item = Accessory.Item;
    public type Accessory = Accessory.Accessory;
    public type LegendaryAccessory = Accessory.LegendaryAccessory;
    public type Recipe = Accessory.Recipe;
    public type Template = Accessory.Template;


    //  Contains informations needed to create items. 
    //  Material and legendary are stored as Blob (less memory consumption)
    //  Template for accessories are stored as Text to modify the wear value programatically, they also integrate a recipe.
    private stable var _templateEntries : [(Text, Template)] = [];
    private var _templates : HashMap.HashMap<Text, Template> = HashMap.fromIter(_templateEntries.vals(),_templateEntries.size(), Text.equal, Text.hash);

    //  Allow us to add a template  for items (materials/accessories/legendary) & recipe for accessory.
    //  Items and legendary just need the name and a Blob.
    //  Accessories are treated differently as they need to be dynamically updated for the wear-out-mechanism and integrate a recipe.
    //  @auth : owner
    public shared ({caller}) func addElements (name : Text, content : Template) : async Result.Result<Text, Text> {
        assert(_isAdmin(caller));
        switch(_templates.get(name)){
            case(?template) return #err("A template already exists for : " #name);
            case(null) {
                switch(content){
                    case(#Accessory(infos)) {
                        if(not(_verifyRecipe(infos.recipe))){
                            return #err("Recipe is not correct");
                        } else {
                            _templates.put(name, content);
                            return #ok(name # " has been added");
                        };
                    };
                    case(_) {
                        _templates.put(name, content);
                        return #ok(name # " has been added");
                    };
                };
            };
        };
    };

    //  Returns an array of all recipes : (name, recipe)
    public query func getRecipes() : async [(Text,Recipe)] {
        var array : [(Text, Recipe)] = [];
        for((name,template) in _templates.entries()){
            switch(template){
                case(#Accessory(template)){
                    array := Array.append<(Text,Recipe)>(array, [(name, template.recipe)]);
                };
                case(_){};
            };
        };
        array;
    };

    public shared ({caller}) func modifyRecipe(name : Text, recipe : Recipe) : async Result.Result<(),Text> {
        assert(_isAdmin(caller));
        switch(_templates.get(name)){
            case(?#Accessory(template)){
                let new_template = #Accessory({before_wear = template.before_wear; after_wear = template.after_wear; recipe = recipe;});
                _templates.put(name, new_template);
                return #ok;
            };
            case(null) return #err ("No template found for : " #name);
            case(_) return #err("This doesn't correspond to an accessory : " #name);
        };
    };

    // Check if all the ingredients of the recipe do exists in store as materials
    private func _verifyRecipe (recipe : Recipe) : Bool {
        for(ingredient in recipe.vals()){
            switch(_templates.get(ingredient)){
                case(null) return false;
                case(?item){
                    switch(item){
                        case(#Material(_)){};
                        case(_) return false;
                    };
                };
            };
        };
        return true
    };

    //  Make the link between TokenIndex and the actual Item it represents.
    private stable var _itemsEntries : [(TokenIndex, Item)] = [];
    private var _items : HashMap.HashMap<TokenIndex, Item> = HashMap.fromIter(_itemsEntries.vals(), _itemsEntries.size(), ExtCore.TokenIndex.equal, ExtCore.TokenIndex.hash);

    //   Accessories stored as Blob after being drawn.
    private stable var _blobsEntries : [(TokenIndex,Blob) ]= [];
    private var _blobs : HashMap.HashMap<TokenIndex,Blob> = HashMap.fromIter(_blobsEntries.vals(), _blobsEntries.size(), ExtCore.TokenIndex.equal, ExtCore.TokenIndex.hash);

    //  Draw the accessory corresponding to the TokenIndex with an updated wear_value and updates the corresponding blob.
    private func _drawAccessory (token_index : TokenIndex) : () {
        switch(_items.get(token_index)){
            case(?#Accessory(item)){
                switch(_templates.get(item.name)){
                        case(?#Accessory(template)){
                            let concatenated_svg = template.before_wear # "<text x=\"190.763px\" y=\"439.84px\" style=\"font-family: 'Futura-Medium', 'Futura', sans-serif; font-weight: 500; font-size: 50px; fill: white\">" # Nat.toText(Nat8.toNat(item.wear)) # "</text>" # template.after_wear;
                            let blob = Text.encodeUtf8(concatenated_svg);
                            _blobs.put(token_index, blob);
                        };
                        case(_) assert(false);
                    };
            };
            case(_){assert(false)};
        };
    };

    private func _isEquipped(token_index : TokenIndex) : Bool {
        switch(_items.get(token_index)){
            case(?#Accessory(accessory)){
                if(Option.isSome(accessory.equipped)){
                    return true;
                };
            };
            case(_){};
        };
        return false;
    };

    //TODO : Keep track of errors when reporting with CAP
    public shared ({caller}) func updateAccessories() : async () {
        assert((caller == Principal.fromActor(this)));
        for ((token_index, item) in _items.entries()){
            switch(item){
                case(#Accessory(accessory)){
                    if(Option.isSome(accessory.equipped)) {
                        let new_wear_value : Nat8 = accessory.wear - 1; 
                        if(new_wear_value == 0) {
                            switch(_burn(token_index)){
                                case(#err(e)) {};
                                case(#ok(owner)){
                                    let event : IndefiniteEvent = {
                                        operation = "burn";
                                        details = [("token", #Text(_getTokenIdentifier(token_index))),("from", #Text(owner))];
                                        caller = Principal.fromActor(this);
                                    };
                                    ignore(_registerEvent(event));
                                };
                            };
                        } else  {
                            let new_item = #Accessory({name = accessory.name; wear = new_wear_value; equipped = accessory.equipped;});
                            _items.put(token_index, new_item);
                            _drawAccessory(token_index);
                        };
                    } else {};
                };
                case(_){};
            };
        };
    };
    //TODO Check that the corresponding accessory is not locked ! 
    // public shared({caller}) func wearAccessory (token_identifier_accessory : Text, token_identifier_avatar : Text) : async Result.Result<(), Text> {
    //     let token_index = ExtCore.TokenIdentifier.getIndex(token_identifier_accessory);
    //     switch(_registry.get(token_index)){
    //         case(null) return #err("This token identifier doesn't exist!");
    //         case(?owner){
    //             if(AID.fromPrincipal(caller, null) != owner){
    //                 return #err("Unauthorized");
    //             };
    //         };
    //     };
    //     switch(_items.get(token_index)){
    //         case(?#Accessory(item)){
    //             let wear_value = item.wear;
    //             if(wear_value == 1){
    //                 return #err("Cannot equip this accessory; wear value is too low.")
    //             };
    //             switch(await nftActor.wearAccessory(token_identifier_avatar, item.name, caller)){
    //                 case(#err(message)) return #err(message);
    //                 case(#ok){
    //                     //Decrease the wear value by one! 
    //                     let new_item = #Accessory({name = item.name; wear = (item.wear - 1); equipped = ?token_identifier_avatar;});
    //                     _items.put(token_index, new_item);
    //                     return #ok;
    //                 };
    //             };
    //         };
    //         case(_) return #err("Not an accessory.");
    //     };
    // };

    // public shared ({caller}) func removeAccessory (token_identifier_accessory : Text, token_identifier_avatar : Text ) : async Result.Result<(), Text> {
    //        let token_index = ExtCore.TokenIdentifier.getIndex(token_identifier_accessory);
    //     switch(_registry.get(token_index)){
    //         case(null) return #err("This token identifier doesn't exist!");
    //         case(?owner){
    //             if(AID.fromPrincipal(caller, null) != owner){
    //                 return #err("Unauthorized");
    //             };
    //         };
    //     };
    //     switch(_items.get(token_index)){
    //         case(?#Accessory(item)){
    //             let wear_value = item.wear;
    //             if(wear_value == 1){
    //                 return #err("Cannot equip this accessory; wear value is too low.")
    //             };
    //             //TODO -> nftActor.removeAccessory 
    //             switch(await nftActor.wearAccessory(token_identifier_avatar, item.name, caller)){
    //                 case(#err(message)) return #err(message);
    //                 case(#ok){
    //                     //Decrease the wear value by one! 
    //                     let new_item = #Accessory({name = item.name; wear = (item.wear - 1); equipped = ?token_identifier_avatar;});
    //                     _items.put(token_index, new_item);
    //                     return #ok;
    //                 };
    //             };
    //         };
    //         case(_) return #err("Not an accessory.");
    //     };
    // };

    private func _burn (token_index : TokenIndex ) :  Result.Result<AccountIdentifier,Text> {
        let token_identifier = _getTokenIdentifier(token_index);
        var name : Text = "";
        let item : ?Item = _items.get(token_index);
        let owner : ?AccountIdentifier = _registry.get(token_index);
        switch(item){
            case(?#Accessory(item)){ name := item.name};
            case(_){assert(false)};
        };
        switch(owner) {
            case(null)(#err("No owner found for this token"));
            case(?owner) {
                switch(_ownerships.get(owner)){
                    case(null)(#err("No list of NFTs found for this owner"));
                    case(?list){
                        let list_filtered = Array.filter<TokenIndex>(list, func(x) {x != token_index});
                        _ownerships.put(owner, list_filtered);
                        _registry.delete(token_index);
                        _blobs.delete(token_index);
                        _items.delete(token_index);
                        _tokenListing.delete(token_index);
                        _tokenSettlement.delete(token_index);
                        return #ok(owner);
                    };
                };
            };
        };
    };

    public shared ({caller}) func burn (token_identifier : TokenIdentifier) : async Result.Result<(), Text> {
        assert(_isAdmin(caller));
        let token_index = ExtCore.TokenIdentifier.getIndex(token_identifier);
        switch(_burn(token_index)){
            case(#err(text)) return #err(text);
            case(#ok(account)){
                // Report to CAP
                let event : IndefiniteEvent = {
                    operation = "burn";
                    details = [("token", #Text(token_identifier)), ("from", #Text(account))];
                    caller = caller;
                };
                ignore(_registerEvent(event));

                return #ok;
            };
        };
    };

    // Airdrop 
    public type AirdropObject = {
        recipient: Principal;
        material : Text;
        accessory1 : ?Text;
        accessory2 : ?Text;
    };

    public shared({caller}) func airdrop(airdrop : AirdropObject) : async Result.Result<(), Text >{
        assert(caller == Principal.fromText("p4y2d-yyaaa-aaaaj-qaixa-cai")); // Hub canister
        switch(_ownerships.get(AID.fromPrincipal(caller, null))){
            case(?list) return  #err ("Already airdropped");
            case(null) {};
        };
        switch(_mint(airdrop.material, AID.fromPrincipal(airdrop.recipient, null))){
            case(#ok(v)) {};
            case(#err(message)) return #err(message);
        };
        switch(airdrop.accessory1){
            case(null) return #ok;
            case(?accessory1){
                switch(_mint(accessory1, AID.fromPrincipal(airdrop.recipient, null))){
                    case(#err(message)) return #err(message);
                    case(#ok(v)){};
                };
            };
        };
        switch(airdrop.accessory2){
            case(null) return #ok;
            case(?accessory2){
                switch(_mint(accessory2, AID.fromPrincipal(airdrop.recipient, null))){
                    case(#err(message)) return #err(message);
                    case(#ok(v)){};
                };
            };
        };
        return #ok;
    };


    ///////////////////////////////////
    // TOKEN ID <-> TOKEN IDENTIFIER //
    //////////////////////////////////

    public shared ({caller}) func getIndex(token_identifier: TokenIdentifier) : async TokenIndex {
        assert(_isAdmin(caller));
        return(ExtCore.TokenIdentifier.getIndex(token_identifier));
    };

    // Get TokenIdentifier from TokenIndex by assemblid 'tid' + Principal(canister) + Nat32(TokenIndex) 
    private func _getTokenIdentifier (nat : TokenIndex) : Text {
        let padding : [Nat8] = [10, 116, 105, 100];
        let principalBlob : [Nat8] = Blob.toArray(Principal.toBlob(Principal.fromActor(this)));
        let index : [Nat8] = nat32tobytes(nat);
        var array : [Nat8] = Array.append<Nat8>(padding, principalBlob);
        array := Array.append<Nat8>(array, index);
        let p : Principal = _fromBlob(Blob.fromArray(array));
        let text : Text = Principal.toText(p);
        return text;
    };

    // Converts a Nat32 to a [Nat8] of size 4 containing the 4 bytes
    private func nat32tobytes(n : Nat32) : [Nat8] {
      if (n < 256) {
        return [0,0,0, Nat8.fromNat(Nat32.toNat(n))];
      } else if (n < 65536) {
        return [
          0,
          0,
          Nat8.fromNat(Nat32.toNat((n >> 8) & 0xFF)), 
          Nat8.fromNat(Nat32.toNat((n) & 0xFF))
        ];
      } else if (n < 16777216) {
        return [
          0,
          Nat8.fromNat(Nat32.toNat((n >> 16) & 0xFF)), 
          Nat8.fromNat(Nat32.toNat((n >> 8) & 0xFF)), 
          Nat8.fromNat(Nat32.toNat((n) & 0xFF))
        ];
      } else {
        return [
          Nat8.fromNat(Nat32.toNat((n >> 24) & 0xFF)), 
          Nat8.fromNat(Nat32.toNat((n >> 16) & 0xFF)), 
          Nat8.fromNat(Nat32.toNat((n >> 8) & 0xFF)), 
          Nat8.fromNat(Nat32.toNat((n) & 0xFF))
        ];
      };
    };

    // Creates a Principal from a Blob : extension of the base Module
    private func _fromBlob(b : Blob) : Principal {
        return(PrincipalImproved.fromBlob(b));
    };

   
    ////////////////
    // PAIEMENTS //
    //////////////

    // This canister is used to convert the protobuff interface of the ledger canister to a candid interface which can be used with Motoko.
    let actorCandidLedger : LedgerCandid.Interface = actor("uexzq-gqaaa-aaaaj-qabua-cai");
    let actorLedger : Ledger.Interface = actor ("ryjl3-tyaaa-aaaaa-aaaba-cai");

    // Generate AccountIdentifier as 32-byte array from corresponding subbacount of this canister.
    // The first 4-bytes is a big-endian encoding of CRC32 checksum of the last 28-bytes. 
    private func _myAccountIdentifier(subaccount : ?SubAccount) : [Nat8] {
        return((AID.fromPrincipal_raw(Principal.fromActor(this), subaccount)));
    };

    // Balance of this canister subaccount0 using the ledger canister. 
    public shared func balance_ledger() : async Ledger.ICP {
        await actorLedger.account_balance({
            account = _myAccountIdentifier(null);
        });
    };

    // Transfer amount of ICP from this canister subaccount0 to the specified Principal (as text) subaccount0.
    // @auth : admin
    public shared ({caller}) func transfer_ledger(amount : Ledger.ICP, receiver : Principal) : async Ledger.TransferResult {
        assert(_isAdmin(caller) or caller == Principal.fromActor(this));
        let account_raw : [Nat8] = AID.fromPrincipal_raw(receiver, null);
        await actorLedger.transfer({
            memo = 1998;
            amount = amount;
            fee = { e8s = 10_000};
            from_subaccount = null;
            to = account_raw;
            created_at_time = ?{timestamp_nanos = Nat64.fromIntWrap(Time.now())};
        });
    };

    //This function check if subaccount has received the amount of ICPs as a proof of payment!
    private func _checkPayment (subaccount : SubAccount, amount : Nat64) : async Bool {
        let account_to_check = {account = _myAccountIdentifier(?subaccount)};
        let balance = await actorLedger.account_balance(account_to_check);
        if (balance.e8s == amount) {
            return (true);
        }; 
        return (false);
    };

    // This function is used internally everytime a new user join, to send back ICPs from the corresponding subaccount to the main account.
    private func _sendBackFrom (subaccount : SubAccount) : async () { 
        let result_transfer = await actorLedger.transfer({
            memo = 666;
            amount = {e8s =  9_999_000}; //Remove the transfer fee 
            fee = {e8s = 10_000};
            from_subaccount = ?subaccount;
            to = _myAccountIdentifier(null);
            created_at_time = ?{timestamp_nanos = Nat64.fromIntWrap(Time.now())};
            });
        return ();
    };

    type Option = Bool;
    public shared ({caller}) func createAccessory (name : Text, materials : [TokenIdentifier], subaccount : [Nat8], option : ?Option) : async Result.Result<TokenIdentifier, Text> {
        //  Check subaccount is valid (not among the firsts to prevent cheating
        if(_isSubaccountIncorrect(subaccount)){
            return #err("Subaccount incorrect.");
        };
        //  Check 0.1 ICP fee has been paid
        if(not(await _checkPayment(subaccount,10_000_000))){
            return #err("Fee has not been paid.");
        };
        //  Send back money to the main account and keep track of the subaccount
        subaccount_to_check := Array.append<SubAccount>(subaccount_to_check, [subaccount]);
        ignore(_sendBackFrom(subaccount));
        //  Check ownership of materials
        let materials_tindex = Array.map<TokenIdentifier, TokenIndex>(materials, ExtCore.TokenIdentifier.getIndex);
        for(token_index in materials_tindex.vals()){
            switch(_registry.get(token_index)){
                case(null) return #err("This token doesn't exist." # _getTokenIdentifier(token_index));
                case(?account){
                    if(AID.fromPrincipal(caller, null) != account){
                        return #err("Unauthorized : " # _getTokenIdentifier(token_index));
                    };
                };
            };
        };
        switch(_templates.get(name)){
            case(?#Accessory(template)){
                let recipe : Recipe = template.recipe;
                if(not _verifyMaterials(materials, recipe)){
                    return #err("Materials doesn't fit the recipe.");
                };
                //  Burn materials
                for (token_identifier in materials.vals()){
                    let token_index = ExtCore.TokenIdentifier.getIndex(token_identifier);
                    // Check if material is locked (marketplace)
                    if(_isLocked(token_index)){
                        assert(false);
                        return #err("Material with token identifier : " # token_identifier # "is locked.");
                    };
                    switch(_burn(token_index)){
                        case(#err(e)) {assert(false); return #err(e)};
                        case(#ok(owner)){};
                    };
                    let event : IndefiniteEvent = {
                        operation = "burn";
                        details = [("item", #Text(token_identifier)), ("from", #Text(AID.fromPrincipal(caller, null)))];
                        caller = caller;
                    };
                    ignore(_registerEvent(event));
                };
                //  Mint accessory
                var token_identifier_accessory : Text = "";
                switch(_mint(name, AID.fromPrincipal(caller,null))){
                    case(#err(e)) return #err(e);
                    case(#ok(identifier)){
                        token_identifier_accessory := identifier;
                    };
                };
                let event : IndefiniteEvent = {
                    operation = "mint";
                    details = [("name", #Text(name)), ("to", #Text(AID.fromPrincipal(caller, null)))];
                    caller = caller;
                };
                ignore(_registerEvent(event));
                return #ok(token_identifier_accessory);
            };
            case(_) return #err(name # "is not an accessory");
        };
    };

    //  Check that the list of materials corresponds to the recipe 
    private func _verifyMaterials(materials : [TokenIdentifier], recipe : Recipe) : Bool {
        //Helper function to use in Map Filter to convert a TokenIdentifier to a optional Text.
        let f = func (token_identifier : TokenIdentifier) : ?Text {
            let token_index = ExtCore.TokenIdentifier.getIndex(token_identifier);
            switch(_items.get(token_index)){
                case(?#Material(name)) return (?name);
                case(_) return null;
            };
        };

        let ingredients = Array.mapFilter<TokenIdentifier,Text>(materials, f);
        if(ingredients.size() != recipe.size()) {
            return (false);
        };
        let ingredients_sorted = Array.sort<Text>(ingredients, Text.compare);
        let recipe_sorted = Array.sort<Text>(recipe, Text.compare);
        let result = Array.equal<Text>(ingredients_sorted, recipe_sorted, Text.equal);

        return(result);
    };


    ///////////////////
    // VERIFICATION //
    /////////////////

    // A list of subaccounts that are supposed to have send their ICPs back to the main account : we regularly run check on their balance. 👮‍♀️
    private stable var subaccount_to_check  : [SubAccount] = [];
    private stable var subaccounts_robber : [SubAccount] = [];

    public shared ({caller}) func verification () : async () {
        assert(caller == Principal.fromActor(this));
        var robbers : [SubAccount] = [];
        for (subaccount in subaccount_to_check.vals()){
            let account_to_check = {account = _myAccountIdentifier(?subaccount)};
            let balance = await actorLedger.account_balance(account_to_check);
            let amount = balance.e8s;
            if(amount > 0) {
                subaccounts_robber := Array.append<SubAccount>(subaccounts_robber, [subaccount]);
            };
        };
        subaccount_to_check := [];
        return ();
    };

    public shared ({caller}) func process () : async () {
        assert(caller == Principal.fromActor(this));
        for (subaccount in subaccounts_robber.vals()){
            await (_sendBackFrom(subaccount));
        };
        subaccounts_robber := [];
    };

    //////////////////////////////////
    // OLD DEPARTURE LABS STANDARD //
    ////////////////////////////////


    stable var id          = 0;
    stable var payloadSize = 0;

    stable var nftEntries : [(
        Text, // Token Identifier.
        (
            ?Principal, // Owner of the token.
            [Principal] // Authorized principals.
        ),
        Token.Token, // NFT data.
    )] = [];
    let nfts = Token.NFTs(
        id, 
        payloadSize, 
        nftEntries,
    );

    public query func nftId() : async Nat {
        nfts.currentID();
    };

    public query func nftSize() : async Nat {
        nfts.getTotalMinted();
    };

    stable var staticAssetsEntries : [(
        Text,        // Asset Identifier (path).
        Static.Asset // Asset data.
    )] = [];
    let staticAssets = Static.Assets(staticAssetsEntries);
    
    stable var circulationEntries : [(Text,Text)] = [];
    let circulation : HashMap.HashMap<Text,Text> = HashMap.fromIter(circulationEntries.vals(),0,Text.equal,Text.hash);

    public query func circulationSize() : async Nat {
        circulation.size();
    };

    public query func showCirculation(id : Text) : async ?Text {
        return(circulation.get(id));
    };

    public query func showItems (id : Nat32) : async ?Item {
        return(_items.get(id))
    };


    ///////////////
    // HEARTBEAT //
    ///////////////

    // A count represents approximately one second
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


    ////////////////
    // STATISTICS //
    ///////////////

    public shared query ({caller}) func getStats() : async [Text]{
        assert(_isAdmin(caller));
        let buffer = Buffer.Buffer<Text>(0);
        for (token_index in _registry.keys()){
            switch(_items.get(token_index)){
                case(?#Material(name)){
                    buffer.add(name);
                };
                case(?#Accessory(accessory)){
                    buffer.add(accessory.name);
                };
                case(_){};
            };
        };
        return(buffer.toArray());
    };


    //////////////
    // UPGRADE //
    /////////////

    system func preupgrade() {
        //  Departure labs 
        id                  := nfts.currentID();
        payloadSize         := nfts.payloadSize();
        nftEntries          := Iter.toArray(nfts.entries());
        staticAssetsEntries := Iter.toArray(staticAssets.entries());
        circulationEntries := Iter.toArray(circulation.entries());

        //  EXT
        _registryEntries := Iter.toArray(_registry.entries());
        _ownershipsEntries := Iter.toArray(_ownerships.entries());
        _itemsEntries := Iter.toArray(_items.entries());
        _templateEntries := Iter.toArray(_templates.entries());
        _blobsEntries := Iter.toArray(_blobs.entries());

        //  Canister geek (Monitoring)
        _canistergeekMonitorUD := ? canistergeekMonitor.preupgrade();

        //CAP
        _eventsEntries := Iter.toArray(_events.entries());

        //  Entrepot
        _tokenListingState := Iter.toArray(_tokenListing.entries());
        _tokenSettlementState := Iter.toArray(_tokenSettlement.entries());
        _paymentsState := Iter.toArray(_payments.entries());
        _refundsState := Iter.toArray(_refunds.entries());
    };

    system func postupgrade() {
        //  Departure labs
        id                  := 0;
        payloadSize         := 0;
        nftEntries          := [];
        staticAssetsEntries := [];
        circulationEntries := [];

        // EXT
        _registryEntries := [];
        _ownershipsEntries := [];
        _templateEntries := [];
        _itemsEntries := [];
        _blobsEntries := [];

        //  Canister geek (Monitoring)
        canistergeekMonitor.postupgrade(_canistergeekMonitorUD);
        _canistergeekMonitorUD := null;

        //  Entrepot
        _tokenListingState := [];
        _tokenSettlementState := [];
        _paymentsState := [];
        _refundsState := [];
    };

};