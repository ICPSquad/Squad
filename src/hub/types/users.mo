import Result "mo:base/Result";
module {

    public type Wallet = {
        #Stoic : Principal;
        #Plug : Principal;
    };

    public func _getPrincipalWallet (wallet : Wallet) : Principal {
       switch (wallet) {
           case(#Stoic(principal)) {principal};
           case(#Plug(principal)) {principal};
       };
    };

    public type Status =  {
        #Level1;
        #Level2;
        #Level3;
        #OG;
        #Legendary;
        #Staff;
    };

    public type TokenIdentifier = Text;

    public type User = {
        wallet : Text;
        email : ?Text;
        discord : ?Text;
        twitter : ?Text;
        rank : ?Nat64; 
        height : ?Nat64;
        avatar : ?TokenIdentifier;  // TokenIdentifier of the avatar created by the user - it might not be updated in the future if we decide to allow sell/transfer
        airdrop : ?[Text];
        status : Status;
    };


    public type WhiteListRequest = {
       principal : Principal;
       wallet : Text;
       height : Nat64;
       email : ?Text;
       discord : ?Text;
       twitter : ?Text;
   };

   public type Infos = {
        wallet : Text;
        email : ?Text;
        discord : ?Text;
        twitter : ?Text;
        subaccount_to_send : [Nat8];
        memo : Nat64;
   };

   public type InfosNew = {
        wallet : Text;
        email : ?Text;
        discord : ?Text;
        twitter : ?Text;
   };

   public type JoiningError = {
        caller : Principal;
        error_message : Text;
        request_associated : ?WhiteListRequest;
   };

   public type PaymentError = {
       caller : Principal;
       error_message : Text;
       request_associated : ?Infos;
   };

    public type ResultRequest = Result.Result<Text,Text>; 


}