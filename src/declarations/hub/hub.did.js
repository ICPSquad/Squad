export const idlFactory = ({ IDL }) => {
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
  const Color = IDL.Tuple(IDL.Nat8, IDL.Nat8, IDL.Nat8, IDL.Nat8);
  const Colors = IDL.Vec(IDL.Record({ 'color' : Color, 'spot' : IDL.Text }));
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
  const MintSuccess = IDL.Record({ 'tokenId' : IDL.Text });
  const Permissions = IDL.Record({
    'canGet' : IDL.Vec(IDL.Principal),
    'canVerify' : IDL.Vec(IDL.Principal),
  });
  const AccountIdentifier = IDL.Variant({
    'principal' : IDL.Principal,
    'blob' : IDL.Vec(IDL.Nat8),
    'text' : IDL.Text,
  });
  const TokenVerbose = IDL.Record({
    'decimals' : IDL.Int,
    'meta' : IDL.Opt(IDL.Record({ 'Issuer' : IDL.Text })),
    'symbol' : IDL.Text,
  });
  const Time = IDL.Int;
  const Details = IDL.Record({
    'meta' : IDL.Vec(IDL.Nat8),
    'description' : IDL.Text,
  });
  const Invoice = IDL.Record({
    'id' : IDL.Nat,
    'permissions' : IDL.Opt(Permissions),
    'creator' : IDL.Principal,
    'destination' : AccountIdentifier,
    'token' : TokenVerbose,
    'paid' : IDL.Bool,
    'verifiedAtTime' : IDL.Opt(Time),
    'amountPaid' : IDL.Nat,
    'expiration' : Time,
    'details' : IDL.Opt(Details),
    'amount' : IDL.Nat,
  });
  const MintErr = IDL.Variant({
    'Invoice' : Invoice,
    'Anonymous' : IDL.Null,
    'AlreadyMinted' : IDL.Null,
    'AvatarCanisterErr' : IDL.Text,
    'Other' : IDL.Text,
    'InvoiceCanisterErr' : IDL.Record({
      'kind' : IDL.Variant({
        'InvalidAccount' : IDL.Null,
        'InvalidDetails' : IDL.Null,
        'InvalidAmount' : IDL.Null,
        'InvalidDestination' : IDL.Null,
        'TransferError' : IDL.Null,
        'MaxInvoicesReached' : IDL.Null,
        'BadSize' : IDL.Null,
        'NotFound' : IDL.Null,
        'NotAuthorized' : IDL.Null,
        'InvalidToken' : IDL.Null,
        'InvalidInvoiceId' : IDL.Null,
        'Other' : IDL.Null,
        'NotYetPaid' : IDL.Null,
        'Expired' : IDL.Null,
      }),
      'message' : IDL.Opt(IDL.Text),
    }),
  });
  const MintResult = IDL.Variant({ 'ok' : MintSuccess, 'err' : MintErr });
  const ICPSquadHub = IDL.Service({
    'acceptCycles' : IDL.Func([], [], []),
    'add_admin' : IDL.Func([IDL.Principal], [], []),
    'availableCycles' : IDL.Func([], [IDL.Nat], ['query']),
    'collectCanisterMetrics' : IDL.Func([], [], []),
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
    'is_admin' : IDL.Func([IDL.Principal], [IDL.Bool], ['query']),
    'mint' : IDL.Func([MintInformation], [MintResult], []),
    'size' : IDL.Func([], [IDL.Nat], ['query']),
  });
  return ICPSquadHub;
};
export const init = ({ IDL }) => {
  return [IDL.Principal, IDL.Principal, IDL.Principal];
};
