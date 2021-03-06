import Array "mo:base/Array";
import Buffer "mo:base/Buffer";
import Hash "mo:base/Hash";
import Int "mo:base/Int";
import Iter "mo:base/Iter";
import Nat "mo:base/Nat";
import Option "mo:base/Option";
import Principal "mo:base/Principal";
import Result "mo:base/Result";
import Time "mo:base/Time";
import TrieMap "mo:base/TrieMap";

import DateModule "mo:canistergeek/dateModule";

import Types "types";
module {

    /////////////////
    // Utilities ///
    ///////////////

    public func dateEqual(date1: Date, date2: Date) : Bool {
        return date1.0 == date2.0 and date1.1 == date2.1 and date1.2 == date2.2;
    };

    public func dateHash(date: Date) : Hash.Hash {
        return Int.hash(date.0 * 100 + date.1 * 10 + date.2);
    };

    /////////////
    // TYPES ///
    ///////////

    public type Leaderboard = Types.Leaderboard;
    public type Round = Types.Round;
    public type UpgradeData = Types.UpgradeData;
    public type StyleScore = Types.StyleScore;
    public type EngagementScore = Types.EngagementScore;
    public type TotalScore = Types.TotalScore;

    type Date = Types.Date; //(Year, Month, Day)
    type Time = Time.Time;
    type TokenIdentifier = Text;
    type AccountIdentifier = Text;
    type Name = Text;
    type Message = Text;

    public class Factory (dependencies : Types.Dependencies) {

        ////////////
        // State //
        //////////

        var current_round_id : ?Nat = null;
        var next_round_id : Nat = 0;

        let _rounds : TrieMap.TrieMap<Nat, Round> = TrieMap.TrieMap<Nat, Round>(Nat.equal, Hash.hash);
        
        let AVATAR_ACTOR = actor(Principal.toText(dependencies.cid_avatar)) : actor {
            get_infos_leaderboard : shared () -> async [(Principal, ?Name, ?TokenIdentifier)];
            get_infos_holders : shared () -> async [(Principal, ?AccountIdentifier, ?Text, ?Text, ?TokenIdentifier)];
        };
        
        let _Logs = dependencies._Logs;
        let _Style = dependencies._Style;
        let _Mission = dependencies._Mission;
        let _Cap = dependencies._Cap;


        public func preupgrade() : UpgradeData {
            return ({
                rounds = Iter.toArray(_rounds.entries());
                next_round_id;
                current_round_id;
            });
        };

        public func postupgrade(ud : ?UpgradeData) : () {
            switch(ud){
                case(null){};
                case(? ud){
                    for((id, round) in ud.rounds.vals()){
                        _rounds.put(id, round);
                    };
                    current_round_id := ud.current_round_id;
                    next_round_id := ud.next_round_id;
                };
            };
        };
        //////////
        // API //
        ////////

        /* 
            Start a round and populate the leaderboards with 0 score for all players.
            @ok : Returns the id of the round.
            @err : Returns an error message.
         */
        public func startRound() : async Result.Result<Nat, Text> {
            if(Option.isSome(current_round_id)){
                return #err("Round already started. Please stop it first.");
            };
            let round_id = next_round_id;
            current_round_id := ?round_id;
            next_round_id += 1;
            // Commit point
            let latest : [(Principal, ?Name, ?TokenIdentifier)] = await AVATAR_ACTOR.get_infos_leaderboard();
            var l : Buffer.Buffer<(Principal, ?Name, ?TokenIdentifier, ?StyleScore, ?EngagementScore, TotalScore)> = Buffer.Buffer<(Principal, ?Name, ?TokenIdentifier, ?StyleScore, ?EngagementScore, TotalScore)>(0);
            for((principal, name, token) in latest.vals()){
                l.add((principal, name, token, null, null, 0));
            };
            let leaderboard = l.toArray();
            let round : Round = {
                id = round_id;
                start_date = Time.now();
                end_date = null;
                leaderboard = ?leaderboard;
            };
            _rounds.put(round_id, round);
            return #ok(round_id);
        };

        /* 
            Update the optional current round and its leaderboard.
            @err : Returns an error message.
         */
        public func updateCurrentRound() : async Result.Result<(), Text> {
            switch(current_round_id){
                case(null){
                    return #err("No round id is currently set");
                };
                case(? id){
                    switch(_rounds.get(id)){
                        case(null){
                            _Logs.logMessage("CRITICAL ERR :: No round found for current round id " # Nat.toText(id));
                            return #err("No round found for the currently set round id");
                        };
                        case(? round){
                            let new_round = await _getUpdatedRound(round);
                            _rounds.put(round.id, new_round);
                            _Logs.logMessage("Round " # Nat.toText(round.id) # " updated");
                            return #ok();
                        };
                    };
                };
            };
        };


        /* 
            Stop the optional current round.
            @ok : Returns the id of the round.
            @err : Returns an error message.
         */
        public func stopRound() : async Result.Result<Nat, Text> {
            switch(current_round_id){
                case(null){
                    return #err("No round id is currently set");
                };
                 case(? id){
                    switch(_rounds.get(id)){
                        case(null){
                            _Logs.logMessage("CRITICAL ERR :: No round found for current round id " # Nat.toText(id));
                            return #err("No round found for the currently set round id");
                        };
                        case(? round){
                            let new_round : Round = {
                                id = round.id;
                                start_date = round.start_date;
                                end_date = ?Time.now();
                                leaderboard = round.leaderboard;
                            };
                            _rounds.put(round.id, new_round);
                            current_round_id := null;
                            _Logs.logMessage("Round " # Nat.toText(round.id) # " stopped");
                            return #ok(id);
                        };
                    };
                };
            };
        };

        public func getCurrentLeaderboard() : ?Leaderboard {
            switch(current_round_id){
                case(null){
                    return null;
                };
                case(? id){
                    switch(_rounds.get(id)){
                        case(null){
                            _Logs.logMessage("CRITICAL ERR :: No round found for current round id " # Nat.toText(id));
                            return null;
                        };
                        case(? round){
                            return round.leaderboard;
                        };
                    };
                };
            };
        };

        public func getCurrentRound() : ?Round {
            switch(current_round_id){
                case(null){
                    return null;
                };
                case(? id){
                    switch(_rounds.get(id)){
                        case(null){
                            _Logs.logMessage("CRITICAL ERR :: No round found for current round id " # Nat.toText(id));
                            return null;
                        };
                        case(? round){
                            return ?round;
                        };
                    };
                };
            };
        };

        /* 
            Needed to communicate a list of Principal to the CAP module.
         */
        public func getAllPrincipals() : async [Principal] {
            let infos = await AVATAR_ACTOR.get_infos_holders();
            return Array.map<(Principal, ?AccountIdentifier, ?Text, ?Text, ?TokenIdentifier), Principal>(infos, func(x) {x.0});
        };

        ////////////////
        // Temporary ///
        ////////////////

        let ACCESSORY_ACTOR = actor(Principal.toText(dependencies.cid_accessory)) : actor {
          get_accessories_holders : shared () -> async [(AccountIdentifier, Nat)];
        };

        public func getBestHolders() : async [(AccountIdentifier, Nat, ?Principal, ?Text, ?Text, ?TokenIdentifier)] {
            let stats : [(AccountIdentifier, Nat)] = await ACCESSORY_ACTOR.get_accessories_holders();
            let infos_opt : [(Principal, ?AccountIdentifier, ?Text, ?Text, ?TokenIdentifier)] = await AVATAR_ACTOR.get_infos_holders();
            let infos = Array.map<(Principal, ?AccountIdentifier, ?Text, ?Text, ?TokenIdentifier), (Principal, AccountIdentifier, Text, Text, TokenIdentifier)>(infos_opt, func(x) {(
                return((x.0, Option.get<Text>(x.1, ""), Option.get<Text>(x.2, ""),  Option.get<Text>(x.3, ""),  Option.get<Text>(x.4, "")))
            )});
            let r : Buffer.Buffer<(AccountIdentifier, Nat, ?Principal, ?Text, ?Text, ?TokenIdentifier)> = Buffer.Buffer<(AccountIdentifier, Nat, ?Principal, ?Text, ?Text, ?TokenIdentifier)>(0);
            for((account, nb) in stats.vals()){
                let infos_opt = Array.find<(Principal, AccountIdentifier, Text, Text, Text)>(infos, func(x) {return(x.1 == account)});
                switch(infos_opt){
                    case(? info){
                        r.add((account, nb, ?info.0, ?info.2, ?info.3, ?info.4));
                    };
                    case(null){
                        r.add((account, nb, null, null, null, null));
                    };
                };
            };
            // Sort by number of accessories
            return(Array.sort<(AccountIdentifier, Nat, ?Principal, ?Text, ?Text, ?TokenIdentifier)>(r.toArray(), func(x, y) {
                return(Nat.compare(x.1, y.1));
            }));
        };

        /////////////////
        // UTILITIES ///
        ////////////////

        func _getTotalScore(style : ?StyleScore, engage : Nat) : Nat {
            var total = 0 + engage;
            switch(style) {
                case(null) {};
                case(? value) {
                    total := total + value;
                };
            };
            total;
        };
        
        func _getUpdatedRound(round : Round) : async Round {
            let latest_infos : [(Principal, ?Name, ?TokenIdentifier)]= await AVATAR_ACTOR.get_infos_leaderboard();
            var buffer : Buffer.Buffer<(Principal, ?Name, ?TokenIdentifier, ?StyleScore, ?EngagementScore, TotalScore)> = Buffer.Buffer<(Principal, ?Name, ?TokenIdentifier, ?StyleScore, ?EngagementScore, TotalScore)>(0);
            let end = Time.now();
            let start = round.start_date;
            let dates = _getDatesBetween(start, end);
            for((p, name, tokenIdentifier)in latest_infos.vals()){
                switch(tokenIdentifier){
                    case(null) {
                        let style_score = null;
                        let engagement_score = _Cap.getScore(p, dates) + _Mission.getMissionScore(p, start, end);
                        let total_score = _getTotalScore(style_score, engagement_score);
                        buffer.add((p, name, tokenIdentifier, style_score, ?engagement_score, total_score));
                    };
                    case(? token) {
                        let style_score = _Style.getScore(token, dates);
                        let engagement_score = _Cap.getScore(p, dates) + _Mission.getMissionScore(p, start, end);
                        let total_score = _getTotalScore(style_score, engagement_score);
                        buffer.add((p, name, tokenIdentifier, style_score, ?engagement_score, total_score));
                    };
                };
            };
            // Order the Leaderboard by total score.
            let leaderboard = buffer.toArray();
            let leaderboard_sorted = Array.sort<(Principal, ?Name, ?TokenIdentifier, ?StyleScore, ?EngagementScore, TotalScore)>(leaderboard, func(a,b) {Nat.compare(b.5, a.5)});
            return ({
                id = round.id;
                start_date = round.start_date;
                end_date = round.end_date;
                leaderboard = ?leaderboard_sorted;
            })
        };
    };

        /*
            Takes T1 & T2 and returns an array of dates between T1 and T2. 
         */
        func _getDatesBetween(start : Time.Time, end : Time.Time) : [Date] {
            if(end < start){
                assert(false);
                return [];
            };
            var buffer : Buffer.Buffer<Date> = Buffer.Buffer<Date>(0);
            let date_start = switch(DateModule.Date.toDatePartsISO8601(start)){
                case(null) {
                    assert(false);
                    (0, 0, 0);
                };
                case(? date_parts) {
                    date_parts;
                };
            };
            buffer.add(date_start);
            let ONE_DAY_NANOS : Nat = 86_400_000_000_000;
            var next_day = start + ONE_DAY_NANOS;
            var count = 0;
            while(next_day <= end and count < 100){
                let date = switch(DateModule.Date.toDatePartsISO8601(next_day)){
                    case(null) {
                        assert(false);
                        (0, 0, 0);
                    };
                    case(? date_parts) {
                        date_parts;
                    };
                };
                buffer.add(date);
                next_day += ONE_DAY_NANOS;
                count += 1;
            };
            return buffer.toArray();
        };
};