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
export interface BalanceRequest { 'token' : TokenIdentifier, 'user' : User }
export type BalanceResponse = { 'ok' : Balance } |
  { 'err' : CommonError };
export type CommonError = { 'InvalidToken' : TokenIdentifier } |
  { 'Other' : string };
export type CommonError__1 = { 'InvalidToken' : TokenIdentifier } |
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
  '_burn' : (arg_0: TokenIndex) => Promise<Result_5>,
  'addElements' : (arg_0: string, arg_1: Template) => Promise<Result_2>,
  'airdrop' : (arg_0: AirdropObject) => Promise<Result>,
  'balance' : (arg_0: BalanceRequest) => Promise<BalanceResponse>,
  'bearer' : (arg_0: TokenIdentifier__1) => Promise<Result_4>,
  'drawAccessory' : (arg_0: TokenIdentifier__1) => Promise<undefined>,
  'extensions' : () => Promise<Array<Extension>>,
  'getContractInfo' : () => Promise<ContractInfo>,
  'getHisInventory' : (arg_0: Principal) => Promise<Inventory>,
  'getInventory' : () => Promise<Inventory>,
  'getMetadata' : () => Promise<ContractMetadata>,
  'getMinter' : () => Promise<Array<Principal>>,
  'getOwnership' : () => Promise<
      Array<[AccountIdentifier__1, Array<TokenIndex>]>
    >,
  'getRegistry' : () => Promise<Array<[TokenIndex, AccountIdentifier__1]>>,
  'http_request' : (arg_0: Request) => Promise<Response>,
  'init' : (arg_0: Array<Principal>, arg_1: ContractMetadata) => Promise<
      undefined
    >,
  'init_cap' : () => Promise<Result>,
  'metadata' : (arg_0: TokenIdentifier__1) => Promise<Result_3>,
  'mint' : (arg_0: string, arg_1: AccountIdentifier__1) => Promise<Result_2>,
  'removeAccessory' : (arg_0: string, arg_1: string) => Promise<Result>,
  'showAdmins' : () => Promise<Array<Principal>>,
  'showAssets' : () => Promise<Array<string>>,
  'sizes' : () => Promise<[bigint, bigint]>,
  'supply' : () => Promise<bigint>,
  'transfer' : (arg_0: TransferRequest) => Promise<TransferResponse>,
  'updateAccessories' : () => Promise<undefined>,
  'updateAdmins' : (arg_0: Principal, arg_1: boolean) => Promise<Result_1>,
  'updateToken' : () => Promise<TokenIndex>,
  'wallet_available' : () => Promise<bigint>,
  'wallet_receive' : () => Promise<undefined>,
  'wearAccessory' : (arg_0: string, arg_1: string) => Promise<Result>,
}
export type Inventory = Array<AssetInventory>;
export type Memo = Array<number>;
export type Metadata = {
    'fungible' : {
      'decimals' : number,
      'metadata' : [] | [Array<number>],
      'name' : string,
      'symbol' : string,
    }
  } |
  { 'nonfungible' : { 'metadata' : [] | [Array<number>] } };
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
export type Result_2 = { 'ok' : string } |
  { 'err' : string };
export type Result_3 = { 'ok' : Metadata } |
  { 'err' : CommonError };
export type Result_4 = { 'ok' : AccountIdentifier__1 } |
  { 'err' : CommonError__1 };
export type Result_5 = { 'ok' : bigint } |
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
export type SubAccount = Array<number>;
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
export interface TransferRequest {
  'to' : User,
  'token' : TokenIdentifier,
  'notify' : boolean,
  'from' : User,
  'memo' : Memo,
  'subaccount' : [] | [SubAccount],
  'amount' : Balance,
}
export type TransferResponse = { 'ok' : Balance } |
  {
    'err' : { 'CannotNotify' : AccountIdentifier } |
      { 'InsufficientBalance' : null } |
      { 'InvalidToken' : TokenIdentifier } |
      { 'Rejected' : null } |
      { 'Unauthorized' : AccountIdentifier } |
      { 'Other' : string }
  };
export type User = { 'principal' : Principal } |
  { 'address' : AccountIdentifier };
export interface _SERVICE extends Hub {}
