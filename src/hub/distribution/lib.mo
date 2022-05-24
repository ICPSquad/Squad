import Types "types";
import TrieMap "mo:base/TrieMap";
import Float "mo:base/Float";
import Int "mo:base/Int";
import Nat "mo:base/Nat";
import Iter "mo:base/Iter";
import Option "mo:base/Option";
import Hash "mo:base/Hash";
import Buffer "mo:base/Buffer";
import Random "mo:base/Random";
import Array "mo:base/Array";
import Nat8 "mo:base/Nat8";
import Nat32 "mo:base/Nat32";
import LFSR "mo:rand/LFSR";
module {

    ////////////
    // Types //
    ///////////

    public type Reward = Types.Reward; 
    // public type UpgradeData = Types.UpgradeData;

    public class Factory(dependencies : Types.Dependencies) {

        //////////////
        /// State ///
        /////////////

        // Total number of materials that will be airdropped
        private var numberMaterials : Nat = 0;

        /*
         This array is used to link the rank of a principal to it's number of tickets 
          rankToTickets[i] => number of tickets for rank i
        */
        private var rankToTickets : [Nat] = [];

        /*
         This array is used to link the ticket serial number to its owner.
          ticketsOwnership[i] => Principal of the owner of tickets with serial number i
        */
        private var ticketsOwnership : [Principal] = [];

        /* This array is to used to store the rewards */

        private var rewards : [Reward] = [];

        // Ratios (can be modified)
        var MATERIAL_TO_POINT_RATIO : Float = dependencies.MATERIAL_TO_POINT_RATIO;

        let _Leaderboard = dependencies._Leaderboard;
        let _Logs = dependencies._Logs;

        let random_generator = LFSR.LFSR32(null);


        // public func preupgrade() : UpgradeData {
        //     return({    

        //     })
        // };

        // public func postupgrade(ud : ?UpgradeData) : () {
        //     switch(ud){
        //         case(null){};
        //         case(? ud){
        //         };
        //     };
        // };

        /* Limit the number of wasm instruction in one message by precomputing the relation between rank and number of tickets */
        public func preCompute() : () {
            switch(_Leaderboard.getCurrentLeaderboard()){
                case(null) return;
                case(? leaderboard) {
                    var buffer = Buffer.Buffer<Nat>(0);
                    let size = leaderboard.size();
                    for(i in Iter.range(0, size - 1 )){

                        let rank = i + 1;
                        let nb_ticket = _rankToNumberOfTicket(rank, size);
                        buffer.add(nb_ticket);
                    };
                    rankToTickets := buffer.toArray();
                    _Logs.logMessage("Computed rank to tickets");
                };
            };
        };
        
        /* Assign a range of tickets to each participant */
        public func generateDraft() : () {
            switch(_Leaderboard.getCurrentLeaderboard()){
                case(null) return;
                case(? leaderboard){
                    let size = leaderboard.size();
                    var buffer : Buffer.Buffer<Principal> = Buffer.Buffer<Principal>(size);
                    for(i in Iter.range(0, size - 1)){
                        let rank = i + 1;
                        let principal = leaderboard[i].0;
                        let nb_ticket = rankToTickets[i];
                        for(j in Iter.range(0, nb_ticket - 1)){
                            buffer.add(principal);
                        };
                    };
                    ticketsOwnership := buffer.toArray();
                    _Logs.logMessage("Generated tickets ownership");
                };
            };
        };

        public func getDraft() : [Principal] {
            return(ticketsOwnership);
        };

        public func getNumberOfTickets(p : Principal) : Nat {
            var count : Nat = 0;
            for(principal in ticketsOwnership.vals()){
                if(p == principal){
                    count += 1;
                };
            };
            return(count);
        };

        public func rankToNumberOfTicket(rank : Nat, total : Nat) : Nat {
            _rankToNumberOfTicket(rank, total);
        };

        public func distributeRewards() : () {

        };

        //////////////////
        /// Utilities ///
        /////////////////

        /*  
            Based on the rank of the person and the total number of users, 
            this function returns the number of tickets for this specific rank.
        */
        func _rankToNumberOfTicket(rank : Nat, total : Nat) : Nat {
            let a : Float = 199 /(Float.fromInt(total) - 1);
            let b : Float = (Float.fromInt(total) - 200) / (Float.fromInt(total) - 1);
            let result = a * Float.fromInt(rank) + b;
            return(Int.abs(Float.toInt(result)));
        };

        /* 
            Based on the total style score of all users, which represents how much accessories are being used 
            and how heathly the economy is we determine the number of materials we should airdrop. 
        */
        func _totalNumberOfMaterials(total_score : Nat) : Nat {
            Int.abs(Float.toInt(Float.fromInt(total_score) / MATERIAL_TO_POINT_RATIO));
        };

        func _totalStyleScore() : Nat {
            var total : Nat = 0;
            switch(_Leaderboard.getCurrentLeaderboard()){
                case(null) {
                    assert(false);
                };
                case(? board) {
                    for(x in board.vals()){
                        total += Option.get<Nat>(x.3, 0);
                    }; 
                };
            };
            return(total);
        };

        func _generateRandomMaterial() : Reward {
            let (v, _) =  random_generator.next();
            return(_valueToMaterial(v % 101));
        };

        public func generateICPSquadRewards() : [(Principal, Reward)] {
            let total_score = _totalStyleScore();
            let total_number = _totalNumberOfMaterials(total_score);
            let rewards = Buffer.Buffer<(Principal,Reward)>(total_number);
            for(x in Iter.range(0, total_number - 1)){
                let reward = _generateRandomMaterial();
                let winner = _selectWinner(); 
                rewards.add((winner, reward));
            };
            return(rewards.toArray());
        };

        func _rewardFromPool() : Nat {
            //TODO
            0;
        }; 

        /* Return a material from a value between 0 and 100 */
        func _valueToMaterial(n : Nat32) : Reward {
            if(n < 48) {
                #ICPSquad({
                    item = #Material;
                    name = "Cloth";
                })
            } else if (n >= 48 and n < 72){
                #ICPSquad({
                    item = #Material;
                    name = "Wood";
                })
            } else if (n >= 72 and n < 84){
                #ICPSquad({
                    item = #Material;
                    name = "Glass";
                })
            } else if(n >= 84 and n < 96){
                #ICPSquad({
                    item = #Material;
                    name = "Metal";
                })
            } else if (n >= 96 and n < 100){
                #ICPSquad({
                    item = #Material;
                    name = "Circuit";
                })
            } else if(n == 100) {
                #ICPSquad({
                    item = #Material;
                    name = "Dfinity-stone";
                })
            } else {
                assert(false);
                #ICPSquad({
                    item = #Material;
                    name = "Unreacheable";
                })
            }
        };

        func _selectWinner() : Principal {
            // Select a random number
            let random_value : Nat32 = random_generator.next().0;
            let random_index : Nat32 = random_value % Nat32.fromNat(ticketsOwnership.size());
            // Select the winner
            let winner = ticketsOwnership[Nat32.toNat(random_index)];
        };

        
    };

}