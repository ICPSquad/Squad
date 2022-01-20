export const idlFactory = ({ IDL }) => {
  const Result = IDL.Variant({ 'ok' : IDL.Null, 'err' : IDL.Text });
  const Result_3 = IDL.Variant({ 'ok' : IDL.Text, 'err' : IDL.Text });
  const Accessory = IDL.Record({
    'content' : IDL.Text,
    'name' : IDL.Text,
    'slot' : IDL.Text,
    'layer' : IDL.Nat8,
  });
  const Component = IDL.Record({
    'content' : IDL.Text,
    'name' : IDL.Text,
    'layer' : IDL.Nat8,
  });
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
  const AccountIdentifier__2 = IDL.Text;
  const CommonError = IDL.Variant({
    'InvalidToken' : TokenIdentifier__1,
    'Other' : IDL.Text,
  });
  const Result_7 = IDL.Variant({
    'ok' : AccountIdentifier__2,
    'err' : CommonError,
  });
  const Extension = IDL.Text;
  const Slots = IDL.Record({
    'Hat' : IDL.Opt(IDL.Text),
    'Body' : IDL.Opt(IDL.Text),
    'Eyes' : IDL.Opt(IDL.Text),
    'Face' : IDL.Opt(IDL.Text),
    'Misc' : IDL.Opt(IDL.Text),
  });
  const TokenIdentifier__3 = IDL.Text;
  const AvatarPreview = IDL.Record({
    'avatar_svg' : IDL.Text,
    'slots' : Slots,
    'token_identifier' : TokenIdentifier__3,
  });
  const Result_6 = IDL.Variant({ 'ok' : AvatarPreview, 'err' : IDL.Text });
  const HeaderField = IDL.Tuple(IDL.Text, IDL.Text);
  const HttpRequest = IDL.Record({
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
  const HttpStreamingStrategy = IDL.Variant({
    'Callback' : IDL.Record({
      'token' : StreamingCallbackToken,
      'callback' : StreamingCallback,
    }),
  });
  const HttpResponse = IDL.Record({
    'body' : IDL.Vec(IDL.Nat8),
    'headers' : IDL.Vec(HeaderField),
    'streaming_strategy' : IDL.Opt(HttpStreamingStrategy),
    'status_code' : IDL.Nat16,
  });
  const TokenIdentifier__2 = IDL.Text;
  const ListRequest = IDL.Record({
    'token' : TokenIdentifier__2,
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
  const Result_5 = IDL.Variant({ 'ok' : Metadata, 'err' : CommonError__1 });
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
  const Result_4 = IDL.Variant({ 'ok' : AvatarInformations, 'err' : IDL.Text });
  const Result_1 = IDL.Variant({
    'ok' : IDL.Vec(
      IDL.Tuple(TokenIndex, IDL.Opt(Listing), IDL.Opt(IDL.Vec(IDL.Nat8)))
    ),
    'err' : CommonError,
  });
  const Transaction = IDL.Record({
    'token' : TokenIdentifier__2,
    'time' : Time,
    'seller' : IDL.Principal,
    'buyer' : AccountIdentifier__1,
    'price' : IDL.Nat64,
  });
  const Memo = IDL.Vec(IDL.Nat8);
  const SubAccount = IDL.Vec(IDL.Nat8);
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
  const erc721_token = IDL.Service({
    'addAdmin' : IDL.Func([IDL.Principal], [Result], []),
    'addLegendary' : IDL.Func([IDL.Text, IDL.Text], [Result_3], []),
    'addListAccessory' : IDL.Func([IDL.Vec(Accessory)], [Result_3], []),
    'addListComponent' : IDL.Func(
        [IDL.Vec(IDL.Tuple(IDL.Text, Component))],
        [Result_3],
        [],
      ),
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
    'bearer' : IDL.Func([TokenIdentifier], [Result_7], ['query']),
    'clearPayments' : IDL.Func([IDL.Principal, IDL.Vec(SubAccount__1)], [], []),
    'draw' : IDL.Func([TokenIdentifier], [Result], []),
    'extensions' : IDL.Func([], [IDL.Vec(Extension)], ['query']),
    'getAllComponents' : IDL.Func(
        [],
        [IDL.Vec(IDL.Tuple(IDL.Text, Component))],
        ['query'],
      ),
    'getAvatarInfos' : IDL.Func([], [Result_6], ['query']),
    'getMinter' : IDL.Func([], [IDL.Vec(IDL.Principal)], ['query']),
    'getRegistry' : IDL.Func(
        [],
        [IDL.Vec(IDL.Tuple(TokenIndex, AccountIdentifier__2))],
        ['query'],
      ),
    'http_request' : IDL.Func([HttpRequest], [HttpResponse], ['query']),
    'list' : IDL.Func([ListRequest], [Result_2], []),
    'listings' : IDL.Func(
        [],
        [IDL.Vec(IDL.Tuple(TokenIndex, Listing, Metadata__1))],
        ['query'],
      ),
    'lock' : IDL.Func(
        [TokenIdentifier, IDL.Nat64, AccountIdentifier__2, SubAccount__1],
        [Result_2],
        [],
      ),
    'metadata' : IDL.Func([TokenIdentifier], [Result_5], ['query']),
    'mint' : IDL.Func([MintRequest], [Result_4], []),
    'mintLegendary' : IDL.Func(
        [IDL.Text, AccountIdentifier__2],
        [Result_3],
        [],
      ),
    'modify_style' : IDL.Func([IDL.Text], [IDL.Text], []),
    'payments' : IDL.Func([], [IDL.Opt(IDL.Vec(SubAccount__1))], ['query']),
    'removeMouth' : IDL.Func([TokenIdentifier], [Result], []),
    'settle' : IDL.Func([TokenIdentifier], [Result_2], []),
    'settlements' : IDL.Func(
        [],
        [IDL.Vec(IDL.Tuple(TokenIndex, AccountIdentifier__2, IDL.Nat64))],
        ['query'],
      ),
    'showFullSvg' : IDL.Func([TokenIdentifier], [IDL.Opt(IDL.Text)], ['query']),
    'showListAccessory' : IDL.Func(
        [],
        [IDL.Vec(IDL.Tuple(IDL.Text, Accessory))],
        ['query'],
      ),
    'showSvg' : IDL.Func([TokenIdentifier], [IDL.Opt(IDL.Text)], ['query']),
    'supply' : IDL.Func([], [IDL.Nat], ['query']),
    'tokens_ext' : IDL.Func([AccountIdentifier__2], [Result_1], ['query']),
    'transactions' : IDL.Func([], [IDL.Vec(Transaction)], ['query']),
    'transfer' : IDL.Func([TransferRequest], [TransferResponse], []),
    'wallet_available' : IDL.Func([], [IDL.Nat], ['query']),
    'wallet_receive' : IDL.Func([], [], []),
    'wearAccessory' : IDL.Func(
        [TokenIdentifier, IDL.Text, IDL.Principal],
        [Result],
        [],
      ),
  });
  return erc721_token;
};
export const init = ({ IDL }) => { return []; };
