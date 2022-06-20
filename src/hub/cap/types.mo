import Canistergeek "mo:canistergeek/canistergeek";

import Collection "../collection";
module {

    public type Date = (Nat, Nat, Nat);
    public type CapStats = {
        buy : (Nat, Nat); // (Number of operations, ICP)
        sell : (Nat, Nat); // (Number of operations, ICP)
        mint : Nat; // Number of operations
        collection_involved : Nat // Number of interaction with different collections
    };


    public type DetailValue = {
        #I64 : Int64;
        #U64 : Nat64;
        #Vec : [DetailValue];
        #Slice : [Nat8];
        #Text : Text;
        #True;
        #False;
        #Float : Float;
        #Principal : Principal;
    };

    public type Event = {
        time : Nat64;
        operation : Text;
        details : [(Text, DetailValue)];
        caller : Principal
    };

    public type ExtendedEvent = {
        time : Nat64;
        operation : Text;
        details : [(Text, DetailValue)];
        caller : Principal;
        collection : Principal;
    };

    public type IndefiniteEvent = {
        operation : Text;
        details : [(Text, DetailValue)];
        caller : Principal;
    };

    public type GetUserTransactionArg = {
        page : ?Nat32;
        user : Principal;
        witness : Bool;
    };   
    public type GetTransactionsArg = { page : ?Nat32; witness : Bool };
    public type Witness = { certificate : [Nat8]; tree : [Nat8] };

    public type GetTransactionsResponseBorrowed = {
        data : [Event];
        page : Nat32;
        witness : ?Witness;
    };

    public type Bucket = actor {
        get_user_transactions : shared query GetUserTransactionArg -> async GetTransactionsResponseBorrowed;
        get_transactions : shared query GetTransactionsArg -> async GetTransactionsResponseBorrowed;
        size : shared query () -> async Nat64;
    };

    public type GetTokenContractRootBucketArg = {
        witness : Bool;
        canister : Principal;
    };
    public type GetTokenContractRootBucketResponse = {
        witness : ?Witness;
        canister : ?Principal;
    };

    public type GetUserRootBucketsArg = { user : Principal; witness : Bool };
    public type GetUserRootBucketsResponse = {
        witness : ?Witness;
        contracts : [Principal];
    };

    public type Router = actor {
        get_token_contract_root_bucket : shared GetTokenContractRootBucketArg -> async GetTokenContractRootBucketResponse;
        get_user_root_buckets : shared GetUserRootBucketsArg -> async GetUserRootBucketsResponse;
    };
    
    // In our case we only need a subtype of the real type. See : https://github.com/Psychedelic/dab/blob/main/candid/nft.did
    public type NFT_CANISTER = {
        name : Text;
        principal_id : Principal;
    };

    public type Dab = actor {
        get_all : shared query () -> async [NFT_CANISTER];
    };

    public type Dependencies = {
        cid_bucket_accessory : Principal;
        cid_bucket_avatar : Principal;
        cid_router : Principal;
        cid_dab : Principal;
        cid_avatar : Principal;
        _Logs : Canistergeek.Logger; 
    };

    public type UpgradeData = {
        cids : [(Collection.Collection, Principal)];
        cid_interacted_collections : [(Principal, [Principal])];
        daily_cached_events_per_collection : [(Principal, [Event])];
        daily_cached_events_per_user : [(Principal, [ExtendedEvent])];
        stats_daily : [((Date, Principal), CapStats)];
        engagement_score_daily : [((Date, Principal), Nat)];
    };

};