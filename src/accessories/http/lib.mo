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
    
    public class HttpHandler(state : Types.Dependencies) {


        public func request(request : Types.Request) : Types.Response {
            if (Text.contains(request.url, #text("tokenid"))) {
                return _http404(?"To do");
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

        ///////////////////
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
                "ICP Squad Season #0 : the incredible Internet Computer community (Accessories).\n"
                # "---\n"
                # "Cycle Balance: " # Nat.toText(Cycles.balance() / 1_000_000_000_000) # "T\n"
                # "Admins  : " # Text.join(" /", Array.map<Principal,Text>(state._Admins.getAdmins(), Principal.toText).vals()) # "\n"
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



        // @path : /overview
        // Serves an overview of all the minted assets.
        // func () : Types.Response {
        
        // };

        // @path : /tokenIndex/<tokenIndex>
        // Serves the blob corresponding to this tokenIndex
        // func _httpTokenIndex(tokenIndex : ?Text) : Types.Response {
        //     switch(tokenIndex) {
        //         case(null) return _http404(?"No tokenIndex specified");
        //         case(? tokenIndex){
        //             let index = _textToNat32(tokenIndex);
        //             switch(index){
        //                 case(? index){
        //                     switch(state._blobs.get(index)){
        //                         case(? blob) {
        //                             _renderBlob(blob, "image/svg+xml");
        //                         };
        //                         case _ _http404(?"Asset not found for this index.");
        //                     };
        //                 };
        //             }
        //         }
        //     }
        // };


    
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
            // ("tokenIndex", _httpTokenIndex) 
        ];

        };
};