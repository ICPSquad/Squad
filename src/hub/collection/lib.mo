import Hash "mo:base/Hash";
import Principal "mo:base/Principal";
module {

    public type Collection = {
        name : Text;
        contractId : Principal;
    };

    public func equal(a : Collection, b : Collection) : Bool {
        return a.name == b.name and a.contractId == b.contractId;
    };

    public func hash(a : Collection) : Hash.Hash {
        Principal.hash(a.contractId);
    };

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

    public type Metadata = {
        name : Text;
        description : Text;
        thumbnail : Text;
        frontend : ?Text;
        principal_id : Principal;
        submitter : Principal;
        last_updated_by : Principal;
        last_updated_at : Nat64;
        details : [(Text, DetailValue)]
    };

    public type Dab = actor {
        name : shared () -> async Text;
        get : shared Principal -> async ?Metadata;
        get_all : shared () -> async [Metadata];
    };

};