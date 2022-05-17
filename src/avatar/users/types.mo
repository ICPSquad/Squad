import Result "mo:base/Result";
import ExtModule "../ext";
import Canistergeek "mo:canistergeek/canistergeek";
module {
    public type Result<A,B> = Result.Result<A,B>;

    public type Name = Text;
    public type Message = Text;
    public type TokenIdentifier = Text;

    public type User = {
        name : ?Name;
        email : ?Text;
        discord : ?Text;
        twitter : ?Text;
        rank : ?Nat64;  // Rank of the user 
        height : ?Nat64; // Optional height of the block used during registration (Old registration system)
        minted : Bool; // Indicates if the user has already minted his avatar.
        account_identifier : ?Text; // Stores the default account identifier (SubAccount 0).
        invoice_id : ?Nat; // Optional invoice id used during registration. (New registration system)
        message_leaderboard : ?Message;
        selected_avatar : ?TokenIdentifier;
    };

    
    public type Dependencies = {
        cid : Principal;
        _Logs : Canistergeek.Logger;
        _Ext : ExtModule.Factory;
    };

    public type UpgradeData = {
        users : [(Principal, User)];
    };

    // public type Interface = {

    //     //  Get the UD before upgrading. 
    //     preupgrade : () -> UpgradeData;

    //     // Reinitialize the state of the module after upgrading.
    //     postupgrade : (ud : ?UpgradeData) -> ();

    //     // Register the user informations a first time.
    //     register : (caller : Principal) -> Result<(), Text>;

    //     // Returns the optional profile of the caller.
    //     getUser : (caller : Principal) -> ?User;

    //     //Modify an user profile
    //     modifyUser : (caller : Principal, user : User) -> Result<(), Text>;
    // };


};