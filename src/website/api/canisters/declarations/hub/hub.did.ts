import { IDL } from "@dfinity/candid";
export const idlFactory: IDL.InterfaceFactory = ({ IDL }) => {
  const Permissions = IDL.Record({
    canGet: IDL.Vec(IDL.Principal),
    canVerify: IDL.Vec(IDL.Principal),
  });
  const AccountIdentifier = IDL.Variant({
    principal: IDL.Principal,
    blob: IDL.Vec(IDL.Nat8),
    text: IDL.Text,
  });
  const TokenVerbose = IDL.Record({
    decimals: IDL.Int,
    meta: IDL.Opt(IDL.Record({ Issuer: IDL.Text })),
    symbol: IDL.Text,
  });
  const Time = IDL.Int;
  const Details = IDL.Record({
    meta: IDL.Vec(IDL.Nat8),
    description: IDL.Text,
  });
  const Invoice = IDL.Record({
    id: IDL.Nat,
    permissions: IDL.Opt(Permissions),
    creator: IDL.Principal,
    destination: AccountIdentifier,
    token: TokenVerbose,
    paid: IDL.Bool,
    verifiedAtTime: IDL.Opt(Time),
    amountPaid: IDL.Nat,
    expiration: Time,
    details: IDL.Opt(Details),
    amount: IDL.Nat,
  });
  const Status = IDL.Variant({
    Invoice: Invoice,
    Member: IDL.Bool,
    InProgress: IDL.Null,
  });
  const User__1 = IDL.Record({
    height: IDL.Opt(IDL.Nat64),
    status: Status,
    twitter: IDL.Opt(IDL.Text),
    rank: IDL.Opt(IDL.Nat64),
    email: IDL.Opt(IDL.Text),
    discord: IDL.Opt(IDL.Text),
  });
  const UpgradeData = IDL.Record({
    users: IDL.Vec(IDL.Tuple(IDL.Principal, User__1)),
  });
  const GetLogMessagesFilter = IDL.Record({
    analyzeCount: IDL.Nat32,
    messageRegex: IDL.Opt(IDL.Text),
    messageContains: IDL.Opt(IDL.Text),
  });
  const Nanos = IDL.Nat64;
  const GetLogMessagesParameters = IDL.Record({
    count: IDL.Nat32,
    filter: IDL.Opt(GetLogMessagesFilter),
    fromTimeNanos: IDL.Opt(Nanos),
  });
  const GetLatestLogMessagesParameters = IDL.Record({
    upToTimeNanos: IDL.Opt(Nanos),
    count: IDL.Nat32,
    filter: IDL.Opt(GetLogMessagesFilter),
  });
  const CanisterLogRequest = IDL.Variant({
    getMessagesInfo: IDL.Null,
    getMessages: GetLogMessagesParameters,
    getLatestMessages: GetLatestLogMessagesParameters,
  });
  const CanisterLogFeature = IDL.Variant({
    filterMessageByContains: IDL.Null,
    filterMessageByRegex: IDL.Null,
  });
  const CanisterLogMessagesInfo = IDL.Record({
    features: IDL.Vec(IDL.Opt(CanisterLogFeature)),
    lastTimeNanos: IDL.Opt(Nanos),
    count: IDL.Nat32,
    firstTimeNanos: IDL.Opt(Nanos),
  });
  const LogMessagesData = IDL.Record({
    timeNanos: Nanos,
    message: IDL.Text,
  });
  const CanisterLogMessages = IDL.Record({
    data: IDL.Vec(LogMessagesData),
    lastAnalyzedMessageTimeNanos: IDL.Opt(Nanos),
  });
  const CanisterLogResponse = IDL.Variant({
    messagesInfo: CanisterLogMessagesInfo,
    messages: CanisterLogMessages,
  });
  const MetricsGranularity = IDL.Variant({
    hourly: IDL.Null,
    daily: IDL.Null,
  });
  const GetMetricsParameters = IDL.Record({
    dateToMillis: IDL.Nat,
    granularity: MetricsGranularity,
    dateFromMillis: IDL.Nat,
  });
  const UpdateCallsAggregatedData = IDL.Vec(IDL.Nat64);
  const CanisterHeapMemoryAggregatedData = IDL.Vec(IDL.Nat64);
  const CanisterCyclesAggregatedData = IDL.Vec(IDL.Nat64);
  const CanisterMemoryAggregatedData = IDL.Vec(IDL.Nat64);
  const HourlyMetricsData = IDL.Record({
    updateCalls: UpdateCallsAggregatedData,
    canisterHeapMemorySize: CanisterHeapMemoryAggregatedData,
    canisterCycles: CanisterCyclesAggregatedData,
    canisterMemorySize: CanisterMemoryAggregatedData,
    timeMillis: IDL.Int,
  });
  const NumericEntity = IDL.Record({
    avg: IDL.Nat64,
    max: IDL.Nat64,
    min: IDL.Nat64,
    first: IDL.Nat64,
    last: IDL.Nat64,
  });
  const DailyMetricsData = IDL.Record({
    updateCalls: IDL.Nat64,
    canisterHeapMemorySize: NumericEntity,
    canisterCycles: NumericEntity,
    canisterMemorySize: NumericEntity,
    timeMillis: IDL.Int,
  });
  const CanisterMetricsData = IDL.Variant({
    hourly: IDL.Vec(HourlyMetricsData),
    daily: IDL.Vec(DailyMetricsData),
  });
  const CanisterMetrics = IDL.Record({ data: CanisterMetricsData });
  const GetBalanceErr = IDL.Record({
    kind: IDL.Variant({
      NotFound: IDL.Null,
      InvalidToken: IDL.Null,
      Other: IDL.Null,
    }),
    message: IDL.Opt(IDL.Text),
  });
  const Result_3 = IDL.Variant({ ok: IDL.Nat, err: GetBalanceErr });
  const User = IDL.Record({
    height: IDL.Opt(IDL.Nat64),
    status: Status,
    twitter: IDL.Opt(IDL.Text),
    rank: IDL.Opt(IDL.Nat64),
    email: IDL.Opt(IDL.Text),
    discord: IDL.Opt(IDL.Text),
  });
  const Color = IDL.Tuple(IDL.Nat8, IDL.Nat8, IDL.Nat8, IDL.Nat8);
  const Colors = IDL.Vec(IDL.Record({ color: Color, spot: IDL.Text }));
  const MintInformation = IDL.Record({
    mouth: IDL.Text,
    background: IDL.Text,
    ears: IDL.Text,
    eyes: IDL.Text,
    hair: IDL.Text,
    cloth: IDL.Text,
    nose: IDL.Text,
    colors: Colors,
    profile: IDL.Text,
  });
  const MintSuccess = IDL.Record({ tokenId: IDL.Text });
  const MintErr = IDL.Variant({
    Invoice: Invoice,
    Anonymous: IDL.Null,
    AlreadyMinted: IDL.Null,
    AvatarCanisterErr: IDL.Text,
    Other: IDL.Text,
    InvoiceCanisterErr: IDL.Record({
      kind: IDL.Variant({
        InvalidAccount: IDL.Null,
        InvalidDetails: IDL.Null,
        InvalidAmount: IDL.Null,
        InvalidDestination: IDL.Null,
        TransferError: IDL.Null,
        MaxInvoicesReached: IDL.Null,
        BadSize: IDL.Null,
        NotFound: IDL.Null,
        NotAuthorized: IDL.Null,
        InvalidToken: IDL.Null,
        InvalidInvoiceId: IDL.Null,
        Other: IDL.Null,
        NotYetPaid: IDL.Null,
        Expired: IDL.Null,
      }),
      message: IDL.Opt(IDL.Text),
    }),
  });
  const MintResult = IDL.Variant({ ok: MintSuccess, err: MintErr });
  const Result = IDL.Variant({ ok: IDL.Null, err: IDL.Text });
  const TransferError = IDL.Record({
    kind: IDL.Variant({
      InvalidDestination: IDL.Null,
      BadFee: IDL.Null,
      InvalidToken: IDL.Null,
      Other: IDL.Null,
      InsufficientFunds: IDL.Null,
    }),
    message: IDL.Opt(IDL.Text),
  });
  const Result_2 = IDL.Variant({ ok: IDL.Nat, err: TransferError });
  const VerifyInvoiceErr = IDL.Record({
    kind: IDL.Variant({
      InvalidAccount: IDL.Null,
      TransferError: IDL.Null,
      NotFound: IDL.Null,
      NotAuthorized: IDL.Null,
      InvalidToken: IDL.Null,
      InvalidInvoiceId: IDL.Null,
      Other: IDL.Null,
      NotYetPaid: IDL.Null,
      Expired: IDL.Null,
    }),
    message: IDL.Opt(IDL.Text),
  });
  const Result_1 = IDL.Variant({ ok: IDL.Null, err: VerifyInvoiceErr });
  const ICPSquadHub = IDL.Service({
    acceptCycles: IDL.Func([], [], []),
    add_admin: IDL.Func([IDL.Principal], [], []),
    availableCycles: IDL.Func([], [IDL.Nat], ["query"]),
    backup_users: IDL.Func([], [UpgradeData], ["query"]),
    collectCanisterMetrics: IDL.Func([], [], []),
    getCanisterLog: IDL.Func([IDL.Opt(CanisterLogRequest)], [IDL.Opt(CanisterLogResponse)], ["query"]),
    getCanisterMetrics: IDL.Func([GetMetricsParameters], [IDL.Opt(CanisterMetrics)], ["query"]),
    get_balance: IDL.Func([], [Result_3], []),
    get_user: IDL.Func([], [IDL.Opt(User)], ["query"]),
    is_admin: IDL.Func([IDL.Principal], [IDL.Bool], ["query"]),
    mint: IDL.Func([MintInformation], [MintResult], []),
    modify_user: IDL.Func([User], [Result], []),
    size_users: IDL.Func([], [IDL.Nat], ["query"]),
    transfer: IDL.Func([IDL.Nat, IDL.Text], [Result_2], []),
    verify_invoice: IDL.Func([IDL.Nat], [Result_1], []),
    whitelist: IDL.Func([IDL.Principal], [Result], []),
  });
  return ICPSquadHub;
};
