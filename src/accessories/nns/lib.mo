import Hex "mo:encoding/Hex";
module {

    public class Factory(dependencies : Types.Dependencies) {
        
        let nns : Types.NNS = actor("ryjl3-tyaaa-aaaaa-aaaba-cai");
        let _Admins = dependencies._Admins
        let _Logs = dependencies._Logs

        //////////
        // API //
        /////////
        
        public func balance(
            account : Blob,
        ) : async Types.ICP {
            await nns.account_balance({
                account;
            });
        };

        public func transfer (
            caller  : Principal,
            amount  : Types.ICP,
            to      : Text,
            memo    : Types.Memo,
        ) : async Types.TransferResult {
            assert(_Admins.isAdmin(caller));
            switch (Hex.decode(to)) {
                case (#ok(aid)) {
                    await nns.transfer({
                        fee = { e8s = 10_000; };
                        amount;
                        memo;
                        from_subaccount = null;
                        created_at_time = null;
                        to = Blob.fromArray(aid);
                    })
                };
                case (#err(#msg(e))) {
                    #Err(#TxCreatedInFuture(null));
                };
            };
        };

    }
}