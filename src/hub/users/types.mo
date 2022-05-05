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
    
    public type Status =  {
        #Invoice : Invoice.Invoice; // Invoice needs to be confirmed before being a member.
        #Member : Bool; // Boolean indicating if the user has minted his avatar.
        #InProgress; // A intermediate status to block re-entrancy attacks.
    };

    public type Dependencies = {
        _Logs : Canistergeek.Logger;
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

        // Modify the status of a specific user. Trap if user doesn't exist.
        modifyStatus : (caller : Principal, status : Status) -> ();

        // Mint an avatar for the user.
        mint : (caller : Principal) ->  Result<(), Text>;

        // Returns the number of confirmed users.
        getSize : () -> Nat;

        // Returns the optional profile of the caller.
        getUser : (caller : Principal) -> ?User;

        //Modify an user profile
        modifyUser : (caller : Principal, user : User) -> Result<(), Text>;
    };


};