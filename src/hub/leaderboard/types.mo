import Canistergeek "mo:canistergeek/canistergeek";
import Date "mo:canistergeek/dateModule";

import Mission "../mission";
import Style "../style";
module {
    public type TokenIdentifier = Text;
    public type Name = Text;
    public type Date = (Nat, Nat, Nat); //(Year, Month, Day)

    public type StyleScore = Nat;
    public type EngagementScore = Nat;
    public type TotalScore = Nat;
    public type Score = Nat;
    public type Leaderboard = [(Principal, ?Name, ?TokenIdentifier, ?StyleScore, ?EngagementScore, TotalScore)];
    
    public type UpgradeData = {
        leaderboards : [(Date, Leaderboard)];
    };

    public type Dependencies = {
        cid_avatar : Principal;
        _Logs : Canistergeek.Logger;
        _Style : Style.Factory;
        _Mission : Mission.Center;
    };

};