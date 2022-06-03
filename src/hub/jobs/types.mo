import Canistergeek "mo:canistergeek/canistergeek";
module {

    public type Job = {
        canister : Principal;
        method_name : Text;
        interval : Int;
        last_time : Int;
    };

    public type UpgradeData = {
        jobs : [(Nat, Job)];
        heartbeat_on : Bool;
        next_job_id : Nat;
    };

    public type Dependencies = {
        _Logs : Canistergeek.Logger;    
    };

  
}