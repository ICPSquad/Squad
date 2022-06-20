import Time "mo:base/Time";

import Canistergeek "mo:canistergeek/canistergeek";
import Date "mo:canistergeek/dateModule";

import Cap "../cap";
import Mission "../mission";
import Style "../style";
module {
    public type TokenIdentifier = Text;
    public type Name = Text;
    public type Date = (Nat, Nat, Nat); //(Year, Month, Day)

    public type StyleScore = Nat;
    public type EngagementScore = Nat;
    public type TotalScore = Nat;
    public type Leaderboard = [(Principal, ?Name, ?TokenIdentifier, ?StyleScore, ?EngagementScore, TotalScore)];

    public type Round = {
        id : Nat;
        start_date : Time.Time;
        end_date : ?Time.Time;
        leaderboard : ?Leaderboard;
    };
    
    public type UpgradeData = {
        rounds : [(Nat, Round)];
        current_round_id : ?Nat;
        next_round_id : Nat;
    };

    public type Dependencies = {
        cid_avatar : Principal;
        cid_accessory : Principal;
        _Logs : Canistergeek.Logger;
        _Style : Style.Factory;
        _Mission : Mission.Center;
        _Cap : Cap.Factory;
    };

};