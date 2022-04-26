module {

    public type TokenIdentifier = Text;
    public type SubAccount = [Nat8];
    public type AccountIdentifier = Text;
    public type AccountBalanceArgs = { account : AccountIdentifier };
    public type ICPTs = { e8s : Nat64 };
    public type Time = Int;

    public type Transaction = {
        token : TokenIdentifier;
        seller : Principal;
        price : Nat64;
        buyer : AccountIdentifier;
        time : Time;
    };

    public type Settlement = {
        seller : Principal;
        price : Nat64;
        subaccount : SubAccount;
        buyer : AccountIdentifier;
    };

    public type Listing = {
        seller : Principal;
        price : Nat64;
        locked : ?Time;
    };

    public type ListRequest = {
        token : TokenIdentifier;
        from_subaccount : ?SubAccount;
        price : ?Nat64;
    };

    public type CommonError = {
        #InvalidToken: TokenIdentifier;
        #Other : Text;
    };

    public type Metadata = {
        #fungible : {
        name : Text;
        symbol : Text;
        decimals : Nat8;
        metadata : ?Blob;
        };
        #nonfungible : {
        metadata : ?Blob;
        };
    };
};