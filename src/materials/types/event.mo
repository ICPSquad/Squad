module Event {
    public type Callback = shared (msg : Message) -> async ();
    public type TopupCallback = shared () -> async ();

    public type CallbackStatus = {
        callback            : ?Callback;
        callsSinceLastTopup : Nat;
        noTopupCallLimit    : Nat;
        failedCalls         : Nat;
        failedCallsLimit    : Nat;
    };

    public type Message = {
        createdAt     : Int;
        event         : {
            #ContractEvent : Contract; 
            #TokenEvent    : Token;
            #MaterialEvent : Material;
            #AccessoryEvent : Accessory
        };
        topupCallback : TopupCallback;
        topupAmount   : Nat;
    };

    public type Material = {
        #Created : {
            name : Text; 
            id : Text;
            to : Principal;

        };
        #Burn : {
            name : Text;
            by : Principal;
            id : Text;
            for_accessory_id : Text; //Specify the accessory this material was burn for
        };
    };

    public type Accessory = {
        #Created : {
            name : Text;
            id : Text;
            to : Principal;
        };
        #Wear : {
            name : Text;
            id : Text;
            to : Principal;
        };
    };


    public type Token = {
        #Transfer : {
            id   : Text; 
            from : Principal; 
            to   : Principal;
        };
        #Authorize : {
            id           : Text; 
            user         : Principal; 
            isAuthorized : Bool;
        };
    };

    public type Contract = {
        #ContractAuthorize : {
            user         : Principal; 
            isAuthorized : Bool;
        };
        #Mint : {
            id    : Text; 
            owner : Principal;
        };
    };
}