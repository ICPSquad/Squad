import Buffer "mo:base/Buffer";
import Hash "mo:base/Hash";
import Int "mo:base/Int";
import Iter "mo:base/Iter";
import Principal "mo:base/Principal";
import Text "mo:base/Text";
import Time "mo:base/Time";
import TrieMap "mo:base/TrieMap";

import DateModule "mo:canistergeek/dateModule";

import Types "types";
module {
    /////////////
    // Types ///
    ///////////

    public type UpgradeData = Types.UpgradeData;
    public type Dependencies = Types.Dependencies;
    public type StyleScore = Types.StyleScore;

    type Date = Types.Date;
    type TokenIdentifier = Types.TokenIdentifier;

    /////////////////
    // Utilities ///
    ///////////////

    func _dateEqual(date1: Date, date2: Date) : Bool {
        return date1.0 == date2.0 and date1.1 == date2.1 and date1.2 == date2.2;
    };

    func _dateHash(date: Date) : Hash.Hash {
        return Int.hash(date.0 * 100 + date.1 * 10 + date.2);
    };

    public func customEqual(a : (Date, TokenIdentifier), b : (Date, TokenIdentifier)) : Bool {
        return _dateEqual(a.0, b.0) and Text.equal(a.1, b.1);
    };

    public func customHash(a : (Date, TokenIdentifier)) : Hash.Hash {
        return _dateHash(a.0) ^ Text.hash(a.1);
    };

    /////////////
    // State ///
    ////////////

    public class Factory(dependencies : Types.Dependencies)  {
        
        let style_score_daily : TrieMap.TrieMap<(Date, TokenIdentifier), StyleScore> = TrieMap.TrieMap<(Date, TokenIdentifier), StyleScore>(customEqual, customHash);

        let AVATAR_ACTOR = actor(Principal.toText(dependencies.cid_avatar)) : actor {
            get_style_score : shared () -> async [(TokenIdentifier, StyleScore)];
            tokens_ids : shared () -> async [TokenIdentifier];
        };

        let _Logs = dependencies._Logs;


        public func preupgrade() : UpgradeData {
            return ({
                style_score_daily = Iter.toArray(style_score_daily.entries());
            });
        };

        public func postupgrade(ud : ?UpgradeData) : () {
            switch(ud){
                case(null){};
                case(? ud){
                    for((date, score) in ud.style_score_daily.vals()){
                        style_score_daily.put(date, score);
                    };
                };
            };
        };

        /* Query the avatar canister and get the latest screenshot of the style score. Archived the scores into the daily_style_score archive. 
            @Cronic : At least once per day. 
            @Verif : If the screenshot has already been taken for the current day; will log a message and doesn't update the database.
        */
        public func updateScores() : async () {
            let latest_style_score = await AVATAR_ACTOR.get_style_score();
            switch(DateModule.Date.nowToDatePartsISO8601()){
                case(null) assert(false);
                case(? date){
                    for((token, score) in latest_style_score.vals()){
                        style_score_daily.put((date, token), score);
                    };
                };
            };
        };

        public func getScore(tokenId : TokenIdentifier, dates : [Date]) : ?StyleScore {
            return ?_getSumStyleScore(dates, tokenId);
        };

        /////////////////
        // Utilities ///
        ///////////////

        /*  
            Sum all the styles scores for the given dates for the specified tokenIdentifier. 
         */
        func _getSumStyleScore(dates : [Date], token : TokenIdentifier) : Nat {
            var sum : Nat = 0;
            for(date in dates.vals()){
                switch(style_score_daily.get(date, token)){
                    case(null) {};
                    case(? score) {
                        sum += score;
                    };
                };
            };
            return sum;
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


};