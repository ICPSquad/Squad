import Result "mo:base/Result";

import Canistergeek "mo:canistergeek/canistergeek";

import Admis "../admins";
import Invoice "../invoice";

module {
    public type Result<A,B> = Result.Result<A,B>;

    public type User = {
        email : ?Text;
        discord : ?Text;
        twitter : ?Text;
        rank : ?Nat64; 
        height : ?Nat64;
        status : Status;
    };

    public type InvoiceInfos = Invoice.Invoice;
    
    public type Status =  {
        #NotAuthenticated; // Anymous principal.
        #NotRegistered; // Principal we have no record of.
        #NotConfirmed : Invoice.Invoice; // Principal has already registered but the invoice has not been confirmed.
        #Member : Bool; // Boolean indicating if the user has minted his avatar.
    };

    public type Dependencies = {
        _Logs : Canistergeek.Logger;
        _Invoice : Invoice.Invoice;
        cid_avatar :  Principal;
    };

    public type UpgradeData = {
        users : [(Principal, User)];
    };

    public type Interface = {

        //  Get the UD before upgrading. 
        preupgrade : () -> UpgradeData;

        // Reinitialize the state of the module after upgrading.
        postupgrade : (ud : ?UpgradeData) -> ();

        // Register the user informations a first time.
        register : (caller : Principal, user : User) -> Result<(), Text>;

        // Confirm the user's registration by verifying the status of the invoice.
        confirm : (caller : Principal) -> Result<(), Text>;

        // Mint an avatar for the user.
        mint : (caller : Principal) ->  Result<(), Text>;

        // Returns the number of confirmed users.
        getSize : () -> Nat;

        // Returns the status of the caller.
        getStatus : (caller : Principal) -> Status;

        // Returns the profile of the caller.
        getUser : (caller : Principal) -> Result<User,Text>;
    };


};