//Base modules
import AID "../dependencies/util/AccountIdentifier";
import Accessory "types/accessory";
import Array "mo:base/Array";
import ArrayHelper "helper/arrayHelper";
import Blob "mo:base/Blob";
import CAPTypes "mo:cap/Types";
import Cap "mo:cap/Cap";
import Char "mo:base/Char";
import Entrepot "../dependencies/entrepot";
import Event "types/event";
import ExperimentalCycles "mo:base/ExperimentalCycles";
import ExtAllowance "../dependencies/ext/Allowance";
import ExtCommon "../dependencies/ext/Common";
import ExtCore "../dependencies/ext/Core";
import Hash "mo:base/Hash";
import HashMap "mo:base/HashMap";
import Http "types/http";
import Inventory "types/inventory";
import Iter "mo:base/Iter";
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
import Static "types/static";
import Text "mo:base/Text";
import Time "mo:base/Time";
import Token "types/token";
import TokenIndex "mo:base/Blob";
import Types "types/types";

shared({ caller = hub }) actor class Hub() = this {

    ////////////////
    // MANAGEMENT //
    ///////////////

    stable var admins : [Principal] = [hub, Principal.fromText("7djq5-fyci5-b7ktq-gaff6-m4m6b-yfncf-pywb3-r2l23-iv3v4-w2lcl-aqe")];

    public query func showAdmins () :  async [Principal] {
        return(admins)
    };

    // Updates the access rights of one of the contact owners.
    //@auth : isAdmin
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



    //////////
    // NFT //
    /////////

    //Transfer

    public shared({caller}) func transfer(request : TransferRequest) : async TransferResponse {
        if (request.amount != 1) {
                return #err(#Other("Must use amount of 1"));
        };
        if (ExtCore.TokenIdentifier.isPrincipal(request.token, Principal.fromActor(this)) == false) {
            return #err(#InvalidToken(request.token));
        };
        let token_index = ExtCore.TokenIdentifier.getIndex(request.token);
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
                switch(_transferTokenOwnership(owner, ?receiver, token_index)){
                    case(#ok){};
                    case(#err(message)) return #err(#Other(message));
                };
                // CAP 
                let event : IndefiniteEvent = {
                    operation = "transfer";
                    details = [("item", #Text(request.token)),("from", #Text(owner)),("to", #Text(receiver))];
                    caller = caller;
                };
                switch(await cap.insert(event)){
                    case(#err(e)) return #err(#Other("Error when reporting event to CAP"));
                    case(#ok(id)) return #ok(request.amount);
                };
            };
            case (_) {
                return #err(#InvalidToken(request.token));
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
            case(?#Material(blob)){{body = blob; headers = [("Content-Type", "text/html; charset=UTF-8")]; streaming_strategy = null; status_code = 200;}}; //TODO check content type
            case(?#LegendaryAccessory(blob)){{body = blob; headers = [("Content-Type", "text/html; charset=UTF-8")]; streaming_strategy = null; status_code = 200;}};
            case(_) {{body = (Text.encodeUtf8("Error unreacheable")); headers = [("Content-Type", "text/html; charset=UTF-8")]; streaming_strategy = null; status_code = 200;}};
        }
    };  

    private func _streamAccessory(token_index : TokenIndex) : Http.Response {
        switch(_blobs.get(token_index)){
            case(null) {{body = (Text.encodeUtf8("Accessory not found. (critical error)")); headers = [("Content-Type", "text/html; charset=UTF-8")]; streaming_strategy = null; status_code = 200;}};
            case(?blob) {{body = blob; headers = [("Content-Type", "text/html; charset=UTF-8")]; streaming_strategy = null; status_code = 200; }}
        }
    };


    /////////////////////////////
    /// Materials & Accessories//
    ////////////////////////////


    // Link materials & accessories in circulation throught their NFT id : materials.get("3") -> "Wood"
    // Those entries are deleted for materials when an accessory is created.
    // Those entries are deleted for accesories when they are wear.

   
    private func _mint (item : Text, recipient : AccountIdentifier) : Result.Result<Text, Text> {
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
        _supply += 1;
        _nextTokenId += 1;
        return #ok(item # " has been created");
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
    

    public shared ({caller}) func mint (name : Text, recipient : AccountIdentifier) : async Result.Result<Text,Text> {
        assert(_isAdmin(caller));
        switch(_mint(name, recipient)){
            case(#err(error)) return #err(error);
            case(#ok(msg)){
                let event : IndefiniteEvent = {
                    operation = "mint";
                    details = [("item", #Text(name)),("from", #Principal(caller)),("to", #Text(recipient))];
                    caller = caller;
                };
                switch(await cap.insert(event)){
                    case(#err(e)) return #err("Error when reporting event to CAP");
                    case(#ok(id)){
                        let id_textual = Nat64.toText(id);
                        return (#ok(msg # ".Cap recorded with id : " #  id_textual));
                    }
                }
            }
        }
    };

 

   
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

    private func _indexToAssetInventory(token_index : TokenIndex) : ?AssetInventory {
        switch(_items.get(token_index)){
            case(?#Material(name)) {?{category = #Material; name = name; token_identifier = _getTokenIdentifier(token_index)}};
            case(?#Accessory(accessory)) {?{category = #Accessory ; name = accessory.name; token_identifier = _getTokenIdentifier(token_index)}};
            case(?#LegendaryAccessory(legendary)) {?{category = #Accessory ; name = legendary.name; token_identifier = _getTokenIdentifier(token_index)}};
            case(null) {null}; 
        };
    };



  

    /////////
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


    //////////////
    // ENTREPOT //
    /////////////

    // type Time = Time.Time;
    // type ListRequest = Entrepot.ListRequest;
    // type TokenIndex = Nat32;
    // type Metadata = {
    //     #fungible : {
    //     name : Text;
    //     symbol : Text;
    //     decimals : Nat8;
    //     metadata : ?Blob;
    //     };
    //     #nonfungible : {
    //     metadata : ?Blob;
    //     };
    // };
    // type Listing = Entrepot.Listing;
    // type Settlement = Entrepot.Settlement;
    // type Transaction = Entrepot.Transaction;
    // type AccountIdentifier = Entrepot.AccountIdentifier;
    // type SubAccount = Entrepot.SubAccount;
    // type AccountBalanceArgs = Entrepot.AccountBalanceArgs;
    // type ICPTs = Entrepot.ICPTs;
    // type CommonError = Entrepot.CommonError;

    // private var ESCROWDELAY : Time = 10 * 60 * 1_000_000_000;
    // let LEDGER_CANISTER = actor "ryjl3-tyaaa-aaaaa-aaaba-cai" : actor { account_balance_dfx : shared query AccountBalanceArgs -> async ICPTs };

    // private stable var _usedPaymentAddressess : [(AccountIdentifier, Principal, SubAccount)] = [];
	// private stable var _transactions : [Transaction] = [];

    // private stable var _tokenListingState : [(TokenIndex, Listing)] = [];
	// private stable var _tokenSettlementState : [(TokenIndex, Settlement)] = [];
	// private stable var _paymentsState : [(Principal, [SubAccount])] = [];
	// private stable var _refundsState : [(Principal, [SubAccount])] = [];

    // let f = func (n : Nat32) : Hash.Hash {
    //     return n
    // };

    // private var _tokenListing : HashMap.HashMap<TokenIndex, Listing> = HashMap.fromIter(_tokenListingState.vals(), _tokenListingState.size(), Core.TokenIndex.equal, Core.TokenIndex.hash);
    // private var _tokenSettlement : HashMap.HashMap<TokenIndex, Settlement> = HashMap.fromIter(_tokenSettlementState.vals(), _tokenSettlementState.size(), Core.TokenIndex.equal, Core.TokenIndex.hash);
    // private var _payments : HashMap.HashMap<Principal, [SubAccount]> = HashMap.fromIter(_paymentsState.vals(), 0, Principal.equal, Principal.hash);
    // private var _refunds : HashMap.HashMap<Principal, [SubAccount]> = HashMap.fromIter(_refundsState.vals(), 0, Principal.equal, Principal.hash);

    // public shared(msg) func list (request : ListRequest) : async Result.Result<(), CommonError> {
    //     let token_identifier = request.token;
    //     let token_index = Core.TokenIdentifier.getIndex(request.token);
    //     if(not(_isCirculating(token_identifier))){
    //         return #err(#InvalidToken(token));
    //     };
    //     if(_isLocked(token_index)){
    //         return #err(#Other("Listing is locked"));
    //     };
    //     switch(_tokenSettlement.get(token_index)){
    //         case(?settlement){
    //             switch(await settle(token_identifier)){
    //                 case(#ok) return #err(#Other("Listing as sold"));
    //                 case(#err(_)) {};
    //             };
    //         };
    //         case(_){};
    //     };
    //     switch(nfts.ownerOf(token_identifier)){
    //         case(#err(_)) return #err(#InvalidToken(token));
    //         case(#ok(p)) {
    //             if(p != msg.caller){
    //                 return #err(#Other("Not authorized"));
    //             };
    //             switch(request.price){
    //                 case(?price){
    //                     _tokenListing.put(token, {seller = msg.caller; price = price; locked = null;});
    //                 };
    //                 case(_) {
    //                     _tokenListing.delete(token);
    //                 };
    //             };
    //             if(Option.isSome(_tokenSettlement.get(token))){
    //                 _tokenSettlement.delete(token);
    //             };
    //             return #ok;
    //         };
    //     };
    // };

    // private func _isCirculating (token : Text) : Bool {
    //     switch(circulation.get(token)){
    //         case(null) return false;
    //         case(?something) return true;
    //     };
    // };

    // private func _isLocked (token : Text) : Bool {
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

    // private func _isSubaccountIncorrect (subaccount : SubAccount) : Bool {
    //     var c : Nat = 0;
    //     var failed : Bool = true;
    //     while(c < 29){
    //         if (failed) {
    //             if (subaccount[c] > 0) { 
    //             failed := false;
    //             };
    //         };
    //         c += 1;
    //     };
    //     failed;
    // };

    // public shared ({caller}) func lock (token : Text, price : Nat64, address : AccountIdentifier, subaccount : SubAccount) : async Result.Result<AccountIdentifier,CommonError> {
    //     if(subaccount.size() != 32) {
    //         return #err(#Other("Wrong subaccount"));
    //     };
    //     if(_isSubaccountIncorrect(subaccount)){
    //         return #err(#Other("Invalid subaccount"));
    //     };
    //     if(not(_isCirculating(token))){
    //         return #err(#InvalidToken(token));
    //     };
    //     if(_isLocked(token)){
    //         return #err(#Other("Listing is locked"));
    //     };
    //     switch(_tokenListing.get(token)){
    //         case(?listing){
    //             if(listing.price != price){
    //                 return #err(#Other("Price has changed"));
    //             } else {
    //                 let paymentAddress : AccountIdentifier = AID.fromPrincipal(listing.seller, ?subaccount);
    //                 if(Option.isSome(Array.find<(AccountIdentifier,Principal,SubAccount)>(_usedPaymentAddressess, func (a : (AccountIdentifier,Principal,SubAccount)) : Bool {a.0 == paymentAddress}))){
    //                     return #err(#Other("Payment address has been used"));
    //                 };
    //                 _tokenListing.put(token, {seller = listing.seller;price = listing.price;locked = ?(Time.now() + ESCROWDELAY);});
    //                 switch(_tokenSettlement.get(token)){
    //                     case(?settlement){
    //                         let resp : Result.Result<(), CommonError> = await settle(token);
    //                         switch(resp){
    //                             case(#ok) {
    //                                 return #err(#Other("Listing as sold"));
    //                             };
    //                             case(#err(_)){
    //                                 if(Option.isNull(_tokenListing.get(token))) {
    //                                     return #err(#Other("Listing as sold"));
    //                                 };
    //                             };
    //                         };
    //                     };
    //                     case(_){};
    //                 };
    //                 _usedPaymentAddressess := Array.append(_usedPaymentAddressess, [(paymentAddress, listing.seller, subaccount)]);
    //                 _tokenSettlement.put(token, {seller = listing.seller;price = listing.price;subaccount = subaccount;buyer = address;});
    //                 return #ok(paymentAddress);
    //             };
    //         };
    //         case(null) {
    //             return #err(#Other("No listing!"))
    //         };
    //     };
    // };


    // public shared (msg) func settle (token_identifier : Text) : async Result.Result<(), CommonError> {
    //     if(not(_isCirculating(token_identifier))){
    //         return #err(#InvalidToken(token_identifier));
    //     };
    //     let token_index = Core.TokenIdentifier.getIndex(token_identifier);
    //     switch(_tokenSettlement.get(token_index)){
    //         case(null) return #err(#Other("Nothing to settle"));
    //         case(?settlement){
    //             let response : ICPTs = await LEDGER_CANISTER.account_balance_dfx({account = AID.fromPrincipal(settlement.seller, ?settlement.subaccount)});
    //             switch(_tokenSettlement.get(token_index)){
    //                 case(null) return #err(#Other("Nothing to settle"));
    //                 case(?settlement) {
    //                     if(response.e8s >= settlement.price){
    //                         _payments.put(settlement.seller, switch(_payments.get(settlement.seller)) {
    //                         case(?p) Array.append(p, [settlement.subaccount]);
    //                         case(_) [settlement.subaccount];
    //                         });
    //                         // TODO : FIND SOMETHING
    //                         // _transferTokenToUser(token, settlement.buyer);
    //                         _transactions := Array.append(_transactions, [{token = token_identifier; seller = settlement.seller; price = settlement.price; buyer = settlement.buyer; time = Time.now();}]);
    //                         _tokenListing.delete(token_index);
    //                         _tokenSettlement.delete(token_index);
    //                         return #ok();
    //                     } else {
    //                         return #err(#Other("Insufficient funds sent"));
    //                     };
    //                 };
    //             };
    //         };
    //     };
    // };

    // public shared(msg) func clearPayments(seller : Principal, payments : [SubAccount]) : async () {
    //     var removedPayments : [SubAccount] = [];
    //     for (p in payments.vals()){
    //         let response : ICPTs = await LEDGER_CANISTER.account_balance_dfx({account = AID.fromPrincipal(seller, ?p)});
    //         if (response.e8s < 10_000){
    //             removedPayments := Array.append(removedPayments, [p]);
    //         };
    //     };
    //     switch(_payments.get(seller)) {
    //         case(null){};
    //         case(?sellerPayments) {
    //             var newPayments : [SubAccount] = [];
    //             for (p in sellerPayments.vals()){
    //                 if (Option.isNull(Array.find(removedPayments, func(a : SubAccount) : Bool {Array.equal(a, p, Nat8.equal);}))) {
    //                     newPayments := Array.append(newPayments, [p]);
    //                 };
    //             };
    //             _payments.put(seller, newPayments)
    //         };
    //     };
    // };

    // // public query func listings() : async [(TokenIndex, Listing, Metadata)] {
    // //     var results : [(TokenIndex, Listing, Metadata)] = [];
    // //     for(a in _tokenListing.entries()) {
    // //         results := Array.append<(TokenIndex, Listing,Metadata)>(results, [(a.0, a.1, #nonfungible({ metadata = null }))]);
    // //     };
    // //     results;
    // // };

    // public query(msg) func payments() : async ?[SubAccount] {
    //     _payments.get(msg.caller);
    // };
    
    // public query func settlements() : async [(TokenIndex, AccountIdentifier, Nat64)] {
    //     var result : [(TokenIndex, AccountIdentifier, Nat64)] = [];
    //     for((token, listing) in _tokenListing.entries()) {
    //         if(_isLocked(token)){
    //             switch(_tokenSettlement.get(token)) {
    //                 case(?settlement) {
    //                     result := Array.append(result, [(token, AID.fromPrincipal(settlement.seller, ?settlement.subaccount), settlement.price)]);
    //                 };
    //                 case(_) {};
    //             };
    //         };
    //     };
    //     result;
    // };

    // public query func transactions() : async [Transaction] {
    //     _transactions;
    // };

    // public query(msg) func allSettlements() : async [(TokenIndex, Settlement)] {
    //     Iter.toArray(_tokenSettlement.entries())
    // };

    // public query(msg) func allPayments() : async [(Principal, [SubAccount])] {
    //     Iter.toArray(_payments.entries())
    // };



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


    //////////////
    // UPGRADE //
    /////////////

    system func preupgrade() {
        //Old
        id                  := nfts.currentID();
        payloadSize         := nfts.payloadSize();
        nftEntries          := Iter.toArray(nfts.entries());
        staticAssetsEntries := Iter.toArray(staticAssets.entries());
        circulationEntries := Iter.toArray(circulation.entries());

        //New
        _registryEntries := Iter.toArray(_registry.entries());
        _ownershipsEntries := Iter.toArray(_ownerships.entries());
        _itemsEntries := Iter.toArray(_items.entries());
        _templateEntries := Iter.toArray(_templates.entries());
        _blobsEntries := Iter.toArray(_blobs.entries());
    };

    system func postupgrade() {
        //Old
        id                  := 0;
        payloadSize         := 0;
        nftEntries          := [];
        staticAssetsEntries := [];
        circulationEntries := [];

        // New 
        _registryEntries := [];
        _ownershipsEntries := [];
        _templateEntries := [];
        _itemsEntries := [];
        _blobsEntries := [];
    };


    ////////////
    // ITEMS //
    //////////


    ////////////////
    // Elements  //
    ///////////////

    public type Item = {
        #Material : Text; 
        #Accessory : Accessory; 
        #LegendaryAccessory : LegendaryAccessory;
    };

    public type Accessory = {
        name : Text;
        wear : Nat8;
        equipped : ?TokenIdentifier; //Token_identifier of the avatar they are equipped on. 
    };

    public type LegendaryAccessory = {
        name : Text;
        date_creation : Int;
    };

    private stable var _itemsEntries : [(TokenIndex, Item)] = [];
    private var _items : HashMap.HashMap<TokenIndex, Item> = HashMap.fromIter(_itemsEntries.vals(), _itemsEntries.size(), ExtCore.TokenIndex.equal, ExtCore.TokenIndex.hash);


    public shared ({caller}) func updateAccessories() : async () {
        assert((caller == Principal.fromActor(this)));
        for ((token_index, item) in _items.entries()){
            switch(item){
                case(#Accessory(accessory)){
                    if(Option.isSome(accessory.equipped)) {
                        let new_wear_value : Nat8 = accessory.wear - 1; 
                        if(new_wear_value == 0) {
                           ignore(_burn(token_index));
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

    // public shared ({caller}) func updateAccessory(token_identifier : Text) : async Result.Result<(), Text> {
    //     let token_index = ExtCore.TokenIdentifier.getIndex(token_identifier);
    //     switch(_items.get(token_index)){
    //         case(?#Accessory(accessory)){
    //             let new_wear_value : Nat8 = accessory.wear - 1; 
    //             if(new_wear_value == 0) {
    //                 switch(await _burn(token_index)){
    //                     case(#err(message)){
    //                         return #err("Error when burning the accessory");
    //                     };
    //                     case(#ok(id)){};
    //                 }
    //             } else  {
    //                 let new_item = #Accessory{name = accessory.name; wear = new_wear_value; equipped = accessory.equipped;};
    //                 _items.put(token_index, new_item);
    //                 _drawAccessory(token_index);
    //                 };
    //         };
    //         case(_) return #err("This item is not an accessory.");
    //     };
    //     return #ok;
    // };

    public shared({caller}) func wearAccessory (token_identifier_accessory : Text, token_identifier_avatar : Text) : async Result.Result<(), Text> {
        let token_index = ExtCore.TokenIdentifier.getIndex(token_identifier_accessory);
        switch(_registry.get(token_index)){
            case(null) return #err("This token identifier doesn't exist!");
            case(?owner){
                if(AID.fromPrincipal(caller, null) != owner){
                    return #err("Unauthorized");
                };
            };
        };
        switch(_items.get(token_index)){
            case(?#Accessory(item)){
                let wear_value = item.wear;
                if(wear_value == 1){
                    return #err("Cannot equip this accessory; wear value is too low.")
                };
                switch(await nftActor.wearAccessory(token_identifier_avatar, item.name, caller)){
                    case(#err(message)) return #err(message);
                    case(#ok){
                        //Decrease the wear value by one! 
                        let new_item = #Accessory({name = item.name; wear = (item.wear - 1); equipped = ?token_identifier_avatar;});
                        _items.put(token_index, new_item);
                        return #ok;
                    };
                };
            };
            case(_) return #err("Not an accessory.");
        };
    };

    public shared ({caller}) func removeAccessory (token_identifier_accessory : Text, token_identifier_avatar : Text ) : async Result.Result<(), Text> {
           let token_index = ExtCore.TokenIdentifier.getIndex(token_identifier_accessory);
        switch(_registry.get(token_index)){
            case(null) return #err("This token identifier doesn't exist!");
            case(?owner){
                if(AID.fromPrincipal(caller, null) != owner){
                    return #err("Unauthorized");
                };
            };
        };
        switch(_items.get(token_index)){
            case(?#Accessory(item)){
                let wear_value = item.wear;
                if(wear_value == 1){
                    return #err("Cannot equip this accessory; wear value is too low.")
                };
                //TODO -> nftActor.removeAccessory 
                switch(await nftActor.wearAccessory(token_identifier_avatar, item.name, caller)){
                    case(#err(message)) return #err(message);
                    case(#ok){
                        //Decrease the wear value by one! 
                        let new_item = #Accessory({name = item.name; wear = (item.wear - 1); equipped = ?token_identifier_avatar;});
                        _items.put(token_index, new_item);
                        return #ok;
                    };
                };
            };
            case(_) return #err("Not an accessory.");
        };
    };

    public shared ({caller}) func _burn (token_index : TokenIndex ) : async Result.Result<Nat64,Text> {
        assert(_isAdmin(caller));
        let token_identifier = _getTokenIdentifier(token_index);
        var name : Text = "";
        let item : ?Item = _items.get(token_index);
        let owner : ?AccountIdentifier = _registry.get(token_index);
        //Get the name of the accessory to add details to CAP
        switch(item){
            case(?#Accessory(item)){ name := item.name};
            case(_){assert(false)};
        };
        let event : IndefiniteEvent = {
            operation = "burn";
            details = [("name", #Text(name)),("identifier", #Text(token_identifier)),("from", #Text(Option.get(owner, "unknown")))];
            caller = caller;
        };
        switch(await cap.insert(event)) {
            case(#err(e))return #err("Error when reporting event to CAP");
            case(#ok(id)){
                switch(owner) {
                    case(null)(#err("No owner found for this token"));
                    case(?owner) {
                        switch(_ownerships.get(owner)){
                            case(null)(#err("No list of NFTs found for this owner"));
                            case(?list){
                                let list_filtered = Array.filter<TokenIndex>(list, func(x) {x != token_index});
                                _ownerships.put(owner, list_filtered);
                                _blobs.delete(token_index);
                                _registry.delete(token_index);
                                _items.delete(token_index);
                                return #ok(id);
                            };
                        };
                    };
                };
            };
        };
    };

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

    public func drawAccessory (token_identifier : TokenIdentifier) : async () {
        let token_index = ExtCore.TokenIdentifier.getIndex(token_identifier);
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

    let materials = ["Cloth", "Wood", "Glass", "Metal", "Circuit", "Dfinity-stone"];
    // public func circulationToItem () : async () {
    //     for((id,name) in circulation.entries()){
    //         let token_index = _textToNat32(id);
    //         if(Option.isSome(Array.find<Text>(materials, func(x) {x == name}))){
    //             let new_material : Item = #Material(name);
    //             _items.put(token_index, new_material);
    //         } else {
    //             let new_accessory : Item = #Accessory({
    //                 name = name;
    //                 wear = 100;
    //                 equipped = null;
    //             });
    //             _items.put(token_index, new_accessory);
    //         };
    //     };
    // };

    public query func sizes () : async (Nat,Nat) {
        return(_items.size(), circulation.size());
    };
    public type Token = {
        payload     : [Blob];
        contentType : Text;
        createdAt   : Int;
        properties  : Property.Properties;
        isPrivate   : Bool;
    };
    let false_token = {
        payload = [Blob.fromArray([0])];
        contentType = "";
        createdAt : Int = Time.now();
        properties : Property.Properties = [];
        isPrivate = false; 
    };

    // public func departureToExt () : async () {
    //     let nftToOwner = nfts.getNftToOwner(); //Registry
    //     let ownerToNft = nfts.getOwnerToNft(); //Owner to NFT
    //     for((text, principal) in nftToOwner.entries()){
    //         let token_index = _textToNat32(text);
    //         let account_identifier = AID.fromPrincipal(principal, null);
    //         _registry.put(token_index, account_identifier);
    //     };
    //     for ((principal, list) in ownerToNft.entries()){
    //         let account_identifier = AID.fromPrincipal(principal, null);
    //         let new_list = Array.map<Text,TokenIndex>(list, _textToNat32);
    //         _ownerships.put(account_identifier, new_list);
    //     };
    // };

    //To get a TokenIndex from a Text 
    private func _textToNat32( txt : Text) : Nat32 {
        assert(txt.size() > 0);
        let chars = txt.chars();

        var num : Nat32 = 0;
        for (v in chars){
            let charToNum = (Char.toNat32(v)-48);
            assert(charToNum >= 0 and charToNum <= 9);
            num := num * 10 +  charToNum;          
        };
        num;
    };
    // Contains all informations needed to create items 
    // Material and legendary are stored as Blob (less memory consumption)
    // Template for accssories are stored as Text to modify the wear value programatically, they also integrate a recipe.
    public type Recipe = [Text];
    public type Template = {
        #Material : Blob; 
        #Accessory : {before_wear : Text; after_wear : Text; recipe : Recipe};
        #LegendaryAccessory : Blob;
    };
    private stable var _templateEntries : [(Text, Template)] = [];
    private var _templates : HashMap.HashMap<Text, Template> = HashMap.fromIter(_templateEntries.vals(),_templateEntries.size(), Text.equal, Text.hash);

    
    //Allow us to add a template  for items (materials/accessories/legendary) & recipe for accessory
    // Items and legendary just need the name and a Blob
    // Accessories are treated differently as they need to be dynamically updated for the wear-out-mechanism and integrate a recipe.
    //@auth : owner
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
    

    //For accessories 
    private stable var _blobsEntries : [(TokenIndex,Blob) ]= [];
    private var _blobs : HashMap.HashMap<TokenIndex,Blob> = HashMap.fromIter(_blobsEntries.vals(), _blobsEntries.size(), ExtCore.TokenIndex.equal, ExtCore.TokenIndex.hash);

  

    ///////////////////
    // EXT - ERC721 //
    /////////////////

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
    private stable var _supply : Balance  = 0;
    private stable var _minter : [Principal]  = [];
    private stable var _nextTokenId : TokenIndex  = 0;

    public func updateToken () : async TokenIndex {
        _nextTokenId := Nat32.fromNat(_registry.size());
        _supply:= _registry.size();
        return _nextTokenId;
    };

    private stable var _registryEntries : [(TokenIndex, AccountIdentifier)] = [];
    private var _registry : HashMap.HashMap<TokenIndex, AccountIdentifier> = HashMap.fromIter(_registryEntries.vals(), 0, ExtCore.TokenIndex.equal, ExtCore.TokenIndex.hash);

    //Increase storage usage but reduce cycle consumptions
    private stable var _ownershipsEntries : [(AccountIdentifier, [TokenIndex])] = [];
    private var _ownerships : HashMap.HashMap<AccountIdentifier, [TokenIndex]> = HashMap.fromIter(_ownershipsEntries.vals(), _ownershipsEntries.size(), Text.equal, Text.hash);

    //Allow to easily update the _ownersToNfts hashmap. If new_account is null token is simply remove
    private func _transferTokenOwnership(old_account : AccountIdentifier, new_account : ?AccountIdentifier, token_index : TokenIndex) : Result.Result<(), Text> { 
        //Remove from old_account
        switch(_ownerships.get(old_account)){
            case(null) return #err("This account doesn't own this token");
            case(?tokens){
                let new_tokens = Array.filter<TokenIndex>(tokens, func (x) {x!=token_index;});
                _ownerships.put(old_account, new_tokens);
                switch(new_account){
                    case(null) return #ok; //Burn
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


    ////////////////
    // Ext-query //
    //////////////

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
        _supply;
    };

    public query func extensions() : async [Extension] {
        EXTENSIONS;
    };
      
    public query func metadata(token : TokenIdentifier): async Result.Result<ExtCommon.Metadata, ExtCore.CommonError> {
        let token_index = ExtCore.TokenIdentifier.getIndex(token);
        switch(_blobs.get(token_index)){
            case(null) {
                return #err(#InvalidToken(token));
            };
            case(?blob){
                let a = #nonfungible({metadata  = ?blob});
                return #ok(a);
            };
        };
    };

    //  public shared query (msg) func tokens_ext (account : AccountIdentifier) : async Result.Result<[(TokenIndex, ?Listing, ?Blob)], CommonError> {
    //     let tokens = _generateTokensExt(account);
    //     if (tokens.size() == 0) {
    //         return #err(#Other ("No token detected for this user."));
    //     } else {
    //         let answer = #ok(tokens);
    //         return answer;
    //     }
    // };
    
    // private func _generateTokensExt (a : AccountIdentifier) : [(TokenIndex, ?Listing, ?Blob)] {
    //     var tokens = Buffer.Buffer<(TokenIndex, ?Listing, ?Blob)>(0);
    //     for ((index,account) in _registry.entries()){
    //         if(a == account) {
    //             let new_element = (index, null, null);
    //             tokens.add(new_element);
    //         };
    //     };
    //     let array = tokens.toArray();
    //     return array;
    // };

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


    ///////////////////////////////////
    // TOKEN ID <-> TOKEN IDENTIFIER //
    //////////////////////////////////
    //TODO : Can be cleaned and moduled

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


    /////////////////////////////////
    // OLD DEPARTURE LABS METHODS //
    ////////////////////////////////

    // Returns the total amount of minted NFTs.
    // public query func getTotalMinted () : async Nat {
    //     nfts.getTotalMinted();
    // };

    var MAX_RESULT_SIZE_BYTES     = 1_000_000; // 1MB Default
    var HTTP_STREAMING_SIZE_BYTES = 1_900_000;

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

    stable var staticAssetsEntries : [(
        Text,        // Asset Identifier (path).
        Static.Asset // Asset data.
    )] = [];
    let staticAssets = Static.Assets(staticAssetsEntries);
    

    // Transfers one of your own NFTs to another principal.
    //TODO : Change parameters
    // public shared ({caller}) func transfer(to : Principal, id : Text) : async Result.Result<Nat64, Types.Error> {
    //     let owner = switch (_canChange(caller, id)) {
    //         case (#err(e)) { return #err(e); };
    //         case (#ok(v))  { v; };
    //     };
    //     let res = await nfts.transfer(to, id);
    //     let event : IndefiniteEvent = {
    //         operation = "transfer";
    //         details = [("item", #Text(id)),("from", #Principal(caller)),("to", #Principal(to))];
    //         caller = caller;
    //     };
    //     switch(await cap.insert(event)){
    //         case(#err(e)) return #err(e);
    //         case(#ok(id)) return #ok(id);
    //     };
    // };

    // private func _canChange(caller : Principal, id : Text) : Result.Result<Principal, Types.Error> {
    //     let owner = switch (nfts.ownerOf(id)) {
    //         case (#err(e)) {
    //             if (not _isAdmin(caller)) return #err(e);
    //             Principal.fromActor(this);
    //         };
    //         case (#ok(v))  {
    //             // The owner not is the caller.
    //             if (not _isAdmin(caller) and v != caller) {
    //                 // Check whether the caller is authorized.
    //                 if (not nfts.isAuthorized(caller, id)) return #err(#Unauthorized);
    //             };
    //             v;
    //         };
    //     };
    //     #ok(owner);
    // };

    stable var circulationEntries : [(Text,Text)] = [];
    let circulation : HashMap.HashMap<Text,Text> = HashMap.fromIter(circulationEntries.vals(),0,Text.equal,Text.hash);


  

    // private func _idToName (id : Text) : Text {
    //     switch(circulation.get(id)) {
    //         case (null) return ("Null");
    //         case (?name) return (name);
    //     };
    // };

    // // Returns optional first id value for which name matchs
    // private func nameToId (name : Text) : ?Text {
    //     for ((k,v) in circulation.entries()) {
    //         if (v == name) {
    //             return ?k;
    //         };
    //     };
    //     return null;
    // };

    // // Returns optional first id value for which name matchs and belongs to user 
    // private func _nameToId (name : Text, from : Principal) : ?Text {
    //     let tokens  : [Text] = nfts.tokensOf(from);
    //     for (token in tokens.vals()) {
    //         if(_idToName(token) == name) {
    //             return ?token;
    //         }
    //     };
    //     return null;
    // };

    // // To query the number of material in circulation, only active units. 
    // public query func howMany(name : Text) : async Nat {
    //     var count = 0;
    //     for(vals in circulation.vals()) {
    //         if(vals == name) {
    //             count += 1
    //         };
    //     };
    //     return count;
    // };


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


    public type Inventory = Inventory.Inventory; 

    // public shared query (msg) func getInventory () : async Inventory {
    //     let principal = msg.caller;
    //     let token_list : [Text] = nfts.tokensOf(principal);
    //     if (token_list.size() == 0){
    //         return [];
    //     };
    //     let asset_name : [Text] = Array.map<Text,Text>(token_list, _idToName);
    //     switch(Inventory.buildInventory(token_list, asset_name)){
    //         case (#err(message)) return [];
    //         case (#ok(inventory)) return inventory;
    //     };
    // };

    // public shared query func getHisInventory_old (principal : Principal) : async Inventory {
    //     let token_list : [Text] = nfts.tokensOf(principal);
    //     if (token_list.size() == 0){
    //         return [];
    //     };
    //     let asset_name : [Text] = Array.map<Text,Text>(token_list, _idToName);
    //     switch(Inventory.buildInventory(token_list, asset_name)){
    //         case (#err(message)) return [];
    //         case (#ok(inventory)) return inventory;
    //     };
    // };


      // Wear Accesory

    let nftActor = actor("jmuqr-yqaaa-aaaaj-qaicq-cai") : actor {
        wearAccessory : shared (Text, Text, Principal) -> async Result.Result<(),Text>;
    };
    
    // TODO : Find a way to "freeze" accessories (so they cannot be sold or wear again during the wait cause this function is not atomic...)
    // public shared(msg) func wearAccessory (token_accessory : Text, token_avatar : Text) : async Result.Result<(),Text> {
    //     let principal = msg.caller;
    //     //  Check if this token is owned by msg.caller
    //     let listId : [Text] = nfts.tokensOf(principal);
    //     if(not (ArrayHelper.contains<Text>(listId, token_accessory, Text.equal))) {
    //         return #err ("You don't own this accessory : " #token_accessory);
    //     };

    //     //  Get the name associated for this token id
    //     let accessory_name : Text = _idToName(token_accessory);
    //     if (accessory_name == "Null") {
    //         return #err ("This token " #token_accessory # " is not an accessory nor a material.");
    //     };
        
    //     switch(await nftActor.wearAccessory(token_avatar, accessory_name , principal)){
    //         case(#ok) {
    //             switch(_removeAccessory(token_accessory, principal)){
    //                 case(#err(message)) return #err ("Accessory was successfully wear but can't destroy it.");
    //                 case (#ok) return #ok;
    //             };
    //         };
    //         case(#err(message)){
    //             return #err(message);
    //         };
    //     };
    // };

    

    // private func _removeAccessory (token : Text, from : Principal) : Result.Result<(),Text> {
    //     switch(nfts.burn(token)) {
    //         case (#err(e)) {return(#err(e))};
    //         case (#ok) {};
    //     };
    //     return #ok;
    // };
     public type Asset = {
        contentType : Text;
        payload     : [Blob];
    };

    public query func showAssets () : async [Text] {
        var array : [Text] = [];
        for (asset in staticAssets.entries()){
            array := Array.append<Text>(array, [asset.0]);
        };
        return array
    };




    




    




};