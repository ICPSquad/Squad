import Array "mo:base/Array";
import Principal "mo:base/Principal";
import Option "mo:base/Option";
import Types "types";
module {
    public class Factory (state : Types.State) {

        //  Returns a boolean indicating if the caller is an admin.
        //  Note : Should be implemented in its own lib.
        private func _isAdmin(caller : Principal) : Bool {
            return(Option.isSome(Array.find(state._Admins, f (x : Principal){Principal.equal(x, caller)})));
        };

        type detail_value = {
            #True;
            #False;
            #I64 : I64;
            #U64 : Nat64;
            #Vec : [detail_value];
            #Slice : [Nat8];
            #Text : Text;
            #Float : Float;
            #Principal : Principal;
        };

        type token = {
            name         : Text;
            description  : Text;
            thumbnail    : Text;
            frontend     : ?Text;
            principal_id : Principal;
            details      : [{Text; detail_value}];
        };

        let dab_interface = actor {
            get_all : query () -> async [token];
        };






    };
};