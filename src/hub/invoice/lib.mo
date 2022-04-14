import Types "types";
module {


    public class Invoice (dependencies : Types.Dependencies) : Types.Interface {

        private let WALLET_SQUAD = "7719a749a50477cc8062376306f7eec7ae365f5e44d9fd8222e4b4ee88e97c4c";
        private let INVOICE : Types.InvoiceInterface = actor(dependencies.invoice);
        private let ICP : Token = { symbol = "ICP" };




    

    };
}: