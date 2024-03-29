export const idlFactory = ({ IDL }) => {
  const TokenIdentifier = IDL.Text;
  const Result = IDL.Variant({ 'ok' : IDL.Null, 'err' : IDL.Text });
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
  const AccountIdentifier__1 = IDL.Text;
  const CommonError = IDL.Variant({
    'InvalidToken' : TokenIdentifier__1,
    'Other' : IDL.Text,
  });
  const Result_7 = IDL.Variant({
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
  const Result_6 = IDL.Variant({
    'ok' : IDL.Tuple(AccountIdentifier__1, IDL.Opt(Listing)),
    'err' : CommonError,
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
  const Name__1 = IDL.Text;
  const UserData = IDL.Record({
    'height' : IDL.Opt(IDL.Nat64),
    'selected_avatar' : IDL.Opt(TokenIdentifier__2),
    'invoice_id' : IDL.Opt(IDL.Nat),
    'twitter' : IDL.Opt(IDL.Text),
    'name' : IDL.Opt(Name__1),
    'rank' : IDL.Opt(IDL.Nat64),
    'minted' : IDL.Bool,
    'email' : IDL.Opt(IDL.Text),
    'account_identifier' : IDL.Opt(IDL.Text),
    'discord' : IDL.Opt(IDL.Text),
  });
  const Slots__1 = IDL.Record({
    'Hat' : IDL.Opt(IDL.Text),
    'Body' : IDL.Opt(IDL.Text),
    'Eyes' : IDL.Opt(IDL.Text),
    'Face' : IDL.Opt(IDL.Text),
    'Misc' : IDL.Opt(IDL.Text),
  });
  const Color = IDL.Tuple(IDL.Nat8, IDL.Nat8, IDL.Nat8, IDL.Nat8);
  const Colors = IDL.Vec(IDL.Record({ 'color' : Color, 'spot' : IDL.Text }));
  const Style = IDL.Variant({ 'Old' : IDL.Text, 'Colors' : Colors });
  const AvatarRendering = IDL.Record({
    'mouth' : IDL.Text,
    'background' : IDL.Text,
    'ears' : IDL.Text,
    'eyes' : IDL.Text,
    'hair' : IDL.Text,
    'cloth' : IDL.Text,
    'nose' : IDL.Text,
    'slots' : Slots__1,
    'style' : Style,
    'profile' : IDL.Text,
  });
  const ComponentCategory = IDL.Variant({
    'Avatar' : IDL.Null,
    'Accessory' : IDL.Null,
    'Other' : IDL.Null,
  });
  const Component = IDL.Record({
    'name' : IDL.Text,
    'layers' : IDL.Vec(IDL.Nat),
    'category' : ComponentCategory,
  });
  const Name__3 = IDL.Text;
  const Slots = IDL.Record({
    'Hat' : IDL.Opt(IDL.Text),
    'Body' : IDL.Opt(IDL.Text),
    'Eyes' : IDL.Opt(IDL.Text),
    'Face' : IDL.Opt(IDL.Text),
    'Misc' : IDL.Opt(IDL.Text),
  });
  const Name__2 = IDL.Text;
  const Stars__1 = IDL.Nat;
  const StyleScore = IDL.Nat;
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
  const Result_5 = IDL.Variant({ 'ok' : Metadata, 'err' : CommonError__1 });
  const MintInformation = IDL.Record({
    'mouth' : IDL.Text,
    'background' : IDL.Text,
    'ears' : IDL.Text,
    'eyes' : IDL.Text,
    'hair' : IDL.Text,
    'cloth' : IDL.Text,
    'nose' : IDL.Text,
    'colors' : Colors,
    'profile' : IDL.Text,
  });
  const MintResult = IDL.Variant({ 'ok' : TokenIdentifier, 'err' : IDL.Text });
  const Result_4 = IDL.Variant({ 'ok' : TokenIndex, 'err' : IDL.Text });
  const Result__1 = IDL.Variant({ 'ok' : IDL.Null, 'err' : IDL.Null });
  const Result_3 = IDL.Variant({
    'ok' : IDL.Vec(TokenIndex),
    'err' : CommonError,
  });
  const Result_2 = IDL.Variant({
    'ok' : IDL.Vec(
      IDL.Tuple(TokenIndex, IDL.Opt(Listing), IDL.Opt(IDL.Vec(IDL.Nat8)))
    ),
    'err' : CommonError,
  });
  const Result_1 = IDL.Variant({
    'ok' : IDL.Vec(TokenIdentifier),
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
  const Name = IDL.Text;
  const Stars = IDL.Nat;
  const Stats = IDL.Vec(IDL.Tuple(Name, Stars));
  const ICPSquadNFT = IDL.Service({
    'acceptCycles' : IDL.Func([], [], []),
    'add_admin' : IDL.Func([IDL.Principal], [], []),
    'associate_legendary' : IDL.Func([IDL.Text, TokenIdentifier], [Result], []),
    'availableCycles' : IDL.Func([], [IDL.Nat], ['query']),
    'balance' : IDL.Func([BalanceRequest], [BalanceResponse], ['query']),
    'bearer' : IDL.Func([TokenIdentifier], [Result_7], ['query']),
    'burn' : IDL.Func([TokenIdentifier], [Result], []),
    'calculate_style_score' : IDL.Func([], [], ['oneway']),
    'changeStyle' : IDL.Func([IDL.Text], [], []),
    'collectCanisterMetrics' : IDL.Func([], [], []),
    'create_profile' : IDL.Func(
        [
          IDL.Opt(IDL.Text),
          IDL.Opt(IDL.Text),
          IDL.Opt(IDL.Text),
          IDL.Opt(IDL.Text),
          TokenIdentifier,
        ],
        [Result],
        [],
      ),
    'cron_default_avatar' : IDL.Func([], [], []),
    'cron_events' : IDL.Func([], [], []),
    'cron_scores' : IDL.Func([], [], []),
    'delete_component' : IDL.Func([IDL.Text], [Result], []),
    'delete_file' : IDL.Func([IDL.Text], [Result], []),
    'details' : IDL.Func([TokenIdentifier], [Result_6], ['query']),
    'draw' : IDL.Func([TokenIdentifier], [Result], []),
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
    'getRegistry' : IDL.Func(
        [],
        [IDL.Vec(IDL.Tuple(TokenIndex, AccountIdentifier__1))],
        ['query'],
      ),
    'getTokens' : IDL.Func(
        [],
        [IDL.Vec(IDL.Tuple(TokenIndex, Metadata))],
        ['query'],
      ),
    'get_admins' : IDL.Func([], [IDL.Vec(IDL.Principal)], ['query']),
    'get_all_users' : IDL.Func(
        [],
        [IDL.Vec(IDL.Tuple(IDL.Principal, UserData))],
        [],
      ),
    'get_avatar_infos' : IDL.Func(
        [],
        [IDL.Opt(TokenIdentifier), IDL.Opt(AvatarRendering)],
        ['query'],
      ),
    'get_avatars' : IDL.Func([], [IDL.Vec(TokenIdentifier)], ['query']),
    'get_components' : IDL.Func(
        [],
        [IDL.Vec(IDL.Tuple(IDL.Text, Component))],
        [],
      ),
    'get_infos_accounts' : IDL.Func(
        [],
        [IDL.Vec(IDL.Tuple(IDL.Principal, AccountIdentifier__1))],
        ['query'],
      ),
    'get_infos_holders' : IDL.Func(
        [],
        [
          IDL.Vec(
            IDL.Tuple(
              IDL.Principal,
              IDL.Opt(AccountIdentifier__1),
              IDL.Opt(IDL.Text),
              IDL.Opt(IDL.Text),
              IDL.Opt(TokenIdentifier),
            )
          ),
        ],
        ['query'],
      ),
    'get_infos_leaderboard' : IDL.Func(
        [],
        [
          IDL.Vec(
            IDL.Tuple(IDL.Principal, IDL.Opt(Name__3), IDL.Opt(TokenIdentifier))
          ),
        ],
        ['query'],
      ),
    'get_number_users' : IDL.Func([], [IDL.Nat], ['query']),
    'get_score' : IDL.Func([TokenIdentifier], [IDL.Opt(IDL.Nat)], ['query']),
    'get_slot' : IDL.Func([TokenIdentifier], [IDL.Opt(Slots)], []),
    'get_stats' : IDL.Func(
        [],
        [IDL.Vec(IDL.Tuple(Name__2, Stars__1))],
        ['query'],
      ),
    'get_style_score' : IDL.Func(
        [],
        [IDL.Vec(IDL.Tuple(TokenIdentifier, StyleScore))],
        ['query'],
      ),
    'get_user' : IDL.Func([], [IDL.Opt(UserData)], ['query']),
    'has_ticket' : IDL.Func([IDL.Principal], [IDL.Bool], ['query']),
    'http_request' : IDL.Func([Request], [Response], ['query']),
    'is_admin' : IDL.Func([IDL.Principal], [IDL.Bool], ['query']),
    'metadata' : IDL.Func([TokenIdentifier], [Result_5], ['query']),
    'mint' : IDL.Func([MintInformation, IDL.Opt(IDL.Nat)], [MintResult], []),
    'mint_legendary' : IDL.Func([IDL.Text, IDL.Principal], [Result], []),
    'mint_ticket' : IDL.Func([IDL.Principal], [Result_4], []),
    'modify_profile' : IDL.Func(
        [
          IDL.Opt(IDL.Text),
          IDL.Opt(IDL.Text),
          IDL.Opt(IDL.Text),
          IDL.Opt(IDL.Text),
          TokenIdentifier,
        ],
        [Result],
        [],
      ),
    'registerComponent' : IDL.Func([IDL.Text, Component], [Result], []),
    'removeAccessory' : IDL.Func(
        [TokenIdentifier, IDL.Text, IDL.Principal],
        [Result],
        [],
      ),
    'remove_admin' : IDL.Func([IDL.Principal], [], []),
    'report_burned_accessory' : IDL.Func(
        [IDL.Text, TokenIdentifier, TokenIndex],
        [Result__1],
        [],
      ),
    'setMaxMessagesCount' : IDL.Func([IDL.Nat], [], []),
    'set_default_avatar' : IDL.Func([TokenIdentifier], [Result], []),
    'show_user' : IDL.Func([IDL.Principal], [IDL.Opt(UserData)], ['query']),
    'supply' : IDL.Func([], [IDL.Nat], ['query']),
    'tokens' : IDL.Func([AccountIdentifier__1], [Result_3], ['query']),
    'tokens_ext' : IDL.Func([AccountIdentifier__1], [Result_2], ['query']),
    'tokens_id' : IDL.Func([AccountIdentifier__1], [Result_1], ['query']),
    'tokens_ids' : IDL.Func([], [IDL.Vec(TokenIdentifier)], ['query']),
    'transfer' : IDL.Func([TransferRequest], [TransferResponse], []),
    'upload' : IDL.Func([IDL.Vec(IDL.Nat8)], [], []),
    'uploadClear' : IDL.Func([], [], []),
    'uploadFinalize' : IDL.Func([IDL.Text, Meta, IDL.Text], [Result], []),
    'upload_stats' : IDL.Func([Stats], [], ['oneway']),
    'wearAccessory' : IDL.Func(
        [TokenIdentifier, IDL.Text, IDL.Principal],
        [Result],
        [],
      ),
  });
  return ICPSquadNFT;
};
export const init = ({ IDL }) => { return []; };
