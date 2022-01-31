export const idlFactory = ({ IDL }) => {
  const Recipe__1 = IDL.Vec(IDL.Text);
  const Template = IDL.Variant({
    'Accessory' : IDL.Record({
      'after_wear' : IDL.Text,
      'before_wear' : IDL.Text,
      'recipe' : Recipe__1,
    }),
    'LegendaryAccessory' : IDL.Vec(IDL.Nat8),
    'Material' : IDL.Vec(IDL.Nat8),
  });
  const Result_3 = IDL.Variant({ 'ok' : IDL.Text, 'err' : IDL.Text });
  const AirdropObject = IDL.Record({
    'recipient' : IDL.Principal,
    'accessory1' : IDL.Opt(IDL.Text),
    'accessory2' : IDL.Opt(IDL.Text),
    'material' : IDL.Text,
  });
  const Result = IDL.Variant({ 'ok' : IDL.Null, 'err' : IDL.Text });
  const SubAccount__1 = IDL.Vec(IDL.Nat8);
  const TokenIndex = IDL.Nat32;
  const SubAccount__2 = IDL.Vec(IDL.Nat8);
  const AccountIdentifier__1 = IDL.Text;
  const Settlement = IDL.Record({
    'subaccount' : SubAccount__2,
    'seller' : IDL.Principal,
    'buyer' : AccountIdentifier__1,
    'price' : IDL.Nat64,
  });
  const TokenIdentifier = IDL.Text;
  const AccountIdentifier = IDL.Text;
  const User = IDL.Variant({
    'principal' : IDL.Principal,
    'address' : AccountIdentifier,
  });
  const BalanceRequest = IDL.Record({
    'token' : TokenIdentifier,
    'user' : User,
  });
  const Balance = IDL.Nat;
  const CommonError__1 = IDL.Variant({
    'InvalidToken' : TokenIdentifier,
    'Other' : IDL.Text,
  });
  const BalanceResponse = IDL.Variant({
    'ok' : Balance,
    'err' : CommonError__1,
  });
  const ICP = IDL.Record({ 'e8s' : IDL.Nat64 });
  const TokenIdentifier__2 = IDL.Text;
  const AccountIdentifier__2 = IDL.Text;
  const CommonError = IDL.Variant({
    'InvalidToken' : TokenIdentifier,
    'Other' : IDL.Text,
  });
  const Result_5 = IDL.Variant({
    'ok' : AccountIdentifier__2,
    'err' : CommonError,
  });
  const Option = IDL.Bool;
  const Result_6 = IDL.Variant({ 'ok' : TokenIdentifier__2, 'err' : IDL.Text });
  const Extension = IDL.Text;
  const MetricsGranularity = IDL.Variant({
    'hourly' : IDL.Null,
    'daily' : IDL.Null,
  });
  const GetMetricsParameters = IDL.Record({
    'dateToMillis' : IDL.Nat,
    'granularity' : MetricsGranularity,
    'dateFromMillis' : IDL.Nat,
  });
  const UpdateCallsAggregatedData = IDL.Vec(IDL.Nat64);
  const CanisterHeapMemoryAggregatedData = IDL.Vec(IDL.Nat64);
  const CanisterCyclesAggregatedData = IDL.Vec(IDL.Nat64);
  const CanisterMemoryAggregatedData = IDL.Vec(IDL.Nat64);
  const HourlyMetricsData = IDL.Record({
    'updateCalls' : UpdateCallsAggregatedData,
    'canisterHeapMemorySize' : CanisterHeapMemoryAggregatedData,
    'canisterCycles' : CanisterCyclesAggregatedData,
    'canisterMemorySize' : CanisterMemoryAggregatedData,
    'timeMillis' : IDL.Int,
  });
  const NumericEntity = IDL.Record({
    'avg' : IDL.Nat64,
    'max' : IDL.Nat64,
    'min' : IDL.Nat64,
    'first' : IDL.Nat64,
    'last' : IDL.Nat64,
  });
  const DailyMetricsData = IDL.Record({
    'updateCalls' : IDL.Nat64,
    'canisterHeapMemorySize' : NumericEntity,
    'canisterCycles' : NumericEntity,
    'canisterMemorySize' : NumericEntity,
    'timeMillis' : IDL.Int,
  });
  const CanisterMetricsData = IDL.Variant({
    'hourly' : IDL.Vec(HourlyMetricsData),
    'daily' : IDL.Vec(DailyMetricsData),
  });
  const CanisterMetrics = IDL.Record({ 'data' : CanisterMetricsData });
  const ContractInfo = IDL.Record({
    'nft_payload_size' : IDL.Nat,
    'memory_size' : IDL.Nat,
    'max_live_size' : IDL.Nat,
    'cycles' : IDL.Nat,
    'total_minted' : IDL.Nat,
    'heap_size' : IDL.Nat,
    'authorized_users' : IDL.Vec(IDL.Principal),
  });
  const AssetInventoryType = IDL.Variant({
    'Accessory' : IDL.Null,
    'LegendaryAccessory' : IDL.Null,
    'Material' : IDL.Null,
  });
  const AssetInventory = IDL.Record({
    'name' : IDL.Text,
    'token_identifier' : IDL.Text,
    'category' : AssetInventoryType,
  });
  const Inventory = IDL.Vec(AssetInventory);
  const ContractMetadata = IDL.Record({
    'name' : IDL.Text,
    'symbol' : IDL.Text,
  });
  const Recipe = IDL.Vec(IDL.Text);
  const HeaderField = IDL.Tuple(IDL.Text, IDL.Text);
  const Request = IDL.Record({
    'url' : IDL.Text,
    'method' : IDL.Text,
    'body' : IDL.Vec(IDL.Nat8),
    'headers' : IDL.Vec(HeaderField),
  });
  const StreamingCallbackToken = IDL.Record({
    'key' : IDL.Text,
    'index' : IDL.Nat,
    'content_encoding' : IDL.Text,
  });
  const StreamingCallbackResponse = IDL.Record({
    'token' : IDL.Opt(StreamingCallbackToken),
    'body' : IDL.Vec(IDL.Nat8),
  });
  const StreamingCallback = IDL.Func(
      [StreamingCallbackToken],
      [StreamingCallbackResponse],
      ['query'],
    );
  const StreamingStrategy = IDL.Variant({
    'Callback' : IDL.Record({
      'token' : StreamingCallbackToken,
      'callback' : StreamingCallback,
    }),
  });
  const Response = IDL.Record({
    'body' : IDL.Vec(IDL.Nat8),
    'headers' : IDL.Vec(HeaderField),
    'streaming_strategy' : IDL.Opt(StreamingStrategy),
    'status_code' : IDL.Nat16,
  });
  const TokenIdentifier__1 = IDL.Text;
  const ListRequest = IDL.Record({
    'token' : TokenIdentifier__1,
    'from_subaccount' : IDL.Opt(SubAccount__2),
    'price' : IDL.Opt(IDL.Nat64),
  });
  const Result_2 = IDL.Variant({ 'ok' : IDL.Null, 'err' : CommonError });
  const Time = IDL.Int;
  const Listing = IDL.Record({
    'locked' : IDL.Opt(Time),
    'seller' : IDL.Principal,
    'price' : IDL.Nat64,
  });
  const Metadata__1 = IDL.Variant({
    'fungible' : IDL.Record({
      'decimals' : IDL.Nat8,
      'metadata' : IDL.Opt(IDL.Vec(IDL.Nat8)),
      'name' : IDL.Text,
      'symbol' : IDL.Text,
    }),
    'nonfungible' : IDL.Record({ 'metadata' : IDL.Opt(IDL.Vec(IDL.Nat8)) }),
  });
  const Metadata = IDL.Variant({
    'fungible' : IDL.Record({
      'decimals' : IDL.Nat8,
      'metadata' : IDL.Opt(IDL.Vec(IDL.Nat8)),
      'name' : IDL.Text,
      'symbol' : IDL.Text,
    }),
    'nonfungible' : IDL.Record({ 'metadata' : IDL.Opt(IDL.Vec(IDL.Nat8)) }),
  });
  const Result_4 = IDL.Variant({ 'ok' : Metadata, 'err' : CommonError__1 });
  const Transaction = IDL.Record({
    'token' : TokenIdentifier__1,
    'time' : Time,
    'seller' : IDL.Principal,
    'buyer' : AccountIdentifier__1,
    'price' : IDL.Nat64,
  });
  const Memo = IDL.Vec(IDL.Nat8);
  const SubAccount = IDL.Vec(IDL.Nat8);
  const TransferRequest = IDL.Record({
    'to' : User,
    'token' : TokenIdentifier,
    'notify' : IDL.Bool,
    'from' : User,
    'memo' : Memo,
    'subaccount' : IDL.Opt(SubAccount),
    'amount' : Balance,
  });
  const TransferResponse = IDL.Variant({
    'ok' : Balance,
    'err' : IDL.Variant({
      'CannotNotify' : AccountIdentifier,
      'InsufficientBalance' : IDL.Null,
      'InvalidToken' : TokenIdentifier,
      'Rejected' : IDL.Null,
      'Unauthorized' : AccountIdentifier,
      'Other' : IDL.Text,
    }),
  });
  const BlockIndex = IDL.Nat64;
  const TransferError = IDL.Variant({
    'TxTooOld' : IDL.Record({ 'allowed_window_nanos' : IDL.Nat64 }),
    'BadFee' : IDL.Record({ 'expected_fee' : ICP }),
    'TxDuplicate' : IDL.Record({ 'duplicate_of' : BlockIndex }),
    'TxCreatedInFuture' : IDL.Null,
    'InsufficientFunds' : IDL.Record({ 'balance' : ICP }),
  });
  const TransferResult = IDL.Variant({
    'Ok' : BlockIndex,
    'Err' : TransferError,
  });
  const Error = IDL.Variant({
    'AssetNotFound' : IDL.Null,
    'Immutable' : IDL.Null,
    'unsupportedResponse' : IDL.Null,
    'NotFound' : IDL.Null,
    'AssetTooHeavy' : IDL.Null,
    'Unauthorized' : IDL.Null,
    'InvalidRequest' : IDL.Null,
    'invalidTransaction' : IDL.Null,
    'ErrorMinting' : IDL.Null,
    'AuthorizedPrincipalLimitReached' : IDL.Nat,
    'FailedToWrite' : IDL.Text,
  });
  const Result_1 = IDL.Variant({ 'ok' : IDL.Null, 'err' : Error });
  const Hub = IDL.Service({
    'addElements' : IDL.Func([IDL.Text, Template], [Result_3], []),
    'airdrop' : IDL.Func([AirdropObject], [Result], []),
    'allPayments' : IDL.Func(
        [],
        [IDL.Vec(IDL.Tuple(IDL.Principal, IDL.Vec(SubAccount__1)))],
        ['query'],
      ),
    'allSettlements' : IDL.Func(
        [],
        [IDL.Vec(IDL.Tuple(TokenIndex, Settlement))],
        ['query'],
      ),
    'balance' : IDL.Func([BalanceRequest], [BalanceResponse], ['query']),
    'balance_ledger' : IDL.Func([], [ICP], []),
    'bearer' : IDL.Func([TokenIdentifier__2], [Result_5], ['query']),
    'clearPayments' : IDL.Func([IDL.Principal, IDL.Vec(SubAccount__1)], [], []),
    'collectCanisterMetrics' : IDL.Func([], [], []),
    'createAccessory' : IDL.Func(
        [
          IDL.Text,
          IDL.Vec(TokenIdentifier__2),
          IDL.Vec(IDL.Nat8),
          IDL.Opt(Option),
        ],
        [Result_6],
        [],
      ),
    'extensions' : IDL.Func([], [IDL.Vec(Extension)], ['query']),
    'getCanisterMetrics' : IDL.Func(
        [GetMetricsParameters],
        [IDL.Opt(CanisterMetrics)],
        ['query'],
      ),
    'getContractInfo' : IDL.Func([], [ContractInfo], []),
    'getInventory' : IDL.Func([], [Inventory], ['query']),
    'getMetadata' : IDL.Func([], [ContractMetadata], ['query']),
    'getMinter' : IDL.Func([], [IDL.Vec(IDL.Principal)], ['query']),
    'getOwnership' : IDL.Func(
        [],
        [IDL.Vec(IDL.Tuple(AccountIdentifier__2, IDL.Vec(TokenIndex)))],
        ['query'],
      ),
    'getRecipes' : IDL.Func(
        [],
        [IDL.Vec(IDL.Tuple(IDL.Text, Recipe))],
        ['query'],
      ),
    'getRegistry' : IDL.Func(
        [],
        [IDL.Vec(IDL.Tuple(TokenIndex, AccountIdentifier__2))],
        ['query'],
      ),
    'getStats' : IDL.Func([], [IDL.Vec(IDL.Text)], ['query']),
    'http_request' : IDL.Func([Request], [Response], ['query']),
    'init' : IDL.Func([IDL.Vec(IDL.Principal), ContractMetadata], [], []),
    'init_cap' : IDL.Func([], [Result], []),
    'list' : IDL.Func([ListRequest], [Result_2], []),
    'listings' : IDL.Func(
        [],
        [IDL.Vec(IDL.Tuple(TokenIndex, Listing, Metadata__1))],
        ['query'],
      ),
    'lock' : IDL.Func(
        [IDL.Text, IDL.Nat64, AccountIdentifier__2, SubAccount__1],
        [Result_5],
        [],
      ),
    'metadata' : IDL.Func([TokenIdentifier__2], [Result_4], ['query']),
    'mint' : IDL.Func([IDL.Text, AccountIdentifier__2], [Result_3], []),
    'modifyRecipe' : IDL.Func([IDL.Text, Recipe], [Result], []),
    'payments' : IDL.Func([], [IDL.Opt(IDL.Vec(SubAccount__1))], ['query']),
    'process' : IDL.Func([], [], []),
    'removeAccessory' : IDL.Func([IDL.Text, IDL.Text], [Result], []),
    'settle' : IDL.Func([IDL.Text], [Result_2], []),
    'settlements' : IDL.Func(
        [],
        [IDL.Vec(IDL.Tuple(TokenIndex, AccountIdentifier__2, IDL.Nat64))],
        ['query'],
      ),
    'showAdmins' : IDL.Func([], [IDL.Vec(IDL.Principal)], ['query']),
    'supply' : IDL.Func([], [IDL.Nat], ['query']),
    'transactions' : IDL.Func([], [IDL.Vec(Transaction)], ['query']),
    'transfer' : IDL.Func([TransferRequest], [TransferResponse], []),
    'transfer_ledger' : IDL.Func([ICP, IDL.Principal], [TransferResult], []),
    'updateAccessories' : IDL.Func([], [], []),
    'updateAdmins' : IDL.Func([IDL.Principal, IDL.Bool], [Result_1], []),
    'updateAdminsData' : IDL.Func([IDL.Principal, IDL.Bool], [Result_1], []),
    'verification' : IDL.Func([], [], []),
    'wallet_available' : IDL.Func([], [IDL.Nat], ['query']),
    'wallet_receive' : IDL.Func([], [], []),
    'wearAccessory' : IDL.Func([IDL.Text, IDL.Text], [Result], []),
    'whoami' : IDL.Func([], [IDL.Principal], ['query']),
  });
  return Hub;
};
export const init = ({ IDL }) => { return []; };
