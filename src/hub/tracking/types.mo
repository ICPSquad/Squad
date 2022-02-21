module {

    ////////////////////
    // EXT Tracking ///
    //////////////////

    public type TokenIdentifier = Text;
    public type AccountIdentifier = Text;
    public type TokenIndex = Nat32;

    public type Transaction = {
        token : TokenIdentifier;
        seller : Principal;
        price : Nat64;
        buyer : AccountIdentifier;
        time : Time;
    };

    public type Listing = {
        seller : Principal;
        price : Nat64;
        locked : ?Time;
    };

    public type ExtActivityInterface = actor {
        transactions : query () -> async [Transaction];
        listings : query () -> async [Listing];
    };

        scores_principal : 
        scores_accountidentifier : 
    };

    public type State = {
        _Admins : [Principal];
        _Projects : [Project];
    };

}