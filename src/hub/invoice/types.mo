import Canistergeek "mo:canistergeek/canistergeek";

import InvoiceType "../invoice/Types";


module {

    public type Dependencies = {
        _Logs : Canistergeek.Logger;
        invoice : Principal;
        cid : Principal;
    };

    public type CreateInvoiceArgs = InvoiceType.CreateInvoiceArgs;
    public type CreateInvoiceResult = InvoiceType.CreateInvoiceResult;
    public type GetInvoiceArgs = InvoiceType.GetInvoiceArgs;
    public type GetInvoiceResult = InvoiceType.GetInvoiceResult;
    public type GetBalanceArgs = InvoiceType.GetBalanceArgs;
    public type GetBalanceResult = InvoiceType.GetBalanceResult;
    public type VerifyInvoiceArgs = InvoiceType.VerifyInvoiceArgs;
    public type VerifyInvoiceResult = InvoiceType.VerifyInvoiceResult;
    public type TransferArgs = InvoiceType.TransferArgs;
    public type TransferResult = InvoiceType.TransferResult;
    public type Token = InvoiceType.Token;
    public type Permissions = InvoiceType.Permissions;
    public type Details = InvoiceType.Details;
    public type TransferError = InvoiceType.TransferError;
    public type GetBalanceErr = InvoiceType.GetBalanceErr;

    public type InvoiceInterface = actor {
        create_invoice : shared(CreateInvoiceArgs) -> async CreateInvoiceResult;
        get_invoice : query (GetInvoiceArgs) -> async GetInvoiceResult;
        get_balance : shared (GetBalanceArgs) -> async GetBalanceResult;
        verify_invoice : shared(VerifyInvoiceArgs) -> async VerifyInvoiceResult;
        transfer :  shared(TransferArgs) -> async TransferResult;
    };

    public type Interface = {

        createInvoice : InvoiceType.CreateInvoiceArgs -> async InvoiceType.CreateInvoiceResult;
        verifyInvoice : InvoiceType.VerifyInvoiceArgs -> async InvoiceType.VerifyInvoiceResult;
        getBalance : () -> Nat;
        transfer : (Nat, Text) -> 
    };
};