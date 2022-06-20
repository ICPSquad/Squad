import Result "mo:base/Result";

import Canistergeek "mo:canistergeek/canistergeek";

import Avatar "../avatar";
import ExtModule "../ext";
module {
    public type Result<A,B> = Result.Result<A,B>;

    public type Name = Text;
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
        selected_avatar : ?TokenIdentifier;
    };

    
    public type Dependencies = {
        cid : Principal;
        _Logs : Canistergeek.Logger;
        _Ext : ExtModule.Factory;
        _Avatar : Avatar.Factory;
    };

    public type UpgradeData = {
        users : [(Principal, User)];
    };

};