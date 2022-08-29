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

  stable var _AdminsUD : ?Admins.UpgradeData = null;
  let _Admins = Admins.Admins(creator);

  /* 
        Returns a boolean indicating whether the given user is an admin.
    */
  public query func is_admin(p : Principal) : async Bool {
    _Admins.isAdmin(p);
  };

  /* 
        Adds the given principal to the list of admins.
        @auth : admin
     */
  public shared ({ caller }) func add_admin(p : Principal) : async () {
    _Admins.addAdmin(p, caller);
    _Monitor.collectMetrics();
    _Logs.logMessage("CONFIG :: Added admin : " # Principal.toText(p) # " by " # Principal.toText(caller));
  };

  //////////////
  // CYCLES  //
  /////////////

  /* 
        Accept cycles from an incoming message and add them to the balance of the canister.
    */
  public func acceptCycles() : async () {
    let available = Cycles.available();
    let accepted = Cycles.accept(available);
    assert (accepted == available);
  };

  /* 
        Returns the balance of the canister.
    */
  public query func availableCycles() : async Nat {
    return Cycles.balance();
  };

  ///////////////
  // METRICS ///
  /////////////

  stable var _MonitorUD : ?Canistergeek.UpgradeData = null;
  private let _Monitor : Canistergeek.Monitor = Canistergeek.Monitor();

  /**
    * Returns collected data based on passed parameters.
    * Called from browser.
    * @auth : admin
    */
  public query ({ caller }) func getCanisterMetrics(parameters : Canistergeek.GetMetricsParameters) : async ?Canistergeek.CanisterMetrics {
    assert (_Admins.isAdmin(caller));
    _Monitor.getMetrics(parameters);
  };

  /**
    * Force collecting the data at current time.
    * Called from browser or any canister "update" method.
    * @auth : admin 
    */
  public shared ({ caller }) func collectCanisterMetrics() : async () {
    assert (_Admins.isAdmin(caller));
    _Monitor.collectMetrics();
  };

  ////////////
  // LOGS ///
  //////////

  stable var _LogsUD : ?Canistergeek.LoggerUpgradeData = null;
  private let _Logs : Canistergeek.Logger = Canistergeek.Logger();

  /**
    * Returns collected log messages based on passed parameters.
    * Called from browser.
    * @auth : admin
    */
  public query ({ caller }) func getCanisterLog(request : ?Canistergeek.CanisterLogRequest) : async ?Canistergeek.CanisterLogResponse {
    assert (_Admins.isAdmin(caller));
    _Logs.getLog(request);
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

  /* 
        Manually register a new collection to the CAP module.
        @auth : admin
    */
  public shared ({ caller }) func register_collection(collection : Collection) : async Result.Result<(), Text> {
    assert (_Admins.isAdmin(caller));
    _Monitor.collectMetrics();
    await _Cap.registerCollection(collection);
  };

  /* 
        Use DAB to query all collections and try registering them if they are not already registered.
        @auth : admin
    */
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

  /* 
        Create a new mission. 
        @ok : Assigned id of the mission.Admins
        @err : Error message
        @auth : admin
    */
  public shared ({ caller }) func create_mission(mission : Mission.CreateMission) : async Result.Result<Nat, Text> {
    assert (_Admins.isAdmin(caller));
    _Monitor.collectMetrics();
    return _Mission.createMission(mission, caller);
  };

  /* 
        Change the status and start the mission with the given id.
        @ok : void
        @err : Error message
        @auth : admin
     */
  public shared ({ caller }) func start_mission(id : Nat) : async Result.Result<(), Text> {
    assert (_Admins.isAdmin(caller));
    _Monitor.collectMetrics();
    return _Mission.startMission(id);
  };

  /* 
        Change the status and finish the mission with the given id.
        @ok : void
        @err : Error message
        @auth : admin
     */
  public shared ({ caller }) func stop_mission(id : Nat) : async Result.Result<(), Text> {
    assert (_Admins.isAdmin(caller));
    _Monitor.collectMetrics();
    return _Mission.stopMission(id);
  };

  /* 
        Verify that the caller has successfully completed the mission with the given id.
        @ok : Boolean indicating if the mission has been validated or not.
        @err : Error message indicating the mission could not be validated for technical reasons. (ie id does not exist, no handler...)
     */
  public shared ({ caller }) func verify_mission(id : Nat) : async Result.Result<Bool, Text> {
    _Monitor.collectMetrics();
    return await _Mission.verifyMission(id, caller, Principal.toBlob(caller));
  };

  /* 
        Returns a list of the completed mission for the specified principal. 
        @return : [(Mission, time of completion)]
     */
  public query func get_completed_missions(p : Principal) : async [(Mission.Mission, Time.Time)] {
    _Monitor.collectMetrics();
    return _Mission.getCompletedMissions(p);
  };

  /* 
        Returns a list of the completed mission for the caller with the time of completion.
        @return : [(id, time of completion)]
     */
  public query ({ caller }) func my_completed_missions() : async [(Nat, Time.Time)] {
    _Monitor.collectMetrics();
    return _Mission.myCompletedMissions(caller);
  };

  /* 
        Delete the mission with the given id.
        @ok : void
        @err : Error message
        @auth : admin
     */
  public shared ({ caller }) func delete_mission(id : Nat) : async Result.Result<(), Text> {
    assert (_Admins.isAdmin(caller));
    _Monitor.collectMetrics();
    return _Mission.deleteMission(id);
  };

  /* 
        Returns a list of all missions.
     */
  public query func get_missions() : async [Mission] {
    return _Mission.getMissions();
  };

  /* 
        Upload a list of winners for the mission with the specified id. The mission needs to be manually verifiable (no handler).
        @ok : void
        @err : Error message
        @auth : admin
    */
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

  /* 
        Start a new round if none is running.
        @ok : ID of the round.
        @err : Error message
        @auth : admin
    */
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

  /* 
        End the current round if one is running.
        @ok : Id of the round.
        @err : Error message
        @auth : admin
    */
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

  /* 
        Get the (optional) current Round.
    */
  public query func get_round() : async ?Round {
    _Leaderboard.getCurrentRound();
  };

  /* 
        Get the (optional) current Leaderboard.
    */
  public query func get_leaderboard() : async ?Leaderboard {
    _Leaderboard.getCurrentLeaderboard();
  };

  /* 
        Get the (optional) specified Leaderboard.
    */
  public query func get_specified_leaderboard(id : Nat) : async ?Leaderboard {
    _Leaderboard.getLeaderboard(id);
  };

  /* 
        Get the (optional) simplified version of the leaderbord
    */
  public query func get_leaderboard_simplified(n : Nat) : async ?[(Principal, Nat)] {
    let leaderboard_opt : ?Leaderboard = _Leaderboard.getLeaderboard(n);
    switch (leaderboard_opt) {
      case (null) {
        return null;
      };
      case (?leaderboard) {
        let simplified : [(Principal, Nat)] = Array.map<(Principal, ?Text, ?Text, ?Nat, ?Nat, Nat), (Principal, Nat)>(leaderboard, func(x) { (x.0, x.5) });
        return ?simplified;
      };
    };
  };

  /* 
        Returns a list of the best holders of accessories with meta-informations.
    */
  public func get_holders() : async [(Ext.AccountIdentifier, Nat, ?Principal, ?Text, ?Text, ?TokenIdentifier)] {
    _Monitor.collectMetrics();
    await _Leaderboard.getBestHolders();
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

  /* 
        Add a new job to the cron job list.
        @param canister : The canister to call for the job.
        @param method : The method to call on the canister.
        @param interval : The interval between each call.
        @auth : admin
    */
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

  /* 
        Remove a job from the cron job list.
        @param id : The id of the job to remove.
        @auth : admin
    */
  public shared ({ caller }) func delete_job(
    id : Nat,
  ) : async () {
    assert (_Admins.isAdmin(caller));
    _Monitor.collectMetrics();
    _Logs.logMessage("CONFIG :: Deleted job " # Nat.toText(id));
    _Jobs.deleteJob(id);
  };

  /* 
        Returns a list of all the jobs.
        @return : [(Id, Job)]
        @auth : admin
    */
  public query ({ caller }) func get_jobs() : async [(Nat, Job)] {
    assert (_Admins.isAdmin(caller));
    return _Jobs.getJobs();
  };

  /* 
        Set the status for the Job module.
        @param : Boolean indicating if the jobs should be running or not.    
        @auth : admin
    */
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

  /*  
        Query the latest available style scores from the Avatar canister and update the daily_style_score accordingly.
        @cronic : Every hour.
     */
  public shared ({ caller }) func cron_style_score() : async () {
    assert (_Admins.isAdmin(caller) or caller == cid);
    _Monitor.collectMetrics();
    await _Style.updateScores();
    _Logs.logMessage("CRON :: Style scores (hub)");
  };

  /*  
        Update the currently running rounds if one is running.  
        @cronic : Every hour.
     */
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

  /* 
        Query all the buckets from all the registered collections on the IC & cache the events.
     */
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

  public shared ({ caller }) func cron_stats() : async Result.Result<(), Text> {
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

  //////////////
  // PURGE ////
  ////////////

  public shared ({ caller }) func purge_round(id : Nat) : async Result.Result<Text, Text> {
    assert (_Admins.isAdmin(caller));
    _Monitor.collectMetrics();
    switch (_Leaderboard.getCurrentRound()) {
      case (null) {};
      case (?round) {
        if (round.id == id) {
          return #err("Cannot purge current round");
        };
      };
    };
    switch (_Leaderboard.getRound(id)) {
      case (null) {
        return #err("Round : " # Nat.toText(id) # " not found");
      };
      case (?round) {
        switch (round.end_date) {
          case (null) {
            return #err("Cannot purge a round that has not ended");
          };
          case (?end_date) {
            switch (await _Style.purgeStyleScores(round.start_date, end_date)) {
              case (#err(e)) {
                return #err(e);
              };
              case (#ok(nb)) {
                return #ok("Entries removed : " # Nat.toText(nb));
              };
            };
          };
        };
      };
    };
  };

};
