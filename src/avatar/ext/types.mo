import Result "mo:base/Result";
import Time "mo:base/Time";

import Canistergeek "mo:canistergeek/canistergeek";
import Cap "mo:cap/Cap";
import Ext "mo:ext/Ext";

import Avatar "../avatar";


module {

    public type Result<A,B> = Result.Result<A,B>;
    public type TokenIndex = Ext.TokenIndex;
    public type TokenIdentifier = Ext.TokenIdentifier;
    public type AccountIdentifier = Ext.AccountIdentifier;
    public type Extension = Ext.Extension;
    public type Balance = Ext.Balance;
    public type CommonError = Ext.CommonError;
    public type BalanceRequest = Ext.Core.BalanceRequest;
    public type BalanceResponse = Ext.Core.BalanceResponse;
    public type TransferRequest = Ext.Core.TransferRequest;
    public type TransferResponse = Ext.Core.TransferResponse;
    public type Metadata = Ext.Common.Metadata;
    public type MetadataResponse = Ext.Common.MetadataResponse;
    public type SupplyResponse = Ext.Common.SupplyResponse;
    public type BearerResponse = Ext.NonFungible.BearerResponse;
    public type MintRequest = Ext.NonFungible.MintRequest;
    public type MintResponse = Ext.NonFungible.MintResponse;

    public type Listing = {
        locked      : ?Time.Time;
        price       : Nat64;  // ICPe8
        seller      : Principal;
        subaccount  : ?Ext.SubAccount;
    };

    public type Dependencies = {
        cid : Principal;
        _Logs : Canistergeek.Logger;
        _Avatar : Avatar.Factory;
    };

    public type UpgradeData = {
        registry : [(TokenIndex, AccountIdentifier)];
    };

    public type Interface = {

        ////////////////
        // @ext:core //
        //////////////

        // Returns a list of EXT extensions supported by this canister.
        extensions : () -> [Extension];

        // Returns the balance of an User.
        balance :  BalanceRequest -> BalanceResponse;

        // Transfer the ownership of an NFT.
        // @dev : Needs to pass the caller to the module as first argument. 
        transfer : (Principal,TransferRequest) -> TransferResponse;

        //////////////////
        // @ext:common //
        ////////////////

        // Returns the metadata associated with the given token.
        metadata : TokenIdentifier -> MetadataResponse;

        // Returns the supply associated with the given token.
        supply : TokenIdentifier -> SupplyResponse;

        ///////////////////////
        // @ext:nonfungible //
        /////////////////////

        // Returns the accountIdentifier of the owner the token, if the token is correct.
        bearer : TokenIdentifier -> BearerResponse;

        // Mint a new token.
        mint : MintRequest -> MintResponse;
        
        // Returns the whole registry.
        getRegistry : () -> [(TokenIndex, AccountIdentifier)];

        /////////////////////////////
        // @ext:stoic integration //
        ///////////////////////////

        tokens : AccountIdentifier -> Result<[TokenIndex], CommonError>;
        tokens_ext : AccountIdentifier -> Result<[(TokenIndex, ?Listing, ?Blob)], CommonError>;

        ////////////////////////////////
        // @ext:entrepot integration //
        ///////////////////////////////

        details : TokenIdentifier -> Result<(AccountIdentifier, ?Listing), CommonError>;



    };


}