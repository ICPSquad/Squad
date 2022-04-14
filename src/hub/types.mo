import Result "mo:base/Result";

import Invoice "invoice";
module {

    public type Color = (Nat8, Nat8, Nat8, Nat8);
    public type Colors = [{spot : Text; color : Color}];
    public type MintInformation = {
        background : Text;
        profile : Text;
        ears : Text;
        mouth : Text;
        eyes : Text;
        nose : Text;
        hair : Text;
        cloth : Text;
        colors : Colors;
    };

    public type MintResult = Result.Result<MintSuccess,MintErr>;

    public type MintSuccess = {
        tokenId : Text;
    };

    public type MintErr = {
        #Anonymous;
        #AlreadyMinted;
        #Invoice: Invoice.Invoice;
        #InvoiceCanisterErr : Invoice.VerifyInvoiceErr or Invoice.CreateInvoiceErr;
        #AvatarCanisterErr : Text;
        #Other : Text;
    };
}