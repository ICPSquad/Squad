import Types "types";
import Text "mo:base/Text";
import Cycles "mo:base/ExperimentalCycles";
import Iter "mo:base/Iter";
import Array "mo:base/Array";
import Principal "mo:base/Principal";
import Nat "mo:base/Nat";
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
            //TODO : more informations.
          {
            body = Text.encodeUtf8(
                "ICP Squad Season #0 : the incredible Internet Computer community.\n"
                # "---\n"
                # "Minted Avatar : ?" # "\n"
                # "Cycle Balance: " # Nat.toText(Cycles.balance() / 1_000_000_000_000) # "T\n"
                # "Admins  : " # Text.join(" /", Array.map<Principal,Text>(state._Admins.toStableState(), Principal.toText).vals()) # "\n");
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

        func _httpAssetManifest(path : ?Text) : Types.Response {
            {
                body = Text.encodeUtf8("Asset manifest");
                headers = [
                    ("Content-Type", "text/plain"),
                ];
                status_code = 200;
                streaming_strategy = null;
            }
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

        //////////////////
        // Path Config //
        ////////////////

        let paths : [(Text , (path : ?Text) -> Types.Response)] = [
            ("asset", _httpAssetFilename),
            ("assets", _httpAssetFilename),
            ("asset-manifest", _httpAssetManifest),
        ];

    };

    

}