import Types "types";
import Buffer "mo:base/Buffer";
import Blob "mo:base/Blob";
import Text "mo:base/Text";
import HashMap "mo:base/HashMap";
import Nat "mo:base/Nat";
import Result "mo:base/Result";
import Iter "mo:base/Iter";
import Array "mo:base/Array";
import SVG "../utils/svg";

module {
    
    public class Assets(parameters : Types.Parameters) : Types.Interface {
        
        ////////////
        // State //
        //////////

        type FilePath = Types.FilePath;
        type Record = Types.Record;
        type Result<T,E> = Result.Result<T,E>;

        // The upload buffer, for adding additional assets.
        private let buffer : Buffer.Buffer<Nat8> = Buffer.Buffer(0);

        // The records that have been uploaded, stored by filePath.
        private let files : HashMap.HashMap<FilePath,Record> = HashMap.HashMap(0, Text.equal, Text.hash);

        public func toStableState() : [(FilePath, Record)] {
            return(Iter.toArray(files.entries()))
        };

        public func fromStableState(stableState : [(FilePath, Record)]) {
            for ((filePath,record) in stableState.vals()) {
                files.put(filePath, record);
            };
        };

        fromStableState(parameters.record);

        //////////
        // API ///
        /////////

        // Upload bytes into the buffer.
        // @auth : admin
        public func upload(
            caller : Principal,
            bytes : [Nat8],
        ) : () {
            assert(parameters._Admins.isAdmin(caller));
            for(byte in bytes.vals()){
                buffer.add(byte);
            };
        };

        // Finalize the upload buffer into an asset, and store a record with the filePath.
        // @auth : admin
        public func uploadFinalize(
            caller : Principal,
            contentType : Text,
            meta : Types.Meta,
            filePath : FilePath
        ) : Result<(), Text> {
            assert(parameters._Admins.isAdmin(caller));

            let asset = {
                contentType = contentType;
                payload = Blob.fromArray(buffer.toArray());
            };
            let record = {
                asset = asset;
                meta = meta;
            };
            files.put(filePath, record);
            buffer.clear();
            return #ok;
        };

        // Clear the upload buffer.
        // @auth : admin
        public func uploadClear(
            caller : Principal
        ): () {
            assert(parameters._Admins.isAdmin(caller));
            buffer.clear();
        };

        // Retrieve an asset using the filePath.
        public func getAssetByName(
            filePath : FilePath
        ) : ?Types.Asset {
            switch(files.get(filePath)){
                case(?record) return ?record.asset;
                case(null) return null;
            }
        };

        // Retrieve a record using the filePath.
        public func getFileByName(
            filePath : FilePath
        ) : ?Types.Record {
            switch(files.get(filePath)){
                case(?record) return ?record;
                case(null) return null;
            }
        };

        // Retrieve a comoponet as textual <g> element.
        public func getComponent(
            name : Text,
            layerId : Nat
        ) : Result<Text,Text> {
            let filePath = name # "-" # Nat.toText(layerId);
            switch(files.get(filePath)){
                case(null) return #err("Asset not found for : " # filePath);
                case(?file) {
                    switch(Text.decodeUtf8(file.asset.payload)){
                        case(null) return #err("Error during decodeUtf8 : " # filePath);
                        case(?svg) return #ok(SVG.unwrap(svg));
                    };
                };  
            };
        };

        ////////////////
        // Utilities //
        //////////////

        // Turn a list of blobs into one blob.
        func _flattenPayload (payload : [Blob]) : Blob {
            Blob.fromArray(
                Array.foldLeft<Blob, [Nat8]>(payload, [], func (a : [Nat8], b : Blob) {
                    Array.append(a, Blob.toArray(b));
                })
            );
        };


    };
 }