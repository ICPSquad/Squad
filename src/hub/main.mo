import Cycles "mo:base/ExperimentalCycles";
import HashMap "mo:base/HashMap";
import Iter "mo:base/Iter";
import Nat64 "mo:base/Nat64";
import Principal "mo:base/Principal";
import Result "mo:base/Result";

import Canistergeek "mo:canistergeek/canistergeek";
import _Monitor "mo:canistergeek/typesModule";

import Admins "admins";
import Invoice "invoice";
import Types "types";
import Users "users";
shared ({ caller = creator }) actor class ICPSquadHub(
    cid : Principal,
    invoice : Principal,
    avatar : Principal,
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

    ///////////////////
    // USERS(old) ////
    //////////////////

    public type TokenIdentifier = Text;
    
    public type User = {
        wallet : Text;
        email : ?Text;
        discord : ?Text;
        twitter : ?Text;
        rank : ?Nat64; 
        height : ?Nat64;
        avatar : ?TokenIdentifier;  // TokenIdentifier of the avatar created by the user - it might not be updated in the future if we decide to allow sell/transfer
        airdrop : ?[Text];
        status : Status;
    };

    public type Status =  {
        #Level1;
        #Level2;
        #Level3;
        #OG;
        #Legendary;
        #Staff;
    };

    stable var usersEntries : [(Principal,User)] = [];
    let users : HashMap.HashMap<Principal,User> = HashMap.fromIter(usersEntries.vals(),0,Principal.equal, Principal.hash);


    //////////////
    // USERS ////
    ////////////

    public type MintInformation = Types.MintInformation;
    public type MintResult = Types.MintResult;

    stable var _UsersUD : ?Users.UpgradeData = null;
    private let _Users : Users.Users = Users.Users({
        _Logs = _Logs;
        _Invoice = _Invoice;
        cid_avatar = avatar;
    });

    let AVATAR = actor(Principal.toText(avatar)) : actor {
        mint : shared (info : MintInformation, caller : Principal) -> async Result<TokenIdentifier,Text>;
    };

    private let AMOUNT_MINT = 1_000_000_000;

    // To document
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
                _Users.modifyStatus(caller, #InProgress);
                switch(await(_Invoice.createInvoice(caller,AMOUNT_MINT))){
                    case(#ok(invoice)){
                        ignore(_Users.register(caller, { email = null; twitter = null; discord = null; rank = ?(Nat64.fromNat(_Users.getSize())); height = null; status = #Invoice(invoice)}));
                        return #err(#Invoice(invoice));
                    };
                    case(#err(e)){
                        return #err(#InvoiceCanisterErr(e));
                    }
                };
            };
        };
    };

    public shared ({ caller }) func whitelist(p : Principal) : async Result<(), Text> {
        _Monitor.collectMetrics();
        assert(_Admins.isAdmin(caller));
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

    //////////////
    // UPGRADE //
    ////////////

    system func preupgrade() {
        _Logs.logMessage("Preupgrade");
        _MonitorUD := ? _Monitor.preupgrade();
        _LogsUD := ? _Logs.preupgrade();
        _AdminsUD := ? _Admins.preupgrade();
        _UsersUD := ?_Users.preupgrade();
        usersEntries := Iter.toArray(users.entries());
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
       usersEntries := [];
    };





};