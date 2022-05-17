import Date "mo:canistergeek/dateModule";
module {

    public type StyleScore = Nat;
    public type EngagementScore = Nat;
    public type MissionScore = Nat;
    public type TotalScore = Nat;

    public type TokenIdentifier = Text;
    public type Name = Text;
    public type Message = Text;
    public type Date = (Nat, Nat, Nat); //(Year, Month, Day)


    public type Leaderboard = [(Principal, ?Name, ?Message, ?TokenIdentifier, ?StyleScore, ?EngagementScore, ?MissionScore, TotalScore)];

    public type UpgradeData = {
        leaderboards : [(Date, Leaderboard)];
    };

    public type Dependencies = {
        cid_avatar : Principal;
    };

};