import Canistergeek "mo:canistergeek/canistergeek";
module {

    public type Date = (Nat,Nat,Nat);
    public type TokenIdentifier = Text;
    public type StyleScore = Nat;


    public type UpgradeData = {
        style_score_daily : [((Date, TokenIdentifier), StyleScore)];
    };

    public type Dependencies = {
        cid_avatar : Principal;
        _Logs : Canistergeek.Logger;
    }
};