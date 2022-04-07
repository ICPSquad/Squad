import Array "mo:base/Array";
import Cycles "mo:base/ExperimentalCycles";
import Float "mo:base/Float";
import Iter "mo:base/Iter";
import Nat "mo:base/Nat";
import Prim "mo:prim";
import Principal "mo:base/Principal";
import Text "mo:base/Text";

import Ext "mo:ext/Ext";

import AssetTypes "../assets/types";
import SVG "../utils/svg";
import Types "types";
module {

    ////////////
    // Types //
    //////////

    public type Request = Types.Request;
    public type Response = Types.Response;
    

    public class HttpHandler(state : Types.Dependencies) {

        ////////////////////
        // Path Handlers //
        //////////////////

        public func request(request : Types.Request) : Types.Response {
            let path = Iter.toArray(Text.tokens(request.url, #text("/")));
            switch(path.size()){
                case 0 return _httpIndex();
                case 1 {
                    for((key, handler) in Iter.fromArray(paths)){
                        if(path[0] == key) return handler(null);
                    };
                    return _http404(?("No handler for path: " # path[0]));
                };
                case 2 {
                    for((key, handler) in Iter.fromArray(paths)){
                        if(path[0] == key) return handler(?path[1]);
                    };
                    return _http404(?("No handler for path: " # path[0] # "/" # path[1]));
                };
                case _ return _http404(?"Path not found");
            }
        };

        // A 404 response with an optional error message.
        func _http404(msg : ?Text) : Types.Response {
            {
                body = Text.encodeUtf8(
                    switch (msg) {
                        case (?msg) msg;
                        case null "Not found.";
                    }
                );
                headers = [
                    ("Content-Type", "text/plain"),
                ];
                status_code = 404;
                streaming_strategy = null;
            };
        };

        // @path: /
        func _httpIndex() : Types.Response {
            let assets_stats = state._Assets.getStats();
            let avatar_stats = state._Avatar.getStats();
          {
            body = Text.encodeUtf8(
                "ICP Squad Season #0 : the incredible Internet Computer community.\n"
                # "---\n"
                # "Cycle Balance: " # Nat.toText(Cycles.balance() / 1_000_000_000_000) # "T\n"
                # "Admins  : " # Text.join(" /", Array.map<Principal,Text>(state._Admins.getAdmins(), Principal.toText).vals()) # "\n"
                # "Asset uploaded : " # Nat.toText(assets_stats.0) # " for size " # Nat.toText(assets_stats.1) # " bytes" # " ( " # Float.toText(Float.fromInt(assets_stats.1) / (1024 * 1024))  # "Mb" # " )\n"
                # "Minted avatar (normal): ?" # Nat.toText(avatar_stats.0) # "\n"
                # "Minted avatar (legendaries): ?" # Nat.toText(avatar_stats.1) # "\n"
                # "---\n"
                # "Version : " # Prim.rts_version() # "\n"
                # "Heap size (current): " # Nat.toText(Prim.rts_heap_size()) # " bytes" # " ( " # Float.toText(Float.fromInt(Prim.rts_heap_size() / (1024 * 1024)))  # "Mb" # " )\n"
                # "Heap size (max)" # Nat.toText(Prim.rts_max_live_size()) # " bytes" # " ( " # Float.toText(Float.fromInt(Prim.rts_max_live_size() / (1024 * 1024)))  # "Mb" # " )\n"
                # "Memory size " # Nat.toText(Prim.rts_memory_size()) # " bytes" # " ( " # Float.toText(Float.fromInt(Prim.rts_memory_size() / (1024 * 1024)))  # "Mb" # " )\n"
                # "Reclaimed " # Nat.toText(Prim.rts_reclaimed()) # " bytes" # " ( " # Float.toText(Float.fromInt(Prim.rts_reclaimed() / (1024 * 1024)))  # "Mb" # " )\n"
                # "Total allocation " # Nat.toText(Prim.rts_total_allocation()) # " bytes");
            headers = [
                ("Content-Type", "text/plain"),
            ];
            status_code = 200;
            streaming_strategy = null;
          };
        };

        // @path : /assets/<text>
        // @path : /asset/<text>
        // Serves an sset based on filename.
        func _httpAssetFilename(path : ?Text) : Types.Response {
            switch(path){
                case(?path){
                    switch(state._Assets.getFileByName(path)){
                        case(?record) {
                            if(record.meta.category == #AvatarComponent or record.meta.category == #AccessoryComponent){
                                _renderComponent(record.asset.payload);
                            } else {
                                _renderAsset(record);
                            }
                        };
                        case _ _http404(?"Asset not found.");
                    };
                };
                case _ return _httpAssetManifest(null);
            };
        };

       // @path: /asset-manifest
        // Serves a JSON list of all assets in the canister.
        func _httpAssetManifest (path : ?Text) : Types.Response {
            {
                body = Text.encodeUtf8(
                    "[\n" #
                    Array.foldLeft<AssetTypes.Record, Text>(state._Assets.getManifest(), "", func (a, b) {
                        let comma = switch (a == "") {
                            case true "\t";
                            case false ", ";
                        };
                        a # comma # "{\n" #
                            "\t\t\"filename\": \"" # b.meta.name # "\",\n" #
                            "\t\t\"url\": \"/assets/" # b.meta.name # "\",\n" #
                            "\t\t\"description\": \"" # b.meta.description # "\",\n" #
                            "\t\t\"tags\": [" # Array.foldLeft<Text, Text>(b.meta.tags, "", func (a, b) {
                                let comma = switch (a == "") {
                                    case true "";
                                    case false ", ";
                                };
                                a # comma # "\"" # b # "\""
                            }) # "]\n" #
                        "\t}";
                    }) #
                    "\n]"
                );
                headers = [
                    ("Content-Type", "application/json"),
                ];
                status_code = 200;
                streaming_strategy = null;
            }
        };



        // @path: /new/<tokenId>
        // Serve an avatar based on tokenId using the svg format. 
        func _httpAvatar(
            tokenId : ?Ext.TokenIdentifier,
        ) : Types.Response {
            switch(tokenId){
                case(?tokenId){
                    switch(state._Avatar.getAvatar(tokenId)){
                        case(?avatar) _renderBlob(avatar.blob, "image/svg+xml");
                        case _ _http404(?"Asset not found.");
                    };
                };
                case _ return _http404(?"No avatar specified.");
            };
        };

        ////////////////
        // Renderers //
        //////////////

        // Create an HTTP response from an Asset Record.
        func _renderAsset(
            record : AssetTypes.Record,
        ) : Types.Response {
            {
                body = record.asset.payload;
                headers = [
                    ("Content-Type", record.asset.contentType),
                    ("Access-Control-Allow-Origin", "*"),
                ];
                status_code = 200;
                streaming_strategy = null;
            }
        };

        // Create an HTTP from a component
        func _renderComponent(
            payload : Blob
        ) : Types.Response {
            switch(Text.decodeUtf8(payload)){
                case(?svg) _renderBlob(Text.encodeUtf8(SVG.addHeader(svg)), "image/svg+xml");
                case _ _http404(?"Asset not found.");
            };
        };

        // Create an HTTP response from an blob.
        func _renderBlob(
            blob : Blob,
            contentType : Text,
        ) : Types.Response {
            {
                body = blob;
                headers = [
                    ("Content-Type", contentType),
                    ("Access-Control-Allow-Origin", "*"),
                ];
                status_code = 200;
                streaming_strategy = null;
            }
        };


        //////////////////
        // Path Config //
        ////////////////

        let paths : [(Text , (path : ?Text) -> Types.Response)] = [
            ("asset", _httpAssetFilename),
            ("assets", _httpAssetFilename),
            ("asset-manifest", _httpAssetManifest),
            ("new", _httpAvatar)
        ];

    };

    

}