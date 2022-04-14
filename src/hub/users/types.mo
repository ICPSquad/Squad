import Result "mo:base/Result";

import Canistergeek "mo:canistergeek/canistergeek";

import Admis "../admins";
import Invoice "../invoice";

module {

    public type Wallet = {
        #Stoic : Principal;
        #Plug : Principal;
    };

    public type TokenIdentifier = Text;

    public type User = {
        email : ?Text;
        discord : ?Text;
        twitter : ?Text;
        rank : ?Nat64; 
        height : ?Nat64;
        avatar : ?TokenIdentifier; 
        status : Status;
    };
    
    public type Status =  {
        #NotAuthenticated;
        #NotRegistered;
        #NotConfirmed;
        #Member : Bool; // Indicates if the user has minted his avatar.
    };

    public type Dependencies = {
        _Admins : Admins.Admins;
        _Logs : Canistergeek.Logger;
        _Invoice : Invoice.Invoice;
    };

    public type UpgradeData = {
        _users : [(Principal, User)];
        _registrations : [(Principal, Registration)];
    };



    public type Interface = {

        //  Get the UD before upgrading. 
        preupgrade : () -> UpgradeData;

        // Reinitialize the state of the module after upgrading.
        postupgrade : (ud : ?UpgradeData) -> ();

        register : (caller : Principal, ) -> 

        confirm : (caller : Principal, ) ->

        mint : (caller : Principal) -> 

        // Returns the number of registered users.
        size : () -> Nat;

        getStatus : (caller : Principal) ->  

    };


}: