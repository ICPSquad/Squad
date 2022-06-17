import Array "mo:base/Array";
import Blob "mo:base/Blob";
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
            if(_isThereAWinner(id)){
                return #err("Cannot delete a mission that has registered winners.");
            };
            switch(missions.get(id)){
                case(null) {
                    return #err("Mission not found for id : " # Nat.toText(id));
                };
                case(? mission){
                    missions.delete(id);
                    return #ok();
                };
            };
        };

        public func getMissionScore(p : Principal, start : Time.Time, end : Time.Time) : Nat {
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

        public func getMissions() : [Mission] {
            return Iter.toArray(missions.vals());
        };

        // public func getRunningMission() : [Mission] {
        //     return Array.filter<Mission>(Iter.toArray(missions.vals(), func (x : Mission) {x.status == #Running}));
        // };

        public func myCompletedMissions(caller : Principal) : [(Nat, Time.Time)] {
            switch(completedMissions.get(caller)){
                case(null) return [];
                case(? completed){
                    return completed;
                };
            };
        };


        /* 
            Manually add a list of winners for missions that are externally validated.
         */

         public func manuallyAddWinners(id : Nat, p_winners : [Principal]) : Result.Result<(), Text> {
            switch(missions.get(id)){
                case(null) {
                    return #err("Mission not found for id : " # Nat.toText(id));
                };
                case(? mission){
                    switch(mission.validation){
                        //TODO : Add support for external moderators responsible for a specific mission
                        case(#Manual(mods)){
                            winners.put(id, p_winners);
                            return #ok();
                        };
                        case(_) {
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
                            switch(Array.find<Principal>(list, func(x : Principal) {x == caller})){
                                case(null) {
                                    return #ok(false);
                                };
                                case(? _){
                                    completedMissions.put(caller, [(mission.id, Time.now())]);
                                    return #ok(true);
                                };
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

        /* 
            Returns a boolean indicating if the principal is among the winners of a mission.
         */
        func _isWinner(id : Nat, p : Principal) : Bool {
            switch(winners.get(id)){
                case(null) return false;
                case(? list){
                    switch(Array.find<Principal>(list, func(x : Principal) {x == p})){
                        case(null) return false;
                        case(? some) return true;
                    };
                };
            };
        };  
        
        /* 
            Returns a boolean indicating if a principal has already completed a mission. Not the same as previous method if the mission is manually provided a list of winners, the user still need to validate his participation.
         */
        func _hasCompletedMission(id : Nat, p : Principal) : Bool {
            switch(completedMissions.get(p)){
                case(null) return false;
                case(? completed){
                    for((mission_id, time) in completed.vals()){
                        if(mission_id == id){
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
            switch(missions.get(id)){
                case(null) {
                    return;
                };
                case(? mission){
                    switch(mission.validation){
                        // In the case of a manual validation, we only need to add the mission to the list of completed missions.
                        case(#Manual(mods)){
                            _addToCompletedMission(id, p);
                        };
                        // Otherwise we need to add the mission to the list of completed missions & add the user to the list of winners.
                        case(_) {
                            _addToWinners(id, p);
                            _addToCompletedMission(id, p);
                        };
                    };
                };
            };
        };

        func _addToWinners(id : Nat, p : Principal) : () {
            switch(winners.get(id)){
                case(null){
                    winners.put(id, [p]);
                };
                case(? list){
                    winners.put(id, Array.append<Principal>(list, [p]));
                };
            };
        };

        func _addToCompletedMission(id : Nat, p : Principal) : () {
            switch(completedMissions.get(p)){
                case(null){
                    completedMissions.put(p, [(id, Time.now())]);
                };
                case(? list){
                    completedMissions.put(p, Array.append<(Nat, Time.Time)>(list, [(id, Time.now())]));
                };
            };
        };  

        func _isThereAWinner(id : Nat) : Bool {
            switch(winners.get(id)){
                case(null) return false;
                case(? list){
                    if(list.size() > 0){
                        return true;
                    };
                    return false;
                };
            };
        };

        func _scoreMission(id : Nat) : Nat {
            switch(missions.get(id)){
                case(null) return 0;
                case(? mission){
                    mission.points;
                };
            };
        };

        //////////////
        // Handler //
        /////////////
        /* 
            Returns a boolean indicating if the caller has minted at least one branded Cronic accessory.
            Might takes a long time to resolve. Wen Promise.all in Motoko ?
        */
        func _mission0(caller : Principal) : async Bool {
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

        func _mission1(caller : Principal) : async Bool {
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

        func _mission4(caller : Principal) : async Bool {
            let number_mint = await _Cap.numberMint(caller, null);
            if(number_mint >= 1){
                return true;
            };
            return false;
        };

        func _mission5(caller : Principal) : async Bool {
            let number_mint = await _Cap.numberMint(caller, null);
            if(number_mint >= 3){
                return true;
            };
            return false;
        };

        func _mission6(caller : Principal) : async Bool {
            let number_mint = await _Cap.numberMint(caller, null);
            if(number_mint >= 1){
                return true;
            };
            return false;
        };

        func _mission8(caller : Principal) : async Bool {
            let a = await _Cap.numberMint(caller, ?"Astro-helmet");
            let b = await _Cap.numberMint(caller, ?"Astro-suit");
            if(a >= 1 and b >= 1){
                return true;
            };
            return false;
        };

        // func _mission6(caller : Principal) : async Bool {
        //     let number_burn = await _Cap.numberBurn(caller, null);
        //     if(number_burn >= 1){
        //         return true;
        //     };
        //     return false;
        // };

        // func _mission7(caller : Principal) : async Bool {
        //     let number_burn = await _Cap.numberBurn(caller, null);
        //     if(number_burn >= 3){
        //         return true;
        //     };
        //     return false;
        // };

        // func _mission8(caller : Principal) : async Bool {
        //     let number_burn = await _Cap.numberBurn(caller, null);
        //     if(number_burn >= 10){
        //         return true;
        //     };
        //     return false;
        // };


        /*
            Associate a mission Id with the function that will process to the verification.
        */
        let handlers : [(Nat, (caller : Principal) -> async Bool)] = [
            (0, _mission0),
            (1, _mission1),
        ];

    
    };
};