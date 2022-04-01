import Types "types";
import Text "mo:base/Text";
import Cycles "mo:base/ExperimentalCycles";
import Iter "mo:base/Iter";
import Array "mo:base/Array";
import Principal "mo:base/Principal";
import Nat "mo:base/Nat";
import Float "mo:base/Float";
import Ext "mo:ext/Ext";
import AssetTypes "../assets/types";
module {

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
          {
            body = Text.encodeUtf8(
                "ICP Squad Season #0 : the incredible Internet Computer community.\n"
                # "---\n"
                # "Cycle Balance: " # Nat.toText(Cycles.balance() / 1_000_000_000_000) # "T\n"
                # "Minted Avatar : ?" # "\n"
                # "Admins  : " # Text.join(" /", Array.map<Principal,Text>(state._Admins.getAdmins(), Principal.toText).vals()) # "\n"
                # "Asset uploaded : " # Nat.toText(assets_stats.0) # " for size " # Nat.toText(assets_stats.1) # " bytes" # " ( " # Float.toText(Float.fromInt(assets_stats.1) / (1024 * 1024))  # "Mb" # " )\n");
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
                        case(?record) _renderAsset(record);
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
                        case(?avatar) _renderBlob(avatar.blob, "image/xml+svg");
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