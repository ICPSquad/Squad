import Prim "mo:prim";
import Result "mo:base/Result";
import Text "mo:base/Text";

import Ext "mo:ext/Ext";

import Types "types";


module {
    public class Factory(dependencies : Types.Dependencies) : Types.Interface {

        //////////////
        /// State ///
        ////////////

        private let _Ext = dependencies._Ext;
        private let _Logs = dependencies._Logs;

        var tickets : [Types.TokenIndex] = [];

        public func preupgrade() : Types.UpgradeData {
            return({
                tickets;
            })
        };
        public func postupgrade(ud : ?Types.UpgradeData) : () {
            switch(ud){
                case(null){};
                case(? ud){
                    tickets := ud.tickets;
                };
            };
        };

        public func isTicket(tokenIndex : Types.TokenIndex) : Bool {
            for(index in tickets.vals()){
                if(index == tokenIndex){
                    return true;
                };
            };
            return false;
        };

        public func addTicket(tokenIndex : Types.TokenIndex) : () {
            tickets := Array.append<Types.TokenIndex>(tickets, [tokenIndex]);
        };

        public func deleteTicket(tokenIndex  : Types.TokenIndex) : () {
            tickets := Array.filter<Types.TokenIndex>(tickets, func(x) -> {x != tokenIndex});
        };

        public func hasTicket(p : Principal) : Bool {
            let account = Text.map(Ext.AccountIdentifier.fromPrincipal(p, null), Prim.charToLower);
            switch(_Ext.tokens(account)){
                case(#err(_)) {
                    return false;
                };
                case(#ok(tokens)){
                    for(tokenIndex in tokens.vals()){
                        if(isTicket(tokenIndex)){
                            return true;
                        };
                    };
                    return false;
                };
            };
        };

        public func mintTicket(p : Principal) : Result.Result<Types.TokenIndex, Text> {
            // Mint token with EXT
            // Add token to list of tickets
        };

    };
}