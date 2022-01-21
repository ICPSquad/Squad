import type { Principal } from '@dfinity/principal';
export type AccountIdentifier = string;
export type AccountIdentifier__1 = string;
export interface AirdropObject {
  'recipient' : Principal,
  'accessory1' : [] | [string],
  'accessory2' : [] | [string],
  'material' : string,
}
export interface AssetInventory {
  'name' : string,
  'token_identifier' : string,
  'category' : AssetInventoryType,
}
export type AssetInventoryType = { 'Accessory' : null } |
  { 'LegendaryAccessory' : null } |
  { 'Material' : null };
export type Balance = bigint;
export interface BalanceRequest { 'token' : TokenIdentifier__1, 'user' : User }
export type BalanceResponse = { 'ok' : Balance } |
  { 'err' : CommonError };
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
  'addElements' : (arg_0: string, arg_1: Template) => Promise<Result_8>,
  'airdrop' : (arg_0: AirdropObject) => Promise<Result>,
  'balance' : (arg_0: BalanceRequest) => Promise<BalanceResponse>,
  'balanceOf' : (arg_0: Principal) => Promise<Array<string>>,
  'bearer' : (arg_0: TokenIdentifier) => Promise<Result_7>,
  'circulationToItem' : () => Promise<undefined>,
  'departureToExt' : () => Promise<undefined>,
  'extensions' : () => Promise<Array<Extension>>,
  'getContractInfo' : () => Promise<ContractInfo>,
  'getHisInventory' : (arg_0: Principal) => Promise<Inventory>,
  'getHisInventory_new' : (arg_0: Principal) => Promise<Inventory>,
  'getInventory' : () => Promise<Inventory>,
  'getMaterials' : (arg_0: Principal) => Promise<Array<string>>,
  'getMetadata' : () => Promise<ContractMetadata>,
  'getMinter' : () => Promise<Array<Principal>>,
  'getOwnership' : () => Promise<Array<[AccountIdentifier, Array<TokenIndex>]>>,
  'getRegistry' : () => Promise<Array<[TokenIndex, AccountIdentifier]>>,
  'getTotalMinted' : () => Promise<bigint>,
  'howMany' : (arg_0: string) => Promise<bigint>,
  'http_request' : (arg_0: Request) => Promise<Response>,
  'init' : (arg_0: Array<Principal>, arg_1: ContractMetadata) => Promise<
      undefined
    >,
  'init_cap' : () => Promise<Result>,
  'metadata' : (arg_0: TokenIdentifier) => Promise<Result_6>,
  'mint' : (arg_0: string, arg_1: Principal) => Promise<Result_5>,
  'ownerOf' : (arg_0: string) => Promise<Result_4>,
  'showAdmins' : () => Promise<Array<Principal>>,
  'sizes' : () => Promise<[bigint, bigint]>,
  'supply' : () => Promise<bigint>,
  'tokenByIndex' : (arg_0: string) => Promise<Result_3>,
  'transfer' : (arg_0: Principal, arg_1: string) => Promise<Result_2>,
  'updateAccessories' : () => Promise<undefined>,
  'updateAdmins' : (arg_0: Principal, arg_1: boolean) => Promise<Result_1>,
  'wallet_available' : () => Promise<bigint>,
  'wallet_receive' : () => Promise<undefined>,
  'wearAccessory' : (arg_0: string, arg_1: string) => Promise<Result>,
}
export type Inventory = Array<AssetInventory>;
export type Metadata = {
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
export type Result = { 'ok' : null } |
  { 'err' : string };
export type Result_1 = { 'ok' : null } |
  { 'err' : Error };
export type Result_2 = { 'ok' : bigint } |
  { 'err' : Error };
export type Result_3 = { 'ok' : PublicToken } |
  { 'err' : Error };
export type Result_4 = { 'ok' : Principal } |
  { 'err' : Error };
export type Result_5 = { 'ok' : string } |
  { 'err' : Error };
export type Result_6 = { 'ok' : Metadata } |
  { 'err' : CommonError };
export type Result_7 = { 'ok' : AccountIdentifier } |
  { 'err' : CommonError__1 };
export type Result_8 = { 'ok' : string } |
  { 'err' : string };
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
    'Accessory' : {
      'after_wear' : string,
      'before_wear' : string,
      'recipe' : Recipe,
    }
  } |
  { 'LegendaryAccessory' : Array<number> } |
  { 'Material' : Array<number> };
export type TokenIdentifier = string;
export type TokenIdentifier__1 = string;
export type TokenIndex = number;
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
export interface _SERVICE extends Hub {}
