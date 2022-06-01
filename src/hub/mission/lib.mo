import Array "mo:base/Array";
import Blob "mo:base/Blob";
import Hash "mo:base/Hash";
import IC "mo:base/ExperimentalInternetComputer";
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

    public type Mission = Types.Mission;
    public type CreateMission = Types.CreateMission;

    public class Center(dependencies : Types.Dependencies) {
 
        ////////////
        // State //
        //////////

        let _Admins = dependencies._Admins;
        let _Logs = dependencies._Logs;

        let false_encoded : [Nat8] =  [68, 73, 68, 76, 0 , 1, 126, 0]; 
        let true_encoded : [Nat8] = [68, 73, 68, 76, 0 , 1, 126, 1];

        var next_mission_id : Nat = 0;
        let missions : TrieMap.TrieMap<Nat, Mission> = TrieMap.TrieMap<Nat, Mission>(Nat.equal, Hash.hash);
        let winners : TrieMap.TrieMap<Nat, [Principal]> = TrieMap.TrieMap<Nat, [Principal]>(Nat.equal, Hash.hash);


        /*  public func preupgrade() :  */
        /* public func postupgrade() : */


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
                            };
                            return #ok(bool);
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
                            if(_isWinner(mission.id, caller)){
                                return #ok(true);
                            } else {
                                return #ok(false);
                            };
                        };
                    };
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
    };
};