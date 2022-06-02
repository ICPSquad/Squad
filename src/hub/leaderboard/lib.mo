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

import Date "mo:canistergeek/dateModule";

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
        };
        
        let _Logs = dependencies._Logs;
        let _Style = dependencies._Style;
        let _Mission = dependencies._Mission;

        public func preupgrade(ud : ?UpgradeData) : () {
            switch(ud){
                case(null){};
                case(? ud){
                    for((id, round) in ud.rounds.vals()){
                        _rounds.put(id, round);
                    };
                };
            };
        };

        public func postupgrade() : UpgradeData {
            return {
                rounds = Iter.toArray(_rounds.entries());
            }
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

        /////////////////
        // UTILITIES ///
        ////////////////

        func _getTotalScore(style : ?StyleScore, engage : ?EngagementScore) : Nat {
            var total = 0;
            switch(style) {
                case(null) {};
                case(? value) {
                    total := total + value;
                };
            };
            switch(engage){
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
            for((p, name, tokenIdentifier)in latest_infos.vals()){
                switch(tokenIdentifier){
                    case(null) {
                        let style_score = null;
                        let engagement_score = _Mission.getEngagementScore(p, round.start_date, Time.now());
                        let total_score = _getTotalScore(style_score, ?engagement_score);
                        buffer.add((p, name, tokenIdentifier, style_score, ?engagement_score, total_score));
                    };
                    case(? token) {
                        let style_score = _Style.getScore(token);
                        let engagement_score =  _Mission.getEngagementScore(p, round.start_date, Time.now());
                        let total_score = _getTotalScore(style_score, ?engagement_score);
                        buffer.add((p, name, tokenIdentifier, style_score, ?engagement_score, total_score));
                    };
                };
            };
            // Order the Leaderboard by total score.
            let leaderboard = buffer.toArray();
            let leaderboard_sorted = Array.sort<(Principal, ?Name, ?TokenIdentifier, ?StyleScore, ?EngagementScore, TotalScore)>(leaderboard, func(a,b) {Nat.compare(a.5, b.5)});
            return ({
                id = round.id;
                start_date = round.start_date;
                end_date = round.end_date;
                leaderboard = ?leaderboard_sorted;
            })
        };
    };
};