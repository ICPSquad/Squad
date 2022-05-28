import Buffer "mo:base/Buffer";
import Hash "mo:base/Hash";
import Int "mo:base/Int";
import Iter "mo:base/Iter";
import Principal "mo:base/Principal";
import Text "mo:base/Text";
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
        let style_score : TrieMap.TrieMap<TokenIdentifier, StyleScore> = TrieMap.TrieMap<TokenIdentifier, StyleScore>(Text.equal, Text.hash);

        let AVATAR_ACTOR = actor(Principal.toText(dependencies.cid_avatar)) : actor {
            get_style_score : shared () -> async [(TokenIdentifier, StyleScore)];
            tokens_ids : shared () -> async [TokenIdentifier];
        };

        let _Logs = dependencies._Logs;


        public func preupgrade() : UpgradeData {
            return {
                    style_score_daily = Iter.toArray(style_score_daily.entries());
                    style_score = Iter.toArray(style_score.entries());
            }
        };

        public func postupgrade(ud : ?UpgradeData) : () {
            switch(ud){
                case(null){};
                case(? ud){
                    for((date, score) in ud.style_score_daily.vals()){
                        style_score_daily.put(date, score);
                    };
                    for((token, score) in ud.style_score.vals()){
                        style_score.put(token, score);
                    };
                };
            };
        };

        /* Query the avatar canister and get the latest screenshot of the style score. Archived the scores into the daily_style_score archive. 
            @Cronic : At least once per day. 
            @Verif : If the screenshot has already been taken for the current day; will log a message and doesn't update the database.
        */
        public func getLatest() : async () {
            let latest_style_score = await AVATAR_ACTOR.get_style_score();
            switch(DateModule.Date.nowToDatePartsISO8601()){
                case(null) assert(false);
                case(? date){
                    for((token, score) in latest_style_score.vals()){
                        switch(style_score_daily(date)){
                            case(? score){
                                _Logs.logMessage("Style score screenshoot has already been taken for today.");
                                return;
                            };
                            case(null){
                                _Logs.logMessage("Style score screenshoot successfully taken for today.");
                                style_score_daily.put((date, token), score);
                                return;
                            };
                        };
                    };
                };
            };
        };

        /* Calculate and update the current style score for the ongoing month based on the scores available in the daily_style_score archive  */
        public func updateScores() : async () {
            // Get all the scores for the current month
            // Sum up all the available style score for this month for each avatar
            // Update the database
            let current_date : Date = switch(DateModule.Date.nowToDatePartsISO8601()){
                case(? date) {date};
                case(_) {
                    assert(false);
                    (0, 0, 0);
                };
            };
            let number_days_in_month = DateModule.Date.getNumberOfDaysInMonth(current_date.0, current_date.1);
            let days_month_buffer : Buffer.Buffer<Date> = Buffer.Buffer<Date>(0);
            for(i in Iter.range(1, number_days_in_month)){
                days_month_buffer.add((current_date.0, current_date.1, i));
            };
            let date_current_month : [Date] = days_month_buffer.toArray();
            let tokens : [TokenIdentifier] = await AVATAR_ACTOR.tokens_ids();
            for(token in tokens.vals()){
                let style_score_month = _getSumStyleScore(date_current_month, token); 
                style_score.put(token, style_score_month);
            };
            _Logs.logMessage("Monthly style score successfully calculated.");
        };

        public func getScores() : [(TokenIdentifier, StyleScore)] {
            return Iter.toArray(style_score.entries());
        };

        public func getScore(tokenId : TokenIdentifier) : ?StyleScore {
            style_score.get(tokenId);
        };

        /////////////////
        // Utilities ///
        ///////////////

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
    }; 


};