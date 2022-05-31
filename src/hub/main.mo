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
import Distribution "distribution";
import Jobs "jobs";
import Leaderboard "leaderboard";
import Style "style";

shared ({ caller = creator }) actor class ICPSquadHub(
    cid : Principal,
    cid_invoice : Principal,
    cid_avatar : Principal,
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

    public shared ({ caller }) func update_style() : async () {
        assert(_Admins.isAdmin(caller));
        _Monitor.collectMetrics();
        // await _Style.getLatest();
        await _Style.updateScores();
    };

    public query func get_style_scores() : async [(TokenIdentifier, StyleScore)] {
        return _Style.getScores();
    };

    ////////////////////
    // Leaderboard ////
    ///////////////////

    public type Leaderboard = Leaderboard.Leaderboard;

    stable var _LeaderboardUD : ?Leaderboard.UpgradeData = null;
    let _Leaderboard = Leaderboard.Factory({
        cid_avatar = cid_avatar;
        _Logs = _Logs;
        _Style = _Style;
    });


    public shared ({ caller }) func update_leaderboard() : async () {
        assert(_Admins.isAdmin(caller));
        _Monitor.collectMetrics();
        await _Leaderboard.updateLeaderboard();
    };

    public query ({ caller }) func get_leaderboard() : async ?Leaderboard {
        assert(_Admins.isAdmin(caller));
        _Leaderboard.getCurrentLeaderboard();
    };

    ////////////////////
    // Distribution ////
    ///////////////////

    public type Reward = Distribution.Reward;

    // stable var _DistributionUD : ?Distribution.UpgradeData = null;
    private let _Distribution : Distribution.Factory = Distribution.Factory({
        _Leaderboard = _Leaderboard;
        _Logs = _Logs;
        MATERIAL_TO_POINT_RATIO = 0.1; //17.4
    });

    public shared ({ caller }) func pre_compute() : async () {
        assert(_Admins.isAdmin(caller));
        _Monitor.collectMetrics();
        _Distribution.preCompute();  
    };

    public shared ({ caller }) func generate_draft() : async () {
        assert(_Admins.isAdmin(caller));
        _Monitor.collectMetrics();
        _Distribution.generateDraft();
    };

    public query func get_draft() : async [Principal] {
        return _Distribution.getDraft();
    };

    public query ({ caller }) func get_number_of_ticket(p : Principal) : async Nat {
        assert(_Admins.isAdmin(caller));
        _Distribution.getNumberOfTickets(p);
    };

    public query ({ caller }) func rank_to_number_of_ticket(rank : Nat, total : Nat) : async Nat {
        assert(_Admins.isAdmin(caller));
        _Distribution.rankToNumberOfTicket(rank, total);
    };

    // public query func test_random() : async [(Principal,Reward)] {
    //     _Distribution.generateICPSquadRewards();
    // };

    public func test_decode(hex : Text) : async [Nat] {
        switch(Hex.decode(hex)){
            case(#ok(bytes)) {
                return (Array.map<Nat8, Nat>(bytes, Nat8.toNat));
            };
            case(#err(_)){
                return []
            };
        };
    };


    ////////////////
    // Heartbeat //
    //////////////

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

    //////////////
    // UPGRADE //
    ////////////

    system func preupgrade() {
        _Logs.logMessage("Preupgrade hub");
        _MonitorUD := ? _Monitor.preupgrade();
        _LogsUD := ? _Logs.preupgrade();
        _AdminsUD := ? _Admins.preupgrade();
        _StyleUD := ? _Style.preupgrade();
        _JobsUD := ? _Jobs.preupgrade();
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
        _Jobs.postupgrade(_JobsUD);
        _JobsUD := null;
        _Logs.logMessage("Postupgrade hub");
    };
};