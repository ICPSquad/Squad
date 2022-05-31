import Canistergeek "mo:canistergeek/canistergeek";

import Leaderboard "../leaderboard";
module {

    public type DistributionPercentage = {
        Total : Nat;
        Cloth : Nat;
        Wood : Nat;
        Glass : Nat;
        Metal : Nat;
        Circuit : Nat;
        DfinityStone : Nat;
    };

    public type Distribution = [(Principal, [Reward])];

    public type Reward =  {
        #ICPSquad : ICPSquadReward;
        #Other : OtherReward;
    };

    public type OtherReward = {
        collection : Text;
        canister_id : Principal;
        token : Text;
    };

    public type ICPSquadReward = {
        item : ItemType; 
        name : Text;
    };

    public type ItemType = {
        #Material;
        #Accessory;
        #LegendaryAccessory;
    };

    public type Dependencies = {
        _Logs : Canistergeek.Logger;
        _Leaderboard : Leaderboard.Factory;
        MATERIAL_TO_POINT_RATIO : Float;
    };

    // public type UpgradeData = {

    // };



}