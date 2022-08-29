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
  const Result_7 = IDL.Variant({ 'ok' : IDL.Text, 'err' : IDL.Text });
  const AccountIdentifier__2 = IDL.Text;
  const Airdrop = IDL.Vec(IDL.Text);
  const TokenIdentifier__1 = IDL.Text;
  const AccountIdentifier = IDL.Text;
  const User = IDL.Variant({
    'principal' : IDL.Principal,
    'address' : AccountIdentifier,
  });
  const BalanceRequest = IDL.Record({
    'token' : TokenIdentifier__1,
    'user' : User,
  });
  const Balance = IDL.Nat;
  const CommonError__1 = IDL.Variant({
    'InvalidToken' : TokenIdentifier__1,
    'Other' : IDL.Text,
  });
  const BalanceResponse = IDL.Variant({
    'ok' : Balance,
    'err' : CommonError__1,
  });
  const TokenIdentifier = IDL.Text;
  const CommonError = IDL.Variant({
    'InvalidToken' : TokenIdentifier__1,
    'Other' : IDL.Text,
  });
  const Result_6 = IDL.Variant({
    'ok' : AccountIdentifier__2,
    'err' : CommonError,
  });
  const Result__1_2 = IDL.Variant({ 'ok' : IDL.Null, 'err' : CommonError__1 });
  const AccessoryInventory = IDL.Record({
    'tokenIdentifier' : IDL.Text,
    'name' : IDL.Text,
    'equipped' : IDL.Bool,
  });
  const MaterialInventory = IDL.Record({
    'tokenIdentifier' : IDL.Text,
    'name' : IDL.Text,
  });
  const ItemInventory = IDL.Variant({
    'Accessory' : AccessoryInventory,
    'Material' : MaterialInventory,
  });
  const Inventory = IDL.Vec(ItemInventory);
  const Result_5 = IDL.Variant({ 'ok' : Inventory, 'err' : IDL.Text });
  const Result__1_1 = IDL.Variant({ 'ok' : TokenIdentifier, 'err' : IDL.Text });
  const Result = IDL.Variant({ 'ok' : IDL.Null, 'err' : IDL.Text });
  const AccountIdentifier__1 = IDL.Text;
  const SubAccount__1 = IDL.Vec(IDL.Nat8);
  const Time = IDL.Int;
  const Listing__1 = IDL.Record({
    'subaccount' : IDL.Opt(SubAccount__1),
    'locked' : IDL.Opt(Time),
    'seller' : IDL.Principal,
    'price' : IDL.Nat64,
  });
  const CommonError__2 = IDL.Variant({
    'InvalidToken' : TokenIdentifier__1,
    'Other' : IDL.Text,
  });
  const DetailsResponse = IDL.Variant({
    'ok' : IDL.Tuple(AccountIdentifier__1, IDL.Opt(Listing__1)),
    'err' : CommonError__2,
  });
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
  const TokenIndex = IDL.Nat32;
  const Metadata = IDL.Variant({
    'fungible' : IDL.Record({
      'decimals' : IDL.Nat8,
      'metadata' : IDL.Opt(IDL.Vec(IDL.Nat8)),
      'name' : IDL.Text,
      'symbol' : IDL.Text,
    }),
    'nonfungible' : IDL.Record({ 'metadata' : IDL.Opt(IDL.Vec(IDL.Nat8)) }),
  });
  const TokenIdentifier__2 = IDL.Text;
  const Transaction = IDL.Record({
    'id' : IDL.Nat,
    'to' : AccountIdentifier__1,
    'closed' : IDL.Opt(Time),
    'token' : TokenIdentifier__2,
    'initiated' : Time,
    'from' : AccountIdentifier__1,
    'memo' : IDL.Opt(IDL.Vec(IDL.Nat8)),
    'seller' : IDL.Principal,
    'bytes' : IDL.Vec(IDL.Nat8),
    'price' : IDL.Nat64,
  });
  const Recipe__1 = IDL.Vec(IDL.Text);
  const TypeReward = IDL.Variant({
    'NFT' : IDL.Null,
    'Token' : IDL.Null,
    'Other' : IDL.Null,
  });
  const Reward = IDL.Record({
    'collection' : IDL.Principal,
    'date' : Time,
    'name' : IDL.Text,
    'category' : TypeReward,
    'identifier' : IDL.Opt(IDL.Text),
    'amount' : IDL.Nat,
  });
  const Supply = IDL.Nat;
  const Floor = IDL.Nat64;
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
  const ListRequest = IDL.Record({
    'token' : TokenIdentifier__2,
    'from_subaccount' : IDL.Opt(SubAccount__1),
    'price' : IDL.Opt(IDL.Nat64),
  });
  const ListResponse = IDL.Variant({ 'ok' : IDL.Null, 'err' : CommonError__2 });
  const TokenIndex__1 = IDL.Nat32;
  const ExtListing = IDL.Record({
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
  const ListingResponse = IDL.Vec(
    IDL.Tuple(TokenIndex__1, ExtListing, Metadata__1)
  );
  const LockResponse = IDL.Variant({
    'ok' : AccountIdentifier__1,
    'err' : CommonError__2,
  });
  const Result_4 = IDL.Variant({ 'ok' : Metadata, 'err' : CommonError__1 });
  const SubAccount__2 = IDL.Vec(IDL.Nat8);
  const Disbursement = IDL.Tuple(
    TokenIndex__1,
    AccountIdentifier__1,
    SubAccount__1,
    IDL.Nat64,
  );
  const Result__1 = IDL.Variant({ 'ok' : IDL.Null, 'err' : IDL.Text });
  const Result_3 = IDL.Variant({ 'ok' : IDL.Null, 'err' : CommonError });
  const Result_2 = IDL.Variant({
    'ok' : IDL.Vec(TokenIndex),
    'err' : CommonError,
  });
  const SubAccount = IDL.Vec(IDL.Nat8);
  const Listing = IDL.Record({
    'subaccount' : IDL.Opt(SubAccount),
    'locked' : IDL.Opt(Time),
    'seller' : IDL.Principal,
    'price' : IDL.Nat64,
  });
  const Result_1 = IDL.Variant({
    'ok' : IDL.Vec(
      IDL.Tuple(TokenIndex, IDL.Opt(Listing), IDL.Opt(IDL.Vec(IDL.Nat8)))
    ),
    'err' : CommonError,
  });
  const EntrepotTransaction = IDL.Record({
    'token' : TokenIdentifier__2,
    'time' : Time,
    'seller' : IDL.Principal,
    'buyer' : AccountIdentifier__1,
    'price' : IDL.Nat64,
  });
  const Memo = IDL.Vec(IDL.Nat8);
  const TransferRequest = IDL.Record({
    'to' : User,
    'token' : TokenIdentifier__1,
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
      'InvalidToken' : TokenIdentifier__1,
      'Rejected' : IDL.Null,
      'Unauthorized' : AccountIdentifier,
      'Other' : IDL.Text,
    }),
  });
  const ICPSquadNFT = IDL.Service({
    'acceptCycles' : IDL.Func([], [], []),
    'add_admin' : IDL.Func([IDL.Principal], [], []),
    'add_template' : IDL.Func([IDL.Text, Template], [Result_7], []),
    'airdrop_rewards' : IDL.Func(
        [IDL.Vec(IDL.Tuple(AccountIdentifier__2, Airdrop))],
        [],
        [],
      ),
    'availableCycles' : IDL.Func([], [IDL.Nat], ['query']),
    'balance' : IDL.Func([BalanceRequest], [BalanceResponse], ['query']),
    'bearer' : IDL.Func([TokenIdentifier], [Result_6], ['query']),
    'can_settle' : IDL.Func(
        [IDL.Principal, TokenIdentifier__1],
        [Result__1_2],
        [],
      ),
    'checkInventory' : IDL.Func([IDL.Principal], [Result_5], ['query']),
    'collectCanisterMetrics' : IDL.Func([], [], []),
    'create_accessory' : IDL.Func([IDL.Text, IDL.Nat], [Result__1_1], []),
    'cron_burned' : IDL.Func([], [], []),
    'cron_disbursements' : IDL.Func([], [], []),
    'cron_events' : IDL.Func([], [], []),
    'cron_settlements' : IDL.Func([], [], []),
    'cron_verification' : IDL.Func([], [], []),
    'delete_item' : IDL.Func([IDL.Text], [Result], []),
    'details' : IDL.Func([TokenIdentifier], [DetailsResponse], ['query']),
    'disbursement_pending_count' : IDL.Func([], [IDL.Nat], ['query']),
    'disbursement_queue_size' : IDL.Func([], [IDL.Nat], ['query']),
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
    'getInventory' : IDL.Func([], [Result_5], ['query']),
    'getRegistry' : IDL.Func(
        [],
        [IDL.Vec(IDL.Tuple(TokenIndex, AccountIdentifier__2))],
        ['query'],
      ),
    'getTokens' : IDL.Func(
        [],
        [IDL.Vec(IDL.Tuple(TokenIndex, Metadata))],
        ['query'],
      ),
    'get_avatar_equipped' : IDL.Func(
        [TokenIdentifier],
        [IDL.Opt(TokenIdentifier)],
        ['query'],
      ),
    'get_items' : IDL.Func(
        [],
        [IDL.Vec(IDL.Tuple(IDL.Text, IDL.Vec(TokenIndex)))],
        ['query'],
      ),
    'get_materials' : IDL.Func(
        [IDL.Principal, IDL.Bool],
        [IDL.Vec(IDL.Tuple(TokenIndex, IDL.Text))],
        ['query'],
      ),
    'get_name' : IDL.Func([TokenIndex], [IDL.Opt(IDL.Text)], ['query']),
    'get_pending_transactions' : IDL.Func(
        [],
        [IDL.Vec(IDL.Tuple(TokenIndex, Transaction))],
        ['query'],
      ),
    'get_recipes' : IDL.Func(
        [],
        [IDL.Vec(IDL.Tuple(IDL.Text, Recipe__1))],
        ['query'],
      ),
    'get_recorded_rewards' : IDL.Func(
        [IDL.Principal],
        [IDL.Opt(IDL.Vec(Reward))],
        ['query'],
      ),
    'get_stats_items' : IDL.Func(
        [],
        [IDL.Vec(IDL.Tuple(IDL.Text, Supply, IDL.Opt(Floor)))],
        ['query'],
      ),
    'get_templates' : IDL.Func(
        [],
        [IDL.Vec(IDL.Tuple(IDL.Text, Template))],
        ['query'],
      ),
    'http_request' : IDL.Func([Request], [Response], ['query']),
    'is_admin' : IDL.Func([IDL.Principal], [IDL.Bool], ['query']),
    'is_owner_account' : IDL.Func(
        [AccountIdentifier__2, TokenIndex],
        [IDL.Bool],
        [],
      ),
    'list' : IDL.Func([ListRequest], [ListResponse], []),
    'listings' : IDL.Func([], [ListingResponse], ['query']),
    'lock' : IDL.Func(
        [TokenIdentifier, IDL.Nat64, AccountIdentifier__2, IDL.Vec(IDL.Nat8)],
        [LockResponse],
        [],
      ),
    'metadata' : IDL.Func([TokenIdentifier], [Result_4], ['query']),
    'mint' : IDL.Func([IDL.Text, IDL.Principal], [Result], []),
    'payments' : IDL.Func([], [IDL.Opt(IDL.Vec(SubAccount__2))], ['query']),
    'purge_pending_transactions' : IDL.Func([], [], ['oneway']),
    'read_disbursements' : IDL.Func([], [IDL.Vec(Disbursement)], ['query']),
    'remove_accessory' : IDL.Func(
        [TokenIdentifier, TokenIdentifier],
        [Result__1],
        [],
      ),
    'remove_admin' : IDL.Func([IDL.Principal], [], []),
    'setMaxMessagesCount' : IDL.Func([IDL.Nat], [], []),
    'settle' : IDL.Func([TokenIdentifier], [Result_3], []),
    'stats' : IDL.Func(
        [],
        [IDL.Nat64, IDL.Nat64, IDL.Nat64, IDL.Nat64, IDL.Nat, IDL.Nat, IDL.Nat],
        ['query'],
      ),
    'tokenId' : IDL.Func([TokenIndex], [IDL.Text], []),
    'tokens' : IDL.Func([AccountIdentifier__2], [Result_2], ['query']),
    'tokens_ext' : IDL.Func([AccountIdentifier__2], [Result_1], ['query']),
    'transactions' : IDL.Func([], [IDL.Vec(EntrepotTransaction)], ['query']),
    'transactions_new' : IDL.Func(
        [],
        [IDL.Vec(IDL.Tuple(IDL.Nat, Transaction))],
        ['query'],
      ),
    'transactions_new_size' : IDL.Func([], [IDL.Nat], ['query']),
    'transfer' : IDL.Func([TransferRequest], [TransferResponse], []),
    'update_accessories' : IDL.Func([], [], []),
    'wear_accessory' : IDL.Func(
        [TokenIdentifier, TokenIdentifier],
        [Result],
        [],
      ),
  });
  return ICPSquadNFT;
};
export const init = ({ IDL }) => {
  return [
    IDL.Principal,
    IDL.Principal,
    IDL.Principal,
    IDL.Principal,
    IDL.Principal,
  ];
};
