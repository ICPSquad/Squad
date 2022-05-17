import Time "mo:base/Time";

import Canistergeek "mo:canistergeek/canistergeek";

import Avatar "../avatar";
import ExtModule "../ext";



module {
    public type Time = Time.Time;

    public type DailyScore = Nat;
    public type StyleScore = Nat;

    public type AccountIdentifier = Text;
    public type TokenIdentifier = Text;

    public type Stars = Nat;
    public type Name = Text;
    public type Stats = [(Name, Stars)];

    public type Slots = {
        Hat :  ?Text;
        Eyes : ?Text;
        Misc : ?Text;
        Body : ?Text;
        Face : ?Text;
    };

    public type Dependencies = {
        cid : Principal;
        accessory_cid : Principal;
        _Logs : Canistergeek.Logger;
        _Avatar : Avatar.Factory;
        _Ext : ExtModule.Factory;
    };

    public type UpgradeData = {
        style_scores : [(TokenIdentifier, DailyScore)];
        stars_accessory : [(Name, Stars)];
        last_time_of_calculation : Time;
    };

    public type Interface = {

        /* Get the UD before upgrading. */
        preupgrade : () -> UpgradeData;

        /* Reinitialize the state of the module after upgrading. */
        postupgrade : (?UpgradeData) -> ();

        /* Upload the stats for accessory so that we can calculate the style score */
        uploadStats : (Stats) -> ();

        /* 
          Returns the a list of the current style scores for all the accounts. 
          DO NOT STORE THE SCORES MORE THAN A DAY. Need to be querried by the accessory canister regularly where all the history is stored.
        */
        getStyleScores : () -> [(TokenIdentifier, DailyScore)];

        /* Recalculate the scores of the avatar based on the accessory they are currently equipped with. 
            SHOULD BE CALLED ONCE DAILY AT A SPECIFIC TIME.
        */
        calculateStyleScores : () -> ();

        /* Give the last time the scores where updated */
        getLastTimeOfCalculation : () -> Time;
    };

}