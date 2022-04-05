export const idlFactory = ({ IDL }) => {
  const Accessory = IDL.Record({
    'content' : IDL.Text,
    'name' : IDL.Text,
    'slot' : IDL.Text,
    'layer' : IDL.Nat8,
  });
  const Result_9 = IDL.Variant({ 'ok' : IDL.Text, 'err' : IDL.Text });
  const ComponentCategory = IDL.Variant({
    'Avatar' : IDL.Null,
    'Accessory' : IDL.Null,
    'Other' : IDL.Null,
  });
  const Component__1 = IDL.Record({
    'name' : IDL.Text,
    'layers' : IDL.Vec(IDL.Nat),
    'category' : ComponentCategory,
  });
  const Result = IDL.Variant({ 'ok' : IDL.Null, 'err' : IDL.Text });
  const Component = IDL.Record({
    'content' : IDL.Text,
    'name' : IDL.Text,
    'layer' : IDL.Nat8,
  });
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
  const AccountIdentifier__1 = IDL.Text;
  const CommonError = IDL.Variant({
    'InvalidToken' : TokenIdentifier__1,
    'Other' : IDL.Text,
  });
  const Result_8 = IDL.Variant({
    'ok' : AccountIdentifier__1,
    'err' : CommonError,
  });
  const SubAccount = IDL.Vec(IDL.Nat8);
  const Time = IDL.Int;
  const Listing = IDL.Record({
    'subaccount' : IDL.Opt(SubAccount),
    'locked' : IDL.Opt(Time),
    'seller' : IDL.Principal,
    'price' : IDL.Nat64,
  });
  const Result_7 = IDL.Variant({
    'ok' : IDL.Tuple(AccountIdentifier__1, IDL.Opt(Listing)),
    'err' : CommonError,
  });
  const Extension = IDL.Text;
  const Slots__1 = IDL.Record({
    'Hat' : IDL.Opt(IDL.Text),
    'Body' : IDL.Opt(IDL.Text),
    'Eyes' : IDL.Opt(IDL.Text),
    'Face' : IDL.Opt(IDL.Text),
    'Misc' : IDL.Opt(IDL.Text),
  });
  const TokenIdentifier__2 = IDL.Text;
  const AvatarPreview = IDL.Record({
    'avatar_svg' : IDL.Text,
    'slots' : Slots__1,
    'token_identifier' : TokenIdentifier__2,
  });
  const Result_6 = IDL.Variant({ 'ok' : AvatarPreview, 'err' : IDL.Text });
  const LayerId = IDL.Nat;
  const Slots = IDL.Record({
    'Hat' : IDL.Opt(IDL.Text),
    'Body' : IDL.Opt(IDL.Text),
    'Eyes' : IDL.Opt(IDL.Text),
    'Face' : IDL.Opt(IDL.Text),
    'Misc' : IDL.Opt(IDL.Text),
  });
  const AvatarPreviewNew = IDL.Record({
    'body_name' : IDL.Text,
    'layers' : IDL.Vec(IDL.Tuple(LayerId, IDL.Text)),
    'slots' : Slots,
    'style' : IDL.Text,
    'token_identifier' : TokenIdentifier,
  });
  const Result_5 = IDL.Variant({ 'ok' : AvatarPreviewNew, 'err' : IDL.Text });
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
  const Result_4 = IDL.Variant({ 'ok' : Metadata, 'err' : CommonError__1 });
  const ComponentRequest = IDL.Record({
    'name' : IDL.Text,
    'layer' : IDL.Nat8,
  });
  const Color = IDL.Tuple(IDL.Nat8, IDL.Nat8, IDL.Nat8, IDL.Nat8);
  const AvatarRequest = IDL.Record({
    'components' : IDL.Vec(ComponentRequest),
    'colors' : IDL.Vec(IDL.Record({ 'color' : Color, 'spot' : IDL.Text })),
  });
  const MintRequest = IDL.Record({ 'to' : User, 'metadata' : AvatarRequest });
  const AvatarInformations = IDL.Record({
    'svg' : IDL.Text,
    'tokenIdentifier' : IDL.Text,
  });
  const Result_3 = IDL.Variant({ 'ok' : AvatarInformations, 'err' : IDL.Text });
  const Result_1 = IDL.Variant({
    'ok' : IDL.Vec(TokenIndex),
    'err' : CommonError,
  });
  const Result_2 = IDL.Variant({
    'ok' : IDL.Vec(
      IDL.Tuple(TokenIndex, IDL.Opt(Listing), IDL.Opt(IDL.Vec(IDL.Nat8)))
    ),
    'err' : CommonError,
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
    'addAccessory' : IDL.Func([IDL.Text, Accessory], [Result_9], []),
    'addComponent_new' : IDL.Func([IDL.Text, Component__1], [Result], []),
    'addListAccessory' : IDL.Func([IDL.Vec(Accessory)], [Result_9], []),
    'addListComponent' : IDL.Func(
        [IDL.Vec(IDL.Tuple(IDL.Text, Component))],
        [Result_9],
        [],
      ),
    'add_admin' : IDL.Func([IDL.Principal], [], []),
    'availableCycles' : IDL.Func([], [IDL.Nat], ['query']),
    'balance' : IDL.Func([BalanceRequest], [BalanceResponse], ['query']),
    'balance_new' : IDL.Func([BalanceRequest], [BalanceResponse], ['query']),
    'bearer' : IDL.Func([TokenIdentifier], [Result_8], ['query']),
    'bearer_new' : IDL.Func([TokenIdentifier], [Result_8], ['query']),
    'changeCSS' : IDL.Func([IDL.Text], [], []),
    'collectCanisterMetrics' : IDL.Func([], [], []),
    'copy' : IDL.Func([], [], []),
    'details' : IDL.Func([TokenIdentifier], [Result_7], ['query']),
    'details_new' : IDL.Func([TokenIdentifier], [Result_7], ['query']),
    'draw' : IDL.Func([TokenIdentifier], [Result], []),
    'eventsSize' : IDL.Func([], [IDL.Nat], ['query']),
    'extensions' : IDL.Func([], [IDL.Vec(Extension)], ['query']),
    'getAllAccessories' : IDL.Func(
        [],
        [IDL.Vec(IDL.Tuple(IDL.Text, Accessory))],
        ['query'],
      ),
    'getAllComponents' : IDL.Func(
        [],
        [IDL.Vec(IDL.Tuple(IDL.Text, Component))],
        ['query'],
      ),
    'getAvatarInfos' : IDL.Func([], [Result_6], ['query']),
    'getAvatarInfos_new' : IDL.Func([], [Result_5], ['query']),
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
    'getRegistry' : IDL.Func(
        [],
        [IDL.Vec(IDL.Tuple(TokenIndex, AccountIdentifier__1))],
        ['query'],
      ),
    'getRegistry_new' : IDL.Func(
        [],
        [IDL.Vec(IDL.Tuple(TokenIndex, AccountIdentifier__1))],
        ['query'],
      ),
    'getTokens' : IDL.Func(
        [],
        [IDL.Vec(IDL.Tuple(TokenIndex, Metadata))],
        ['query'],
      ),
    'getTokens_new' : IDL.Func(
        [],
        [IDL.Vec(IDL.Tuple(TokenIndex, Metadata))],
        ['query'],
      ),
    'http_request' : IDL.Func([Request], [Response], ['query']),
    'init_cap' : IDL.Func([], [Result], []),
    'is_admin' : IDL.Func([IDL.Principal], [IDL.Bool], ['query']),
    'metadata' : IDL.Func([TokenIdentifier], [Result_4], ['query']),
    'mint' : IDL.Func([MintRequest], [Result_3], []),
    'modify_style' : IDL.Func([IDL.Text], [IDL.Text], []),
    'removeAccessory' : IDL.Func(
        [TokenIdentifier, IDL.Text, IDL.Principal],
        [Result],
        [],
      ),
    'showFullSvg' : IDL.Func([TokenIdentifier], [IDL.Opt(IDL.Text)], ['query']),
    'test' : IDL.Func([], [], []),
    'test_hex' : IDL.Func([], [IDL.Vec(AccountIdentifier__1)], []),
    'tokens' : IDL.Func([AccountIdentifier__1], [Result_1], ['query']),
    'tokens_ext' : IDL.Func([AccountIdentifier__1], [Result_2], ['query']),
    'tokens_ext_new' : IDL.Func([AccountIdentifier__1], [Result_2], ['query']),
    'tokens_new' : IDL.Func([AccountIdentifier__1], [Result_1], ['query']),
    'transfer' : IDL.Func([TransferRequest], [TransferResponse], []),
    'upload' : IDL.Func([IDL.Vec(IDL.Nat8)], [], []),
    'uploadClear' : IDL.Func([], [], []),
    'uploadFinalize' : IDL.Func([IDL.Text, Meta, IDL.Text], [Result], []),
    'verificationEvents' : IDL.Func([], [], []),
    'wearAccessory' : IDL.Func(
        [TokenIdentifier, IDL.Text, IDL.Principal],
        [Result],
        [],
      ),
  });
  return ICPSquadNFT;
};
export const init = ({ IDL }) => { return [IDL.Principal]; };
