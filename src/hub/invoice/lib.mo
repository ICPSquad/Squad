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
        private let INVOICE : Types.InvoiceInterface = actor(Principal.toText(dependencies.invoice_cid));


    };
};