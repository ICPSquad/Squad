import Nat64 "mo:base/Nat64";
import Principal "mo:base/Principal";
import Result "mo:base/Result";

import Types "types";
module {

    ////////////
    // Types //
    ///////////

    public type Result<A,B> = Result.Result<A,B>;
    public type AccountIdentifier = Types.AccountIdentifier;
    public type Invoice = Types.Invoice;
    public type Token = Types.Token;
    public type CreateInvoiceErr = Types.CreateInvoiceErr;
    public type VerifyInvoiceErr = Types.VerifyInvoiceErr;
    public type GetBalanceErr = Types.GetBalanceErr;
    public type TransferError = Types.TransferError;

    public class Factory (dependencies : Types.Dependencies) : Types.Interface {

        //////////////
        /// State ///
        ////////////

        private let WALLET_SQUAD = "7719a749a50477cc8062376306f7eec7ae365f5e44d9fd8222e4b4ee88e97c4c";
        private let ICP : Token = { symbol = "ICP" };
        private let CID : Principal = dependencies.cid;
        private let CREATOR : Principal = dependencies.creator;
        private let INVOICE : Types.InvoiceInterface = actor(Principal.toText(dependencies.invoice_cid));

        ////////////
        // API ////
        ///////////

        public func createInvoice(
            caller : Principal,
            amount : Nat,
        ) : async Result<Invoice, CreateInvoiceErr> {
            switch(await INVOICE.create_invoice({
                amount = amount;
                token = ICP;
                permissions = ?{canGet = [caller, CREATOR, CID]; canVerify = [caller, CREATOR, CID];};
                details = null;
            })){
                case(#ok(a)) return #ok(a.invoice);
                case(#err(e)) return #err(e);
            }
        };

        public func verifyInvoice(
            id : Nat
        ) : async Result<(), VerifyInvoiceErr> {
            switch(await INVOICE.verify_invoice({ id = id })){
                case(#ok(_)) return #ok(());
                case(#err(e)) return #err(e);
            };
        };

        public func getBalance() : async Result<Nat,GetBalanceErr> {
            switch(await INVOICE.get_balance({ token = ICP })){
                case(#ok(answer)) return #ok(answer.balance);
                case(#err(e)) return #err(e);
            };
        };

        public func transfer(
            amount : Nat,
            wallet : Text
        ) : async Result<Nat, TransferError> {
            switch(await INVOICE.transfer({ amount = amount; token = ICP; destination = #text(wallet) })){
                case(#ok(a)) return #ok(Nat64.toNat(a.blockHeight));
                case(#err(e)) return #err(e);
            };
        };
    

    };
};