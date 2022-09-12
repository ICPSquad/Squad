import Array "mo:base/Array";
import Cycles "mo:base/ExperimentalCycles";
import Error "mo:base/Error";
import Int "mo:base/Int";
import Nat "mo:base/Nat";
import Nat8 "mo:base/Nat8";
import Option "mo:base/Option";
import Principal "mo:base/Principal";
import Result "mo:base/Result";
import Time "mo:base/Time";

import Canistergeek "mo:canistergeek/canistergeek";
import Date "mo:canistergeek/dateModule";
import Ext "mo:ext/Ext";

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
  // CONST ///
  ///////////

  let ONE_DAY_NANO = 24 * 60 * 60 * 1000 * 1000 * 1000;
  let ONE_HOUR_NANO = 60 * 60 * 1000 * 1000 * 1000;

  ////////////
  // TYPES //
  ///////////

  public type Time = Time.Time;
  public type Result<A, B> = Result.Result<A, B>;
  public type TokenIdentifier = Ext.TokenIdentifier;
  public type ExtendedEvent = Cap.ExtendedEvent;
  public type Activity = Cap.Activity;
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

  /**
   * Returns the current block time in nanoseconds.
   * @return {Int} 
   */
  public query func time() : async Time {
    Time.now();
  };

  /**
    * Returns the date corresponding to the specified time.
    * @param {Time} time
    * @return {Date} Format: (year, month, day)
    */
  public query func time_to_date(time : Time) : async Date {
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

  ////////////
  // ADMIN //
  ///////////

  stable var master : Principal = creator;

  stable var _AdminsUD : ?Admins.UpgradeData = null;
  let _Admins = Admins.Admins(creator);

  /**
    * Returns a boolean indicating if the specified principal is an admin.
    */
  public query func is_admin(p : Principal) : async Bool {
    _Admins.isAdmin(p);
  };

  /**
    * Returns a list of all the admins.
    */
  public query func get_admins() : async [Principal] {
    _Admins.getAdmins();
  };

  /**
    * Adds the specified principal as an admin.
    * @auth : admin
    */
  public shared ({ caller }) func add_admin(p : Principal) : async () {
    _Admins.addAdmin(p, caller);
    _Monitor.collectMetrics();
    _Logs.logMessage("CONFIG :: Added admin : " # Principal.toText(p) # " by " # Principal.toText(caller));
  };

  /**
    * Removes the specified principal as an admin.
    * @auth : master
    */
  public shared ({ caller }) func remove_admin(p : Principal) : async () {
    assert (caller == master);
    _Monitor.collectMetrics();
    _Admins.removeAdmin(p, caller);
    _Logs.logMessage("CONFIG :: Removed admin : " # Principal.toText(p) # " by " # Principal.toText(caller));
  };

  //////////////
  // CYCLES  //
  /////////////

  /**
    * Add the cycles attached to the incoming message to the balance of the canister.
    */
  public func acceptCycles() : async () {
    let available = Cycles.available();
    let accepted = Cycles.accept(available);
    assert (accepted == available);
  };

  /**
    * Returns the cycle balance of the canister.
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
  public query ({ caller }) func getCanisterMetrics(
    parameters : Canistergeek.GetMetricsParameters,
  ) : async ?Canistergeek.CanisterMetrics {
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
  /**
    * Set the maximum number of saved log messages.
    * @auth : admin
    */
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

  /**
    * Register a new collection. 
    * @remarks : This collection needs to be integrate with CAP.
    * @auth : admin
    */
  public shared ({ caller }) func register_collection(collection : Collection) : async Result<(), Text> {
    assert (_Admins.isAdmin(caller));
    _Monitor.collectMetrics();
    await _Cap.registerCollection(collection);
  };

  /**
    * Automatically registers all collections by calling DAB.  
    * @remarks : Collections registered will be collections that are both in the NFT registry of DAB and that have integrate with CAP.
    * @auth : admin
    */
  public shared ({ caller }) func register_all_collections() : async Result<(), Text> {
    assert (_Admins.isAdmin(caller));
    _Monitor.collectMetrics();
    await _Cap.registerAllCollections();
  };

  /**
    * Returns a list of all registered collections.
    */
  public query func get_registered_cids() : async [(Collection, Principal)] {
    return _Cap.entriesCids();
  };

  /**
    * Returns a list of all collected events.
    * @param {Principal} p : The user we want to get the events for.
    * @param {Date} date : The day we want to target. 
    */
  public query func get_daily_events(
    p : Principal,
    date : Date,
  ) : async ?[ExtendedEvent] {
    return _Cap.getDailyEvents(p, date);
  };

  /**
    * Returns the optional score of an user for a specific day.
    * @param {Principal} p : The user we want to get the events for.
    * @param {Date} date : The day we want to target. 
    * @remark : A return value of null indicates that no event have been collected for this user, for this day. Hence no score was calculated.
    */
  public query func get_daily_score(
    p : Principal,
    date : Date,
  ) : async ?Nat {
    return _Cap.getDailyScore(p, date);
  };

  /**
    * Returns a list of recorded events.
    * @param {Principal} p : The user we want to get the events for.
    * @param {Date} t1 : An optional start date (if null default to BEGIN TIME)
    * @param {Date} t2 : An optional start date (if null default to TIME NOW)
    */
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

  stable var _MissionUD : ?Mission.UpgradeData = null;
  let _Mission = Mission.Center(
    {
      cid_avatar = cid_avatar;
      _Admins;
      _Logs;
      _Cap;
    },
  );

  /**
    * Add a mission into the registry.
    * @auth : admin
    * @return : {ok} The mission id.
    * @return : {err} An error message.
    */
  public shared ({ caller }) func create_mission(mission : Mission.CreateMission) : async Result.Result<Nat, Text> {
    assert (_Admins.isAdmin(caller));
    _Monitor.collectMetrics();
    return _Mission.createMission(mission, caller);
  };

  /**
    * Start the mission with the given id.
    * @auth : admin
    * @return : {ok}.
    * @return : {err} An error message.
    */
  public shared ({ caller }) func start_mission(id : Nat) : async Result.Result<(), Text> {
    assert (_Admins.isAdmin(caller));
    _Monitor.collectMetrics();
    return _Mission.startMission(id);
  };

  /**
    * Stop the mission with the given id.
    * @auth : admin
    * @return : {ok}.
    * @return : {err} An error message.
    */
  public shared ({ caller }) func stop_mission(id : Nat) : async Result.Result<(), Text> {
    assert (_Admins.isAdmin(caller));
    _Monitor.collectMetrics();
    return _Mission.stopMission(id);
  };

  /**
    * Verify the mission with the given id against the caller.
    * @return : {ok} A boolean indicating if the user has completed the mission.
    * @return : {err} An error message.
    */
  public shared ({ caller }) func verify_mission(id : Nat) : async Result.Result<Bool, Text> {
    _Monitor.collectMetrics();
    return await _Mission.verifyMission(id, caller, Principal.toBlob(caller));
  };

  /**
    * Returns a list of all completed mission & their time of completion for the given user.
    */
  public query func get_completed_missions(p : Principal) : async [(Mission.Mission, Time)] {
    return _Mission.getCompletedMissions(p);
  };

  /**
    * Returns the list of all completed mission & their time of completion for the caller.
    */
  public query ({ caller }) func my_completed_missions() : async [(Nat, Time.Time)] {
    return _Mission.myCompletedMissions(caller);
  };

  /**
    * Delete the mission with the given id.
    * @auth : admin
    */
  public shared ({ caller }) func delete_mission(id : Nat) : async Result.Result<(), Text> {
    assert (_Admins.isAdmin(caller));
    _Monitor.collectMetrics();
    return _Mission.deleteMission(id);
  };

  /**
    * Get the list of all missions.
    */
  public query func get_missions() : async [Mission] {
    return _Mission.getMissions();
  };

  /**
    * Add of list of winners for the missions that needs it (ie manual verification).
    * @auth : admin
    */
  public shared ({ caller }) func manually_add_winners(
    id : Nat,
    winners : [Principal],
  ) : async Result.Result<(), Text> {
    assert (_Admins.isAdmin(caller));
    _Monitor.collectMetrics();
    return _Mission.manuallyAddWinners(id, winners);
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

  /**
    * Start a new round.
    * @auth : admin
    * @return : {ok} The round id.
    * @return : {err} An error message.
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

  /**
    * Stop the running round.
    * @auth : admin
    * @return : {ok} The round id.
    * @return : {err} An error message.
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

  /**
    * Get the round corresponding to the given id.
    */
  public query func get_round(n : Nat) : async ?Round {
    _Leaderboard.getRound(n);
  };

  /**
    * Get the current leaderboard
    */
  public query func get_leaderboard() : async ?Leaderboard {
    _Leaderboard.getCurrentLeaderboard();
  };

  /**
    * Get the leaderboard corresponding to the given round id.
    */
  public query func get_specified_leaderboard(id : Nat) : async ?Leaderboard {
    _Leaderboard.getLeaderboard(id);
  };

  /**
    * Get the simplified version of the leaderboard corresponding to the given round id.
  */
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

  /////////////
  // JOBS ////
  ///////////

  stable var _JobsUD : ?Jobs.UpgradeData = null;
  let _Jobs : Jobs.Factory = Jobs.Factory(
    {
      _Logs = _Logs;
    },
  );

  /**
    * Add a new job.
    * @auth : admin
    * @param: {Principal} canister The principal id of the canister that will be called.
    * @param: {Text} method The method that will be called.
    * @param: {Int} interval The period in nanoseconds at which we should call the method.
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

  /**
    * Remove the job corresponding to the given id.
    * @auth : admin
    */
  public shared ({ caller }) func delete_job(
    id : Nat,
  ) : async () {
    assert (_Admins.isAdmin(caller));
    _Monitor.collectMetrics();
    _Logs.logMessage("CONFIG :: Deleted job " # Nat.toText(id));
    _Jobs.deleteJob(id);
  };

  /**
    * Get the list of all jobs.
    */
  public query ({ caller }) func get_jobs() : async [(Nat, Job)] {
    assert (_Admins.isAdmin(caller));
    return _Jobs.getJobs();
  };

  /**
    * Turn on or off all the jobs.
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
  // CRONIC //
  ///////////

  /**
    * Update the internal style scores by querying the Avatar canister.
    * @auth : admin or hub
    * @cronic : 1 hour
    */
  public shared ({ caller }) func cron_style_score() : async () {
    assert (_Admins.isAdmin(caller) or caller == cid);
    _Monitor.collectMetrics();
    await _Style.updateScores();
    _Logs.logMessage("CRON :: Style scores (hub)");
  };

  /**  
    * Update the currently running rounds if one is running.  
    * @auth : admin or hub
    * @cronic : Every hour.
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

  /** 
    * Query all the buckets from all the registered collections on the IC and cache the event of the last 24 hours.
    * @auth : admin or hub
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

  /**
    * Assign cached events to users.
    * @auth : admin or hub
    */
  public shared ({ caller }) func cron_users() : async Result.Result<(), Text> {
    assert (_Admins.isAdmin(caller) or caller == cid);
    _Monitor.collectMetrics();
    await _Cap.cronUsers();
  };

  /**
    * Clean cached events & add them into the permanent database.
    * @auth : admin or hub
    */
  public shared ({ caller }) func cron_clean() : async Result.Result<(), Text> {
    assert (_Admins.isAdmin(caller) or caller == cid);
    _Monitor.collectMetrics();
    _Cap.cronClean();
  };

  /**
    * Calculate the daily score based on collected events.
    * @auth : admin or hub
    */
  public shared ({ caller }) func cron_scores() : async Result.Result<(), Text> {
    assert (_Admins.isAdmin(caller) or caller == cid);
    _Monitor.collectMetrics();
    await _Cap.cronScores();
  };

  /**
    * Perfomns all necessary cronic events for engagement tracking in a row (events, user, clean, clean).
    * @auth : admin or hub
    * @cronic : 2 hours.
    */
  public shared ({ caller }) func cron_stats() : async Result.Result<(), Text> {
    assert (_Admins.isAdmin(caller) or caller == cid);
    switch (await cron_events()) {
      case (#ok) {
        switch (await cron_users()) {
          case (#ok) {
            switch (await cron_clean()) {
              case (#ok) {
                switch (await cron_scores()) {
                  case (#ok) {
                    return #ok;
                  };
                  case (#err(e)) {
                    return #err(e);
                  };
                };
              };
              case (#err(e)) {
                return #err(e);
              };
            };
          };
          case (#err(e)) {
            return #err(e);
          };
        };
      };
      case (#err(e)) {
        return #err(e);
      };
    };
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
