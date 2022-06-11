import Array "mo:base/Array";
import Blob "mo:base/Blob";
import Hash "mo:base/Hash";
import IC "mo:base/ExperimentalInternetComputer";
import Iter "mo:base/Iter";
import Nat "mo:base/Nat";
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
    public type Reward = Types.Reward;

    public class Center(dependencies : Types.Dependencies) {
 
        ////////////
        // State //
        //////////

        let _Admins = dependencies._Admins;
        let _Logs = dependencies._Logs;
        let _Cap = dependencies._Cap;

        let false_encoded : [Nat8] =  [68, 73, 68, 76, 0 , 1, 126, 0]; 
        let true_encoded : [Nat8] = [68, 73, 68, 76, 0 , 1, 126, 1];

        var next_mission_id : Nat = 0;
        let missions : TrieMap.TrieMap<Nat, Mission> = TrieMap.TrieMap<Nat, Mission>(Nat.equal, Hash.hash);
        let winners : TrieMap.TrieMap<Nat, [Principal]> = TrieMap.TrieMap<Nat, [Principal]>(Nat.equal, Hash.hash);
        let scores : TrieMap.TrieMap<Principal,Nat> = TrieMap.TrieMap<Principal,Nat>(Principal.equal, Principal.hash);

        /* 
            Keep track for each user of it's completed mission by keeping a record of the time they completed it.  
            Also used to compute the scores for a specific round.
        */
        let completedMissions : TrieMap.TrieMap<Principal, [(Nat, Time.Time)]> = TrieMap.TrieMap<Principal, [(Nat, Time.Time)]>(Principal.equal, Principal.hash);

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
                    for((id, list) in ud.winners.vals()){
                        winners.put(id, list);
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
                rewards = mission.rewards;
            };
            missions.put(id, mission_complete);
            next_mission_id := next_mission_id + 1;
            return #ok(id);
        };

        public func startMission(id : Nat) : Result.Result<(), Text> {
            switch(missions.get(id)){
                case(null) {
                    _Logs.logMessage("Mission not found for id : " # Nat.toText(id));
                    return #err("Mission not found for id :" # Nat.toText(id));
                };
                case(? mission){
                    let new_mission = {
                        id = mission.id;
                        creator = mission.creator;
                        title = mission.title;
                        description = mission.description;
                        url_icon = mission.url_icon;
                        created_at = mission.created_at;
                        started_at = ?Time.now();
                        ended_at = null;
                        restricted = mission.restricted;
                        validation = mission.validation;
                        status = #Running;
                        rewards = mission.rewards;
                    };
                    _Logs.logMessage("Mission started : " # Nat.toText(id));
                    missions.put(id, new_mission);
                    return #ok();
                };
            };
        };

        public func verifyMission(id : Nat, caller : Principal, args : Blob) : async Result.Result<Bool, Text> {
            switch(missions.get(id)){
                case(null){
                    _Logs.logMessage("Mission not found for id : " # Nat.toText(id));
                    return #err("Mission not found for id :" # Nat.toText(id));
                };
                case(? mission){
                    if(mission.status != #Running){
                        _Logs.logMessage("Mission not running for id : " # Nat.toText(id));
                        return #err("Mission not running for id :" # Nat.toText(id));
                    };
                    switch(await _validate(mission, caller, args)){
                        case(#err(e)) {
                            _Logs.logMessage("verifyMission :: ERR :: " # e);
                            return #err(e);
                        };
                        case(#ok(bool)){
                            if(bool){
                                if(_isWinner(id, caller)){
                                    return #err("You have already verified this mission");
                                };
                                _addToWinner(id, caller);
                                for(reward in mission.rewards.vals()){
                                    _distributeReward(caller,reward);
                                };
                            };
                            return #ok(bool);
                        };
                    };
                };
            };
        };

        public func deleteMission(id : Nat) : Result.Result<(), Text> {
            switch(missions.get(id)){
                case(null) {
                    _Logs.logMessage("Mission not found for id : " # Nat.toText(id));
                    return #err("Mission not found for id : " # Nat.toText(id));
                };
                case(? mission){
                    missions.delete(id);
                    return #ok();
                };
            };
        };


        public func getEngagementScore(p : Principal, start : Time.Time, end : Time.Time) : Nat {
            switch(completedMissions.get(p)){
                case(null) return 0;
                case(? completed){
                    var count : Nat = 0;
                    for((id, time) in completed.vals()){
                        if(time >= start and time <= end){
                            count += _scoreMission(id);
                        };
                    };
                    return count;
                };
            };
        };

        public func resetScore() : () {
            for((principal, _) in scores.entries()){
                scores.put(principal, 0);
            };
        };

        public func getMissions() : [Mission] {
            return Iter.toArray(missions.vals());
        };

        //////////////
        // Helpers //
        ////////////

        func _validate(mission : Mission, caller : Principal, args : Blob) : async Result.Result<Bool, Text> {
            switch(mission.validation){
                case(#Custom(info)){
                    let result = await IC.call(info.canister, info.method_name, to_candid(args));
                    if(Blob.equal(result, Blob.fromArray(true_encoded))){
                        return return #ok(true)
                    } else if(Blob.equal(result, Blob.fromArray(false_encoded))){
                        return return#ok(false)
                    } else {
                        return #err("Invalid result from canister");
                    };

                };
                case (#Automatic(info)) {
                    let validator = actor(Principal.toText(info.canister)) : actor {
                        verify_mission : shared (id : Nat, caller : Principal) -> async Bool;
                    };
                    try {
                        let result = await validator.verify_mission(mission.id, caller);
                        if(result) {
                            return #ok(true);
                        } else {
                            return #ok(false);
                        };
                    } catch e {
                        return #err("Invalid result from canister");
                    }
                };
                case(#Manual(mods)){
                    switch(winners.get(mission.id)){
                        case(null){
                            return #err("No list of winners found for this mission");
                        };
                        case(? list){
                            if(_isWinner(mission.id, caller)){
                                return #ok(true);
                            } else {
                                return #ok(false);
                            };
                        };
                    };
                };
                case(#Internal){
                    for((id, handler) in handlers.vals()){
                        if(id == mission.id){
                            let result = await handler(caller);
                            if(result) {
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

        func _isWinner(id : Nat, p : Principal) : Bool {
            switch(winners.get(id)){
                case(null){
                    return false;
                };
                case(? winners){
                    return(Option.isSome(Array.find<Principal>(winners,func(x) { p == x })))
                };
            };
           
        };  

        func _addToWinner(id : Nat, p : Principal) : () {
            switch(winners.get(id)){
                case(null){
                    let list = [p];
                    winners.put(id, list);
                };
                case(? list){
                    let new_list = Array.append<Principal>(list, [p]);
                    winners.put(id, new_list);
                };
            };
        };

        func _distributeReward(p : Principal, reward : Reward) : () {
            switch(reward){
                case(#Points(points)){
                    _addPoints(p, points);
                };
                case _ {
                    assert(false);
                };
            };
        };

        func _addPoints(p : Principal, points : Nat) : () {
            switch(scores.get(p)){
                case(null) {
                    scores.put(p, points);
                };
                case(? score){
                    scores.put(p, score + points);
                };
            };
        };

        func _scoreMission(id : Nat) : Nat {
            switch(missions.get(id)) {
                case(null) {
                    _Logs.logMessage("Mission not found for id : " # Nat.toText(id));
                    return 0;
                };
                case(? mission){
                    _getPointRewardFromMission(mission);
                };
            };
        };

        func _getPointRewardFromMission(mission : Mission) : Nat {
            for(reward in mission.rewards.vals()){
                switch(reward){
                    case(#Points(points)){
                        return points;
                    };
                    case _ {};
                }
            };
            return 0;
        };


        //////////////
        // Handler //
        /////////////

        func _mission2(caller : Principal) : async Bool {
            let number_mint = await _Cap.numberMint(caller, null);
            if(number_mint >= 1){
                return true;
            };
            return false;
        };

        func _mission3(caller : Principal) : async Bool {
            let number_mint = await _Cap.numberMint(caller, null);
            if(number_mint >= 3){
                return true;
            };
            return false;
        };

        func _mission4(caller : Principal) : async Bool {
            let number_mint = await _Cap.numberMint(caller, null);
            if(number_mint >= 1){
                return true;
            };
            return false;
        };

        func _mission5(caller : Principal) : async Bool {
            let a = await _Cap.numberMint(caller, ?"Astro-helmet");
            let b = await _Cap.numberMint(caller, ?"Astro-suit");
            if(a >= 1 and b >= 1){
                return true;
            };
            return false;
        };

        func _mission6(caller : Principal) : async Bool {
            let number_burn = await _Cap.numberBurn(caller, null);
            if(number_burn >= 1){
                return true;
            };
            return false;
        };

        func _mission7(caller : Principal) : async Bool {
            let number_burn = await _Cap.numberBurn(caller, null);
            if(number_burn >= 3){
                return true;
            };
            return false;
        };

        func _mission8(caller : Principal) : async Bool {
            let number_burn = await _Cap.numberBurn(caller, null);
            if(number_burn >= 10){
                return true;
            };
            return false;
        };
        /* 
            Might takes a long time to resolve 
            Wen Promise.all in Motoko ?
        */
        func _mission9(caller : Principal) : async Bool {
            let a = await _Cap.numberMint(caller, ?"Cronic-eyepatch");
            if(a >= 1){
                return true;
            };
            let b = await _Cap.numberMint(caller, ?"Cronic-tshirt");
            if(b >= 1){
                return true;
            };
            let c = await _Cap.numberMint(caller, ?"Cronic-hypnose");
            if(c >= 1){
                return true;
            };
            let d = await _Cap.numberMint(caller, ?"Cronic-wallpaper");
            if(d >= 1){
                return true;
            };
            return false;
        };

        func _mission10(caller : Principal) : async Bool {
            let a = await _Cap.numberMint(caller, ?"Punk-mask");
            if(a >= 1){
                return true;
            };
            let b = await _Cap.numberMint(caller, ?"Punk-glasses");
            if(b >= 1){
                return true;
            };
            return false;
        };

        /*
            Associate id with the name of the function that will process the verification of the mission.
        */
        let handlers : [(Nat, (caller : Principal) -> async Bool)] = [
            (2, _mission2),
            (3, _mission3),
            (4, _mission4),
            (5, _mission5),
            (6, _mission6),
            (7, _mission7),
            (8, _mission8),
            (9, _mission9),
            (10, _mission10)
        ];

    
    };
};