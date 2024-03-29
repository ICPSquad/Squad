import Array "mo:base/Array";
import Blob "mo:base/Blob";
import Buffer "mo:base/Buffer";
import Hash "mo:base/Hash";
import IC "mo:base/ExperimentalInternetComputer";
import Iter "mo:base/Iter";
import Nat "mo:base/Nat";
import Nat32 "mo:base/Nat32";
import Nat8 "mo:base/Nat8";
import Option "mo:base/Option";
import Principal "mo:base/Principal";
import Result "mo:base/Result";
import Time "mo:base/Time";
import TrieMap "mo:base/TrieMap";

import Types "types";
module {

  ////////////
  // Types //
  //////////

  public type UpgradeData = Types.UpgradeData;
  public type Mission = Types.Mission;
  public type CreateMission = Types.CreateMission;

  type Name = Text;
  type TokenIdentifier = Text;

  public class Center(dependencies : Types.Dependencies) {

    ////////////
    // State //
    //////////

    let _Admins = dependencies._Admins;
    let _Logs = dependencies._Logs;
    let _Cap = dependencies._Cap;

    let AVATAR_ACTOR = actor (Principal.toText(dependencies.cid_avatar)) : actor {
      get_infos_leaderboard : shared () -> async [(Principal, ?Name, ?TokenIdentifier)];
    };

    let false_encoded : [Nat8] = [68, 73, 68, 76, 0, 1, 126, 0];
    let true_encoded : [Nat8] = [68, 73, 68, 76, 0, 1, 126, 1];

    let BEGINNING_TIME_AUGUST = 1_659_355_118_663_245_979;
    let ENDING_TIME_AUGUST = 1_662_009_390_821_475_918;

    var next_mission_id : Nat = 0;

    let missions : TrieMap.TrieMap<Nat, Mission> = TrieMap.TrieMap<Nat, Mission>(Nat.equal, Hash.hash);
    let winners : TrieMap.TrieMap<Nat, [Principal]> = TrieMap.TrieMap<Nat, [Principal]>(Nat.equal, Hash.hash);
    let completedMissions : TrieMap.TrieMap<Principal, [(Nat, Time.Time)]> = TrieMap.TrieMap<Principal, [(Nat, Time.Time)]>(Principal.equal, Principal.hash);

    /* 
            Keep track for each user of it's completed mission by keeping a record of the time they completed it.  
            Also used to compute the scores for a specific round.
        */

        public func preupgrade() : UpgradeData {
            return({
                next_mission_id;
                missions = Iter.toArray(missions.entries());
                winners = Iter.toArray(winners.entries());
                completedMissions = Iter.toArray(completedMissions.entries());
            })
        };

        public func postupgrade(ud : ?UpgradeData) : () {
            switch(ud){
                case(null) return;
                case(? ud){
                    next_mission_id := ud.next_mission_id;
                    for((id, mission) in ud.missions.vals()){
                        missions.put(id, mission);
                    };
                    for((id, p_winners) in ud.winners.vals()){
                        winners.put(id, p_winners);
                    };
                    for((principal, completed) in ud.completedMissions.vals()){
                        completedMissions.put(principal, completed);
                    };
                };
            };
        };


        //////////
        // API //
        ////////

        public func createMission(mission : CreateMission, caller : Principal) : Result.Result<Nat, Text> {
            let id = next_mission_id;
            let mission_complete : Mission = {
                id;
                creator = caller;
                title = mission.title;
                description = mission.description;
                url_icon = mission.url_icon;
                created_at = Time.now();
                started_at = null;
                ended_at = null;
                restricted = mission.restricted;
                validation = mission.validation;
                status = #Pending;
                points = mission.points;
                tags = Array.append<Text>(mission.tags, ["pending"]);
            };
            missions.put(id, mission_complete);
            next_mission_id := next_mission_id + 1;
            return #ok(id);
        };

        public func startMission(id : Nat) : Result.Result<(), Text> {
            switch(missions.get(id)){
                case(null) {
                    return #err("Mission not found for id :" # Nat.toText(id));
                };
                case(? mission){
                    let new_mission = {
                        id = mission.id;
                        title = mission.title;
                        description = mission.description;
                        url_icon = mission.url_icon;
                        created_at = mission.created_at;
                        started_at = ?Time.now();
                        ended_at = null;
                        restricted = mission.restricted;
                        validation = mission.validation;
                        points = mission.points;
                        tags = mission.tags;
                        status = #Running;
                    };
                    missions.put(id, new_mission);
                    return #ok();
                };
            };
        };

        public func stopMission(id : Nat) : Result.Result<(), Text> {
            switch(missions.get(id)){
                case(null){
                    return #err("Mission not found for id :" # Nat.toText(id));
                };
                case(? mission) {
                    let new_mission = {
                        id = mission.id;
                        title = mission.title;
                        description = mission.description;
                        url_icon = mission.url_icon;
                        created_at = mission.created_at;
                        started_at = mission.started_at;
                        ended_at = ?Time.now();
                        restricted = mission.restricted;
                        validation = mission.validation;
                        points = mission.points;
                        tags = Array.append<Text>(mission.tags, ["ended"]);
                        status = #Ended;
                    };
                    _Logs.logMessage("Mission stopped : " # Nat.toText(id));
                    missions.put(id, new_mission);
                    return #ok();
                };
            };
        };

        public func verifyMission(id : Nat, caller : Principal, args : Blob) : async Result.Result<Bool, Text> {
            switch(missions.get(id)){
                case(null){
                    return #err("Mission not found for id :" # Nat.toText(id));
                };
                case(? mission){
                    if(mission.status != #Running){
                        return #err("Mission not running for id :" # Nat.toText(id));
                    };
                    switch(await _validate(mission, caller, args)){
                        case(#err(e)) {
                            return #err(e);
                        };
                        case(#ok(bool)){
                            if(bool){
                                if(_hasCompletedMission(id, caller)){
                                    return #err("You have already verified this mission");
                                };
                                _afterVerification(id, caller);
                            };
                            return #ok(bool);
                        };
                    };
                };
            };
        };

        /* 
            Delete a mission by id 
            Cannot delete a mission that has already been completed by at least one user. Otherwise the scores won't be computed.
        */
    public func deleteMission(id : Nat) : Result.Result<(), Text> {
      if (_isThereAWinner(id)) {
        return #err("Cannot delete a mission that has registered winners.");
      };
      switch (missions.get(id)) {
        case (null) {
          return #err("Mission not found for id : " # Nat.toText(id));
        };
        case (?mission) {
          missions.delete(id);
          return #ok();
        };
      };
    };

    public func getMissionScore(p : Principal, start : Time.Time, end : Time.Time) : Nat {
      switch (completedMissions.get(p)) {
        case (null) return 0;
        case (?completed) {
          var count : Nat = 0;
          for ((id, time) in completed.vals()) {
            if (time >= start and time <= end) {
              count += _scoreMission(id);
            };
          };
          return count;
        };
      };
    };

    public func getMissions() : [Mission] {
      return Iter.toArray(missions.vals());
    };

    // public func getRunningMission() : [Mission] {
    //     return Array.filter<Mission>(Iter.toArray(missions.vals(), func (x : Mission) {x.status == #Running}));
    // };

    public func myCompletedMissions(caller : Principal) : [(Nat, Time.Time)] {
      switch (completedMissions.get(caller)) {
        case (null) return [];
        case (?completed) {
          return completed;
        };
      };
    };

    public func getCompletedMissions(p : Principal) : [(Mission, Time.Time)] {
      switch (completedMissions.get(p)) {
        case (null) return [];
        case (?completed) {
          var r : Buffer.Buffer<(Mission, Time.Time)> = Buffer.Buffer(0);
          for ((id, time) in completed.vals()) {
            switch (missions.get(id)) {
              case (null) {};
              case (?mission) {
                r.add(mission, time);
              };
            };
          };
          return r.toArray();
        };
      };
    };

    /* 
            Manually add a list of winners for missions that are externally validated.
         */

    public func manuallyAddWinners(id : Nat, p_winners : [Principal]) : Result.Result<(), Text> {
      switch (missions.get(id)) {
        case (null) {
          return #err("Mission not found for id : " # Nat.toText(id));
        };
        case (?mission) {
          switch (mission.validation) {
            //TODO : Add support for external moderators responsible for a specific mission
            case (#Manual(mods)) {
              winners.put(id, p_winners);
              return #ok();
            };
            case (_) {
              return #err("Mission is not eligible for manual validation");
            };
          };
        };
      };
    };

    //////////////
    // Helpers //
    ////////////

    func _validate(mission : Mission, caller : Principal, args : Blob) : async Result.Result<Bool, Text> {
      switch (mission.validation) {
        case (#Custom(info)) {
          let result = await IC.call(info.canister, info.method_name, to_candid (args));
          if (Blob.equal(result, Blob.fromArray(true_encoded))) {
            return return #ok(true);
          } else if (Blob.equal(result, Blob.fromArray(false_encoded))) {
            return return #ok(false);
          } else {
            return #err("Invalid result from canister");
          };

        };
        case (#Automatic(info)) {
          let validator = actor (Principal.toText(info.canister)) : actor {
            verify_mission : shared (id : Nat, caller : Principal) -> async Bool;
          };
          try {
            let result = await validator.verify_mission(mission.id, caller);
            if (result) {
              return #ok(true);
            } else {
              return #ok(false);
            };
          } catch e {
            return #err("Invalid result from canister");
          };
        };
        case (#Manual(mods)) {
          switch (winners.get(mission.id)) {
            case (null) {
              return #err("No list of winners found for this mission");
            };
            case (?list) {
              switch (Array.find<Principal>(list, func(x : Principal) { x == caller })) {
                case (null) {
                  return #ok(false);
                };
                case (?_) {
                  completedMissions.put(caller, [(mission.id, Time.now())]);
                  return #ok(true);
                };
              };
            };
          };
        };
        case (#Internal) {
          for ((id, handler) in handlers.vals()) {
            if (id == mission.id) {
              let result = await handler(caller);
              if (result) {
                return #ok(true);
              } else {
                return #ok(false);
              };
            };
          };
          return #err("No handler found for this mission");
        };
      };
    };

    /* 
            Returns a boolean indicating if the principal is among the winners of a mission.
         */
    func _isWinner(id : Nat, p : Principal) : Bool {
      switch (winners.get(id)) {
        case (null) return false;
        case (?list) {
          switch (Array.find<Principal>(list, func(x : Principal) { x == p })) {
            case (null) return false;
            case (?some) return true;
          };
        };
      };
    };

    /* 
            Returns a boolean indicating if a principal has already completed a mission. Not the same as previous method if the mission is manually provided a list of winners, the user still need to validate his participation.
         */
    func _hasCompletedMission(id : Nat, p : Principal) : Bool {
      switch (completedMissions.get(p)) {
        case (null) return false;
        case (?completed) {
          for ((mission_id, time) in completed.vals()) {
            if (mission_id == id) {
              return true;
            };
          };
          return false;
        };
      };
    };

    /* 
           Performs the necessary action after a user has completed a mission.
           If the mission is a manual one, we only need to add it into the list of completed mission of the user, his principal is already among the list of winners.
           Otherwise we need to perform both actions.
         */
    func _afterVerification(id : Nat, p : Principal) : () {
      switch (missions.get(id)) {
        case (null) {
          return;
        };
        case (?mission) {
          switch (mission.validation) {
            // In the case of a manual validation, we only need to add the mission to the list of completed missions.
            case (#Manual(mods)) {
              _addToCompletedMission(id, p);
            };
            // Otherwise we need to add the mission to the list of completed missions & add the user to the list of winners.
            case (_) {
              _addToWinners(id, p);
              _addToCompletedMission(id, p);
            };
          };
        };
      };
    };

    func _addToWinners(id : Nat, p : Principal) : () {
      switch (winners.get(id)) {
        case (null) {
          winners.put(id, [p]);
        };
        case (?list) {
          winners.put(id, Array.append<Principal>(list, [p]));
        };
      };
    };

    func _addToCompletedMission(id : Nat, p : Principal) : () {
      switch (completedMissions.get(p)) {
        case (null) {
          completedMissions.put(p, [(id, Time.now())]);
        };
        case (?list) {
          completedMissions.put(p, Array.append<(Nat, Time.Time)>(list, [(id, Time.now())]));
        };
      };
    };

    func _isThereAWinner(id : Nat) : Bool {
      switch (winners.get(id)) {
        case (null) return false;
        case (?list) {
          if (list.size() > 0) {
            return true;
          };
          return false;
        };
      };
    };

    func _scoreMission(id : Nat) : Nat {
      switch (missions.get(id)) {
        case (null) return 0;
        case (?mission) {
          mission.points;
        };
      };
    };

    //////////////
    // Handler //
    /////////////
    /* 
            Returns a boolean indicating if the caller has minted at least one branded Cronic accessory.
            Might takes a long time to resolve -> Wen Promise.all in Motoko ?
        */
    func _mission0(caller : Principal) : async Bool {
      _Cap.hasEverMinted(caller, ["Cronic-eyepatch", "Cronic-tshirt", "Cronic-hypnose", "Cronic-wallpaper"], null, null);
    };

    /* 
            Returns a boolean indicating if the caller has minted at least one branded ICPunk accessory.
         */
    func _mission1(caller : Principal) : async Bool {
      _Cap.hasEverMinted(caller, ["Punk-mask", "Punk-glasses"], null, null);
    };

    /* 
            Returns a boolean indicating if the caller has minted at least one accessory.
         */
    func _mission4(caller : Principal) : async Bool {
      let number_mint = _Cap.numberMintAccessory(caller, null, null);
      if (number_mint >= 1) {
        return true;
      };
      false;
    };

    /* 
            Returns a boolean indicating if the caller has minted at least 3 accessories.
         */
    func _mission5(caller : Principal) : async Bool {
      let number_mint = _Cap.numberMintAccessory(caller, null, null);
      if (number_mint >= 3) {
        return true;
      };
      false;
    };

    /* 
            Returns a boolean indicating if the caller has minted at least 10 accessories.
         */
    func _mission6(caller : Principal) : async Bool {
      let number_mint = _Cap.numberMintAccessory(caller, null, null);
      if (number_mint >= 10) {
        return true;
      };
      false;
    };

    /* 
            Returns a boolean indicating if the caller has burned at least 1 accessory.
         */
    func _mission7(caller : Principal) : async Bool {
      let number_burn = _Cap.numberBurnAccessory(caller, null, null);
      if (number_burn >= 1) {
        return true;
      };
      false;
    };

    /* 
            Returns a boolean indicating if the caller has burned at least 3 accessories.
         */
    func _mission8(caller : Principal) : async Bool {
      let number_burn = _Cap.numberBurnAccessory(caller, null, null);
      if (number_burn >= 3) {
        return true;
      };
      false;
    };

    /* 
            Returns a boolean indicating if the caller has burned at least 10 accessories.
         */
    func _mission9(caller : Principal) : async Bool {
      let number_burn = _Cap.numberBurnAccessory(caller, null, null);
      if (number_burn >= 10) {
        return true;
      };
      false;
    };

    /* 
            Returns a boolean indicating if the caller has added a name to his avatar.
         */
    func _mission14(caller : Principal) : async Bool {
      let infos = await AVATAR_ACTOR.get_infos_leaderboard();
      switch (Array.find<(Principal, ?Text, ?Text)>(infos, func(x) { x.0 == caller })) {
        case (null) {
          return false;
        };
        case (?x) {
          switch (x.1) {
            case (null) {
              return false;
            };
            case (?name) {
              return true;
            };
          };
        };
      };
    };

    /* 
            Returns a boolean indicating if the caller has interacted with at least 3 different collections.
         */
    func _mission15(caller : Principal) : async Bool {
      let collections = _Cap.collectionInteracted(caller, null, null);
      if (collections.size() >= 3) {
        return true;
      };
      false;
    };

    /* 
            Returns a boolean indicating if the caller has interacted with at least 20 different collections.
         */
    func _mission16(caller : Principal) : async Bool {
      let collections = _Cap.collectionInteracted(caller, null, null);
      if (collections.size() >= 20) {
        return true;
      };
      false;
    };

    /* 
            Returns a boolean indicating if the caller has realized more than 10 transactions with a least 100 ICPs involved.
         */
    func _mission17(caller : Principal) : async Bool {
      let activity = _Cap.cumulativeActivity(caller, null, null);
      let number_transaction = activity.buy.0 + activity.sell.0;
      let amount_transaction = activity.buy.1 + activity.sell.1;
      if (number_transaction >= 10 and amount_transaction >= 10_000_000_000) {
        return true;
      };
      false;
    };

    /*  
      (FIX) SPECIAL MISSION : change the time of completion for all the missions completed during the month of August!
    */
    func _mission19(caller : Principal) : async Bool {
      var modified = false;
      let now = Time.now();
      let completed_missions = _getCompletedMissions(caller);
      let r = Buffer.Buffer<(Nat, Time.Time)>(0);
      for ((id, time) in completed_missions.vals()) {
        if (time > BEGINNING_TIME_AUGUST and time < ENDING_TIME_AUGUST) {
          r.add((id, now));
          modified := true;
        } else {
          r.add((id, time));
        };
      };
      if (modified) {
        _setCompletedMissions(caller, r.toArray());
      };
      modified;
    };

    func _getCompletedMissions(p : Principal) : [(Nat, Time.Time)] {
      switch (completedMissions.get(p)) {
        case (null) {
          return [];
        };
        case (?some) {
          return some;
        };
      };
    };

    func _setCompletedMissions(p : Principal, completed : [(Nat, Time.Time)]) : () {
      completedMissions.put(p, completed);
    };

    let handlers : [(Nat, (caller : Principal) -> async Bool)] = [
      (0, _mission0),
      (1, _mission1),
      // 2 is handled manually
      (4, _mission4),
      (5, _mission5),
      (6, _mission6),
      (7, _mission7),
      (8, _mission8),
      (9, _mission9),
      // 10 - 13 have been deleted
      (14, _mission14),
      (15, _mission15),
      (16, _mission16),
      (17, _mission17),
      // 18 is handled manually
      (19, _mission19),
    ];

  };

};
