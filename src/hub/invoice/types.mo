import Result "mo:base/Result";

import Canistergeek "mo:canistergeek/canistergeek";
import Ext "mo:ext/Ext";

import Admins "../admins";
import InvoiceType "../../invoice/Types";

module {

    public type Dependencies = {
        invoice_cid : Principal;
    };

    public type Result<A,B> = Result.Result<A,B>;
    public type Invoice = InvoiceType.Invoice;

    public type InvoiceInterface = actor {
        verify_invoice_avatar : shared(VerifyInvoiceArgs, caller : Principal) -> async VerifyInvoiceResult;
    };

    public type Interface = {


        // Verify the invoice with the specified id for the specified principal.
        // @param id : The id of the invoice to verify.
        // @result(ok) : The invoice has been paid.
        // @result(err) : An error.
        verifyInvoice : (id : Nat, caller : Principal) -> async Result<(), VerifyInvoiceErr>;
    };
};