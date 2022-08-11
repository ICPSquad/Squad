import Canistergeek "mo:canistergeek/canistergeek";

import Ext "../ext";

module {

    public type TokenIndex = Nat32;

    public type Dependencies = {
        _Ext : Ext.Factory;
        _Logs : Canistergeek.Logger;
        cid : Principal;
    };

    public type UpgradeData = {
        tickets : [TokenIndex];
    };

    public type Interface = {
        postupgrade : (ud : ?UpgradeData) -> ();

        preupgrade : () -> UpgradeData;

        isTicket : (tokenIndex : TokenIndex) -> Bool;

        addTicket : (tokenIndex : TokenIndex) -> ();

        deleteTicket : (tokenIndex : TokenIndex) -> (); 


    };
}