import Buffer "mo:base/Buffer";
import Hash "mo:base/Hash";
import HashMap "mo:base/HashMap";
import Types "types";

module {
    // TODO: make this configurable.
    public let TTL : Int = 5_000_000_000; // 5 sec.

    public type Data<K> = HashMap.HashMap<
        K,
        (
            Int,                 // TTL
            Buffer.Buffer<Blob>, // Buffered data.
        ),
    >;

    public func empty<K>(
        capacity : Nat,
        equal    : (K, K) -> Bool,
        hash     : (K) -> Hash.Hash,
    ) : Data<K> {
        HashMap.HashMap<K, (Int, Buffer.Buffer<Blob>)>(
            capacity, equal, hash,
        );
    };

    public type WriteNFT = {
        #Init : {
            size     : Nat; 
            callback : ?Types.Callback;
        };
        #Chunk : {
            id       : Text;
            chunk    : Blob; 
            callback : ?Types.Callback;
        };
    };

    public type WriteAsset = {
        #Init : {
            id       : Text;
            size     : Nat; 
            callback : ?Types.Callback;
        };
        #Chunk : {
            id       : Text;
            chunk    : Blob; 
            callback : ?Types.Callback;
        };
    };
}