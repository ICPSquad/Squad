export const idlFactory = ({ IDL }) => {
  const AccountIdentifier__1 = IDL.Variant({
    'principal' : IDL.Principal,
    'blob' : IDL.Vec(IDL.Nat8),
    'text' : IDL.Text,
  });
  const AccountIdentifierToBlobSuccess = IDL.Vec(IDL.Nat8);
  const AccountIdentifierToBlobErr = IDL.Record({
    'kind' : IDL.Variant({
      'InvalidAccountIdentifier' : IDL.Null,
      'Other' : IDL.Null,
    }),
    'message' : IDL.Opt(IDL.Text),
  });
  const AccountIdentifierToBlobResult = IDL.Variant({
    'ok' : AccountIdentifierToBlobSuccess,
    'err' : AccountIdentifierToBlobErr,
  });
  const Category = IDL.Variant({
    'AvatarMint' : IDL.Null,
    'AccessoryFee' : IDL.Null,
  });
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
  const Invoice__1 = IDL.Record({
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
  const CreateInvoiceSuccess = IDL.Record({ 'invoice' : Invoice__1 });
  const CreateInvoiceErr = IDL.Record({
    'kind' : IDL.Variant({
      'InvalidDetails' : IDL.Null,
      'InvalidAmount' : IDL.Null,
      'InvalidDestination' : IDL.Null,
      'MaxInvoicesReached' : IDL.Null,
      'BadSize' : IDL.Null,
      'InvalidToken' : IDL.Null,
      'Other' : IDL.Null,
    }),
    'message' : IDL.Opt(IDL.Text),
  });
  const CreateInvoiceResult = IDL.Variant({
    'ok' : CreateInvoiceSuccess,
    'err' : CreateInvoiceErr,
  });
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
  const Token = IDL.Record({ 'symbol' : IDL.Text });
  const GetDestinationAccountIdentifierArgs = IDL.Record({
    'token' : Token,
    'invoiceId' : IDL.Nat,
    'caller' : IDL.Principal,
  });
  const GetDestinationAccountIdentifierSuccess = IDL.Record({
    'accountIdentifier' : AccountIdentifier,
  });
  const GetDestinationAccountIdentifierErr = IDL.Record({
    'kind' : IDL.Variant({
      'InvalidToken' : IDL.Null,
      'InvalidInvoiceId' : IDL.Null,
      'Other' : IDL.Null,
    }),
    'message' : IDL.Opt(IDL.Text),
  });
  const GetDestinationAccountIdentifierResult = IDL.Variant({
    'ok' : GetDestinationAccountIdentifierSuccess,
    'err' : GetDestinationAccountIdentifierErr,
  });
  const GetAccountIdentifierArgs = IDL.Record({
    'principal' : IDL.Principal,
    'token' : Token,
  });
  const GetAccountIdentifierSuccess = IDL.Record({
    'accountIdentifier' : AccountIdentifier,
  });
  const GetAccountIdentifierErr = IDL.Record({
    'kind' : IDL.Variant({ 'InvalidToken' : IDL.Null, 'Other' : IDL.Null }),
    'message' : IDL.Opt(IDL.Text),
  });
  const GetAccountIdentifierResult = IDL.Variant({
    'ok' : GetAccountIdentifierSuccess,
    'err' : GetAccountIdentifierErr,
  });
  const GetBalanceArgs = IDL.Record({ 'token' : Token });
  const GetBalanceSuccess = IDL.Record({ 'balance' : IDL.Nat });
  const GetBalanceErr = IDL.Record({
    'kind' : IDL.Variant({
      'NotFound' : IDL.Null,
      'InvalidToken' : IDL.Null,
      'Other' : IDL.Null,
    }),
    'message' : IDL.Opt(IDL.Text),
  });
  const GetBalanceResult = IDL.Variant({
    'ok' : GetBalanceSuccess,
    'err' : GetBalanceErr,
  });
  const GetInvoiceArgs = IDL.Record({ 'id' : IDL.Nat });
  const GetInvoiceSuccess = IDL.Record({ 'invoice' : Invoice__1 });
  const GetInvoiceErr = IDL.Record({
    'kind' : IDL.Variant({
      'NotFound' : IDL.Null,
      'NotAuthorized' : IDL.Null,
      'InvalidInvoiceId' : IDL.Null,
      'Other' : IDL.Null,
    }),
    'message' : IDL.Opt(IDL.Text),
  });
  const GetInvoiceResult = IDL.Variant({
    'ok' : GetInvoiceSuccess,
    'err' : GetInvoiceErr,
  });
  const TransferArgs = IDL.Record({
    'destination' : AccountIdentifier,
    'token' : Token,
    'amount' : IDL.Nat,
  });
  const TransferSuccess = IDL.Record({ 'blockHeight' : IDL.Nat64 });
  const TransferError = IDL.Record({
    'kind' : IDL.Variant({
      'InvalidDestination' : IDL.Null,
      'BadFee' : IDL.Null,
      'InvalidToken' : IDL.Null,
      'Other' : IDL.Null,
      'InsufficientFunds' : IDL.Null,
    }),
    'message' : IDL.Opt(IDL.Text),
  });
  const TransferResult = IDL.Variant({
    'ok' : TransferSuccess,
    'err' : TransferError,
  });
  const VerifyInvoiceArgs = IDL.Record({ 'id' : IDL.Nat });
  const VerifyInvoiceSuccess = IDL.Variant({
    'Paid' : IDL.Record({ 'invoice' : Invoice__1 }),
    'AlreadyVerified' : IDL.Record({ 'invoice' : Invoice__1 }),
  });
  const VerifyInvoiceErr = IDL.Record({
    'kind' : IDL.Variant({
      'InvalidAccount' : IDL.Null,
      'TransferError' : IDL.Null,
      'NotFound' : IDL.Null,
      'NotAuthorized' : IDL.Null,
      'InvalidToken' : IDL.Null,
      'InvalidInvoiceId' : IDL.Null,
      'Other' : IDL.Null,
      'NotYetPaid' : IDL.Null,
      'Expired' : IDL.Null,
    }),
    'message' : IDL.Opt(IDL.Text),
  });
  const VerifyInvoiceResult = IDL.Variant({
    'ok' : VerifyInvoiceSuccess,
    'err' : VerifyInvoiceErr,
  });
  const Invoice = IDL.Service({
    'acceptCycles' : IDL.Func([], [], []),
    'accountIdentifierToBlob' : IDL.Func(
        [AccountIdentifier__1],
        [AccountIdentifierToBlobResult],
        [],
      ),
    'add_admin' : IDL.Func([IDL.Principal], [], []),
    'availableCycles' : IDL.Func([], [IDL.Nat], ['query']),
    'collectCanisterMetrics' : IDL.Func([], [], []),
    'create_invoice' : IDL.Func([Category], [CreateInvoiceResult], []),
    'cron_balance' : IDL.Func([], [], []),
    'cron_transfer' : IDL.Func([], [], []),
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
    'getDestinationAccountIdentifierPublic' : IDL.Func(
        [GetDestinationAccountIdentifierArgs],
        [GetDestinationAccountIdentifierResult],
        [],
      ),
    'get_account_identifier' : IDL.Func(
        [GetAccountIdentifierArgs],
        [GetAccountIdentifierResult],
        ['query'],
      ),
    'get_balance' : IDL.Func([GetBalanceArgs], [GetBalanceResult], []),
    'get_invoice' : IDL.Func([GetInvoiceArgs], [GetInvoiceResult], ['query']),
    'is_admin' : IDL.Func([IDL.Principal], [IDL.Bool], ['query']),
    'transfer' : IDL.Func([TransferArgs], [TransferResult], []),
    'transfer_back_invoice' : IDL.Func([IDL.Nat], [], []),
    'verify_invoice_accessory' : IDL.Func(
        [VerifyInvoiceArgs],
        [VerifyInvoiceResult],
        [],
      ),
    'verify_invoice_avatar' : IDL.Func(
        [VerifyInvoiceArgs, IDL.Principal],
        [VerifyInvoiceResult],
        [],
      ),
  });
  return Invoice;
};
export const init = ({ IDL }) => {
  return [
    IDL.Principal,
    IDL.Principal,
    IDL.Principal,
    IDL.Principal,
    IDL.Opt(IDL.Nat),
    IDL.Opt(IDL.Nat),
  ];
};
