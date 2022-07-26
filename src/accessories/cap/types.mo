import Canistergeek "mo:canistergeek/canistergeek";
import Root "mo:cap/Root";

import Admins "../admins"
module {
    public type IndefiniteEvent = Root.IndefiniteEvent;
    public type Event = Root.Event;
    public type DetailValue = Root.DetailValue;

    public type Dependencies = {
        _Logs : Canistergeek.Logger;
        _Admins : Admins.Admins;
        cid : Principal;
        overrideRouterId : ?Text;
        provideRootBucketId : ?Text;
    };

    public type UpgradeData = {
        events : [IndefiniteEvent];
    };

};