export const idlFactory = ({ IDL }) => {
  const Recipe = IDL.Vec(IDL.Text);
  const Template = IDL.Variant({
    'Accessory' : IDL.Record({
      'after_wear' : IDL.Text,
      'before_wear' : IDL.Text,
      'recipe' : Recipe,
    }),
    'LegendaryAccessory' : IDL.Vec(IDL.Nat8),
    'Material' : IDL.Vec(IDL.Nat8),
  });
  const Result_6 = IDL.Variant({ 'ok' : IDL.Text, 'err' : IDL.Text });
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
  const TokenIdentifier__2 = IDL.Text;
  const AccountIdentifier__2 = IDL.Text;
  const CommonError = IDL.Variant({
    'InvalidToken' : TokenIdentifier,
    'Other' : IDL.Text,
  });
  const Result_4 = IDL.Variant({
    'ok' : AccountIdentifier__2,
    'err' : CommonError,
  });
  const Result = IDL.Variant({ 'ok' : IDL.Null, 'err' : IDL.Text });
  const Result_5 = IDL.Variant({ 'ok' : TokenIdentifier__2, 'err' : IDL.Text });
  const Result__1 = IDL.Variant({ 'ok' : IDL.Null, 'err' : IDL.Text });
  const Extension = IDL.Text;
  const GetLogMessagesFilter = IDL.Record({
    'analyzeCount' : IDL.Nat32,
    'messageRegex' : IDL.Opt(IDL.Text),
    'messageContains' : IDL.Opt(IDL.Text),
  });
  const Nanos = IDL.Nat64;
  const GetLogMessagesParameters = IDL.Record({
    'count' : IDL.Nat32,
    'filter' : IDL.Opt(GetLogMessagesFilter),
    'fromTimeNanos' : IDL.Opt(Nanos),
  });
  const GetLatestLogMessagesParameters = IDL.Record({
    'upToTimeNanos' : IDL.Opt(Nanos),
    'count' : IDL.Nat32,
    'filter' : IDL.Opt(GetLogMessagesFilter),
  });
  const CanisterLogRequest = IDL.Variant({
    'getMessagesInfo' : IDL.Null,
    'getMessages' : GetLogMessagesParameters,
    'getLatestMessages' : GetLatestLogMessagesParameters,
  });
  const CanisterLogFeature = IDL.Variant({
    'filterMessageByContains' : IDL.Null,
    'filterMessageByRegex' : IDL.Null,
  });
  const CanisterLogMessagesInfo = IDL.Record({
    'features' : IDL.Vec(IDL.Opt(CanisterLogFeature)),
    'lastTimeNanos' : IDL.Opt(Nanos),
    'count' : IDL.Nat32,
    'firstTimeNanos' : IDL.Opt(Nanos),
  });
  const LogMessagesData = IDL.Record({
    'timeNanos' : Nanos,
    'message' : IDL.Text,
  });
  const CanisterLogMessages = IDL.Record({
    'data' : IDL.Vec(LogMessagesData),
    'lastAnalyzedMessageTimeNanos' : IDL.Opt(Nanos),
  });
  const CanisterLogResponse = IDL.Variant({
    'messagesInfo' : CanisterLogMessagesInfo,
    'messages' : CanisterLogMessages,
  });
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
  const Metadata__1 = IDL.Variant({
    'fungible' : IDL.Record({
      'decimals' : IDL.Nat8,
      'metadata' : IDL.Opt(IDL.Vec(IDL.Nat8)),
      'name' : IDL.Text,
      'symbol' : IDL.Text,
    }),
    'nonfungible' : IDL.Record({ 'metadata' : IDL.Opt(IDL.Vec(IDL.Nat8)) }),
  });
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
  const Metadata = IDL.Variant({
    'fungible' : IDL.Record({
      'decimals' : IDL.Nat8,
      'metadata' : IDL.Opt(IDL.Vec(IDL.Nat8)),
      'name' : IDL.Text,
      'symbol' : IDL.Text,
    }),
    'nonfungible' : IDL.Record({ 'metadata' : IDL.Opt(IDL.Vec(IDL.Nat8)) }),
  });
  const Result_3 = IDL.Variant({ 'ok' : Metadata, 'err' : CommonError__1 });
  const Result_1 = IDL.Variant({
    'ok' : IDL.Vec(
      IDL.Tuple(TokenIndex, IDL.Opt(Listing), IDL.Opt(IDL.Vec(IDL.Nat8)))
    ),
    'err' : CommonError,
  });
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
  const Tag = IDL.Text;
  const Category = IDL.Variant({
    'LegendaryCharacter' : IDL.Null,
    'AccessoryComponent' : IDL.Null,
    'AvatarComponent' : IDL.Null,
  });
  const Meta = IDL.Record({
    'name' : IDL.Text,
    'tags' : IDL.Vec(Tag),
    'description' : IDL.Text,
    'category' : Category,
  });
  const ICPSquadNFT = IDL.Service({
    'acceptCycles' : IDL.Func([], [], []),
    'addElements' : IDL.Func([IDL.Text, Template], [Result_6], []),
    'add_admin' : IDL.Func([IDL.Principal], [], []),
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
    'availableCycles' : IDL.Func([], [IDL.Nat], ['query']),
    'balance' : IDL.Func([BalanceRequest], [BalanceResponse], ['query']),
    'bearer' : IDL.Func([TokenIdentifier__2], [Result_4], ['query']),
    'burn' : IDL.Func([TokenIdentifier__2], [Result], []),
    'clearPayments' : IDL.Func([IDL.Principal, IDL.Vec(SubAccount__1)], [], []),
    'collectCanisterMetrics' : IDL.Func([], [], []),
    'createAccessory' : IDL.Func(
        [IDL.Text, IDL.Vec(TokenIdentifier__2), IDL.Vec(IDL.Nat8)],
        [Result_5],
        [],
      ),
    'delete' : IDL.Func([IDL.Text], [Result__1], []),
    'eventsSize' : IDL.Func([], [IDL.Nat], ['query']),
    'extensions' : IDL.Func([], [IDL.Vec(Extension)], ['query']),
    'getCanisterLog' : IDL.Func(
        [IDL.Opt(CanisterLogRequest)],
        [IDL.Opt(CanisterLogResponse)],
        ['query'],
      ),
    'getCanisterMetrics' : IDL.Func(
        [GetMetricsParameters],
        [IDL.Opt(CanisterMetrics)],
        ['query'],
      ),
    'getMinter' : IDL.Func([], [IDL.Vec(IDL.Principal)], ['query']),
    'getOwnership' : IDL.Func(
        [],
        [IDL.Vec(IDL.Tuple(AccountIdentifier__2, IDL.Vec(TokenIndex)))],
        ['query'],
      ),
    'getRegistry' : IDL.Func(
        [],
        [IDL.Vec(IDL.Tuple(TokenIndex, AccountIdentifier__2))],
        ['query'],
      ),
    'getTokens' : IDL.Func(
        [],
        [IDL.Vec(IDL.Tuple(TokenIndex, Metadata__1))],
        ['query'],
      ),
    'http_request' : IDL.Func([Request], [Response], ['query']),
    'init_cap' : IDL.Func([], [Result], []),
    'is_admin' : IDL.Func([IDL.Principal], [IDL.Bool], ['query']),
    'list' : IDL.Func([ListRequest], [Result_2], []),
    'listings' : IDL.Func(
        [],
        [IDL.Vec(IDL.Tuple(TokenIndex, Listing, Metadata__1))],
        ['query'],
      ),
    'lock' : IDL.Func(
        [IDL.Text, IDL.Nat64, AccountIdentifier__2, SubAccount__1],
        [Result_4],
        [],
      ),
    'metadata' : IDL.Func([TokenIdentifier__2], [Result_3], ['query']),
    'mint' : IDL.Func([IDL.Text, AccountIdentifier__2], [Result], []),
    'nextTokenId' : IDL.Func([], [IDL.Nat], ['query']),
    'payments' : IDL.Func([], [IDL.Opt(IDL.Vec(SubAccount__1))], ['query']),
    'removeAccessory' : IDL.Func([IDL.Text, IDL.Text], [Result], []),
    'settle' : IDL.Func([IDL.Text], [Result_2], []),
    'settlements' : IDL.Func(
        [],
        [IDL.Vec(IDL.Tuple(TokenIndex, AccountIdentifier__2, IDL.Nat64))],
        ['query'],
      ),
    'stats' : IDL.Func(
        [],
        [IDL.Nat64, IDL.Nat64, IDL.Nat64, IDL.Nat64, IDL.Nat, IDL.Nat, IDL.Nat],
        ['query'],
      ),
    'stats_circulation' : IDL.Func(
        [],
        [IDL.Vec(IDL.Tuple(IDL.Text, IDL.Nat32))],
        ['query'],
      ),
    'supply' : IDL.Func([], [IDL.Nat], ['query']),
    'tokens_ext' : IDL.Func([AccountIdentifier__2], [Result_1], ['query']),
    'transactions' : IDL.Func([], [IDL.Vec(Transaction)], ['query']),
    'transfer' : IDL.Func([TransferRequest], [TransferResponse], []),
    'updateAccessories' : IDL.Func([], [], []),
    'upload' : IDL.Func([IDL.Vec(IDL.Nat8)], [], []),
    'uploadClear' : IDL.Func([], [], []),
    'uploadFinalize' : IDL.Func([IDL.Text, Meta, IDL.Text], [Result__1], []),
    'verificationEvents' : IDL.Func([], [], []),
    'wearAccessory' : IDL.Func([IDL.Text, IDL.Text], [Result], []),
  });
  return ICPSquadNFT;
};
export const init = ({ IDL }) => { return [IDL.Principal]; };
