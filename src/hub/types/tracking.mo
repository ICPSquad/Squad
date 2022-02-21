module {

    ////////////////
    // ENTREPOT ///
    ///////////////

    //Note : This is called Entrepot cause all the trafics goes there and they have implemented all those methods along with there marketplace but in reality the tracking happens for each individual canister.

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

    public type ExtActivity = actor {
        transactions : query () -> async [Transaction];
        listings : query () -> async [Listing];
    };

    public type EntrepotScore = {
        Seniority : Nat8; 
        Regularity : Nat8;
        Amount : Nat32;
        Transactions : Nat32;
        Penalty : Nat32;
    };

    public type EntrepotDaily = {
        Listings : Nat16;
        Transactions : Nat16;
        Amount : Nat16;
    };


};