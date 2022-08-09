import Int "mo:base/Int";
import Iter "mo:base/Iter";
import Principal "mo:base/Principal";
import Result "mo:base/Result";
import Text "mo:base/Text";
import Time "mo:base/Time";
import TrieMap "mo:base/TrieMap";

import Ext "mo:ext/Ext";

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
            _Logs.logMessage("CONFIG :: uploaded stats");
        };  

        public func getLastTimeOfCalculation() : Time {
            return last_time_of_calculation;
        };

        public func getStyleScores() : [(TokenIdentifier, StyleScore)] {
            return Iter.toArray(styleScores.entries());
        };

        /*
            Updates the style score using the latest equipped accessories on the avatar corresponding to the tokenIdentifier. 
        */
        public func calculateStyleScores() : () {
            let registry = _Ext.getRegistry();
            for ((tokenIndex, account ) in registry.vals()){
                let tokenIdentifier = Ext.TokenIdentifier.encode(CID, tokenIndex);
                switch(_calculateScore(tokenIdentifier)){
                    case(null){
                        _Logs.logMessage("ERR :: no score for : " # tokenIdentifier);
                    };
                    case(?  score){
                        styleScores.put(tokenIdentifier, score);
                    };
                };
            };
        };


        //////////////////
        /// Helpers /////
        /////////////////

        func _calculateScore(tokenId : TokenIdentifier) : ?Nat {
            switch(_Avatar.getSlot(tokenId)){
                case(null) {
                    _Logs.logMessage("ERR :: no slot found for token :" # tokenId);
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
                    _Logs.logMessage("ERR :: no score found for name : " # name);
                    return 0;
                };
                case(? stars){
                    return stars;
                };
            };
        };
    };
};