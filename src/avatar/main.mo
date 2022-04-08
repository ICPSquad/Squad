import Array "mo:base/Array";
import Blob "mo:base/Blob";
import Buffer "mo:base/Buffer";
import Cycles "mo:base/ExperimentalCycles";
import Hash "mo:base/Hash";
import HashMap "mo:base/HashMap";
import Int "mo:base/Int";
import Iter "mo:base/Iter";
import Nat "mo:base/Nat";
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

import Admins "admins";
import Assets "assets";
import Avatar "avatar";
import ExtModule "ext";
import Http "http";

shared ({ caller = creator }) actor class ICPSquadNFT(
    cid : Principal,
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

    ////////////
    // ASSET //
    ///////////

    public type FilePath = Assets.FilePath;
    public type File = Assets.File;

    stable var _AssetsUD : ?Assets.UpgradeData = null;
    let _Assets = Assets.Assets();

    public shared ({caller}) func upload(
        bytes : [Nat8]
    ) : async () {
        assert(_Admins.isAdmin(caller));
        _Monitor.collectMetrics();
        _Assets.upload(bytes);
    };

    public shared ({caller}) func uploadFinalize (
        contentType : Text,
        meta : Assets.Meta,
        filePath : Text,
    ) : async Result<(), Text> {
        assert(_Admins.isAdmin(caller));
        _Monitor.collectMetrics();
        switch(_Assets.uploadFinalize(contentType,meta,filePath)){
            case(#ok(())){
                _Logs.logMessage("Uploaded file: " # filePath);
                return #ok(());
            };
            case(#err(message)){
                _Logs.logMessage("Failed to upload file: " # filePath);
                return #err(message);
            };
        }
    };

    public shared ({caller}) func uploadClear() : async () {
        assert(_Admins.isAdmin(caller));
        _Monitor.collectMetrics();
        _Assets.uploadClear();
    };

    public shared ({ caller }) func delete(
        filePath : Text
    ) : async Result<(), Text> {
        assert(_Admins.isAdmin(caller));
        _Monitor.collectMetrics();
        _Assets.delete(filePath);
    };

    ///////////////
    // Avatar ////
    /////////////

    type Avatar_New = Avatar.Avatar;
    type Component_New = Avatar.Component;
    type MintInformation = Avatar.MintInformation;

    stable var _AvatarUD : ?Avatar.UpgradeData = null;
    let _Avatar = Avatar.Factory({
        _Admins = _Admins;
        _Assets = _Assets;
        _Logs = _Logs;
    });

    public shared ({caller}) func registerComponent(
        name : Text,
        component : Avatar.Component
    ) : async Result<(), Text> {
        assert(_Admins.isAdmin(caller));
        _Monitor.collectMetrics();
        switch(_Avatar.addComponent(name, component)){
            case(#ok(())){
                _Logs.logMessage("Added component: " # name);
                return #ok(());
            };
            case(#err(message)){
                _Logs.logMessage("Failed to add component: " # name);
                return #err(message);
            };
        };
    };

    public shared ({caller}) func changeStyle(
        style : Text 
    ) : async () {
        assert(_Admins.isAdmin(caller));
        _Monitor.collectMetrics();
        _Avatar.changeCSS(style);
        _Logs.logMessage("Changed CSS");
    };
   
    public shared ({caller}) func draw(
        tokenId : TokenIdentifier
    ) : async Result<(), Text> {
        assert(_Admins.isAdmin(caller));
        _Monitor.collectMetrics();
        _Avatar.drawAvatar(tokenId);
    };

    public shared ({caller}) func mint(
        info : MintInformation
    ) : async Result<TokenIdentifier, Text> {
        assert(_Admins.isAdmin(caller));
        _Monitor.collectMetrics();
        switch(_Ext.mint({ to = #principal(info.user); metadata = null; })){
            case(#err(#Other(e))) return #err(e);
            case(#err(#InvalidToken(e))) return #err(e);
            case(#ok(index)){
                let tokenId = Ext.TokenIdentifier.encode(cid, index);
                switch(_Avatar.createAvatar(info, tokenId)){
                    case(#ok) return #ok(tokenId);
                    case(#err(e)) return #err(e);
                };
            };
        };
    };

    public shared ({caller}) func wearAccessory(
        tokenId : TokenIdentifier,
        name : Text,
        p : Principal
    ) : async Result<(), Text> {
        assert(_Admins.isAdmin(caller));
        _Monitor.collectMetrics();
        switch(_Ext.balance({ user = #principal(p); token = tokenId})){
            case(#err(_)){
                return #err("Error trying to access EXT balance : " # tokenId);
            };
            case(#ok(n)){
                switch(n){
                    case(0){
                        _Logs.logMessage("Main/wearAccessory/502." # " Caller :  " #Principal.toText(p) # " doesnt own : " # tokenId);
                        return #err("Caller :  " #Principal.toText(caller) # " doesn't own : " # tokenId);
                    };
                    case(1){
                        _Avatar.wearAccessory(tokenId, name);
                    };
                    case _ {
                        _Logs.logMessage("Main/wearAccessory/502." # " Caller :  " #Principal.toText(p) # " doesnt own : " # tokenId);
                        return #err("Unexpected value for balance : " # Nat.toText(n));
                    }
                };
            };
        }
    };

    public shared ({caller}) func removeAccessory(
        tokenId : TokenIdentifier,
        name : Text,
        p : Principal
    ) : async Result<(), Text> {
        assert(_Admins.isAdmin(caller));
        _Monitor.collectMetrics();
         switch(_Ext.balance({ user = #principal(p); token = tokenId})){
            case(#err(_)){
                return #err("Error trying to access EXT balance : " # tokenId);
            };
            case(#ok(n)){
                switch(n){
                    case(0){
                        _Logs.logMessage("Main/wearAccessory/502." # " Caller :  " #Principal.toText(p) # " doesnt own : " # tokenId);
                        return #err("Caller :  " #Principal.toText(p) # " doesn't own : " # tokenId);
                    };
                    case(1){
                        _Avatar.removeAccessory(tokenId, name)
                    };
                    case _ {
                        _Logs.logMessage("Main/wearAccessory/502." # " Caller :  " #Principal.toText(p) # " doesnt own : " # tokenId);
                        return #err("Unexpected value for balance : " # Nat.toText(n));
                    }
                };
            };
        };
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
        _Avatar = _Avatar;
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
    public shared ({caller}) func init_cap() : async Result<(), Text> {
        assert(_Admins.isAdmin(caller));
        let tokenContractId = Principal.toText(cid);
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
        assert(caller == cid or _Admins.isAdmin(caller));
        for((time,event) in _events.entries()){
            switch(await cap.insert(event)){
                case(#err(message)){};
                case(#ok(id)){
                    _events.delete(time);
                };
            };
        };
    };

    // It should  always be 0
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
 
    ///////////
    // HTTP //
    //////////

    let _HttpHandler = Http.HttpHandler({
        _Admins = _Admins;
        _Assets = _Assets;
        _Avatar = _Avatar;
    });

    public query func http_request (request : Http.Request) : async Http.Response {
        _HttpHandler.request(request);  
    };

    /////////////
    // UPGRADE //
    /////////////

    system func preupgrade() {
        _Logs.logMessage("Pre-upgrade");
        _MonitorUD := ? _Monitor.preupgrade();
        _LogsUD := ? _Logs.preupgrade();
        _AdminsUD := ? _Admins.preupgrade();
        _AssetsUD := ? _Assets.preupgrade();
        _AvatarUD := ? _Avatar.preupgrade();
        _ExtUD := ? _Ext.preupgrade();
        _eventsEntries := Iter.toArray(_events.entries());
    };

    system func postupgrade() {
        _Logs.postupgrade(_LogsUD);
        _LogsUD := null;
        _Monitor.postupgrade(_MonitorUD);
        _MonitorUD := null;
        _Admins.postupgrade(_AdminsUD);
        _AdminsUD := null;
        _Assets.postupgrade(_AssetsUD);
        _AssetsUD := null;
        _Avatar.postupgrade(_AvatarUD);
        _AvatarUD := null;
        _Ext.postupgrade(_ExtUD);
        _ExtUD := null;
        _eventsEntries := [];
    };

};