export const idlFactory = ({ IDL }) => {
  const Result_2 = IDL.Variant({ 'ok' : IDL.Null, 'err' : IDL.Text });
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
  const WhiteListRequest__1 = IDL.Record({
    'height' : IDL.Nat64,
    'principal' : IDL.Principal,
    'twitter' : IDL.Opt(IDL.Text),
    'email' : IDL.Opt(IDL.Text),
    'discord' : IDL.Opt(IDL.Text),
    'wallet' : IDL.Text,
  });
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
  const Result_1 = IDL.Variant({ 'ok' : IDL.Nat64, 'err' : IDL.Text });
  const Result = IDL.Variant({ 'ok' : IDL.Text, 'err' : IDL.Text });
  const Time = IDL.Int;
  const MintingError = IDL.Variant({
    'Avatar' : IDL.Text,
    'Verification' : IDL.Text,
  });
  const WhiteListRequest = IDL.Record({
    'height' : IDL.Nat64,
    'principal' : IDL.Principal,
    'twitter' : IDL.Opt(IDL.Text),
    'email' : IDL.Opt(IDL.Text),
    'discord' : IDL.Opt(IDL.Text),
    'wallet' : IDL.Text,
  });
  const JoiningError = IDL.Record({
    'request_associated' : IDL.Opt(WhiteListRequest),
    'error_message' : IDL.Text,
    'caller' : IDL.Principal,
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
  return IDL.Service({
    'acceptCycles' : IDL.Func([], [], []),
    'addAdmin' : IDL.Func([IDL.Principal], [Result_2], []),
    'addUser' : IDL.Func([IDL.Principal, User], [Result_2], []),
    'airdrop' : IDL.Func([], [AirdropResponse], []),
    'availableCycles' : IDL.Func([], [IDL.Nat], ['query']),
    'balance' : IDL.Func([], [ICP], []),
    'checkRegistration' : IDL.Func([], [IDL.Bool], ['query']),
    'confirm' : IDL.Func([IDL.Nat64], [Result_2], []),
    'getInformations' : IDL.Func(
        [],
        [IDL.Vec(IDL.Tuple(IDL.Principal, User))],
        [],
      ),
    'getRank' : IDL.Func([IDL.Principal], [IDL.Opt(IDL.Nat)], ['query']),
    'isUserAuthorized' : IDL.Func([], [Result_2], ['query']),
    'join' : IDL.Func([WhiteListRequest__1, IDL.Vec(IDL.Nat8)], [Result_2], []),
    'mintRequest' : IDL.Func([MintRequest], [AvatarResponse], []),
    'modifyUser' : IDL.Func([IDL.Principal, User], [Result_2], []),
    'numberUsers' : IDL.Func([], [IDL.Nat], ['query']),
    'prejoin' : IDL.Func(
        [
          IDL.Text,
          IDL.Opt(IDL.Text),
          IDL.Opt(IDL.Text),
          IDL.Opt(IDL.Text),
          SubAccount,
        ],
        [Result_1],
        [],
      ),
    'removeUser' : IDL.Func([IDL.Principal], [Result], []),
    'showErrors' : IDL.Func(
        [],
        [IDL.Vec(IDL.Tuple(Time, MintingError))],
        ['query'],
      ),
    'showJoiningErrors' : IDL.Func(
        [],
        [IDL.Vec(IDL.Tuple(Time, JoiningError))],
        ['query'],
      ),
    'showUser' : IDL.Func([IDL.Principal], [IDL.Opt(User)], ['query']),
    'transfer' : IDL.Func([ICP, IDL.Principal], [TransferResult], []),
    'verificationPayments' : IDL.Func([], [IDL.Vec(SubAccount)], []),
  });
};
export const init = ({ IDL }) => { return []; };
