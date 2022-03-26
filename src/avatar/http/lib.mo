import Types "types";
import Text "mo:base/Text";
import Cycles "mo:base/ExperimentalCycles";
import Iter "mo:base/Iter";
import Array "mo:base/Array";
import Principal "mo:base/Principal";
import Nat "mo:base/Nat";
module {

    public class HttpHandler(state : Types.Dependencies) {

        ////////////////////
        // Path Handlers //
        //////////////////

        // A 404 response with an optional error message.
        private func http404(msg : ?Text) : Types.Response {
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
        private func httpIndex() : Types.Response {
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

        public func request(request : Types.Request) : Types.Response {
            let path = Iter.toArray(Text.tokens(request.url, #text("/")));
            switch(path.size()){
                case 0 return httpIndex();
                case _ return http404(?"Path not found.");
            }
        };



    };

    

}