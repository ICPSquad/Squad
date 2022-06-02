module {
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

    public type Witness = { certificate : [Nat8]; tree : [Nat8] };

    public type GetTransactionsResponseBorrowed = {
        data : [Event];
        page : Nat32;
        witness : ?Witness;
    };

    public type Dependencies = {
        cid_bucket_accessory : Principal;
        cid_bucket_avatar : Principal;
    };

    public type Bucket = actor {
        get_user_transactions : shared query GetUserTransactionArg -> async GetTransactionsResponseBorrowed;
    };

    public type Interface = {
        /* 
            This function takes a caller and an optional name for an accessory and returns the number of time the accessory has been minted.
            If no name was supplied it returns the total number of minted accessory.
        */
        numberMint: (caller : Principal, accessory : ?Text) -> async Nat;

        /* 
            This function takes a caller and an optional name for an accessory and returns the number of time this accessory has been burned.
            If no name was supplied it returns the total number of burned accessory.
        */
        numberBurn: (caller : Principal, accessory : ?Text) -> async Nat;
    };


};