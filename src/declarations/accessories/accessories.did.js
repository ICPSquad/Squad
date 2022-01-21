export const idlFactory = ({ IDL }) => {
  const Property = IDL.Rec();
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
  const Result_8 = IDL.Variant({ 'ok' : IDL.Text, 'err' : IDL.Text });
  const AirdropObject = IDL.Record({
    'recipient' : IDL.Principal,
    'accessory1' : IDL.Opt(IDL.Text),
    'accessory2' : IDL.Opt(IDL.Text),
    'material' : IDL.Text,
  });
  const Result = IDL.Variant({ 'ok' : IDL.Null, 'err' : IDL.Text });
  const TokenIdentifier__1 = IDL.Text;
  const AccountIdentifier__1 = IDL.Text;
  const User = IDL.Variant({
    'principal' : IDL.Principal,
    'address' : AccountIdentifier__1,
  });
  const BalanceRequest = IDL.Record({
    'token' : TokenIdentifier__1,
    'user' : User,
  });
  const Balance = IDL.Nat;
  const CommonError = IDL.Variant({
    'InvalidToken' : TokenIdentifier__1,
    'Other' : IDL.Text,
  });
  const BalanceResponse = IDL.Variant({ 'ok' : Balance, 'err' : CommonError });
  const TokenIdentifier = IDL.Text;
  const AccountIdentifier = IDL.Text;
  const CommonError__1 = IDL.Variant({
    'InvalidToken' : TokenIdentifier__1,
    'Other' : IDL.Text,
  });
  const Result_7 = IDL.Variant({
    'ok' : AccountIdentifier,
    'err' : CommonError__1,
  });
  const Extension = IDL.Text;
  const ContractInfo = IDL.Record({
    'nft_payload_size' : IDL.Nat,
    'memory_size' : IDL.Nat,
    'max_live_size' : IDL.Nat,
    'cycles' : IDL.Nat,
    'total_minted' : IDL.Nat,
    'heap_size' : IDL.Nat,
    'authorized_users' : IDL.Vec(IDL.Principal),
  });
  const AssetInventoryType = IDL.Variant({
    'Accessory' : IDL.Null,
    'LegendaryAccessory' : IDL.Null,
    'Material' : IDL.Null,
  });
  const AssetInventory = IDL.Record({
    'name' : IDL.Text,
    'token_identifier' : IDL.Text,
    'category' : AssetInventoryType,
  });
  const Inventory = IDL.Vec(AssetInventory);
  const ContractMetadata = IDL.Record({
    'name' : IDL.Text,
    'symbol' : IDL.Text,
  });
  const TokenIndex = IDL.Nat32;
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
  const Metadata = IDL.Variant({
    'fungible' : IDL.Record({
      'decimals' : IDL.Nat8,
      'metadata' : IDL.Opt(IDL.Vec(IDL.Nat8)),
      'name' : IDL.Text,
      'symbol' : IDL.Text,
    }),
    'nonfungible' : IDL.Record({ 'metadata' : IDL.Opt(IDL.Vec(IDL.Nat8)) }),
  });
  const Result_6 = IDL.Variant({ 'ok' : Metadata, 'err' : CommonError });
  const Error = IDL.Variant({
    'AssetNotFound' : IDL.Null,
    'Immutable' : IDL.Null,
    'unsupportedResponse' : IDL.Null,
    'NotFound' : IDL.Null,
    'AssetTooHeavy' : IDL.Null,
    'Unauthorized' : IDL.Null,
    'InvalidRequest' : IDL.Null,
    'invalidTransaction' : IDL.Null,
    'ErrorMinting' : IDL.Null,
    'AuthorizedPrincipalLimitReached' : IDL.Nat,
    'FailedToWrite' : IDL.Text,
  });
  const Result_5 = IDL.Variant({ 'ok' : IDL.Text, 'err' : Error });
  const Result_4 = IDL.Variant({ 'ok' : IDL.Principal, 'err' : Error });
  const Value = IDL.Variant({
    'Int' : IDL.Int,
    'Nat' : IDL.Nat,
    'Empty' : IDL.Null,
    'Bool' : IDL.Bool,
    'Text' : IDL.Text,
    'Float' : IDL.Float64,
    'Principal' : IDL.Principal,
    'Class' : IDL.Vec(Property),
  });
  Property.fill(
    IDL.Record({ 'value' : Value, 'name' : IDL.Text, 'immutable' : IDL.Bool })
  );
  const Properties = IDL.Vec(Property);
  const Chunk = IDL.Record({
    'data' : IDL.Vec(IDL.Nat8),
    'totalPages' : IDL.Nat,
    'nextPage' : IDL.Opt(IDL.Nat),
  });
  const PayloadResult = IDL.Variant({
    'Complete' : IDL.Vec(IDL.Nat8),
    'Chunk' : Chunk,
  });
  const PublicToken = IDL.Record({
    'id' : IDL.Text,
    'contentType' : IDL.Text,
    'owner' : IDL.Principal,
    'createdAt' : IDL.Int,
    'properties' : Properties,
    'payload' : PayloadResult,
  });
  const Result_3 = IDL.Variant({ 'ok' : PublicToken, 'err' : Error });
  const Result_2 = IDL.Variant({ 'ok' : IDL.Nat64, 'err' : Error });
  const Result_1 = IDL.Variant({ 'ok' : IDL.Null, 'err' : Error });
  const Hub = IDL.Service({
    'addElements' : IDL.Func([IDL.Text, Template], [Result_8], []),
    'airdrop' : IDL.Func([AirdropObject], [Result], []),
    'balance' : IDL.Func([BalanceRequest], [BalanceResponse], ['query']),
    'balanceOf' : IDL.Func([IDL.Principal], [IDL.Vec(IDL.Text)], ['query']),
    'bearer' : IDL.Func([TokenIdentifier], [Result_7], ['query']),
    'circulationToItem' : IDL.Func([], [], []),
    'departureToExt' : IDL.Func([], [], []),
    'extensions' : IDL.Func([], [IDL.Vec(Extension)], ['query']),
    'getContractInfo' : IDL.Func([], [ContractInfo], []),
    'getHisInventory' : IDL.Func([IDL.Principal], [Inventory], ['query']),
    'getHisInventory_new' : IDL.Func([IDL.Principal], [Inventory], ['query']),
    'getInventory' : IDL.Func([], [Inventory], ['query']),
    'getMaterials' : IDL.Func([IDL.Principal], [IDL.Vec(IDL.Text)], ['query']),
    'getMetadata' : IDL.Func([], [ContractMetadata], ['query']),
    'getMinter' : IDL.Func([], [IDL.Vec(IDL.Principal)], ['query']),
    'getOwnership' : IDL.Func(
        [],
        [IDL.Vec(IDL.Tuple(AccountIdentifier, IDL.Vec(TokenIndex)))],
        ['query'],
      ),
    'getRegistry' : IDL.Func(
        [],
        [IDL.Vec(IDL.Tuple(TokenIndex, AccountIdentifier))],
        ['query'],
      ),
    'getTotalMinted' : IDL.Func([], [IDL.Nat], ['query']),
    'howMany' : IDL.Func([IDL.Text], [IDL.Nat], ['query']),
    'http_request' : IDL.Func([Request], [Response], ['query']),
    'init' : IDL.Func([IDL.Vec(IDL.Principal), ContractMetadata], [], []),
    'init_cap' : IDL.Func([], [Result], []),
    'metadata' : IDL.Func([TokenIdentifier], [Result_6], ['query']),
    'mint' : IDL.Func([IDL.Text, IDL.Principal], [Result_5], []),
    'ownerOf' : IDL.Func([IDL.Text], [Result_4], ['query']),
    'showAdmins' : IDL.Func([], [IDL.Vec(IDL.Principal)], ['query']),
    'sizes' : IDL.Func([], [IDL.Nat, IDL.Nat], ['query']),
    'supply' : IDL.Func([], [IDL.Nat], ['query']),
    'tokenByIndex' : IDL.Func([IDL.Text], [Result_3], []),
    'transfer' : IDL.Func([IDL.Principal, IDL.Text], [Result_2], []),
    'updateAccessories' : IDL.Func([], [], []),
    'updateAdmins' : IDL.Func([IDL.Principal, IDL.Bool], [Result_1], []),
    'wallet_available' : IDL.Func([], [IDL.Nat], ['query']),
    'wallet_receive' : IDL.Func([], [], []),
    'wearAccessory' : IDL.Func([IDL.Text, IDL.Text], [Result], []),
  });
  return Hub;
};
export const init = ({ IDL }) => { return []; };
