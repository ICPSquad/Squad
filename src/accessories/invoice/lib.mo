import Nat64 "mo:base/Nat64";
import Principal "mo:base/Principal";
import Result "mo:base/Result";

import Types "types";
module {

    ////////////
    // Types //
    ///////////

    public type Result<A,B> = Result.Result<A,B>;

    public class Factory (dependencies : Types.Dependencies) : Types.Interface {

        //////////////
        /// State ///
        ////////////
        private let INVOICE : Types.InvoiceInterface = actor(Principal.toText(dependencies.invoice_cid));

        public func verifyInvoice(
            id : Nat,
            caller : Principal
        ) : async Result<(),()>{
            switch(await INVOICE.verify_invoice_accessory({ id }, caller)){
                case(#err(_)) return #err();
                case(#ok(_)) return #ok();
            };
        };
    };
};