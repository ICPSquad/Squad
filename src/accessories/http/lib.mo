import Array "mo:base/Array";
import Char "mo:base/Char";
import Cycles "mo:base/ExperimentalCycles";
import Debug "mo:base/Debug";
import Float "mo:base/Float";
import Iter "mo:base/Iter";
import Nat "mo:base/Nat";
import Nat32 "mo:base/Nat32";
import Prim "mo:prim";
import Principal "mo:base/Principal";
import Text "mo:base/Text";

import Ext "mo:ext/Ext";

import Types "types";
module {

    ////////////
    // Types //
    //////////

    public type Request = Types.Request;
    public type Response = Types.Response;
    type TokenIdentifier = Ext.TokenIdentifier;
    type TokenIndex = Ext.TokenIndex;
    
    public class HttpHandler(dependencies : Types.Dependencies) {

        ////////////
        // State //
        ///////////

        let _Admins = dependencies._Admins;
        let _Items = dependencies._Items;
        let _Logs = dependencies._Logs;

        let HTML_BLOCK_START = "<!DOCTYPE html><html lang='en'><head><style>img{ width: 300px;height : 300px; padding : 10px 10px 10px 10px;}div{ margin : 25px 25px 25px 25px;}</style><meta charset='UTF-8'><meta http-equiv='X-UA-Compatible' content='IE=edge'><meta name='viewport' content='width=device-width, initial-scale=1.0'><title>dSquad</title></head><body>";
        let HTML_BLOCK_END = "</body></html>";
        let SRC_IC = "https://" # Principal.toText(dependencies.cid) # ".raw.ic0.app/tokenIndex/";
        let SRC_LOCAL = "http://" # Principal.toText(dependencies.cid) # ".localhost:8000/tokenIndex/";


        //////////////////
        // Utilities ////
        ////////////////

        func _textToNat32( txt : Text) : ?Nat32 {
            if(txt.size() == 0) {
                return null;
            };
            let chars = txt.chars();
            var num : Nat32 = 0;
            for (v in chars){
                let charToNum = Char.toNat32(v)-48;
                assert(charToNum >= 0 and charToNum <= 9);
                num := num * 10 +  charToNum;          
            };
            ? num;
        };

        func _imgBlockFromTokenIndex(index : TokenIndex) : Text {
            let img = "<img src='" # SRC_LOCAL # Nat32.toText(index) # "'>";
        };

        ////////////
        // API ////
        //////////

        public func request(request : Types.Request) : Types.Response {
            if (Text.contains(request.url, #text("tokenid"))) {
                return _httpTokenIdentifier(?Iter.toArray(Text.tokens(request.url, #text("tokenid=")))[1]);
            };
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

        ////////////////////
        // Path Handlers //
        //////////////////

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
          {
            body = Text.encodeUtf8(
                "dSquad Season #0 : the incredible Internet Computer community (Accessories).\n"
                # "---\n"
                # "Cycle Balance: " # Nat.toText(Cycles.balance() / 1_000_000_000_000) # "T\n"
                # "Admins  : " # Text.join(" /", Array.map<Principal,Text>(dependencies._Admins.getAdmins(), Principal.toText).vals()) # "\n"
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

        // @path : /overview/<number>
        // Serves an overview of the first <number> minted assets. Cannot be higher than 100 assets (too expensive).
        func _httpOverview(number : ?Text) : Types.Response {
            switch(number){
                case(null) return _http404(?"You need to specify a number");
                case(? number){
                    let nb = _textToNat32(number);
                    switch(nb){
                        case(null) return _http404(?"Number not found");
                        case(?nb) {
                            if(nb > 100){
                                return _http404(?"Number too high");
                            };
                            var xml = HTML_BLOCK_START; 
                            for(x in Iter.range(0, Nat32.toNat(nb))){
                                if(x % 8 == 0){
                                    xml #= "<div>"# _imgBlockFromTokenIndex(Nat32.fromNat(x));
                                } else if(x % 8 == 7){
                                    xml #= _imgBlockFromTokenIndex(Nat32.fromNat(x)) # "</div>";
                                } else {
                                    xml #= _imgBlockFromTokenIndex(Nat32.fromNat(x));
                                }
                            };
                            xml #= HTML_BLOCK_END;
                            return {
                                body = Text.encodeUtf8(xml);
                                headers = [
                                    ("Content-Type", "text/html"),
                                ];
                                status_code = 200;
                                streaming_strategy = null;
                            };
                        };
                    };
                };
            };
        };

        // @path : /template/<name>
        // Serves the template of the item with the given name.
        func _httpTemplate(name : ?Text) : Types.Response {
            switch(name){
                case(null) return _http404(?"You need to specify a name");
                case(? name){
                    switch(_Items.getTemplate(name)){
                        case(null) return _http404(?"No template found");
                        case(? blob) {
                            _renderBlob(blob, "image/svg+xml");
                        };
                    };
                };
            };
        };

        // @path : /tokenIndex/<tokenIndex>
        // Serves the blob corresponding to this tokenIndex
        func _httpTokenIndex(tokenIndex : ?Text) : Types.Response {
            switch(tokenIndex) {
                case(null) return _http404(?"No tokenIndex specified");
                case(? tokenIndex){
                    let index = _textToNat32(tokenIndex);
                    switch(index){
                        case(? index){
                            switch(_Items.getBlob(index)){
                                case(? blob) {
                                    _renderBlob(blob, "image/svg+xml");
                                };
                                case _ _http404(?"Asset not found for this index.");
                            };
                        };
                        case _ _http404(?"Invalid tokenIndex.");
                    }
                }
            }
        };

        // @path : /tokenId=<tokenId>
        // Serves the blob corresponding to this tokenIdentifier
        func _httpTokenIdentifier(
            tokenIdentifier : ?TokenIdentifier
        ) : Types.Response {
            switch(tokenIdentifier){
                case(null) return _http404(?"No tokenIdentifier specified");
                case(? tokenIdentifier) {
                    let index = switch(Ext.TokenIdentifier.decode(tokenIdentifier)){
                        case(#ok(p, i)) {
                            if(p != dependencies.cid){
                                _Logs.logMessage("Error when decoding the tokenIdentifier : " # tokenIdentifier # "the canister id is " # Principal.toText(p));
                                return _http404(?"This tokenIdentifier doesn't belong to this canister.");
                            };
                            i;
                        };
                        case(#err(e)) {
                            _Logs.logMessage("Error during decode of tokenIdentifier : " # tokenIdentifier # ". Detail : " # e);
                            return _http404(?"This tokenIdentifier is not valid.");
                        };
                    };
                    switch(_Items.getBlob(index)){
                        case(? blob) {
                            _renderBlob(blob, "image/svg+xml");
                        };
                        case _ _http404(?"Asset not found for this index.");
                    };
                };
            };
        };

        ////////////////
        // Renderers //
        //////////////

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
            ("tokenIndex", _httpTokenIndex), 
            ("tokenIdentifier", _httpTokenIdentifier), 
            ("template", _httpTemplate), 
            ("overview", _httpOverview),
        ];

        };
};