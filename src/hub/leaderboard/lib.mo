import Array "mo:base/Array";
import Buffer "mo:base/Buffer";
import Hash "mo:base/Hash";
import Int "mo:base/Int";
import Iter "mo:base/Iter";
import Nat "mo:base/Nat";
import Principal "mo:base/Principal";
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

        let _leaderboards : TrieMap.TrieMap<Date,Leaderboard> = TrieMap.TrieMap<Date,Leaderboard>(dateEqual, dateHash);
        
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
                    for((date, board) in ud.leaderboards.vals()){
                        _leaderboards.put(date, board);
                    };
                };
            };
        };

        public func postupgrade() : UpgradeData {
            return {
                leaderboards = Iter.toArray(_leaderboards.entries());
            }
        };
        
        /* 
            Query the latest infos from the avatar canister and query the scores from each individual modules to update the leaderboard
            @Cronic : Called once per hour.
        */        
        public func updateLeaderboard() : async () {
            let latest_infos : [(Principal, ?Name, ?TokenIdentifier)]= await AVATAR_ACTOR.get_infos_leaderboard();
            let date_now = switch(Date.Date.nowToDatePartsISO8601()){
                case(null) {
                    assert(false);
                    (0,0,0);
                };
                case(? date){
                    date;
                };
            };
            var buffer : Buffer.Buffer<(Principal, ?Name, ?TokenIdentifier, ?StyleScore, ?EngagementScore, TotalScore)> = Buffer.Buffer<(Principal, ?Name, ?TokenIdentifier, ?StyleScore, ?EngagementScore, TotalScore)>(0);
            for((p, name, tokenIdentifier)in latest_infos.vals()){
                switch(tokenIdentifier){
                    case(null) {
                        let style_score = null;
                        let engagement_score = _Mission.getEngagementScore(p);
                        let total_score = _getTotalScore(style_score, ?engagement_score);
                        buffer.add((p, name, tokenIdentifier, style_score, ?engagement_score, total_score));
                    };
                    case(? token) {
                        let style_score = _Style.getScore(token);
                        let engagement_score =  _Mission.getEngagementScore(p);
                        let total_score = _getTotalScore(style_score, ?engagement_score);
                        buffer.add((p, name, tokenIdentifier, style_score, ?engagement_score, total_score));
                    };
                };
            };
            // Order the Leaderboard by total score.
            let leaderboard = buffer.toArray();
            let leaderboard_sorted = Array.sort<(Principal, ?Name, ?TokenIdentifier, ?StyleScore, ?EngagementScore, TotalScore)>(leaderboard, func(a,b) {Nat.compare(a.5, b.5)});
            _leaderboards.put(date_now, leaderboard_sorted);
            _Logs.logMessage("Leaderboard has been updated");
        };

        public func getCurrentLeaderboard() : ?Leaderboard {
            let current_date = switch(Date.Date.nowToDatePartsISO8601()){
                case(null) return null;
                case(? date) getLeaderboard(date);
            }
        };

        public func getLeaderboard(date : Date) : ?Leaderboard {
            switch(_leaderboards.get(date)){
                case(null){
                    return null;
                };
                case(? board){
                    return ?board;
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
    };
};