module Admins {

    public type State = {
        admins : [Principal];
    };

    public type Interface = {
        //  Check if a principal is an admin.
        isAdmin : (p : Principal) -> Bool;

        //  Add a new principal as admin.
        //  @auth : Admin
        addAdmin : (p : Principal, caller : Principal) -> ();

        //  Remove a principal from the list of admins. 
        //  @auth : admin
        removeAdmin : (p : Principal, caller : Principal) -> ();

        //  Get the state of the module.Interface
        getStateStable : () -> [Principal];
    };
}