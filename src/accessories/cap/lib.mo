import Error "mo:base/Error";
import List "mo:base/List";
import Option "mo:base/Option";
import Principal "mo:base/Principal";
import Result "mo:base/Result";

import Cap "mo:cap/Cap";

import Types "types";
module {   

    public type UpgradeData = Types.UpgradeData; 
    public type IndefiniteEvent = Types.IndefiniteEvent;

    public class Factory(dependencies : Types.Dependencies) {

        let _Logs = dependencies._Logs;
        let _Admins = dependencies._Admins;

        let cap = Cap.Cap(dependencies.overrideRouterId, dependencies.provideRootBucketId);
        let creationCycles : Nat = 1_000_000_000_000;

        var pendingEvents : List.List<Types.IndefiniteEvent> = null;

        public func preupgrade() : Types.UpgradeData {
            return ({
                events = List.toArray(pendingEvents);
            });
        };

        public func postupgrade(ud : ?Types.UpgradeData) : () {
            switch(ud){
                case(null){};
                case(? ud){
                    pendingEvents := List.fromArray<Types.IndefiniteEvent>(ud.events);
                };
            }
        };

        public func initCap() : async Result.Result<(), Text>{
            let contractId = Principal.toText(dependencies.cid);
            try {
                let handshake = await cap.handshake(
                    contractId,
                    creationCycles
                );
                return #ok();
            } catch e {
                throw e;
            };
        };

        public func registerEvent(event : Types.IndefiniteEvent) : async () {
            switch(await cap.insert(event)){
                case(#ok(_)){};
                case(#err(_)){
                    _Logs.logMessage("registerEvent " # ":: ERR :: will be inserted into queue for later");
                    pendingEvents := List.push(event, pendingEvents);
                };
            };
        };
        

        // Process the queue of events (in case they have failed before)
        var pendingCount : Nat = 0;
        public func cronEvents () : async () {
            if(List.size(pendingEvents) == 0){
                return;
            };

            // Keep track of completed and failed jobs
            var completed : List.List<Types.IndefiniteEvent> = null;
            var failed : List.List<Types.IndefiniteEvent> = null;

            let (event, remaining) = List.pop(pendingEvents);
            var job = event;
            pendingEvents := remaining;
            
            label queue while (Option.isSome(job)) ignore do ? {
                pendingCount += 1;
                try {
                    switch (await cap.insert(job!)){
                        case(#ok(id)){
                            completed := List.push(job!, completed);
                            pendingCount -= 1;
                        };
                        case(#err(#invalidTransaction)){
                            _Logs.logMessage("cronicEvents" # "ERR :: Failed to insert(Invalid transaction)");
                            failed := List.push(job!, failed);
                            pendingCount -= 1;
                        };
                        case(#err(#unsupportedResponse)){
                            _Logs.logMessage("cronicEvents" # "ERR :: Failed to insert(Unsupported response)");
                            failed := List.push(job!, failed);
                            pendingCount -= 1;
                        };
                        case _ {
                            _Logs.logMessage("cronicEvents" # "ERR :: Failed to insert(Unknown error)");
                            failed := List.push(job!, failed);
                            pendingCount -= 1;
                        };
                    };
                } catch (e) {
                    _Logs.logMessage("cronciEvent" # "ERR :: Unexpected CAP failure : " # Error.message(e) );
                    failed := List.push(job!, failed);
                    pendingCount -= 1;
                };
                let (event, remaining) = List.pop(pendingEvents);
                job := event;
                pendingEvents := remaining;
            };

            // If there are any failed jobs, re-queue them
            if(List.size(failed) > 0){
                pendingEvents := List.append(failed, pendingEvents);
            };
        };
    }; 
};