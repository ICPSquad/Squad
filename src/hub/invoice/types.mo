import Result "mo:base/Result";

import Canistergeek "mo:canistergeek/canistergeek";
import Ext "mo:ext/Ext";

import Admins "../admins";
import InvoiceType "../../invoice/Types";

module {

    public type Dependencies = {
        invoice_cid : Principal;
        cid : Principal;
        creator : Principal;
    };

    public type Result<A,B> = Result.Result<A,B>;
    public type Invoice = InvoiceType.Invoice;
    public type AccountIdentifier = Ext.AccountIdentifier;
    public type CreateInvoiceArgs = InvoiceType.CreateInvoiceArgs;
    public type CreateInvoiceResult = InvoiceType.CreateInvoiceResult;
    public type CreateInvoiceErr = InvoiceType.CreateInvoiceErr;
    public type GetInvoiceArgs = InvoiceType.GetInvoiceArgs;
    public type GetInvoiceResult = InvoiceType.GetInvoiceResult;
    public type GetBalanceArgs = InvoiceType.GetBalanceArgs;
    public type GetBalanceResult = InvoiceType.GetBalanceResult;
    public type GetBalanceErr = InvoiceType.GetBalanceErr;
    public type VerifyInvoiceArgs = InvoiceType.VerifyInvoiceArgs;
    public type VerifyInvoiceResult = InvoiceType.VerifyInvoiceResult;
    public type TransferArgs = InvoiceType.TransferArgs;
    public type TransferResult = InvoiceType.TransferResult;
    public type TransferError = InvoiceType.TransferError;
    public type Token = InvoiceType.Token;
    public type Permissions = InvoiceType.Permissions;
    public type Details = InvoiceType.Details;

    public type VerifyInvoiceErr = {
        message : ?Text;
        kind : {
        #InvalidInvoiceId;
        #NotFound;
        #NotYetPaid;
        #NotAuthorized;
        #Expired;
        #TransferError;
        #InvalidToken;
        #InvalidAccount;
        #Other;
        };
    };

    public type InvoiceInterface = actor {
        create_invoice : shared(CreateInvoiceArgs) -> async CreateInvoiceResult;
        get_invoice : query (GetInvoiceArgs) -> async GetInvoiceResult;
        get_balance : shared (GetBalanceArgs) -> async GetBalanceResult;
        verify_invoice : shared(VerifyInvoiceArgs) -> async VerifyInvoiceResult;
        transfer :  shared(TransferArgs) -> async TransferResult;
    };

    public type Interface = {

        // Creates an invoice for the caller to pay the specified amount in ICPs. 
        // @param caller : The person to who the invoice is for.
        // @param amount : The amount to be paid.
        // @result(ok) : The invoice.
        // @result(err) : An error message.
        createInvoice : (caller : Principal, amount : Nat) -> async Result<Invoice, CreateInvoiceErr>;

        // Verify the invoice with the specified id.
        // @param id : The id of the invoice to verify.
        // @result(ok) : The invoice has been paid.
        // @result(err) : An error.
        verifyInvoice : (id : Nat) -> async Result<(), VerifyInvoiceErr>;

        // Returns the ICP balance of this canister subaccount in the Invoice canister. 
        getBalance : () -> async Result<Nat, GetBalanceErr>;

        // Transfer ICPs from this canister main account in the invoice canister to a new address.
        // @param amount : The amount of ICP to transfer.
        // @param wallet : The wallet to transfer to.
        // @result(ok) : The height of the transfer.
        // @result(err) : An error message.
        transfer : (amount : Nat, wallet : AccountIdentifier) -> async Result<Nat, TransferError>;
    };
};