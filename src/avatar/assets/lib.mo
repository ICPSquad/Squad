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
    
    
    ////////////
    // Types //
    //////////

    public type FilePath = Types.FilePath;
    public type Record = Types.Record;
    public type UpgradeData = Types.UpgradeData;
    public type Meta = Types.Meta;



    public class Assets() : Types.Interface {
        
        ////////////
        // State //
        //////////

        type Result<T,E> = Result.Result<T,E>;

        // The upload buffer, to add chunks of assets.
        private let buffer : Buffer.Buffer<Nat8> = Buffer.Buffer(0);

        // The records that have been uploaded, stored by filePath.
        private let files : HashMap.HashMap<FilePath,Record> = HashMap.HashMap(0, Text.equal, Text.hash);

        public func preupgrade() : UpgradeData {
            {
                record = Iter.toArray(files.entries());
            }
        };

        public func postupgrade(state : ?UpgradeData) : () {
            switch(state) {
                case (?state) {
                    for ((filePath,record) in state.record.vals()) {
                        files.put(filePath, record);
                    };
                };
                case _ {};
            };
        };

        //////////
        // API ///
        /////////

        // Upload bytes into the buffer.

        public func upload(
            bytes : [Nat8],
        ) : () {
            for(byte in bytes.vals()){
                buffer.add(byte);
            };
        };

        // Finalize the upload buffer into an asset, and store a record with the filePath.
        public func uploadFinalize(
            contentType : Text,
            meta : Types.Meta,
            filePath : FilePath
        ) : Result<(), Text> {
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
        public func uploadClear(): () {
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

        public func getManifest() : [Record] {
            Iter.toArray(files.vals())
        };

        public func getStats() : (Nat,Nat) {
            var assets_count = 0;
            var assets_size = 0;
            for (record in files.vals()) {
                assets_count += 1;
                assets_size += record.asset.payload.size();
            };
            return(assets_count, assets_size);
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