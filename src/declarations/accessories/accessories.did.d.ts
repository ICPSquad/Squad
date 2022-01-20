import type { Principal } from '@dfinity/principal';
export type AccountIdentifier = string;
export type AccountIdentifier__1 = string;
export interface AirdropObject {
  'recipient' : Principal,
  'accessory1' : [] | [string],
  'accessory2' : [] | [string],
  'material' : string,
}
export interface Asset {
  'contentType' : string,
  'payload' : Array<Array<number>>,
}
export interface AssetInventory {
  'name' : string,
  'token_identifier' : string,
  'category' : AssetInventoryType,
}
export type AssetInventoryType = { 'Accessory' : null } |
  { 'Material' : null };
export type AssetRequest = {
    'Put' : {
      'key' : string,
      'contentType' : string,
      'callback' : [] | [Callback],
      'payload' : { 'StagedData' : null } |
        { 'Payload' : Array<number> },
    }
  } |
  { 'Remove' : { 'key' : string, 'callback' : [] | [Callback] } } |
  { 'StagedWrite' : WriteAsset };
export interface AuthorizeRequest {
  'p' : Principal,
  'id' : string,
  'isAuthorized' : boolean,
}
export type Balance = bigint;
export interface BalanceRequest { 'token' : TokenIdentifier__1, 'user' : User }
export type BalanceResponse = { 'ok' : Balance } |
  { 'err' : CommonError };
export type Blueprint = Array<string>;
export type Callback = () => Promise<undefined>;
export interface Chunk {
  'data' : Array<number>,
  'totalPages' : bigint,
  'nextPage' : [] | [bigint],
}
export type CommonError = { 'InvalidToken' : TokenIdentifier__1 } |
  { 'Other' : string };
export type CommonError__1 = { 'InvalidToken' : TokenIdentifier__1 } |
  { 'Other' : string };
export interface ContractInfo {
  'nft_payload_size' : bigint,
  'memory_size' : bigint,
  'max_live_size' : bigint,
  'cycles' : bigint,
  'total_minted' : bigint,
  'heap_size' : bigint,
  'authorized_users' : Array<Principal>,
}
export interface ContractMetadata { 'name' : string, 'symbol' : string }
export type Error = { 'AssetNotFound' : null } |
  { 'Immutable' : null } |
  { 'unsupportedResponse' : null } |
  { 'NotFound' : null } |
  { 'AssetTooHeavy' : null } |
  { 'Unauthorized' : null } |
  { 'InvalidRequest' : null } |
  { 'invalidTransaction' : null } |
  { 'ErrorMinting' : null } |
  { 'AuthorizedPrincipalLimitReached' : bigint } |
  { 'FailedToWrite' : string };
export type Extension = string;
export type HeaderField = [string, string];
export interface Hub {
  'addAccessory' : (arg_0: [string, Asset, Blueprint]) => Promise<Result_11>,
  'addElements' : (
      arg_0: string,
      arg_1: Template,
      arg_2: [] | [Recipe],
    ) => Promise<Result_11>,
  'addListAccessory' : (arg_0: Array<[string, Asset, Blueprint]>) => Promise<
      Result_11
    >,
  'addListMaterial' : (arg_0: Array<[string, Asset]>) => Promise<Result_11>,
  'airdrop' : (arg_0: AirdropObject) => Promise<Result_1>,
  'assetRequest' : (arg_0: AssetRequest) => Promise<Result_3>,
  'authorize' : (arg_0: AuthorizeRequest) => Promise<Result_3>,
  'balance' : (arg_0: BalanceRequest) => Promise<BalanceResponse>,
  'balanceOf' : (arg_0: Principal) => Promise<Array<string>>,
  'bearer' : (arg_0: TokenIdentifier) => Promise<Result_10>,
  'extensions' : () => Promise<Array<Extension>>,
  'getAllInventory' : (arg_0: Array<Principal>) => Promise<
      Array<[Principal, Inventory]>
    >,
  'getAuthorized' : (arg_0: string) => Promise<Array<Principal>>,
  'getContractInfo' : () => Promise<ContractInfo>,
  'getHisInventory' : (arg_0: Principal) => Promise<Inventory>,
  'getInventory' : () => Promise<Inventory>,
  'getMaterials' : (arg_0: Principal) => Promise<Array<string>>,
  'getMetadata' : () => Promise<ContractMetadata>,
  'getMinter' : () => Promise<Array<Principal>>,
  'getOwnership' : () => Promise<Array<[AccountIdentifier, Array<TokenIndex>]>>,
  'getRegistry' : () => Promise<Array<[TokenIndex, AccountIdentifier]>>,
  'getTotalMinted' : () => Promise<bigint>,
  'howMany' : (arg_0: string) => Promise<bigint>,
  'http_request' : (arg_0: Request) => Promise<Response>,
  'http_request_streaming_callback' : (
      arg_0: StreamingCallbackToken,
    ) => Promise<StreamingCallbackResponse>,
  'init' : (arg_0: Array<Principal>, arg_1: ContractMetadata) => Promise<
      undefined
    >,
  'init_cap' : () => Promise<Result_1>,
  'isAuthorized' : (arg_0: string, arg_1: Principal) => Promise<boolean>,
  'listAssets' : () => Promise<Array<[string, string, bigint]>>,
  'metadata' : (arg_0: TokenIdentifier) => Promise<Result_9>,
  'mint' : (arg_0: string, arg_1: Principal) => Promise<Result>,
  'nftStreamingCallback' : (arg_0: StreamingCallbackToken) => Promise<
      StreamingCallbackResponse
    >,
  'ownerOf' : (arg_0: string) => Promise<Result_8>,
  'queryProperties' : (arg_0: QueryRequest) => Promise<Result_2>,
  'staticStreamingCallback' : (arg_0: StreamingCallbackToken) => Promise<
      StreamingCallbackResponse
    >,
  'supply' : () => Promise<bigint>,
  'tokenByIndex' : (arg_0: string) => Promise<Result_7>,
  'tokenChunkByIndex' : (arg_0: string, arg_1: bigint) => Promise<Result_6>,
  'tokenMetadataByIndex' : (arg_0: string) => Promise<Result_5>,
  'transfer' : (arg_0: Principal, arg_1: string) => Promise<Result_4>,
  'updateAdmins' : (arg_0: Principal, arg_1: boolean) => Promise<Result_3>,
  'updateProperties' : (arg_0: UpdateRequest) => Promise<Result_2>,
  'wallet_available' : () => Promise<bigint>,
  'wallet_receive' : () => Promise<undefined>,
  'wearAccessory' : (arg_0: string, arg_1: string) => Promise<Result_1>,
  'writeStaged' : (arg_0: WriteNFT) => Promise<Result>,
}
export type Inventory = Array<AssetInventory>;
export interface Metadata {
  'id' : string,
  'contentType' : string,
  'owner' : Principal,
  'createdAt' : bigint,
  'properties' : Properties,
}
export type Metadata__1 = {
    'fungible' : {
      'decimals' : number,
      'metadata' : [] | [Array<number>],
      'name' : string,
      'symbol' : string,
    }
  } |
  { 'nonfungible' : { 'metadata' : [] | [Array<number>] } };
export type PayloadResult = { 'Complete' : Array<number> } |
  { 'Chunk' : Chunk };
export type Properties = Array<Property>;
export interface Property {
  'value' : Value,
  'name' : string,
  'immutable' : boolean,
}
export interface PublicToken {
  'id' : string,
  'contentType' : string,
  'owner' : Principal,
  'createdAt' : bigint,
  'properties' : Properties,
  'payload' : PayloadResult,
}
export interface Query { 'name' : string, 'next' : Array<Query> }
export type QueryMode = { 'All' : null } |
  { 'Some' : Array<Query> };
export interface QueryRequest { 'id' : string, 'mode' : QueryMode }
export type Recipe = Array<string>;
export interface Request {
  'url' : string,
  'method' : string,
  'body' : Array<number>,
  'headers' : Array<HeaderField>,
}
export interface Response {
  'body' : Array<number>,
  'headers' : Array<HeaderField>,
  'streaming_strategy' : [] | [StreamingStrategy],
  'status_code' : number,
}
export type Result = { 'ok' : string } |
  { 'err' : Error };
export type Result_1 = { 'ok' : null } |
  { 'err' : string };
export type Result_10 = { 'ok' : AccountIdentifier } |
  { 'err' : CommonError__1 };
export type Result_11 = { 'ok' : string } |
  { 'err' : string };
export type Result_2 = { 'ok' : Properties } |
  { 'err' : Error };
export type Result_3 = { 'ok' : null } |
  { 'err' : Error };
export type Result_4 = { 'ok' : bigint } |
  { 'err' : Error };
export type Result_5 = { 'ok' : Metadata } |
  { 'err' : Error };
export type Result_6 = { 'ok' : Chunk } |
  { 'err' : Error };
export type Result_7 = { 'ok' : PublicToken } |
  { 'err' : Error };
export type Result_8 = { 'ok' : Principal } |
  { 'err' : Error };
export type Result_9 = { 'ok' : Metadata__1 } |
  { 'err' : CommonError };
export type StreamingCallback = (arg_0: StreamingCallbackToken) => Promise<
    StreamingCallbackResponse
  >;
export interface StreamingCallbackResponse {
  'token' : [] | [StreamingCallbackToken],
  'body' : Array<number>,
}
export interface StreamingCallbackToken {
  'key' : string,
  'index' : bigint,
  'content_encoding' : string,
}
export type StreamingStrategy = {
    'Callback' : {
      'token' : StreamingCallbackToken,
      'callback' : StreamingCallback,
    }
  };
export type Template = {
    'Accessory' : { 'after_wear' : string, 'before_wear' : string }
  } |
  { 'LegendaryAccessory' : Array<number> } |
  { 'Material' : Array<number> };
export type TokenIdentifier = string;
export type TokenIdentifier__1 = string;
export type TokenIndex = number;
export interface Update { 'mode' : UpdateMode, 'name' : string }
export type UpdateMode = { 'Set' : Value } |
  { 'Next' : Array<Update> };
export interface UpdateRequest { 'id' : string, 'update' : Array<Update> }
export type User = { 'principal' : Principal } |
  { 'address' : AccountIdentifier__1 };
export type Value = { 'Int' : bigint } |
  { 'Nat' : bigint } |
  { 'Empty' : null } |
  { 'Bool' : boolean } |
  { 'Text' : string } |
  { 'Float' : number } |
  { 'Principal' : Principal } |
  { 'Class' : Array<Property> };
export type WriteAsset = {
    'Init' : { 'id' : string, 'size' : bigint, 'callback' : [] | [Callback] }
  } |
  {
    'Chunk' : {
      'id' : string,
      'chunk' : Array<number>,
      'callback' : [] | [Callback],
    }
  };
export type WriteNFT = {
    'Init' : { 'size' : bigint, 'callback' : [] | [Callback] }
  } |
  {
    'Chunk' : {
      'id' : string,
      'chunk' : Array<number>,
      'callback' : [] | [Callback],
    }
  };
export interface _SERVICE extends Hub {}
