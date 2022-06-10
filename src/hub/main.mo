import Array "mo:base/Array";
import Cycles "mo:base/ExperimentalCycles";
import Error "mo:base/Error";
import HashMap "mo:base/HashMap";
import Int "mo:base/Int";
import Iter "mo:base/Iter";
import Nat "mo:base/Nat";
import Nat64 "mo:base/Nat64";
import Nat8 "mo:base/Nat8";
import Principal "mo:base/Principal";
import Result "mo:base/Result";
import TrieMap "mo:base/Trie";

import Canistergeek "mo:canistergeek/canistergeek";
import Date "mo:canistergeek/dateModule";
import Ext "mo:ext/Ext";
import Hex "mo:encoding/Hex";

import Admins "admins";
import Cap "cap";
import Jobs "jobs";
import Leaderboard "leaderboard";
import Mission "mission";
import Style "style";

shared ({ caller = creator }) actor class ICPSquadHub(
    cid : Principal,
    cid_invoice : Principal,
    cid_avatar : Principal,
    cid_accessory : Principal,
) = this {

    ////////////
    // TYPES //
    ///////////

    public type Result<A,B> = Result.Result<A,B>;
    public type TokenIdentifier = Ext.TokenIdentifier;

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

    //////////////
    // STYLE ////
    ////////////

    public type StyleScore = Style.StyleScore;
    stable var _StyleUD: ? Style.UpgradeData = null;
    private let _Style : Style.Factory = Style.Factory({
        cid_avatar = cid_avatar;
        _Logs = _Logs;
    });


    ////////////////
    // CAP ////////
    //////////////

    let _Cap = Cap.Factory({
        cid_bucket_accessory = Principal.fromText("qfevy-hqaaa-aaaaj-qanda-cai");
        cid_bucket_avatar = Principal.fromText("ffu6n-ciaaa-aaaaj-qaotq-cai");
    });

    ////////////////
    // Mission ////
    //////////////  
    
    stable var _MissionUD : ?Mission.UpgradeData = null;
    let _Mission = Mission.Center({
        _Admins;
        _Logs;
        _Cap;
    });

    public shared ({ caller }) func create_mission(mission :  Mission.CreateMission) : async Result.Result<Nat, Text> {
        assert(_Admins.isAdmin(caller));
        _Monitor.collectMetrics();
        return _Mission.createMission(mission, caller);
    };

    public shared ({ caller }) func start_mission(id : Nat) : async Result.Result<(), Text> {
        assert(_Admins.isAdmin(caller));
        _Monitor.collectMetrics();
        return _Mission.startMission(id);
    };

    public shared ({ caller }) func verify_mission(id : Nat) : async Result.Result<Bool, Text> {
        assert(_Admins.isAdmin(caller));
        _Monitor.collectMetrics();
        return await _Mission.verifyMission(id, caller, Principal.toBlob(caller));
    };


    ////////////////////
    // Leaderboard ////
    ///////////////////

    public type Leaderboard = Leaderboard.Leaderboard;
    public type Round = Leaderboard.Round;

    stable var _LeaderboardUD : ?Leaderboard.UpgradeData = null;
    let _Leaderboard = Leaderboard.Factory({
        cid_avatar = cid_avatar;
        cid_accessory;
        _Logs = _Logs;
        _Style = _Style;
        _Mission = _Mission;
    });

    public shared ({ caller }) func start_round() : async Result<Nat, Text> {
        assert(_Admins.isAdmin(caller));
        _Monitor.collectMetrics();
        switch(await _Leaderboard.startRound()){
            case(#err(e)){
                return #err(e);
            };
            case(#ok(id)){
                _Logs.logMessage("Round started : " # Nat.toText(id));
                return #ok(id);
            };
        };
    };

    public shared ({ caller }) func stop_round() : async Result<Nat, Text> {
        assert(_Admins.isAdmin(caller));
        _Monitor.collectMetrics();
        switch(await _Leaderboard.stopRound()){
            case(#err(e)){
                return #err(e);
            };
            case(#ok(id)) {
                _Logs.logMessage("Round stopped : " # Nat.toText(id));
                return #ok(id);
            };
        };
    };

    public query func get_round() : async ?Round {
        _Leaderboard.getCurrentRound();
    };

    public query func get_leaderboard() : async ?Leaderboard {
        _Leaderboard.getCurrentLeaderboard();
    };

    public shared ({ caller }) func get_holders() : async [(Ext.AccountIdentifier, Nat, ?Principal, ?Text, ?Text, ?TokenIdentifier)] {
        assert(_Admins.isAdmin(caller));
        _Monitor.collectMetrics();
        await _Leaderboard.getBestHolders();
    };
 
    ///////////////////////
    // Heartbeat & Jobs //
    /////////////////////

    public type Job = Jobs.Job;

    stable var _JobsUD : ?Jobs.UpgradeData = null;
    let _Jobs : Jobs.Factory = Jobs.Factory({
        _Logs = _Logs;
    });

    public shared ({ caller }) func set_job_status(bool : Bool) : async () {
        assert(_Admins.isAdmin(caller));
        _Monitor.collectMetrics();
        if(bool) {
            _Logs.logMessage("Starting job");
        } else {
            _Logs.logMessage("Stopping job");
        };
        _Jobs.setJobStatus(bool);
    };

    public shared ({ caller }) func add_job(
        canister : Principal,
        method : Text,
        interval : Int,
    ) : async () {
        assert(_Admins.isAdmin(caller));
        _Monitor.collectMetrics();
        _Logs.logMessage("Added job for canister " # Principal.toText(canister) # " with method " # method # " and interval " # Int.toText(interval));
        _Jobs.addJob(canister, method, interval);
    };

    public shared ({ caller }) func delete_job(
        id : Nat
    ) : async () {
        assert(_Admins.isAdmin(caller));
        _Monitor.collectMetrics();
        _Logs.logMessage("Deleted job " # Nat.toText(id));
        _Jobs.deleteJob(id);
    };

    public query ({ caller }) func get_jobs() : async [(Nat, Job)] {
        assert(_Admins.isAdmin(caller));
        return _Jobs.getJobs();  
    };

    system func heartbeat() : async () {
        await _Jobs.doJobs();
    };

    /////////////
    // Cronic //
    ///////////

    /*  
        Query the latest available style scores from the Avatar canister and update the daily_style_score accordingly.
        @cronic : Every hour.
     */
    public shared ({ caller }) func cron_style_score() : async () {
        assert(_Admins.isAdmin(caller) or caller == cid);
        _Monitor.collectMetrics();
        await _Style.updateScores();
        _Logs.logMessage("Cron :: Style scores (hub)");
    };

    /*  
        Update the currently running rounds if one is running.  
        @cronic : Every hour.
     */
    public shared ({ caller }) func cron_round() : async Result<(), Text> {
        assert(_Admins.isAdmin(caller) or caller == cid);
        _Monitor.collectMetrics();
        switch(await _Leaderboard.updateCurrentRound()){
            case(#err(e)){
                return #err(e);
            };
            case(#ok()) {
                _Logs.logMessage("Cron :: round updated");
                return #ok();
            };
        };
    };

    //////////////
    // UPGRADE //
    ////////////

    system func preupgrade() {
        _Logs.logMessage("Preupgrade hub");
        _MonitorUD := ? _Monitor.preupgrade();
        _LogsUD := ? _Logs.preupgrade();
        _AdminsUD := ? _Admins.preupgrade();
        _StyleUD := ? _Style.preupgrade();
        _LeaderboardUD := ? _Leaderboard.preupgrade();
        _JobsUD := ? _Jobs.preupgrade();
        _MissionUD := ? _Mission.preupgrade();
    };

    system func postupgrade() {
        _Logs.postupgrade(_LogsUD);
        _LogsUD := null;
        _Monitor.postupgrade(_MonitorUD);
        _MonitorUD := null;
        _Admins.postupgrade(_AdminsUD);
        _AdminsUD := null;
        _Style.postupgrade(_StyleUD);
        _StyleUD := null;
        _Leaderboard.postupgrade(_LeaderboardUD);
        _LeaderboardUD := null;
        _Jobs.postupgrade(_JobsUD);
        _JobsUD := null;
        _Mission.postupgrade(_MissionUD);
        _MissionUD := null;
        _Logs.logMessage("Postupgrade hub");
    };
};