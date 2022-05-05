import Cycles "mo:base/ExperimentalCycles";
import Error "mo:base/Error";
import HashMap "mo:base/HashMap";
import Iter "mo:base/Iter";
import Nat64 "mo:base/Nat64";
import Principal "mo:base/Principal";
import Result "mo:base/Result";

import Canistergeek "mo:canistergeek/canistergeek";
import Ext "mo:ext/Ext";

import Admins "admins";
import Invoice "invoice";
import Types "types";
import Users "users";
shared ({ caller = creator }) actor class ICPSquadHub(
    cid : Principal,
    invoice : Principal,
    avatar : Principal,
    ledger : Principal
) = this {

    ////////////
    // TYPES //
    ///////////

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

    ///////////////
    // INVOICE ///
    /////////////

    private let _Invoice : Invoice.Factory = Invoice.Factory({
        invoice_cid = invoice;
        cid = cid;
        creator = creator;
    });

    public shared ({ caller }) func transfer(
        amount : Nat,
        account : Text
    ) : async Result<Nat, Invoice.TransferError> {
        assert(_Admins.isAdmin(caller));
        await _Invoice.transfer(amount, account);
    };

    public shared ({ caller }) func get_balance() : async Result<Nat,Invoice.GetBalanceErr> {
        assert(_Admins.isAdmin(caller));
        try {
            await _Invoice.getBalance();
        } catch e {
            _Logs.logMessage("Error while getting balance : " # Error.message(e));
            throw e
        }
    };

    public shared ({ caller }) func verify_invoice(
        id : Nat
    ) : async Result<(), Invoice.VerifyInvoiceErr>{
        assert(_Admins.isAdmin(caller));
        try {
            await _Invoice.verifyInvoice(id);
        } catch e {
            _Logs.logMessage("Error while getting balance : " # Error.message(e));
            throw e
        }
    };

    //////////////
    // USERS ////
    ////////////

    public type MintInformation = Types.MintInformation;
    public type MintResult = Types.MintResult;
    public type TokenIdentifier = Ext.TokenIdentifier;

    stable var _UsersUD : ?Users.UpgradeData = null;
    private let _Users : Users.Users = Users.Users({
        _Logs = _Logs;
        _Invoice = _Invoice;
        cid_avatar = avatar;
    });

    let AVATAR = actor(Principal.toText(avatar)) : actor {
        mint : shared (info : MintInformation, caller : Principal) -> async Result<TokenIdentifier,Text>;
    };

    private let AMOUNT_MINT = 1_000_000_000; // 1 ICP

    
    public shared ({ caller }) func mint(info : MintInformation) : async MintResult {
        _Monitor.collectMetrics();
        if(Principal.isAnonymous(caller)){
            _Logs.logMessage("Mint request from anonymous user");
            return #err(#Anonymous);
        };
        switch(_Users.getUser(caller)){
            case(? user){
                switch(user.status){
                    case(#Member(mint)){
                        if(mint) {
                            _Logs.logMessage("Double mint request from user " # Principal.toText(caller));
                            return #err(#AlreadyMinted);
                        } else {
                            _Logs.logMessage("Send mint request to avatar canister for user : " # Principal.toText(caller));

                            switch(await AVATAR.mint(info, caller)){
                                    case(#ok(a)) {
                                        _Users.modifyStatus(caller, #Member(true));
                                        _Logs.logMessage("Mint request successfull : " # a # " minted for : " # Principal.toText(caller));
                                        return #ok({ tokenId = a });
                                    };
                                    case (#err(e)) {
                                        _Logs.logMessage("Mint request issue : " # e # " for : " #Principal.toText(caller));
                                        return #err(#AvatarCanisterErr(e));
                                };
                            };
                        }
                    };
                    case (#Invoice(invoice)) {
                        _Users.modifyStatus(caller, #InProgress);
                        switch(await _Invoice.verifyInvoice(invoice.id)){
                            case(#ok){
                                _Logs.logMessage("Send mint request to avatar canister for user : " # Principal.toText(caller));
                                switch(await AVATAR.mint(info, caller)){
                                    case(#ok(a)) {
                                        _Users.modifyStatus(caller, #Member(true));
                                        _Logs.logMessage("Mint request successfull : " # a # " minted for : " # Principal.toText(caller));
                                        return #ok({ tokenId = a });
                                    };
                                    case (#err(e)) {
                                        _Users.modifyStatus(caller, #Invoice(invoice));
                                        _Logs.logMessage("Mint request issue : " # e # " for : " #Principal.toText(caller));
                                        return #err(#AvatarCanisterErr(e));
                                    };
                                };
                            };
                            case(#err(e)) {
                                _Logs.logMessage("Error when verifying invoice for user : " # Principal.toText(caller));
                                _Users.modifyStatus(caller, #Invoice(invoice));
                                return #err(#InvoiceCanisterErr(e));
                            };
                        };
                    };
                    case(#InProgress) {
                        _Logs.logMessage("Re-entrancy attack from " # Principal.toText(caller));
                        return #err(#Other("Re-entrancy attack detected"));
                    };
                };
            };
            case(null){
                _Logs.logMessage("User " # Principal.toText(caller) # " not found");
                return #err(#Other("User not found"));
            };
        };
    };

    /* 
        This function is called by the user when he wants to mint an avatar. 
    */
    public shared ({ caller }) func create_invoice() : async Result<Invoice, Text> {
        _Monitor.collectMetrics();
        if(Principal.isAnonymous(caller)){
            _Logs.logMessage("Join request from anonymous user");
            return #err("Request from anonymous user");
        };
        switch(_Users.register(caller){
            case(#err(e)){
                return #err(e);
            };
            case(#ok()){
                switch(await(_Invoice.createInvoice(caller, AMOUNT_MINT))){
                    case(#ok(invoice)){
                        _Users.modifyStatus(caller, #Invoice(invoice));
                        return #ok(invoice));
                    };
                    case(#err(e)){
                        _Logs.logMessage("Error when creating an invoice for user : " # Principal.toText(caller));
                        return #err("Error when creating invoice.");
                    }
                };
            };
        };
    };

    public shared ({ caller }) func whitelist(p : Principal) : async Result<(), Text> {
        assert(_Admins.isAdmin(caller));
        _Monitor.collectMetrics();
        switch(_Users.whitelist(p)){
            case(#ok()) {
                _Logs.logMessage(Principal.toText(p) # "has been whitelisted by " # Principal.toText(caller));
                return #ok;
            };
            case(#err(e)){
                return #err(e);
            };
        };
    };

    public shared ({ caller }) func modify_user(user : Users.User) : async Result<(),Text> {
        _Monitor.collectMetrics();
        _Users.modifyUser(caller, user);
    };

    public query ({ caller }) func get_user() : async ?Users.User {
        _Users.getUser(caller);
    };

    public query ({ caller }) func size_users() : async Nat {
        _Monitor.collectMetrics();
        _Users.getSize();
    };

    public query ({ caller }) func backup_users() : async Users.UpgradeData {
        assert(_Admins.isAdmin(caller));
        _Monitor.collectMetrics();
        _Users.preupgrade()
    };


    //////////////
    // UPGRADE //
    ////////////

    system func preupgrade() {
        _Logs.logMessage("Preupgrade");
        _MonitorUD := ? _Monitor.preupgrade();
        _LogsUD := ? _Logs.preupgrade();
        _AdminsUD := ? _Admins.preupgrade();
        _UsersUD := ?_Users.preupgrade();
    };

    system func postupgrade() {
        _Logs.postupgrade(_LogsUD);
        _LogsUD := null;
        _Monitor.postupgrade(_MonitorUD);
        _MonitorUD := null;
        _Admins.postupgrade(_AdminsUD);
        _AdminsUD := null;
        _Users.postupgrade(_UsersUD);
        _UsersUD := null;
    };





};