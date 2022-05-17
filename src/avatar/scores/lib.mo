import Ext "mo:ext/Ext";
import Int "mo:base/Int";
import Iter "mo:base/Iter";
import Text "mo:base/Text";
import Time "mo:base/Time";
import TrieMap "mo:base/TrieMap";
import Result "mo:base/Result";
import Principal "mo:base/Principal";
import Types "types";


module {

    ////////////
    // Types //
    ///////////

    public type Result<A,B> = Result.Result<A,B>;
    public type UpgradeData = Types.UpgradeData;
    public type Stats = Types.Stats;
    public type StyleScore = Types.StyleScore;

    public class Factory (dependencies : Types.Dependencies) : Types.Interface {

        //////////////
        /// State ///
        ////////////

        type AccountIdentifier = Types.AccountIdentifier;
        type Name = Types.Name;
        type Stars = Types.Stars;
        type Time = Time.Time;
        type Slots = Types.Slots;
        type TokenIdentifier = Types.TokenIdentifier;
        type StyleScore = Types.StyleScore;

        private let CID : Principal = dependencies.cid;
        private let ACCESSORY_CID : Principal = dependencies.accessory_cid;

        private let _Logs = dependencies._Logs;
        private let _Avatar = dependencies._Avatar;
        private let _Ext = dependencies._Ext;

        private var last_time_of_calculation : Time = 0;

        private let styleScores : TrieMap.TrieMap<TokenIdentifier, StyleScore> = TrieMap.TrieMap<TokenIdentifier, StyleScore>(Text.equal, Text.hash);
        private let starsAccessory : TrieMap.TrieMap<Name,Stars> = TrieMap.TrieMap<Name,Stars>(Text.equal, Text.hash);

        //////////////
        /// API /////
        /////////////


        public func preupgrade () : UpgradeData {
            return ({
                style_scores = Iter.toArray(styleScores.entries());
                stars_accessory = Iter.toArray(starsAccessory.entries());
                last_time_of_calculation;
            })
        };

        public func postupgrade(ud : ?UpgradeData) : () {
            switch(ud){
                case(null) {};
                case(?  ud){
                    for((account, score) in ud.style_scores.vals()){
                        styleScores.put(account, score);
                    };
                    for((name, stars) in ud.stars_accessory.vals()){
                        starsAccessory.put(name, stars);
                    };
                    last_time_of_calculation := ud.last_time_of_calculation;
                };
            };
        };

        public func uploadStats(stats : Stats) : () {
            for((name, stars) in stats.vals()){
                starsAccessory.put(name, stars);
            };  
            _Logs.logMessage("Uploaded stats");
        };  

        public func getLastTimeOfCalculation() : Time {
            return last_time_of_calculation;
        };

        public func getStyleScores() : [(TokenIdentifier, StyleScore)] {
            return Iter.toArray(styleScores.entries());
        };

        public func calculateStyleScores() : () {
            if(not (_isTimeToCalculate())){
                _Logs.logMessage("Not time to calculate");
                return;
            };
            _Logs.logMessage("Calculating style scores ");
            let registry = _Ext.getRegistry();
            for ((tokenIndex, account ) in registry.vals()){
                let tokenIdentifier = Ext.TokenIdentifier.encode(CID, tokenIndex);
                switch(_calculateScore(tokenIdentifier)){
                    case(null){
                        _Logs.logMessage("No score for : " # tokenIdentifier);
                    };
                    case(?  score){
                        styleScores.put(tokenIdentifier, score);
                    };
                };
            };
            last_time_of_calculation := Time.now();
            _Logs.logMessage("Calculated style scores");
        };


        //////////////////
        /// Helpers /////
        /////////////////

        let ONE_DAY_NANOSECONDS : Time = 24 * 60 * 60 * 1000000000;

        func _isTimeToCalculate () : Bool {
            let now = Time.now();
            let diff = now - last_time_of_calculation;
            return (diff >= ONE_DAY_NANOSECONDS);
        };

        func _calculateScore(tokenId : TokenIdentifier) : ?Nat {
            switch(_Avatar.getSlot(tokenId)){
                case(null) {
                    _Logs.logMessage("No slot found for token " # tokenId);
                    return null;
                };
                case(? slot){
                    return ?_calculateScoreFromSlot(slot);
                };
            };
        };

        func _calculateScoreFromSlot(slot : Slots) : Nat {
            var score = 0;
            switch(slot.Hat){
                case(null) {};
                case(? hat){
                    score += _getScore(hat);
                };
            };
            switch(slot.Eyes){
                case(null) {};
                case(? accessory){
                    score += _getScore(accessory);
                };
            };
            switch(slot.Misc){
                case(null) {};
                case(? accessory){
                    score += _getScore(accessory);
                };
            };
            switch(slot.Body){
                case(null) {};
                case(? accessory){
                    score += _getScore(accessory);
                };
            };
            switch(slot.Face){
                case(null) {};
                case(? accessory){
                    score += _getScore(accessory);
                };
            };
            score;

        };

        func _getScore(name : Text) : Nat {
            switch(starsAccessory.get(name)){
                case(null) {
                    _Logs.logMessage("No score found for name :" # name);
                    return 0;
                };
                case(? stars){
                    return stars;
                };
            };
        };
    };
};