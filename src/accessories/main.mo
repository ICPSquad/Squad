//Base modules
import Array "mo:base/Array";
import Blob "mo:base/Blob";
import ExperimentalCycles "mo:base/ExperimentalCycles";
import Iter "mo:base/Iter";
import HashMap "mo:base/HashMap";
import Hash "mo:base/Hash";
import Nat8 "mo:base/Nat8";
import Nat32 "mo:base/Nat32";
import Nat64 "mo:base/Nat64";
import Nat "mo:base/Nat";
import Option "mo:base/Option";
import Prim "mo:⛔";
import Principal "mo:base/Principal";
import Result "mo:base/Result";
import Text "mo:base/Text";
import Time "mo:base/Time";

// Departure labs
import ArrayHelper "helper/arrayHelper";
import Event "types/event";
import Http "types/http";
import MapHelper "helper/mapHelper";
import Property "types/property";
import Staged "types/staged";
import Static "types/static";
import Token "types/token";
import Types "types/types";

//Custom
import Accessory "types/accessory";
import Inventory "types/inventory";

//Cap integration
import Cap "mo:cap/Cap";
import Root "mo:cap/Root";
import Router "mo:cap/Router";
import CAPTypes "mo:cap/Types";

//Entrepot integration
import Entrepot "../dependencies/entrepot";
import AID "../dependencies/util/AccountIdentifier";
import Core "../dependencies/ext/Core"


shared({ caller = hub }) actor class Hub() = this {

    ////////////////
    // MANAGEMENT //
    ///////////////

    stable var INITALIZED : Bool = false;
    stable var contractOwners : [Principal] = [hub];

    public type ContractMetadata = {
        name   : Text;
        symbol : Text;
    };
    stable var CONTRACT_METADATA : ContractMetadata = {
        name   = "none"; 
        symbol = "none";
    };

    // Initializes the contract with the given (additional) owners and metadata. Can only be called once.
    // @auth: not INITALIZED
    public shared({caller}) func init(
        owners   : [Principal],
        metadata : ContractMetadata,
    ) : async () {
        assert(not INITALIZED);
        contractOwners    := Array.append(contractOwners, owners);
        CONTRACT_METADATA := metadata;
        INITALIZED        := true;
    };

    // Updates the access rights of one of the contact owners.
    //@auth : isOwner
    public shared({caller}) func updateContractOwners(
        user          : Principal, 
        isAuthorized : Bool,
    ) : async Result.Result<(), Types.Error> {
        if (not _isOwner(caller)) { return #err(#Unauthorized); };
        switch(isAuthorized) {
            case (true) {
                contractOwners := Array.append(
                    contractOwners,
                    [user],
                );
            };
            case (false) {
                contractOwners := Array.filter<Principal>(
                    contractOwners, 
                    func(v) { v != user; },
                );
            };
        };
        #ok();
    };

    ////////////
    // INFOS //
    ///////////

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
        assert(_isOwner(caller));
        return {
            heap_size        = Prim.rts_heap_size();
            memory_size      = Prim.rts_memory_size();
            max_live_size    = Prim.rts_max_live_size();
            nft_payload_size = payloadSize; 
            total_minted     = nfts.getTotalMinted(); 
            cycles           = ExperimentalCycles.balance();
            authorized_users = contractOwners;
        };
    };

    // Returns the total amount of minted NFTs.
    public query func getTotalMinted() : async Nat {
        nfts.getTotalMinted();
    };

    var MAX_RESULT_SIZE_BYTES     = 1_000_000; // 1MB Default
    var HTTP_STREAMING_SIZE_BYTES = 1_900_000;


    // stable var BROKER_CALL_LIMIT        = 25;
    // stable var BROKER_FAILED_CALL_LIMIT = 25;

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
    


    //////////
    // NFT //
    /////////



    // Writes a part of an NFT to the staged data. 
    // Initializing another NFT will destruct the data in the buffer.
    public shared({caller}) func writeStaged(data : Staged.WriteNFT) : async Result.Result<Text, Types.Error> {
        assert(_isOwner(caller));
        switch (await nfts.writeStaged(data)) {
            case (#ok(id)) { #ok(id); };
            case (#err(e)) { #err(#FailedToWrite(e)); };
        };
    };

    // List all static assets.
    // @pre: isOwner
    public query ({caller}) func listAssets() : async [(Text, Text, Nat)] {
        // assert(_isOwner(caller));
        staticAssets.list();
    };

    // Allows you to replace delete and stage NFTs.
    // Putting and initializing staged data will overwrite the present data.
    public shared ({caller}) func assetRequest(data : Static.AssetRequest) : async Result.Result<(), Types.Error> {
        assert(_isOwner(caller));
        switch (await staticAssets.handleRequest(data)) {
            case (#ok())   { #ok(); };
            case (#err(e)) { #err(#FailedToWrite(e)); };
        };
    };

    // Returns the tokens of the given principal.
    public query func balanceOf(p : Principal) : async [Text] {
        nfts.tokensOf(p);
    };

    // Returns the owner of the NFT with given identifier.
    public query func ownerOf(id : Text) : async Result.Result<Principal, Types.Error> {
        nfts.ownerOf(id);
    };

    // Transfers one of your own NFTs to another principal.
    //TODO : add CAP 
    public shared ({caller}) func transfer(to : Principal, id : Text) : async Result.Result<Nat64, Types.Error> {
        let owner = switch (_canChange(caller, id)) {
            case (#err(e)) { return #err(e); };
            case (#ok(v))  { v; };
        };
        let res = await nfts.transfer(to, id);
        let event : IndefiniteEvent = {
            operation = "transfer";
            details = [("item", #Text(id)),("from", #Principal(caller)),("to", #Principal(to))];
            caller = caller;
        };
        switch(await cap.insert(event)){
            case(#err(e)) return #err(e);
            case(#ok(id)) return #ok(id);
        };
    };

    // Allows the caller to authorize another principal to act on its behalf.
    // TODO : add CAP 
    public shared ({caller}) func authorize(req : Token.AuthorizeRequest) : async Result.Result<(), Types.Error> {
        switch (_canChange(caller, req.id)) {
            case (#err(e)) { return #err(e); };
            case (#ok(v))  { };
        };
        if (not nfts.authorize(req)) {
            return #err(#AuthorizedPrincipalLimitReached(Token.AUTHORIZED_LIMIT))
        };
        #ok();
    };

    private func _canChange(caller : Principal, id : Text) : Result.Result<Principal, Types.Error> {
        let owner = switch (nfts.ownerOf(id)) {
            case (#err(e)) {
                if (not _isOwner(caller)) return #err(e);
                Principal.fromActor(this);
            };
            case (#ok(v))  {
                // The owner not is the caller.
                if (not _isOwner(caller) and v != caller) {
                    // Check whether the caller is authorized.
                    if (not nfts.isAuthorized(caller, id)) return #err(#Unauthorized);
                };
                v;
            };
        };
        #ok(owner);
    };

    // Returns whether the given principal is authorized to change to NFT with the given identifier.
    public query func isAuthorized(id : Text, p : Principal) : async Bool {
        nfts.isAuthorized(p, id);
    };

    // Returns which principals are authorized to change the NFT with the given identifier.
    public query func getAuthorized(id : Text) : async [Principal] {
        nfts.getAuthorized(id);
    };

    // Gets the token with the given identifier.
    public shared({caller}) func tokenByIndex(id : Text) : async Result.Result<Token.PublicToken, Types.Error> {
        switch(nfts.getToken(id)) {
            case (#err(e)) { return #err(e); };
            case (#ok(v))  {
                if (v.isPrivate) {
                    if (not nfts.isAuthorized(caller, id) and not _isOwner(caller)) {
                        return #err(#Unauthorized);
                    };
                };
                var payloadResult : Token.PayloadResult = #Complete(v.payload[0]);
                if (v.payload.size() > 1) {
                    payloadResult := #Chunk({
                        data       = v.payload[0]; 
                        totalPages = v.payload.size(); 
                        nextPage   = ?1;
                    });
                };
                let owner = switch (nfts.ownerOf(id)) {
                    case (#err(_)) { Principal.fromActor(this); };
                    case (#ok(v))  { v;                         }; 
                };
                return #ok({
                    contentType = v.contentType;
                    createdAt = v.createdAt;
                    id = id;
                    owner = owner;
                    payload = payloadResult;
                    properties = v.properties;
                });
            }
        }
    };
    
    // Gets the token chuck with the given identifier and page number.
    // Not used has payload is never big enough to make usage of this functionnality
    public shared({caller}) func tokenChunkByIndex(id : Text, page : Nat) : async Result.Result<Token.Chunk, Types.Error> {
        switch (nfts.getToken(id)) {
            case (#err(e)) { return #err(e); };
            case (#ok(v)) {
                if (v.isPrivate) {
                    if (not nfts.isAuthorized(caller, id) and not _isOwner(caller)) {
                        return #err(#Unauthorized);
                    };
                };
                let totalPages = v.payload.size();
                if (page > totalPages) {
                    return #err(#InvalidRequest);
                };
                var nextPage : ?Nat = null;
                if (totalPages > page + 1) {
                    nextPage := ?(page + 1);
                };
                #ok({
                    data       = v.payload[page];
                    nextPage   = nextPage;
                    totalPages = totalPages;
                });
            };
        };
    };

    // Returns the token metadata of an NFT based on the given identifier.
    public shared ({caller}) func tokenMetadataByIndex(id : Text) : async Result.Result<Token.Metadata, Types.Error> {
        switch (nfts.getToken(id)) {
            case (#err(e)) { return #err(e); };
            case (#ok(v)) {
                if (v.isPrivate) {
                    if (not nfts.isAuthorized(caller, id) and not _isOwner(caller)) {
                        return #err(#Unauthorized);
                    };
                };
                #ok({
                    contentType = v.contentType;
                    createdAt   = v.createdAt;
                    id          = id;
                    owner       = switch (nfts.ownerOf(id)) {
                        case (#err(_)) { hub; };
                        case (#ok(v))  { v;   };
                    };
                    properties  = v.properties;
                });
            };
        };
    };

    // Returns the attributes of an NFT based on the given query.
    public query ({caller}) func queryProperties(
        q : Property.QueryRequest,
    ) : async Result.Result<Property.Properties, Types.Error> {
        switch(nfts.getToken(q.id)) {
            case (#err(e)) { #err(e); };
            case (#ok(v))  {
                if (v.isPrivate) {
                    if (not nfts.isAuthorized(caller, q.id) and not _isOwner(caller)) {
                        return #err(#Unauthorized);
                    };
                };
                switch (q.mode) {
                    case (#All)      { #ok(v.properties); };
                    case (#Some(qs)) { Property.get(v.properties, qs); };
                };
            };
        };
    };

    // Updates the attributes of an NFT and returns the resulting (updated) attributes.
    public shared ({caller}) func updateProperties(
        u : Property.UpdateRequest,
    ) : async Result.Result<Property.Properties, Types.Error> {
        switch(nfts.getToken(u.id)) {
            case (#err(e)) { #err(e); };
            case (#ok(v))  {
                if (v.isPrivate) {
                    if (not nfts.isAuthorized(caller, u.id) and not _isOwner(caller)) {
                        return #err(#Unauthorized);
                    };
                };
                switch (Property.update(v.properties, u.update)) {
                    case (#err(e)) { #err(e); };
                    case (#ok(ps)) {
                        switch (nfts.updateProperties(u.id, ps)) {
                            case (#err(e)) { #err(e); };
                            case (#ok())   { #ok(ps); };
                        };
                    };
                };
            };
        };
    };

    private func _isOwner(p : Principal) : Bool {
        switch(Array.find<Principal>(contractOwners, func(v) {return v == p})) {
            case (null) { false; };
            case (? v)  { true;  };
        };
    };

   


    //////////
    // HTTP //
    //////////

    public query func http_request(request : Http.Request) : async Http.Response {
        let path = Iter.toArray(Text.tokens(request.url, #text("/")));
        if (path.size() != 0 and path[0] == "nft") {
            if (path.size() != 2) {
                return Http.BAD_REQUEST();
            };
            return nfts.get(path[1], nftStreamingCallback);
        };
        return staticAssets.get(request.url, staticStreamingCallback);
    };

    public query func http_request_streaming_callback(
        tk : Http.StreamingCallbackToken
    ) : async Http.StreamingCallbackResponse {
        if (Text.startsWith(tk.key, #text("nft/"))) {
            switch (nfts.getToken(tk.key)) {
                case (#err(_)) { };
                case (#ok(v))  {
                    return Http.streamContent(
                        tk.key, 
                        tk.index, 
                        v.payload,
                    );
                };
            };
        } else {
            switch (staticAssets.getToken(tk.key)) {
                case (#err(_)) { };
                case (#ok(v))  {
                    return Http.streamContent(
                        tk.key, 
                        tk.index, 
                        v.payload,
                    );
                };
            };
        };
        return {
            body  = Blob.fromArray([]); 
            token = null;
        };
    };

    // A streaming callback based on static assets.
    // Returns {[], null} if the asset can not be found.
    public query func staticStreamingCallback(tk : Http.StreamingCallbackToken) : async Http.StreamingCallbackResponse {
        switch(staticAssets.getToken(tk.key)) {
            case (#err(_)) { };
            case (#ok(v))  {
                return Http.streamContent(
                    tk.key,
                    tk.index,
                    v.payload,
                );
            };
        };
        {
            body = Blob.fromArray([]);
            token = null;
        };
    };

    // A streaming callback based on NFTs. Returns {[], null} if the token can not be found.
    // Expects a key of the following pattern: "nft/{key}".
    public query func nftStreamingCallback(tk : Http.StreamingCallbackToken) : async Http.StreamingCallbackResponse {
        let path = Iter.toArray(Text.tokens(tk.key, #text("/")));
         if (path.size() == 2 and path[0] == "nft") {
            switch (nfts.getToken(path[1])) {
                case (#err(e)) {};
                case (#ok(v))  {
                    if (not v.isPrivate) {
                        return Http.streamContent(
                            "nft/" # tk.key,
                            tk.index,
                            v.payload,
                        );
                    };
                };
            };
        };
        {
            body  = Blob.fromArray([]);
            token = null;
        };
    };


    /////////////////////////////
    /// Materials & Accessories//
    ////////////////////////////


    // Link materials & accessories in circulation throught their NFT id : materials.get("3") -> "Wood"
    // Those entries are deleted for materials when an accessory is created.
    // Those entries are deleted for accesories when they are wear.

    stable var circulationEntries : [(Text,Text)] = [];
    let circulation : HashMap.HashMap<Text,Text> = HashMap.fromIter(circulationEntries.vals(),0,Text.equal,Text.hash);


    // This hashmap store for each accessory the associated blueprint used when creating a new accessory from materials. 
    type Blueprint = Accessory.Blueprint;
    stable var blueprintsEntries : [(Text,Blueprint)] = [];
    let blueprints : HashMap.HashMap<Text,Blueprint> = HashMap.fromIter(blueprintsEntries.vals(),0,Text.equal,Text.hash);



    private func _idToName (id : Text) : Text {
        switch(circulation.get(id)) {
            case (null) return ("Null");
            case (?name) return (name);
        };
    };

    // Returns optional first id value for which name matchs
    private func nameToId (name : Text) : ?Text {
        for ((k,v) in circulation.entries()) {
            if (v == name) {
                return ?k;
            };
        };
        return null;
    };

    // Returns optional first id value for which name matchs and belongs to user 
    private func _nameToId (name : Text, from : Principal) : ?Text {
        let tokens  : [Text] = nfts.tokensOf(from);
        for (token in tokens.vals()) {
            if(_idToName(token) == name) {
                return ?token;
            }
        };
        return null;
    };

    // To query the number of material in circulation, only active units. 
    public query func howMany(name : Text) : async Nat {
        var count = 0;
        for(vals in circulation.vals()) {
            if(vals == name) {
                count += 1
            };
        };
        return count;
    };

    public query func getMaterials (p : Principal) : async [Text] {
        let tokens_id_user : [Text] = nfts.tokensOf(p);
        let materials : [Text] = Array.map<Text,Text>(tokens_id_user,_idToName);
        return materials;
    };

    
    private func _mint (name : Text, recipient : Principal) : Result.Result<Text, Types.Error> {
        switch (staticAssets.getToken(name)) {
            case (#err(v)) return #err (#AssetNotFound);
            case (#ok(v)) {
                if (v.payload.size() > 1) {
                    return #err(#AssetTooHeavy);
                };
                let egg : Token.Egg = {
                    payload = #Payload(v.payload[0]);
                    contentType = v.contentType;
                    owner = ?recipient;
                    properties = [];
                    isPrivate = false;
                };
                switch(nfts.mintSynchro(Principal.fromActor(this), egg)) {
                    case (#err(e)) { #err((#ErrorMinting)); };
                    case (#ok(id, owner)) {
                        circulation.put(id, name);
                        #ok(name # " has been created with id : " #id);
                    };
                };
            };
        };
    };
    

    public shared ({caller}) func mint (name : Text, recipient : Principal) : async Result.Result<Text,Types.Error> {
        assert(caller == Principal.fromText("dv5tj-vdzwm-iyemu-m6gvp-p4t5y-ec7qa-r2u54-naak4-mkcsf-azfkv-cae"));
        switch(_mint(name, recipient)){
            case(#err(error)) return #err(error);
            case(#ok(msg)){
                let event : IndefiniteEvent = {
                    operation = "mint";
                    details = [("item", #Text(name)),("from", #Principal(caller)),("to", #Principal(recipient))];
                    caller = caller;
                };
                switch(await cap.insert(event)){
                    case(#err(e)) return #err(e);
                    case(#ok(id)){
                        let id_textual = Nat64.toText(id);
                        return (#ok(msg # ".Cap recorded with id : " #  id_textual));
                    }
                }
            }
        }
    };

    // Airdrop 

    public type AirdropObject = {
        recipient: Principal;
        material : Text;
        accessory1 : ?Text;
        accessory2 : ?Text;
    };

    public shared(msg) func airdrop (airdrop : AirdropObject) : async Result.Result<(), Text> {
        assert(msg.caller == Principal.fromText("p4y2d-yyaaa-aaaaj-qaixa-cai")); // Only the hub canister can authorize an airdrop.
        let token_list : [Text] = nfts.tokensOf(airdrop.recipient);
        if (token_list.size() > 0) {
            return #err ("Already airdropped");
        };
        switch(_mint(airdrop.material, airdrop.recipient)){
            case(#err(message)) return #err("Unknown error");
            case(#ok(v)){
                switch(airdrop.accessory1){
                    case(null) return #ok;
                    case(?accessory1){
                        switch(_mint(accessory1, airdrop.recipient)){
                            case(#err(message)) return #err("Unknown error");
                            case(#ok(v)){
                                switch(airdrop.accessory2){
                                    case(null) return #ok;
                                    case(?accessory2){
                                        switch(_mint(accessory2, airdrop.recipient)){
                                            case(#err(message)) return #err("Unknown error");
                                            case(#ok(v)){
                                                return #ok;
                                            };
                                        };
                                    };
                                };
                            };
                        };
                    };
                };
            }; 
        };
    };


    public shared(msg) func addListAccessory (list : [(Text, Static.Asset, Blueprint)]) : async Result.Result<Text,Text> {
        assert(_isOwner(msg.caller));
        for (accessory in list.vals()){
            // Add asset with the corresponding name assuming payload is light enough.
            let asset_request : Static.AssetRequest = #Put({
                key = accessory.0;
                contentType = accessory.1.contentType;
                payload = #Payload(accessory.1.payload[0]);
                callback = null;
            });
            switch(await staticAssets.handleRequest(asset_request)){
                case(#err(message)) return #err(message);
                case (#ok) {};
            };

            // Add blueprint with the corresponding name
            blueprints.put(accessory.0, accessory.2);
        };
        return #ok("All accessories have been added.");
    };

    public shared(msg) func addAccessory (accessory : (Text,Static.Asset,Blueprint)) : async Result.Result<Text,Text> {
        assert(_isOwner(msg.caller));
        let asset_request : Static.AssetRequest = #Put({
                key = accessory.0;
                contentType = accessory.1.contentType;
                payload = #Payload(accessory.1.payload[0]);
                callback = null;
                
        });

        switch(await staticAssets.handleRequest(asset_request)){
                case(#err(message)) return #err(message);
                case (#ok) {};
        };
        blueprints.put(accessory.0, accessory.2);
        return #ok("Accessory has been added : " # accessory.0);
    };

    public shared(msg) func addListMaterial (list : [(Text,Static.Asset)]) : async Result.Result<Text,Text> {
        assert(_isOwner(msg.caller));
        for (material in list.vals()){
            let asset_request : Static.AssetRequest = #Put({
                key = material.0;
                contentType = material.1.contentType;
                payload = #Payload(material.1.payload[0]);
                callback = null;
            });
             switch(await staticAssets.handleRequest(asset_request)){
                case(#err(message)) return #err(message);
                case (#ok()) {};
            };
        };
        return #ok("All materials have been added.");
    };



    public type Inventory = Inventory.Inventory; 

    public shared query (msg) func getInventory () : async Inventory {
        let principal = msg.caller;
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

    public shared query func getHisInventory (principal : Principal) : async Inventory {
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

    // To help clean up

    public shared query ({caller}) func getAllInventory (users:  [Principal]) : async [(Principal, Inventory)] {
        assert(caller == Principal.fromText("p4y2d-yyaaa-aaaaj-qaixa-cai"));
        var array : [(Principal,Inventory)] = [];
        for (principal in users.vals()){
            let token_list : [Text] = nfts.tokensOf(principal);
            if(token_list.size() == 0) {
                array := Array.append<(Principal,Inventory)>(array, [(principal, [])]);
            };
            let asset_name : [Text] = Array.map<Text,Text>(token_list, _idToName);
            switch(Inventory.buildInventory(token_list, asset_name)){
                case (#err(message)) {
                    array := Array.append<(Principal,Inventory)>(array, [(principal, [])]);
                };
                case (#ok(inventory)) {
                    array := Array.append<(Principal,Inventory)>(array, [(principal, inventory)]);
                };
            };
        };
        return array;
    };



    // Wear Accesory

    let nftActor = actor("jmuqr-yqaaa-aaaaj-qaicq-cai") : actor {
        wearAccessory : shared (Text, Text, Principal) -> async Result.Result<(),Text>;
    };
    
    // TODO : Find a way to "freeze" accessories (so they cannot be sold or wear again during the wait cause this function is not atomic...)
    public shared(msg) func wearAccessory (token_accessory : Text, token_avatar : Text) : async Result.Result<(),Text> {
        let principal = msg.caller;
        //  Check if this token is owned by msg.caller
        let listId : [Text] = nfts.tokensOf(principal);
        if(not (ArrayHelper.contains<Text>(listId, token_accessory, Text.equal))) {
            return #err ("You don't own this accessory : " #token_accessory);
        };

        //  Get the name associated for this token id
        let accessory_name : Text = _idToName(token_accessory);
        if (accessory_name == "Null") {
            return #err ("This token " #token_accessory # " is not an accessory nor a material.");
        };
        
        switch(await nftActor.wearAccessory(token_avatar, accessory_name , principal)){
            case(#ok) {
                switch(_removeAccessory(token_accessory, principal)){
                    case(#err(message)) return #err ("Accessory was successfully wear but can't destroy it.");
                    case (#ok) return #ok;
                };
            };
            case(#err(message)){
                return #err(message);
            };
        };
    };

    private func _removeAccessory (token : Text, from : Principal) : Result.Result<(),Text> {
        switch(nfts.burn(token)) {
            case (#err(e)) {return(#err(e))};
            case (#ok) {};
        };
        return #ok;
    };

    // public func showToken (from : Principal) : async [Text] {
    //     let tokens_id_user : [Text] = nfts.tokensOf(from);
    //     return (tokens_id_user);
    // };

    // public func showMaterials (from :Principal): async [Text] {
    //     let tokens_id_user : [Text] = nfts.tokensOf(from);
    //     let materials : [Text] = Array.map<Text,Text>(tokens_id_user, _idToName);
    //     return materials;
    // };
            


    //    // Once the accessory with the specified blueprint has been created we can burn the materials of the user
    // private func _destroyMaterials (names: [Text], from : Principal) : Result.Result<(),Text> {
    //     for (name in names.vals()){
    //         let tokens_id_user : [Text] = nfts.tokensOf(from);
    //         let materials : [Text] = Array.map<Text,Text>(tokens_id_user, _idToName);
    //         let f = func (x : Text) : Bool {
    //             if(x == name) {
    //                 return true;
    //             };
    //             return false;
    //         };
    //         switch(Array.find<Text>(materials, f)) {
    //             case (null) {return #err ("No material found")};
    //             case (?material) {
    //                 switch(_nameToId(material, from)) {
    //                     case (null) {return #err ("No material found (strange)")};
    //                     case (?id) {
    //                         switch(nfts.burn(id)){
    //                             case (#err(e)) {return #err((e))};
    //                             case (#ok) {};
    //                         };
    //                     };
    //                 };
    //             };
    //         };
    //     };
    //     return #ok;
    // };


    


    // TODO reupdate this methods 

    // public shared(msg) func createMaterial(material : Text, recipient : Principal) : async Result.Result<Text,Text> {
    //     assert(_isOwner(msg.caller));
    //     switch(staticAssets.getToken(material)) {
    //         case(#err(v)) {return (#err ("This material doesn't exist"))};
    //         case (#ok(v)) {
    //             if(v.payload.size() > 1) {
    //                 return #err("This material is too heavy (payload toolarge).");
    //             };
    //             let egg : Token.Egg = {
    //                 payload = #Payload(v.payload[0]);
    //                 contentType = v.contentType;
    //                 owner = ?recipient;
    //                 properties = [];
    //                 isPrivate = false;
    //             };

    //             switch (await nfts.mint(Principal.fromActor(this), egg)) {
    //                 case (#err(e)) { #err((e)); };
    //                 case (#ok(id, owner)) {
    //                     // Material event
    //                     circulation.put(id, material);
    //                     #ok("The material : " # material # " has been created with id : " #id);
    //                 };
    //             };
    //         };
    //     };
    // };

    // public func destroyMaterials (names: [Text], from : Principal) : async Result.Result<(),Text> {
    //     for (name in names.vals()){
    //         let tokens_id_user : [Text] = nfts.tokensOf(from);
    //         let materials : [Text] = Array.map<Text,Text>(tokens_id_user, _idToName);
    //         let f = func (x : Text) : Bool {
    //             if(x == name) {
    //                 return true;
    //             };
    //             return false;
    //         };
    //         switch(Array.find<Text>(materials, f)) {
    //             case (null) {return #err ("No material found")};
    //             case (?material) {
    //                 switch(_nameToId(material, from)) {
    //                     case (null) {return #err ("No material found (strange)")};
    //                     case (?id) {
    //                         switch(nfts.burn(id)){
    //                             case (#err(e)) {return #err((e))};
    //                             case (#ok) {};
    //                         };
    //                     };
    //                 };
    //             };
    //         };
    //     };
    //     return #ok;
    // };

     // This function should be called with the name of the accessory and a list of tokens ids to burn (tokens ids should belong to msg.caller)
    // Example -> createAccessory ("Explore-helmet", ["2", "50", "68"]) 
    // This function should be atomic ! (To avoid concurrent state issue like selling while creating accessories).
    // public shared(msg) func createAccessory (name : Text, with : [Text]) : async Result.Result <Text,Text> {
        
    //     // Check if some tokens are used twice 
    //     if((ArrayHelper.isArrayRedundant(with))) {
    //         return #err ("Trying to use a token twice !")
    //     };

    //     let tokens_id_user : [Text] = nfts.tokensOf(msg.caller);
    //     // Check if the specified tokens belong to the caller 
    //     if(not (ArrayHelper.isSubset(with,tokens_id_user))) {
    //         return #err ("Trying to use an non-authorized materials !");
    //     };

    //     let materials : [Text] = Array.map<Text,Text>(with, _idToName);
    //     switch(infos.get(name)) {
    //         case (null) return #err ("No blueprint for this accessory!");
    //         case (?blueprint) {
    //             if(not (ArrayHelper.isSubset(infos.blueprint, materials))) {
    //                 return #err ("User don't have the required material for this accesory");
    //             };
    //             // Try to mint the accessory 
    //             switch(_mintAccessory(name, msg.caller)) {
    //                 case (#err(e)) {#err((e));};
    //                 case (#ok(e)) {
    //                     switch(_destroyMaterial(with, msg.caller)){
    //                         // In the case where we mint an accessory but destroy the material result in an error -> We trap to revert any state change (no commit point previously).
    //                         case (#err(e)) { assert(false); return #err(e); };
    //                         case (#ok) {

    //                             return (#ok("Accessory has been created and materials have been removed."));
    //                         }; 
    //                     };
    //                 };
    //             };
    //         };
    //     };
    // };

    // public shared(msg) func createAccessory2 (name : Text) : async Result.Result<Text,Text> {
    //     // Does this accessory exists?
    //     switch(infos.get(name)) {
    //         case (null) return #err("This accessory doesn't exist");
    //         case (?infos) {
    //             let tokens_id : [Text] = nfts.tokensOf(msg.caller);
    //             let materials : [Text] = Array.map<Text,Text>(tokens_id, _idToName);
    //             // Does msg.caller have enough materials to create this accessory ?
    //             if(not (ArrayHelper.isSubset(infos.blueprint,materials))) {
    //                 return #err ("User doesn't have the required materials for this accessory");
    //             };
    //             switch(_mintAccessory(name, msg.caller)) {
    //                 case (#err(e)) {#err((e));};
    //                 case (#ok(e)) {
    //                     switch(_destroyMaterials(infos.blueprint, msg.caller)){
    //                         // In the case where we mint an accessory but destroy the material result in an error -> We trap to revert any state change (no commit point previously).
    //                         case (#err(e)) { assert(false); return #err(e); };
    //                         case (#ok) {
    //                             return (#ok("Accessory has been created and materials have been removed."));
    //                         }; 
    //                     };
    //                 };
    //             };

    //         };
    //     };
    // };



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
        assert(_isOwner(caller));
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

    public func acceptCycles() : async () {
        let available = ExperimentalCycles.available();
        let accepted = ExperimentalCycles.accept(available);
        assert (accepted == available);
    };

    public query func availableCycles() : async Nat {
        return ExperimentalCycles.balance();
    };


    //////////////
    // UPGRADE //
    /////////////

    system func preupgrade() {
        id                  := nfts.currentID();
        payloadSize         := nfts.payloadSize();
        nftEntries          := Iter.toArray(nfts.entries());
        staticAssetsEntries := Iter.toArray(staticAssets.entries());
        circulationEntries := Iter.toArray(circulation.entries());
        blueprintsEntries := Iter.toArray(blueprints.entries());
    };

    system func postupgrade() {
        id                  := 0;
        payloadSize         := 0;
        nftEntries          := [];
        staticAssetsEntries := [];
        circulationEntries := [];
        blueprintsEntries := [];
    };

};