import Blob "mo:base/Blob";
import Error "mo:base/Error";
import Hash "mo:base/Hash";
import IC "mo:base/ExperimentalInternetComputer";
import Iter "mo:base/Iter";
import Nat "mo:base/Nat";
import Time "mo:base/Time";
import TrieMap "mo:base/TrieMap";

import Hex "mo:encoding/Hex";

import Types "types";
module {

  public type UpgradeData = Types.UpgradeData;
  public type Job = Types.Job;

  let candid_encoded_args_null : [Nat8] = [68, 73, 68, 76, 0, 0];
  public class Factory(dependencies : Types.Dependencies) {

    ////////////
    // State //
    //////////

    var heartbeat_on : Bool = false;
    var next_job_id : Nat = 0;

    let jobs : TrieMap.TrieMap<Nat, Job> = TrieMap.TrieMap(Nat.equal, Hash.hash);

    let _Logs = dependencies._Logs;

    public func preupgrade() : UpgradeData {
      return (
        {
          jobs = Iter.toArray(jobs.entries());
          heartbeat_on;
          next_job_id;
        },
      );
    };

    public func postupgrade(ud : ?UpgradeData) : () {
      switch (ud) {
        case (null) {};
        case (?ud) {
          for ((id, job) in ud.jobs.vals()) {
            jobs.put(id, job);
          };
          heartbeat_on := ud.heartbeat_on;
          next_job_id := ud.next_job_id;
        };
      };
    };

    ////////////
    // API ////
    //////////

    public func setJobStatus(bool : Bool) : () {
      heartbeat_on := bool;
    };

    public func addJob(
      canister : Principal,
      method : Text,
      interval : Int,
    ) : () {
      let id = next_job_id;
      next_job_id += 1;
      let job : Job = { canister; method_name = method; interval; last_time = Time.now() };
      jobs.put(id, job);
    };

    public func deleteJob(
      id : Nat,
    ) : () {
      jobs.delete(id);
    };

    public func getJobs() : [(Nat, Job)] {
      Iter.toArray(jobs.entries());
    };

    public func doJobs() : async () {
      if (not (heartbeat_on)) {
        return;
      };
      for ((id, job) in jobs.entries()) {
        if (job.last_time + job.interval < Time.now()) {
          jobs.put(id, _updated(job));
          ignore (_doJob(job));
        };
      };

    };

    ////////////////
    // Helpers ////
    //////////////

    private func _doJob(job : Job) : async () {
      try {
        ignore (await IC.call(job.canister, job.method_name, Blob.fromArray(candid_encoded_args_null)));
      } catch e {
        _Logs.logMessage("Error in job: " # job.method_name # " : " # Error.message(e));
        throw e;
      };
    };

    private func _updated(job : Job) : Job {
      return (
        {
          canister = job.canister;
          method_name = job.method_name;
          interval = job.interval;
          last_time = Time.now();
        },
      );
    };

  };
};
