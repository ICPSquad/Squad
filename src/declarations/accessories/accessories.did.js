export const idlFactory = ({ IDL }) => {
  const Property = IDL.Rec();
  const Query = IDL.Rec();
  const Update = IDL.Rec();
  const Asset = IDL.Record({
    'contentType' : IDL.Text,
    'payload' : IDL.Vec(IDL.Vec(IDL.Nat8)),
  });
  const Blueprint = IDL.Vec(IDL.Text);
  const Result_11 = IDL.Variant({ 'ok' : IDL.Text, 'err' : IDL.Text });
  const Template = IDL.Variant({
    'Accessory' : IDL.Record({
      'after_wear' : IDL.Text,
      'before_wear' : IDL.Text,
    }),
    'LegendaryAccessory' : IDL.Vec(IDL.Nat8),
    'Material' : IDL.Vec(IDL.Nat8),
  });
  const Recipe = IDL.Vec(IDL.Text);
  const AirdropObject = IDL.Record({
    'recipient' : IDL.Principal,
    'accessory1' : IDL.Opt(IDL.Text),
    'accessory2' : IDL.Opt(IDL.Text),
    'material' : IDL.Text,
  });
  const Result_1 = IDL.Variant({ 'ok' : IDL.Null, 'err' : IDL.Text });
  const Callback = IDL.Func([], [], []);
  const WriteAsset = IDL.Variant({
    'Init' : IDL.Record({
      'id' : IDL.Text,
      'size' : IDL.Nat,
      'callback' : IDL.Opt(Callback),
    }),
    'Chunk' : IDL.Record({
      'id' : IDL.Text,
      'chunk' : IDL.Vec(IDL.Nat8),
      'callback' : IDL.Opt(Callback),
    }),
  });
  const AssetRequest = IDL.Variant({
    'Put' : IDL.Record({
      'key' : IDL.Text,
      'contentType' : IDL.Text,
      'callback' : IDL.Opt(Callback),
      'payload' : IDL.Variant({
        'StagedData' : IDL.Null,
        'Payload' : IDL.Vec(IDL.Nat8),
      }),
    }),
    'Remove' : IDL.Record({ 'key' : IDL.Text, 'callback' : IDL.Opt(Callback) }),
    'StagedWrite' : WriteAsset,
  });
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
  const Result_3 = IDL.Variant({ 'ok' : IDL.Null, 'err' : Error });
  const AuthorizeRequest = IDL.Record({
    'p' : IDL.Principal,
    'id' : IDL.Text,
    'isAuthorized' : IDL.Bool,
  });
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
  const Result_10 = IDL.Variant({
    'ok' : AccountIdentifier,
    'err' : CommonError__1,
  });
  const Extension = IDL.Text;
  const AssetInventoryType = IDL.Variant({
    'Accessory' : IDL.Null,
    'Material' : IDL.Null,
  });
  const AssetInventory = IDL.Record({
    'name' : IDL.Text,
    'token_identifier' : IDL.Text,
    'category' : AssetInventoryType,
  });
  const Inventory = IDL.Vec(AssetInventory);
  const ContractInfo = IDL.Record({
    'nft_payload_size' : IDL.Nat,
    'memory_size' : IDL.Nat,
    'max_live_size' : IDL.Nat,
    'cycles' : IDL.Nat,
    'total_minted' : IDL.Nat,
    'heap_size' : IDL.Nat,
    'authorized_users' : IDL.Vec(IDL.Principal),
  });
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
  const Metadata__1 = IDL.Variant({
    'fungible' : IDL.Record({
      'decimals' : IDL.Nat8,
      'metadata' : IDL.Opt(IDL.Vec(IDL.Nat8)),
      'name' : IDL.Text,
      'symbol' : IDL.Text,
    }),
    'nonfungible' : IDL.Record({ 'metadata' : IDL.Opt(IDL.Vec(IDL.Nat8)) }),
  });
  const Result_9 = IDL.Variant({ 'ok' : Metadata__1, 'err' : CommonError });
  const Result = IDL.Variant({ 'ok' : IDL.Text, 'err' : Error });
  const Result_8 = IDL.Variant({ 'ok' : IDL.Principal, 'err' : Error });
  Query.fill(IDL.Record({ 'name' : IDL.Text, 'next' : IDL.Vec(Query) }));
  const QueryMode = IDL.Variant({ 'All' : IDL.Null, 'Some' : IDL.Vec(Query) });
  const QueryRequest = IDL.Record({ 'id' : IDL.Text, 'mode' : QueryMode });
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
  const Result_2 = IDL.Variant({ 'ok' : Properties, 'err' : Error });
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
  const Result_7 = IDL.Variant({ 'ok' : PublicToken, 'err' : Error });
  const Result_6 = IDL.Variant({ 'ok' : Chunk, 'err' : Error });
  const Metadata = IDL.Record({
    'id' : IDL.Text,
    'contentType' : IDL.Text,
    'owner' : IDL.Principal,
    'createdAt' : IDL.Int,
    'properties' : Properties,
  });
  const Result_5 = IDL.Variant({ 'ok' : Metadata, 'err' : Error });
  const Result_4 = IDL.Variant({ 'ok' : IDL.Nat64, 'err' : Error });
  const UpdateMode = IDL.Variant({ 'Set' : Value, 'Next' : IDL.Vec(Update) });
  Update.fill(IDL.Record({ 'mode' : UpdateMode, 'name' : IDL.Text }));
  const UpdateRequest = IDL.Record({
    'id' : IDL.Text,
    'update' : IDL.Vec(Update),
  });
  const WriteNFT = IDL.Variant({
    'Init' : IDL.Record({ 'size' : IDL.Nat, 'callback' : IDL.Opt(Callback) }),
    'Chunk' : IDL.Record({
      'id' : IDL.Text,
      'chunk' : IDL.Vec(IDL.Nat8),
      'callback' : IDL.Opt(Callback),
    }),
  });
  const Hub = IDL.Service({
    'addAccessory' : IDL.Func(
        [IDL.Tuple(IDL.Text, Asset, Blueprint)],
        [Result_11],
        [],
      ),
    'addElements' : IDL.Func(
        [IDL.Text, Template, IDL.Opt(Recipe)],
        [Result_11],
        [],
      ),
    'addListAccessory' : IDL.Func(
        [IDL.Vec(IDL.Tuple(IDL.Text, Asset, Blueprint))],
        [Result_11],
        [],
      ),
    'addListMaterial' : IDL.Func(
        [IDL.Vec(IDL.Tuple(IDL.Text, Asset))],
        [Result_11],
        [],
      ),
    'airdrop' : IDL.Func([AirdropObject], [Result_1], []),
    'assetRequest' : IDL.Func([AssetRequest], [Result_3], []),
    'authorize' : IDL.Func([AuthorizeRequest], [Result_3], []),
    'balance' : IDL.Func([BalanceRequest], [BalanceResponse], ['query']),
    'balanceOf' : IDL.Func([IDL.Principal], [IDL.Vec(IDL.Text)], ['query']),
    'bearer' : IDL.Func([TokenIdentifier], [Result_10], ['query']),
    'extensions' : IDL.Func([], [IDL.Vec(Extension)], ['query']),
    'getAllInventory' : IDL.Func(
        [IDL.Vec(IDL.Principal)],
        [IDL.Vec(IDL.Tuple(IDL.Principal, Inventory))],
        ['query'],
      ),
    'getAuthorized' : IDL.Func([IDL.Text], [IDL.Vec(IDL.Principal)], ['query']),
    'getContractInfo' : IDL.Func([], [ContractInfo], []),
    'getHisInventory' : IDL.Func([IDL.Principal], [Inventory], ['query']),
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
    'http_request_streaming_callback' : IDL.Func(
        [StreamingCallbackToken],
        [StreamingCallbackResponse],
        ['query'],
      ),
    'init' : IDL.Func([IDL.Vec(IDL.Principal), ContractMetadata], [], []),
    'init_cap' : IDL.Func([], [Result_1], []),
    'isAuthorized' : IDL.Func([IDL.Text, IDL.Principal], [IDL.Bool], ['query']),
    'listAssets' : IDL.Func(
        [],
        [IDL.Vec(IDL.Tuple(IDL.Text, IDL.Text, IDL.Nat))],
        ['query'],
      ),
    'metadata' : IDL.Func([TokenIdentifier], [Result_9], ['query']),
    'mint' : IDL.Func([IDL.Text, IDL.Principal], [Result], []),
    'nftStreamingCallback' : IDL.Func(
        [StreamingCallbackToken],
        [StreamingCallbackResponse],
        ['query'],
      ),
    'ownerOf' : IDL.Func([IDL.Text], [Result_8], ['query']),
    'queryProperties' : IDL.Func([QueryRequest], [Result_2], ['query']),
    'staticStreamingCallback' : IDL.Func(
        [StreamingCallbackToken],
        [StreamingCallbackResponse],
        ['query'],
      ),
    'supply' : IDL.Func([], [IDL.Nat], ['query']),
    'tokenByIndex' : IDL.Func([IDL.Text], [Result_7], []),
    'tokenChunkByIndex' : IDL.Func([IDL.Text, IDL.Nat], [Result_6], []),
    'tokenMetadataByIndex' : IDL.Func([IDL.Text], [Result_5], []),
    'transfer' : IDL.Func([IDL.Principal, IDL.Text], [Result_4], []),
    'updateAdmins' : IDL.Func([IDL.Principal, IDL.Bool], [Result_3], []),
    'updateProperties' : IDL.Func([UpdateRequest], [Result_2], []),
    'wallet_available' : IDL.Func([], [IDL.Nat], ['query']),
    'wallet_receive' : IDL.Func([], [], []),
    'wearAccessory' : IDL.Func([IDL.Text, IDL.Text], [Result_1], []),
    'writeStaged' : IDL.Func([WriteNFT], [Result], []),
  });
  return Hub;
};
export const init = ({ IDL }) => { return []; };
