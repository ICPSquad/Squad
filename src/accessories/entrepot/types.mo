import Principal "mo:base/Principal";
import Result "mo:base/Result";
import Time "mo:base/Time";

import Canistergeek "mo:canistergeek/canistergeek";

import Admins "../Admins";
import Cap "../Cap";
import Ext "../Ext";
import Items "../Items";
import NNS "../NNS";

module {
    public type Dependencies = {
        _Ext : Ext.Factory;
        _Admins : Admins.Admins;
        _Cap : Cap.Factory;
        _Logs : Canistergeek.Logger;
        _Items : Items.Factory;
        cid : Principal;
        cid_ledger : Principal;
    };

    public type UpgradeData = {
        listings : [(Ext.TokenIndex, Listing)];
        transactions : [(Nat, Transaction)];
        pendingTransactions : [(Ext.TokenIndex, Transaction)];
        totalVolume : Nat64;
        lowestPriceSales : Nat64;
        highestPriceSales : Nat64;
        nextSubAccount : Nat;
        pendingDisbursements : [(Ext.TokenIndex, Ext.AccountIdentifier, SubAccount, Nat64)];
    };


    public type SubAccount = [Nat8];

    public type Listing = {
        locked : ?Time.Time;
        price : Nat64; //e8s
        seller : Principal;
        subaccount : ?SubAccount;
    };

    public type ExtListing = {
        locked : ?Time.Time;
        price : Nat64; //e8s
        seller : Principal;
    };

    public type ListingsResponse = [(
        Ext.TokenIndex,
        ExtListing,
        Metadata,
    )];

    public type Transaction = {
        id : Nat;
        token : Ext.TokenIdentifier;
        memo : ?Blob;
        from : Ext.AccountIdentifier;
        to : Ext.AccountIdentifier;
        seller : Principal;
        price : Nat64; //e8s
        initiated : Time.Time; //When it was locked for
        closed : ?Time.Time; // When it was settled
        bytes : [Nat8];
    };

    public type EntrepotTransaction = {
        token   : Ext.TokenIdentifier;
        seller  : Principal;
        price   : Nat64;
        buyer   : Ext.AccountIdentifier;
        time    : Time.Time;
    };

    public type Metadata = {
         #fungible : {
            decimals    : Nat8;
            metadata    : ?Blob;
            name        : Text;
            symbol      : Text;
        };
        #nonfungible : {
            metadata : ?Blob;
        };
    };

    ////////////
    // API ////
    //////////
    
    public type ListRequest = {
        from_subaccount : ?SubAccount;
        price : ?Nat64;
        token : Ext.TokenIdentifier;
    };
    public type ListResponse = Result.Result<(), Ext.CommonError>;

    public type LockRequest = {
        token : Ext.TokenIdentifier;
        price : Nat64;
        buyer : Ext.AccountIdentifier;
        bytes : [Nat8];
    };
    // Returns the address to pay out to.
    public type LockResponse = Result.Result<Ext.AccountIdentifier, Ext.CommonError>;

    // First tuple value is seller's account identifier
    public type DetailsResponse = Result.Result<(Ext.AccountIdentifier, ?Listing), Ext.CommonError>;

    public type StatsResponse = (
        Nat64,  // Total volume
        Nat64,  // Highest price sale
        Nat64,  // Lowest price sale
        Nat64,  // Current floor price
        Nat,    // # Listings
        Nat,    // # Supply
        Nat,    // # Sales
    ); 

    public type Disbursement = (Ext.TokenIndex, Ext.AccountIdentifier, SubAccount, Nat64);
};