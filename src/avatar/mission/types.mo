import Result "mo:base/Result";

import Canistergeek "mo:canistergeek/canistergeek";

import Avatar "../avatar";
import Ext "../ext";
module {

    public type Dependencies = {
        _Logs : Canistergeek.Logger;
        _Ext : Ext.Factory;
        _Avatar : Avatar.Factory;
        cid : Principal;
    };


    public type Interface = {

        // preupgrade : () -> UpgradeData

        // postupgrade : (ud : ?UpgradeData) -> ();

        verifyMission : (id : Nat, caller : Principal) -> Bool

    };
};