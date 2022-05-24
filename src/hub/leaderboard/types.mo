import Date "mo:canistergeek/dateModule";
import Canistergeek "mo:canistergeek/canistergeek";

import Style "../style";
module {
    public type TokenIdentifier = Text;
    public type Name = Text;
    public type Date = (Nat, Nat, Nat); //(Year, Month, Day)

    public type StyleScore = Nat;
    public type EngagementScore = Nat;
    public type MissionScore = Nat;
    public type TotalScore = Nat;
    public type Score = Nat;
    public type Leaderboard = [(Principal, ?Name, ?TokenIdentifier, ?StyleScore, ?EngagementScore, ?MissionScore, TotalScore)];
    
    public type Application = Text;
    public type EngagementScoreDetails = [(Application, Score)];

    public type MissionId = Nat;
    public type MissionScoreDetails = [(MissionId, Score)];


    public type UpgradeData = {
        leaderboards : [(Date, Leaderboard)];
    };

    public type Dependencies = {
        cid_avatar : Principal;
        _Logs : Canistergeek.Logger;
        _Style : Style.Factory;
    };

};