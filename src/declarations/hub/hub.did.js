export const idlFactory = ({ IDL }) => {
  const DetailValue = IDL.Rec();
  const List = IDL.Rec();
  const Status = IDL.Variant({
    'OG' : IDL.Null,
    'Staff' : IDL.Null,
    'Level1' : IDL.Null,
    'Level2' : IDL.Null,
    'Level3' : IDL.Null,
    'Legendary' : IDL.Null,
  });
  const TokenIdentifier = IDL.Text;
  const User = IDL.Record({
    'height' : IDL.Opt(IDL.Nat64),
    'status' : Status,
    'twitter' : IDL.Opt(IDL.Text),
    'rank' : IDL.Opt(IDL.Nat64),
    'email' : IDL.Opt(IDL.Text),
    'airdrop' : IDL.Opt(IDL.Vec(IDL.Text)),
    'discord' : IDL.Opt(IDL.Text),
    'wallet' : IDL.Text,
    'avatar' : IDL.Opt(TokenIdentifier),
  });
  const Result = IDL.Variant({ 'ok' : IDL.Null, 'err' : IDL.Text });
  const AirdropObject = IDL.Record({
    'recipient' : IDL.Principal,
    'accessory1' : IDL.Opt(IDL.Text),
    'accessory2' : IDL.Opt(IDL.Text),
    'material' : IDL.Text,
  });
  const AirdropResponse = IDL.Variant({
    'ok' : AirdropObject,
    'err' : IDL.Text,
  });
  const ICP = IDL.Record({ 'e8s' : IDL.Nat64 });
  const Time = IDL.Int;
  const InfosNew = IDL.Record({
    'twitter' : IDL.Opt(IDL.Text),
    'email' : IDL.Opt(IDL.Text),
    'discord' : IDL.Opt(IDL.Text),
    'wallet' : IDL.Text,
  });
  const Registration = IDL.Record({
    'invoice_id' : IDL.Nat,
    'time' : Time,
    'infos' : InfosNew,
    'account_to_send' : IDL.Text,
  });
  const StatusRegistration = IDL.Variant({
    'NotRegistered' : IDL.Null,
    'Member' : IDL.Null,
    'NotConfirmed' : Registration,
    'NotAuthenticated' : IDL.Null,
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
  const AccountIdentifier = IDL.Text;
  const ExtCoreUser = IDL.Variant({
    'principal' : IDL.Principal,
    'address' : AccountIdentifier,
  });
  const Color = IDL.Tuple(IDL.Nat8, IDL.Nat8, IDL.Nat8, IDL.Nat8);
  const AvatarRequest = IDL.Record({
    'components' : IDL.Vec(
      IDL.Record({ 'name' : IDL.Text, 'layer' : IDL.Nat8 })
    ),
    'colors' : IDL.Vec(IDL.Record({ 'color' : Color, 'spot' : IDL.Text })),
  });
  const MintRequest = IDL.Record({
    'to' : ExtCoreUser,
    'metadata' : AvatarRequest,
  });
  const AvatarInformations = IDL.Record({
    'svg' : IDL.Text,
    'tokenIdentifier' : IDL.Text,
  });
  const AvatarResponse = IDL.Variant({
    'ok' : AvatarInformations,
    'err' : IDL.Text,
  });
  const SubAccount = IDL.Vec(IDL.Nat8);
  const Result_3 = IDL.Variant({ 'ok' : IDL.Nat64, 'err' : IDL.Text });
  const RecipeInfos = IDL.Record({ 'block' : IDL.Nat64, 'amount' : IDL.Nat });
  const Result_2 = IDL.Variant({ 'ok' : RecipeInfos, 'err' : IDL.Text });
  const Result_1 = IDL.Variant({ 'ok' : IDL.Text, 'err' : IDL.Text });
  const MintingError = IDL.Variant({
    'Avatar' : IDL.Text,
    'Verification' : IDL.Text,
  });
  const Infos__1 = IDL.Record({
    'subaccount_to_send' : IDL.Vec(IDL.Nat8),
    'twitter' : IDL.Opt(IDL.Text),
    'memo' : IDL.Nat64,
    'email' : IDL.Opt(IDL.Text),
    'discord' : IDL.Opt(IDL.Text),
    'wallet' : IDL.Text,
  });
  const PaymentError = IDL.Record({
    'request_associated' : IDL.Opt(Infos__1),
    'error_message' : IDL.Text,
    'caller' : IDL.Principal,
  });
  const Infos = IDL.Record({
    'subaccount_to_send' : IDL.Vec(IDL.Nat8),
    'twitter' : IDL.Opt(IDL.Text),
    'memo' : IDL.Nat64,
    'email' : IDL.Opt(IDL.Text),
    'discord' : IDL.Opt(IDL.Text),
    'wallet' : IDL.Text,
  });
  const Audit = IDL.Record({
    'new_users' : IDL.Int,
    'new_items' : IDL.Int,
    'time' : IDL.Int,
    'new_icps' : ICP,
    'new_avatar' : IDL.Int,
  });
  DetailValue.fill(
    IDL.Variant({
      'I64' : IDL.Int64,
      'U64' : IDL.Nat64,
      'Vec' : IDL.Vec(DetailValue),
      'Slice' : IDL.Vec(IDL.Nat8),
      'Text' : IDL.Text,
      'True' : IDL.Null,
      'False' : IDL.Null,
      'Float' : IDL.Float64,
      'Principal' : IDL.Principal,
    })
  );
  const LogCategory = IDL.Variant({
    'Result' : IDL.Text,
    'Operation' : IDL.Null,
    'Cronic' : IDL.Null,
    'ErrorSystem' : IDL.Null,
    'ErrorResult' : IDL.Null,
  });
  const Event = IDL.Record({
    'time' : IDL.Nat64,
    'operation' : IDL.Text,
    'details' : IDL.Vec(IDL.Tuple(IDL.Text, DetailValue)),
    'category' : LogCategory,
    'caller' : IDL.Principal,
  });
  List.fill(IDL.Opt(IDL.Tuple(Event, List)));
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
  const Hub = IDL.Service({
    'addUser' : IDL.Func([IDL.Principal, User], [Result], []),
    'add_admin' : IDL.Func([IDL.Principal], [], []),
    'airdrop' : IDL.Func([], [AirdropResponse], []),
    'audit' : IDL.Func([], [], []),
    'balance' : IDL.Func([], [ICP], []),
    'checkRegistration' : IDL.Func([], [IDL.Bool], ['query']),
    'check_status' : IDL.Func([], [StatusRegistration], ['query']),
    'collectCanisterMetrics' : IDL.Func([], [], []),
    'confirm' : IDL.Func([IDL.Nat64], [Result], []),
    'confirm_new' : IDL.Func([], [Result], []),
    'getCanisterMetrics' : IDL.Func(
        [GetMetricsParameters],
        [IDL.Opt(CanisterMetrics)],
        ['query'],
      ),
    'getInformations' : IDL.Func(
        [],
        [IDL.Vec(IDL.Tuple(IDL.Principal, User))],
        [],
      ),
    'getRank' : IDL.Func([IDL.Principal], [IDL.Opt(IDL.Nat)], ['query']),
    'isUserAuthorized' : IDL.Func([], [Result], ['query']),
    'is_admin' : IDL.Func([IDL.Principal], [IDL.Bool], ['query']),
    'mintRequest' : IDL.Func([MintRequest], [AvatarResponse], []),
    'modifyHeight' : IDL.Func([IDL.Principal, IDL.Nat64], [Result], []),
    'modifyRank' : IDL.Func([IDL.Principal, IDL.Nat64], [Result], []),
    'modifyUser' : IDL.Func([IDL.Principal, User], [Result], []),
    'numberUsers' : IDL.Func([], [IDL.Nat], ['query']),
    'prejoin' : IDL.Func(
        [
          IDL.Text,
          IDL.Opt(IDL.Text),
          IDL.Opt(IDL.Text),
          IDL.Opt(IDL.Text),
          SubAccount,
        ],
        [Result_3],
        [],
      ),
    'process' : IDL.Func([], [], []),
    'recipe' : IDL.Func([], [Result_2], []),
    'register' : IDL.Func(
        [IDL.Text, IDL.Opt(IDL.Text), IDL.Opt(IDL.Text), IDL.Opt(IDL.Text)],
        [Result_1],
        [],
      ),
    'removeUser' : IDL.Func([IDL.Principal], [Result_1], []),
    'showErrors' : IDL.Func(
        [],
        [IDL.Vec(IDL.Tuple(Time, MintingError))],
        ['query'],
      ),
    'showPaymentErrors' : IDL.Func(
        [],
        [IDL.Vec(IDL.Tuple(Time, PaymentError))],
        ['query'],
      ),
    'showPrejoins' : IDL.Func(
        [],
        [IDL.Vec(IDL.Tuple(IDL.Principal, Infos))],
        ['query'],
      ),
    'showUser' : IDL.Func([IDL.Principal], [IDL.Opt(User)], ['query']),
    'show_audits' : IDL.Func([], [IDL.Vec(Audit)], ['query']),
    'show_logs' : IDL.Func([], [List], ['query']),
    'show_robbers' : IDL.Func([], [IDL.Vec(SubAccount)], ['query']),
    'transfer' : IDL.Func([ICP, IDL.Principal], [TransferResult], []),
    'updateAdminsData' : IDL.Func([IDL.Principal, IDL.Bool], [Result], []),
    'verification' : IDL.Func([], [], []),
    'verification_registrations' : IDL.Func([], [], []),
    'wallet_available' : IDL.Func([], [IDL.Nat], ['query']),
    'wallet_receive' : IDL.Func([], [], []),
  });
  return Hub;
};
export const init = ({ IDL }) => { return []; };
