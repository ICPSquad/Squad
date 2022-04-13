import Array "mo:base/Array";
import Blob "mo:base/Blob";
import Buffer "mo:base/Buffer";
import Debug "mo:base/Debug";
import HashMap "mo:base/HashMap";
import Iter "mo:base/Iter";
import Nat "mo:base/Nat";
import Result "mo:base/Result";
import Text "mo:base/Text";

import Types "types";

module {
    
    ////////////
    // Types //
    //////////

    public type FilePath = Types.FilePath;
    public type File = Types.File;
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
        private let files : HashMap.HashMap<FilePath,File> = HashMap.HashMap(0, Text.equal, Text.hash);

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

        public func upload(
            bytes : [Nat8],
        ) : () {
            for(byte in bytes.vals()){
                buffer.add(byte);
            };
        };

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

        public func uploadClear(): () {
            buffer.clear();
        };
        
        public func delete(filePath : FilePath) : Result<(), Text> {
            switch(files.remove(filePath)){
                case(null) return #err("File not found : " # filePath);
                case(?record) return #ok;
            };
        };

        public func getFile(
            filePath : FilePath
        ) : ?File {
            switch(files.get(filePath)){
                case(?record) return ?record;
                case(null) return null;
            }
        };

        public func getComponent(
            name : Text,
            layerId : Nat
        ) : Result<Text,Text> {
            let filePath = name # "-" # Nat.toText(layerId);
            switch(files.get(filePath)){
                case(null) {
                    return #err("Asset not found for : " # filePath);
                };
                case(?file) {
                    switch(Text.decodeUtf8(file.asset.payload)){
                        case(null) return #err("Error during decodeUtf8 : " # filePath);
                        case(?svg) {
                            return #ok(svg);
                        };
                    };
                };  
            };
        };

        public func getManifest() : [File] {
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
    };
 };