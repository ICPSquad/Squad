module {

  public type Result<T, E> = {
        #Ok  : T;
        #Err : E;
    };

  // Amount of ICP tokens, measured in 10^-8 of a one token.
  public type ICP = { e8s : Nat64 };

  // Number of nanoseconds from the UNIX epoch (00:00:00 UTC, Jan 1, 1970).
  public type Timestamp = { timestamp_nanos : Nat64 };

  // AccountIdentifier is a 32-byte array.
  // The first 4 bytes is big-endian encoding of CRC32 checksum of the last 28-bytes.
  public type AccountIdentifier = [Nat8];

  // SubAccount is an arbitrary 32-byte array.
  // Ledger canister uses subaccounts to compute the source address, which enables one principal to control multiple ledgers accounts.
  public type SubAccount = [Nat8];

  public type TransferResult = { #Ok : BlockIndex; #Err : TransferError };
  public type TransferError = {
        // The fee that the caller specified in the transfer request was not the one that the ledger expects.
        // The caller can change the transfer fee to the `expected_fee` and retry the request.
        #BadFee : { expected_fee : ICP };
        // The account specified by the caller doesn't have enough funds.
        #InsufficientFunds : { balance: ICP };
        // The request is too old.
        // The ledger only accepts requests created within a 24 hours window.
        // This is a non-recoverable error.
        #TxTooOld : { allowed_window_nanos: Nat64 };
        // The caller specified `created_at_time` that is too far in future.
        // The caller can retry the request later.
        #TxCreatedInFuture;
        // The ledger has already executed the request.
        // `duplicate_of` field is equal to the index of the block containing the original transaction.
        #TxDuplicate : { duplicate_of: BlockIndex; };
  };


    // Arguments for the `transfer` call.
    public type TransferArgs = {
        // Transaction memo.
        // See comments for the `Memo` type.
        memo : Memo;
        // The amount that the caller wants to transfer to the destination address.
        amount : ICP;
        // The amount that the caller pays for the transaction.
        // Must be 10000 e8s.
        fee : ICP;
        // The subaccount from which the caller wants to transfer funds.
        // If null, the ledger uses the default (all zeros) subaccount to compute the source address.
        // See comments for the `SubAccount` type.
        from_subaccount : ?SubAccount;
        // The destination account.
        // If the transfer is successful, the balance of this account increases by `amount`.
        to : AccountIdentifier;
        // The point in time when the caller created this request.
        // If null, the ledger uses current IC time as the timestamp.
        created_at_time : ?Timestamp;
    };

  // Sequence number of a block produced by the ledger. One transaction corresponds to one block. 
  public type BlockIndex = Nat64;

  // Arguments for the `account_balance` call.
  public type AccountBalanceArgs = { account : AccountIdentifier };
  
  // An arbitrary number associated with a transaction.
  public type Memo = Nat64;


  public type Interface = actor {
    account_balance : shared query AccountBalanceArgs -> async ICP;
    transfer : shared TransferArgs -> async TransferResult;
  }
}