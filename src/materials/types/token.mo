import Array "mo:base/Array";
import Blob "mo:base/Blob";
import Buffer "mo:base/Buffer";
import Hash "mo:base/Hash";
import HashMap "mo:base/HashMap";
import Http "http";
import Iter "mo:base/Iter";
import MapHelper "../helper/mapHelper";
import Nat "mo:base/Nat";
import Principal "mo:base/Principal";
import Property "property";
import Result "mo:base/Result";
import Staged "staged";
import Text "mo:base/Text";
import Time "mo:base/Time";
import Types "types";

module Token {

    public let AUTHORIZED_LIMIT = 25;

    public type AuthorizeRequest = {
        id           : Text;
        p            : Principal;
        isAuthorized : Bool;
    };

    public type Token = {
        payload     : [Blob];
        contentType : Text;
        createdAt   : Int;
        properties  : Property.Properties;
        isPrivate   : Bool;
    };

    public type Metadata = {
        id          : Text;
        contentType : Text;
        owner       : Principal;
        createdAt   : Int;
        properties  : Property.Properties;
    };

    public type PublicToken = {
        id          : Text;
        payload     : PayloadResult;
        contentType : Text;
        owner       : Principal;
        createdAt   : Int;
        properties  : Property.Properties;
    };

    public type PayloadResult = {
        #Complete : Blob;
        #Chunk    : Chunk;
    };

    public type Chunk = {
        data       : Blob; 
        nextPage   : ?Nat; 
        totalPages : Nat;
    };

    public type Egg = {
        payload : {
            #Payload    : Blob;
            #StagedData : Text;
        };
        contentType : Text;
        owner       : ?Principal;
        properties  : Property.Properties;
        isPrivate   : Bool;
    };

    public class NFTs(
        lastID        : Nat,
        lastTotalSize : Nat,
        nftEntries : [(
            Text, // Token Identifier.
            (
                ?Principal, // Owner of the token.
                [Principal] // Authorized principals.
            ), 
            Token, // NFT data.
        )],
    ) {
        var id = lastID;
        public func currentID() : Nat { id; };

        var totalSize = lastTotalSize;
        public func payloadSize() : Nat { id; };

        var stagedData = Staged.empty<Text>(
            0, Text.equal, Text.hash,
        );

        let nfts = HashMap.HashMap<Text, Token>(
            nftEntries.size(),
            Text.equal,
            Text.hash,
        );
        let authorized = HashMap.HashMap<Text, [Principal]>(
            0,
            Text.equal,
            Text.hash,
        );
        let nftToOwner = HashMap.HashMap<Text, Principal>(
            nftEntries.size(),
            Text.equal,
            Text.hash,
        );
        let ownerToNFT = HashMap.HashMap<Principal, [Text]>(
            nftEntries.size(),
            Principal.equal,
            Principal.hash,
        );
        for ((t, (p, ps), nft) in Iter.fromArray(nftEntries)) {
            nfts.put(t, nft);
            if (ps.size() != 0) {
                authorized.put(t, ps);
            };
            switch (p) {
                case (null) {};
                case (? v)  {
                    nftToOwner.put(t, v);
                    switch (ownerToNFT.get(v)) {
                        case (null) ownerToNFT.put(v, [t]);
                        case (? ts) ownerToNFT.put(v, Array.append(ts, [t]));
                    };
                };
            };
        };

        public func entries() : Iter.Iter<(Text, (?Principal, [Principal]), Token)> {
            return Iter.map<(Text, Token), (Text, (?Principal, [Principal]), Token)>(
                nfts.entries(),
                func((t, n) : (Text, Token)) : (Text, (?Principal, [Principal]), Token) {
                    let ps = switch (authorized.get(t)) {
                        case (null) { []; };
                        case (? v)  { v;  };
                    };
                    switch (nftToOwner.get(t)) {
                        case (null) { return (t, (null, ps), n); };
                        case (? p)  { return (t, (?p,   ps), n); };
                    };
                },
            );
        };

        public func getTotalMinted() : Nat {
            return nfts.size();
        };

        public func writeStaged(data : Staged.WriteNFT) : async Result.Result<Text, Text> {
            switch (data) {
                case (#Init(v)) {
                    let id_ = Nat.toText(id);
                    stagedData.put(
                        id_, (
                            Time.now() + Staged.TTL,
                            Buffer.Buffer(v.size),
                        ),
                    );
                    id += 1;
                    ignore Types.notify(v.callback);
                    #ok(id_);
                };
                case (#Chunk(v)) {
                    switch (stagedData.get(v.id)) {
                        case (null) {
                            return #err("data was not initialized or was removed (passed ttl)");
                        };
                        case (? (ttl, buffer)) {
                            if (ttl < Time.now()) {
                                stagedData.delete(v.id);
                                return #err("data was removed (passed ttl)")
                            };
                            let buf = buffer;
                            buf.add(v.chunk);
                            stagedData.put(v.id, (
                                Time.now() + Staged.TTL, // Reset TTL.
                                buf,
                            ));
                            ignore Types.notify(v.callback);
                            #ok(v.id);
                        };
                    };
                };
            };
        };

        public func ownerOf(id : Text) : Result.Result<Principal, Types.Error> {
            switch (nftToOwner.get(id)) {
                case (null) { return #err(#NotFound); };
                case (? v)  { return #ok(v);          };
            };
        };

        public func isAuthorized(p : Principal, id : Text) : Bool {
            switch (authorized.get(id)) {
                case (null) { false; };
                case (? ps) {
                    // Check wheter the principal is authorized.
                    switch (Array.find<Principal>(ps, func (v) { return v == p; })) {
                        case (null) { false; };
                        case (?  v) { true;  };
                    };
                };
            };
        };

        public func getAuthorized(id : Text) : [Principal] {
            switch (authorized.get(id)) {
                case (null) { return []; };
                case (? v)  { return v;  };
            };
        };

        public func tokensOf(p : Principal) : [Text] {
            switch (ownerToNFT.get(p)) {
                case (null) { return []; };
                case (? v)  { return v;  };
            };
        };

        public func mint(hub : Principal, egg : Egg) : async Result.Result<(Text, Principal), Text> {
            let (size, id_) : (Nat, Text) = switch (egg.payload) {
                case (#Payload(v)) {
                    let id_ = Nat.toText(id);
                    id += 1;
                    nfts.put(id_, {
                        contentType = egg.contentType;
                        createdAt   = Time.now();
                        payload     = [v];
                        properties  = egg.properties;
                        isPrivate   = egg.isPrivate;
                    });
                    (v.size(), id_);
                };
                case (#StagedData(id_)) {
                    switch (stagedData.get(id_)) {
                        case (null) {
                            return #err("data was not initialized or was removed (passed ttl)");
                        };
                        case (? (ttl, data)) {
                            if (ttl < Time.now()) {
                                stagedData.delete(id_);
                                return #err("data was removed (passed ttl)")
                            };
                            nfts.put(id_, {
                                contentType = egg.contentType;
                                createdAt   = Time.now();
                                payload     = data.toArray();
                                properties  = egg.properties;
                                isPrivate   = egg.isPrivate;
                            });
                            var size = 0;
                            for (x in data.vals()) {
                                size := size + x.size();
                            };
                            stagedData.put(id_, (
                                Time.now() + Staged.TTL,
                                Buffer.Buffer(0),
                            ));
                            (size, id_);
                        };
                    };
                };
            };
            totalSize += size;

            let owner = switch (egg.owner) {
                case (null) { hub; };
                case (? v)  { v;   };
            };

            nftToOwner.put(id_, owner);
            MapHelper.add<Principal, Text>(
                ownerToNFT,
                owner,
                id_,
                MapHelper.textEqual(id_),
            );

            #ok(id_, owner);
        };

        // To make the public function createAccessory atomic we need a synchrounous mint method for this class 
        public func mintSynchro (hub : Principal, egg : Egg) : Result.Result<(Text,Principal), Text> {
            let (size, id_) : (Nat, Text) = switch (egg.payload) {
                case (#Payload(v)) {
                    let id_ = Nat.toText(id);
                    id += 1;
                    nfts.put(id_, {
                        contentType = egg.contentType;
                        createdAt   = Time.now();
                        payload     = [v];
                        properties  = egg.properties;
                        isPrivate   = egg.isPrivate;
                    });
                    (v.size(), id_);
                };
                case (#StagedData(id_)) {
                    switch (stagedData.get(id_)) {
                        case (null) {
                            return #err("data was not initialized or was removed (passed ttl)");
                        };
                        case (? (ttl, data)) {
                            if (ttl < Time.now()) {
                                stagedData.delete(id_);
                                return #err("data was removed (passed ttl)")
                            };
                            nfts.put(id_, {
                                contentType = egg.contentType;
                                createdAt   = Time.now();
                                payload     = data.toArray();
                                properties  = egg.properties;
                                isPrivate   = egg.isPrivate;
                            });
                            var size = 0;
                            for (x in data.vals()) {
                                size := size + x.size();
                            };
                            stagedData.put(id_, (
                                Time.now() + Staged.TTL,
                                Buffer.Buffer(0),
                            ));
                            (size, id_);
                        };
                    };
                };
            };
            totalSize += size;

            let owner = switch (egg.owner) {
                case (null) { hub; };
                case (? v)  { v;   };
            };

            nftToOwner.put(id_, owner);
            MapHelper.add<Principal, Text>(
                ownerToNFT,
                owner,
                id_,
                MapHelper.textEqual(id_),
            );

            #ok(id_, owner);
        };

        public func transfer(to : Principal, id : Text) : async Result.Result<(), Types.Error> {
            switch (nfts.get(id)) {
                case (null) {
                    // NFT does not exist.
                    return #err(#NotFound);
                };
                case (? v) {};
            };
            switch (nftToOwner.get(id)) {
                case (null) { };
                case (? v)  {
                    // Can not send NFT to yourself.
                    if (v == to) { return #err(#InvalidRequest); };
                    // Remove previous owner.
                    MapHelper.filter<Principal, Text>(
                        ownerToNFT, 
                        v, 
                        id, 
                        MapHelper.textNotEqual(id),
                    );
                };
            };

            nftToOwner.put(id, to);
            MapHelper.add<Principal, Text>(
                ownerToNFT, 
                to,
                id, 
                MapHelper.textEqual(id),
            );
            #ok();
        };

        public func authorize(req : AuthorizeRequest) : Bool {
            if (not req.isAuthorized) {
                MapHelper.filter<Text,Principal>(
                    authorized,
                    req.id,
                    req.p,
                    func (v) { v != req.p },
                );
                return true;
            };
            MapHelper.addIfNotLimit<Text, Principal>(
                authorized,
                req.id,
                req.p,
                AUTHORIZED_LIMIT,
                MapHelper.principalEqual(req.p),
            );
        };

        public func getToken(id : Text) : Result.Result<Token, Types.Error> {
            switch (nfts.get(id)) {
                case (null) { return #err(#NotFound); };
                case (? v)  { return #ok(v);          };
            };
        };

        // Returns an NFT based on the given key (identifier).
        // Limitation: callback is a shared function and is only allowed as a public field of an actor.
        public func get(key : Text, callback : Http.StreamingCallback) : Http.Response {
            switch (nfts.get(key)) {
                case (null) { Http.NOT_FOUND() };
                case (? v)  {
                    if (v.isPrivate) return Http.UNAUTHORIZED();
                    if (v.payload.size() > 1) {
                        return Http.handleLargeContent(
                            key,
                            v.contentType,
                            v.payload,
                            callback,
                        );
                    };
                    return {
                        status_code        = 200;
                        headers            = [("Content-Type", v.contentType)];
                        body               = v.payload[0];
                        streaming_strategy = null;
                    };
                };
            };
        };

        // @pre: key exists.
        public func updateProperties(key : Text, ps : Property.Properties) : Result.Result<(), Types.Error> {
            switch (nfts.get(key)) {
                case (null)  { #err(#NotFound); };
                case (? nft) {
                    nfts.put(key, {
                        contentType = nft.contentType;
                        createdAt   = nft.createdAt;
                        isPrivate   = nft.isPrivate;
                        payload     = nft.payload;
                        properties  = ps;
                    });
                    #ok();
                };
            };
        };

        public func burn (token : Text) : Result.Result<(), Text> {
            // Just a random value
            var _owner: Principal = Principal.fromText("dv5tj-vdzwm-iyemu-m6gvp-p4t5y-ec7qa-r2u54-naak4-mkcsf-azfkv-cae");
            switch(nfts.get(token)) {
                case (null) return #err ("Token not found in : nfts.");
                case (?found) {
                    nfts.delete(token);
                };
            };
            switch(nftToOwner.get(token)) {
                case (null) return #err("Token not found in : nftToOwner");
                case(?owner) {
                    nftToOwner.delete(token);
                    _owner := owner;
                };
            };
            switch(ownerToNFT.get(_owner)) {
                case (null) return #err("Token not found in : ownerToNFT");
                case (?list) {
                    // Remove the token from the list of tokens of the owner
                    MapHelper.filter<Principal, Text>(
                        ownerToNFT, 
                        _owner, 
                        token, 
                        MapHelper.textNotEqual(token),
                    );
                };
            };
            return #ok();
        };

    };
};
