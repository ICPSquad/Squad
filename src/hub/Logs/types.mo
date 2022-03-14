import List "mo:base/List";
module {

    public type DetailValue = {
        #I64 : Int64;
        #U64 : Nat64;
        #Vec : [DetailValue];
        #Slice : [Nat8];
        #Text : Text;
        #True;
        #False;
        #Float : Float;
        #Principal : Principal;
    };

    public type Event = {
        time : Nat64;
        operation : Text;
        details : [(Text, DetailValue)];
        caller : Principal;
        category : LogCategory;
    };

    public type LogCategory = {
        #ErrorSystem;
        #ErrorResult;
        #Result : Text;
        #Operation;
        #Cronic;
    };

    public type State = {
        events : [Event];
    };

    public type Percent = Nat;

    public type Interface = {
        // Push a new event to the log.
        addLog : (e : Event) -> ();
        //  Get the current state of the log.
        getLogs: () -> List.List<Event>;
        //  Remove the oldest percent% of the log. (only #Debug)
        purgeLogs: (percent : Percent) -> ();
        //  Get the stable state using an array.
        getStateStable : () -> [Event]; 
    };

};