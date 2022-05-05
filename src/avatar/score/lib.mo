import Int "mo:base/Int";
import Iter "mo:base/Blob";
import Text "mo:base/Text";
import TrieMap "mo:base/TrieMap";

import Types "types";
module {

    ////////////
    // Types //
    ///////////

    public type Result<A,B> = Result.Result<A,B>;

    public class Factory (dependencies : Types.Dependencies) : Types.Interface {

        //////////////
        /// State ///
        ////////////

        type AccountIdentifier = Types.AccountIdentifier;
        type DailyScore = Types.DailyScore;
        type Name = Types.Name;
        type Stars = Types.Stars;
        type Stats = Types.Stats;

        private let CID : Principal = dependencies.cid;
        private let ACCESSORY_CID : Principal = dependencies.accessory_cid;

        private let _Logs = dependencies._Logs;
        private let _Avatar = dependencies._Avatar;
        private let _Ext = dependencies._Ext;

        private let last_time_of_calculation : Time = 0;
        private let styleScores : TrieMap.TrieMap<AccountIdentifier, DailyScore> = TrieMap.TrieMap<AccountIdentifier, DailyScore>(Text.equal, Text.hash);
        private let starsAccessory : TrieMap.TrieMap<Name,Stars> = TrieMap.TrieMap<Name,Stars>(Text.equal, Text.hash);

        //////////////
        /// API /////
        /////////////


        public func preugrade () : UpgradeData {
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
                    for((account, score) in ud.style_scores){
                        styleScores.put(account, score);
                    };
                    for((name, stars) in ud.stars_accessory){
                        starsAccessory.put(name, stars);
                    };
                    last_time_of_calculation = ud.last_time_of_calculation;
                };
            };
        }

        public func uploadStats(stats : Stats) : () {
            for((name, stars) in stats.vals()){
                starsAccessory.put(name, stars);
            };  
            _Logs.logMessage("Uploaded stats");
        };  

        public func getLastTimeOfCalculation () : Time {
            return last_time_of_calculation;
        };

        public func getStyleScores() : [(AccountIdentifier, DailyScore)] {
            return styleScores.entries();
        };

        public func calculateStyleScores() : () {
            if(not (_isTimeToCalculate())){
                _Logs.logMessage("Not time to calculate" : Int.toText(Time.now()));
                return;
            };
            _Logs.logMessage("Calculating style scores" : Int.toText(Time.now()));
            ///TODO
        };


        //////////////////
        /// Helpers /////
        /////////////////

        let ONE_DAY_NANOSECONDS : Time = 24 * 60 * 60 * 1000000000;

        func _isTimeToCalculate () : Bool {
            let now = Time.now();
            let diff = now - last_time_of_calculation;
            return (diff >= ONE_DAY_NANOSECONDS);
        }

        

    };
};