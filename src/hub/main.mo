import Admins "admins";
import Array "mo:base/Array";
import Canistergeek "mo:canistergeek/canistergeek";
import Cap "cap";
import Cycles "mo:base/ExperimentalCycles";
import Date "mo:canistergeek/dateModule";
import Error "mo:base/Error";
import Ext "mo:ext/Ext";
import Int "mo:base/Int";
import Jobs "jobs";
import Leaderboard "leaderboard";
import Mission "mission";
import Nat "mo:base/Nat";
import Nat8 "mo:base/Nat8";
import Option "mo:base/Option";
import Principal "mo:base/Principal";
import Result "mo:base/Result";
import Style "style";
import TIme "mo:base/Float";
import Time "mo:base/Time";

shared ({ caller = creator }) actor class ICPSquadHub(
  cid : Principal,
  cid_invoice : Principal,
  cid_avatar : Principal,
  cid_accessory : Principal,
) = this {

  ////////////
  // TYPES //
  ///////////

  public type Result<A, B> = Result.Result<A, B>;
  public type TokenIdentifier = Ext.TokenIdentifier;
  public type Collection = Cap.Collection;
  public type Event = Cap.Event;
  public type CapStats = Cap.CapStats;
  public type StyleScore = Style.StyleScore;
  public type Mission = Mission.Mission;
  public type Job = Jobs.Job;
  public type Leaderboard = Leaderboard.Leaderboard;
  public type Round = Leaderboard.Round;
  public type Date = (Nat, Nat, Nat);

  ////////////
  // TIME ///
  ///////////

  public query func time() : async Time.Time {
    Time.now();
  };

  public query func time_difference(t1 : Time.Time, t2 : ?Time.Time) : async Time.Time {
    switch (t2) {
      case (null) {
        return Time.now() - t1;
      };
      case (?t2) {
        return t2 - t1;
      };
    };
  };

  public query func nano_to_seconds(t1 : Int) : async Int {
    Int.div(t1, 1_000_000_000);
  };

  public query func time_to_date(time : Time.Time) : async Date {
    let date = switch (Date.Date.toDatePartsISO8601(time)) {
      case (null) {
        assert (false);
        (0, 0, 0);
      };
      case (?date_parts) {
        date_parts;
      };
    };
    date;
  };

  ///////////
  // ADMIN //
  ///////////

  stable var master : Principal = creator;

  stable var _AdminsUD : ?Admins.UpgradeData = null;
  let _Admins = Admins.Admins(creator);

  public query func is_admin(p : Principal) : async Bool {
    _Admins.isAdmin(p);
  };

  public query func get_admins() : async [Principal] {
    _Admins.getAdmins();
  };

  public shared ({ caller }) func add_admin(p : Principal) : async () {
    _Admins.addAdmin(p, caller);
    _Monitor.collectMetrics();
    _Logs.logMessage("CONFIG :: Added admin : " # Principal.toText(p) # " by " # Principal.toText(caller));
  };

  public shared ({ caller }) func remove_admin(p : Principal) : async () {
    assert (caller == master);
    _Monitor.collectMetrics();
    _Admins.removeAdmin(p, caller);
    _Logs.logMessage("CONFIG :: Removed admin : " # Principal.toText(p) # " by " # Principal.toText(caller));
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

  stable var _MonitorUD : ?Canistergeek.UpgradeData = null;
  private let _Monitor : Canistergeek.Monitor = Canistergeek.Monitor();

  public query ({ caller }) func getCanisterMetrics(parameters : Canistergeek.GetMetricsParameters) : async ?Canistergeek.CanisterMetrics {
    assert (_Admins.isAdmin(caller));
    _Monitor.getMetrics(parameters);
  };

  public shared ({ caller }) func collectCanisterMetrics() : async () {
    assert (_Admins.isAdmin(caller));
    _Monitor.collectMetrics();
  };

  ////////////
  // LOGS ///
  //////////

  stable var _LogsUD : ?Canistergeek.LoggerUpgradeData = null;
  private let _Logs : Canistergeek.Logger = Canistergeek.Logger();

  public query ({ caller }) func getCanisterLog(request : ?Canistergeek.CanisterLogRequest) : async ?Canistergeek.CanisterLogResponse {
    assert (_Admins.isAdmin(caller));
    _Logs.getLog(request);
  };

  public shared ({ caller }) func setMaxMessagesCount(n : Nat) : async () {
    assert (_Admins.isAdmin(caller));
    _Logs.setMaxMessagesCount(n);
  };

  //////////////
  // STYLE ////
  ////////////

  stable var _StyleUD : ?Style.UpgradeData = null;
  private let _Style : Style.Factory = Style.Factory(
    {
      cid_avatar = cid_avatar;
      _Logs = _Logs;
    },
  );

  ///////////
  // CAP ///
  //////////

  public type ExtendedEvent = Cap.ExtendedEvent;
  public type Activity = Cap.Activity;

  /// ADMIN ///

  public shared query ({ caller }) func get_entries_events() : async [((Date, Principal), [ExtendedEvent])] {
    assert (_Admins.isAdmin(caller));
    return _Cap.entriesEvents();
  };

  stable var _CapUD : ?Cap.UpgradeData = null;
  let _Cap = Cap.Factory(
    {
      cid_bucket_accessory = Principal.fromText("qfevy-hqaaa-aaaaj-qanda-cai");
      cid_bucket_avatar = Principal.fromText("ffu6n-ciaaa-aaaaj-qaotq-cai");
      cid_router = Principal.fromText("lj532-6iaaa-aaaah-qcc7a-cai");
      cid_dab = Principal.fromText("ctqxp-yyaaa-aaaah-abbda-cai");
      cid_avatar = cid_avatar;
      _Logs;
    },
  );

  public shared ({ caller }) func register_collection(collection : Collection) : async Result.Result<(), Text> {
    assert (_Admins.isAdmin(caller));
    _Monitor.collectMetrics();
    await _Cap.registerCollection(collection);
  };

  public shared ({ caller }) func register_all_collections() : async Result.Result<(), Text> {
    assert (_Admins.isAdmin(caller));
    _Monitor.collectMetrics();
    await _Cap.registerAllCollections();
  };

  public query func get_registered_cids() : async [(Collection, Principal)] {
    return _Cap.entriesCids();
  };

  public query func get_daily_events(
    p : Principal,
    date : Date,
  ) : async ?[ExtendedEvent] {
    return _Cap.getDailyEvents(p, date);
  };

  public query func get_daily_score(
    p : Principal,
    date : Date,
  ) : async ?Nat {
    return _Cap.getDailyScore(p, date);
  };

  public query func get_daily_activity(
    p : Principal,
    date : Date,
  ) : async ?Activity {
    return _Cap.getDailyActivity(p, date);
  };

  public query func get_recorded_events(
    p : Principal,
    t1 : ?Time.Time,
    t2 : ?Time.Time,
  ) : async ?[ExtendedEvent] {
    _Cap.getRecordedEvents(p, t1, t2);
  };

  ////////////////
  // MISSION ////
  //////////////

  let ONE_DAY_NANO = 24 * 60 * 60 * 1000 * 1000 * 1000;

  stable var _MissionUD : ?Mission.UpgradeData = null;
  let _Mission = Mission.Center(
    {
      cid_avatar = cid_avatar;
      _Admins;
      _Logs;
      _Cap;
    },
  );

  public shared ({ caller }) func create_mission(mission : Mission.CreateMission) : async Result.Result<Nat, Text> {
    assert (_Admins.isAdmin(caller));
    _Monitor.collectMetrics();
    return _Mission.createMission(mission, caller);
  };

  public shared ({ caller }) func start_mission(id : Nat) : async Result.Result<(), Text> {
    assert (_Admins.isAdmin(caller));
    _Monitor.collectMetrics();
    return _Mission.startMission(id);
  };

  public shared ({ caller }) func stop_mission(id : Nat) : async Result.Result<(), Text> {
    assert (_Admins.isAdmin(caller));
    _Monitor.collectMetrics();
    return _Mission.stopMission(id);
  };

  public shared ({ caller }) func verify_mission(id : Nat) : async Result.Result<Bool, Text> {
    _Monitor.collectMetrics();
    return await _Mission.verifyMission(id, caller, Principal.toBlob(caller));
  };

  public query func get_completed_missions(p : Principal) : async [(Mission.Mission, Time.Time)] {
    _Monitor.collectMetrics();
    return _Mission.getCompletedMissions(p);
  };

  public query ({ caller }) func my_completed_missions() : async [(Nat, Time.Time)] {
    _Monitor.collectMetrics();
    return _Mission.myCompletedMissions(caller);
  };

  public shared ({ caller }) func delete_mission(id : Nat) : async Result.Result<(), Text> {
    assert (_Admins.isAdmin(caller));
    _Monitor.collectMetrics();
    return _Mission.deleteMission(id);
  };

  public query func get_missions() : async [Mission] {
    return _Mission.getMissions();
  };

  public shared ({ caller }) func manually_add_winners(id : Nat, principals : [Principal]) : async Result.Result<(), Text> {
    assert (_Admins.isAdmin(caller));
    _Monitor.collectMetrics();
    return _Mission.manuallyAddWinners(id, principals);
  };

  ////////////////////
  // LEADERBOARD ////
  ///////////////////

  stable var _LeaderboardUD : ?Leaderboard.UpgradeData = null;
  let _Leaderboard = Leaderboard.Factory(
    {
      cid_avatar = cid_avatar;
      cid_accessory;
      _Logs = _Logs;
      _Style = _Style;
      _Mission = _Mission;
      _Cap = _Cap;
    },
  );

  public shared ({ caller }) func start_round() : async Result<Nat, Text> {
    assert (_Admins.isAdmin(caller));
    _Monitor.collectMetrics();
    switch (await _Leaderboard.startRound()) {
      case (#err(e)) {
        return #err(e);
      };
      case (#ok(id)) {
        _Logs.logMessage("EVENT :: Round started : " # Nat.toText(id));
        return #ok(id);
      };
    };
  };

  public shared ({ caller }) func stop_round() : async Result<Nat, Text> {
    assert (_Admins.isAdmin(caller));
    _Monitor.collectMetrics();
    switch (await _Leaderboard.stopRound()) {
      case (#err(e)) {
        return #err(e);
      };
      case (#ok(id)) {
        _Logs.logMessage("EVENT :: Round stopped : " # Nat.toText(id));
        return #ok(id);
      };
    };
  };

  public query func get_round(n : Nat) : async ?Round {
    _Leaderboard.getRound(n);
  };

  public query func get_leaderboard() : async ?Leaderboard {
    _Leaderboard.getCurrentLeaderboard();
  };

  public query func get_specified_leaderboard(id : Nat) : async ?Leaderboard {
    _Leaderboard.getLeaderboard(id);
  };

  public query func get_leaderboard_simplified(n : Nat) : async ?[(Principal, Nat, Nat, Nat)] {
    let leaderboard_opt : ?Leaderboard = _Leaderboard.getLeaderboard(n);
    switch (leaderboard_opt) {
      case (null) {
        return null;
      };
      case (?leaderboard) {
        let simplified : [(Principal, Nat, Nat, Nat)] = Array.map<(Principal, ?Text, ?Text, ?Nat, ?Nat, Nat), (Principal, Nat, Nat, Nat)>(
          leaderboard,
          func(x) { (x.0, Option.get(x.3, 0), Option.get(x.4, 0), x.5) },
        );
        return ?simplified;
      };
    };
  };

  ///////////////////////
  //  CRONIC JOBS //////
  /////////////////////

  stable var _JobsUD : ?Jobs.UpgradeData = null;
  let _Jobs : Jobs.Factory = Jobs.Factory(
    {
      _Logs = _Logs;
    },
  );

  public shared ({ caller }) func add_job(
    canister : Principal,
    method : Text,
    interval : Int,
  ) : async () {
    assert (_Admins.isAdmin(caller));
    _Monitor.collectMetrics();
    _Logs.logMessage("CONFIG :: Added job for canister " # Principal.toText(canister) # " with method " # method # " and interval " # Int.toText(interval));
    _Jobs.addJob(canister, method, interval);
  };

  public shared ({ caller }) func delete_job(
    id : Nat,
  ) : async () {
    assert (_Admins.isAdmin(caller));
    _Monitor.collectMetrics();
    _Logs.logMessage("CONFIG :: Deleted job " # Nat.toText(id));
    _Jobs.deleteJob(id);
  };

  public query ({ caller }) func get_jobs() : async [(Nat, Job)] {
    assert (_Admins.isAdmin(caller));
    return _Jobs.getJobs();
  };

  public shared ({ caller }) func set_job_status(bool : Bool) : async () {
    assert (_Admins.isAdmin(caller));
    _Monitor.collectMetrics();
    if (bool) {
      _Logs.logMessage("CONFIG :: Starting jobs");
    } else {
      _Logs.logMessage("CONFIG :: Stopping jobs");
    };
    _Jobs.setJobStatus(bool);
  };

  /////////////
  // Cronic //
  ///////////

  public shared ({ caller }) func cron_style_score() : async () {
    assert (_Admins.isAdmin(caller) or caller == cid);
    _Monitor.collectMetrics();
    await _Style.updateScores();
    _Logs.logMessage("CRON :: Style scores (hub)");
  };

  public shared ({ caller }) func cron_round() : async Result<(), Text> {
    assert (_Admins.isAdmin(caller) or caller == cid);
    _Monitor.collectMetrics();
    switch (await _Leaderboard.updateCurrentRound()) {
      case (#err(e)) {
        return #err(e);
      };
      case (#ok()) {
        _Logs.logMessage("CRON :: Round");
        return #ok();
      };
    };
  };

  public shared ({ caller }) func cron_events() : async Result.Result<(), Text> {
    assert (_Admins.isAdmin(caller) or caller == cid);
    _Monitor.collectMetrics();
    _Logs.logMessage("CRON :: querying events");
    switch (await _Cap.cronEvents()) {
      case (#err(e)) {
        _Logs.logMessage("CRON :: ERR :: error while querying events : " # e);
        return #err(e);
      };
      case (#ok()) {
        return #ok();
      };
    };
  };

  public shared ({ caller }) func cron_users() : async Result.Result<(), Text> {
    assert (_Admins.isAdmin(caller) or caller == cid);
    _Monitor.collectMetrics();
    await _Cap.cronUsers();
  };

  public shared ({ caller }) func cron_clean() : async Result.Result<(), Text> {
    assert (_Admins.isAdmin(caller) or caller == cid);
    _Monitor.collectMetrics();
    _Cap.cronClean();
  };

  public shared ({ caller }) func cron_scores() : async Result.Result<(), Text> {
    assert (_Admins.isAdmin(caller) or caller == cid);
    _Monitor.collectMetrics();
    await _Cap.cronScores();
  };

  //////////////
  // SYSTEM ///
  ////////////

  system func preupgrade() {
    _Logs.logMessage("PREUPGRADE :: hub");
    _MonitorUD := ?_Monitor.preupgrade();
    _LogsUD := ?_Logs.preupgrade();
    _AdminsUD := ?_Admins.preupgrade();
    _StyleUD := ?_Style.preupgrade();
    _LeaderboardUD := ?_Leaderboard.preupgrade();
    _JobsUD := ?_Jobs.preupgrade();
    _MissionUD := ?_Mission.preupgrade();
    _CapUD := ?_Cap.preupgrade();
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
    _Cap.postupgrade(_CapUD);
    _CapUD := null;
    _Logs.logMessage("POSTUPGRADE :: hub");
  };

  system func heartbeat() : async () {
    await _Jobs.doJobs();
  };

};
