import type { Principal } from '@dfinity/principal';
export type AccountIdentifier = string;
export type AccountIdentifier__1 = string;
export type AccountIdentifier__2 = string;
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
  { 'err' : CommonError__1 };
export type BlockIndex = bigint;
export type CanisterCyclesAggregatedData = Array<bigint>;
export type CanisterHeapMemoryAggregatedData = Array<bigint>;
export type CanisterMemoryAggregatedData = Array<bigint>;
export interface CanisterMetrics { 'data' : CanisterMetricsData }
export type CanisterMetricsData = { 'hourly' : Array<HourlyMetricsData> } |
  { 'daily' : Array<DailyMetricsData> };
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
export interface DailyMetricsData {
  'updateCalls' : bigint,
  'canisterHeapMemorySize' : NumericEntity,
  'canisterCycles' : NumericEntity,
  'canisterMemorySize' : NumericEntity,
  'timeMillis' : bigint,
}
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
export interface GetMetricsParameters {
  'dateToMillis' : bigint,
  'granularity' : MetricsGranularity,
  'dateFromMillis' : bigint,
}
export type HeaderField = [string, string];
export interface HourlyMetricsData {
  'updateCalls' : UpdateCallsAggregatedData,
  'canisterHeapMemorySize' : CanisterHeapMemoryAggregatedData,
  'canisterCycles' : CanisterCyclesAggregatedData,
  'canisterMemorySize' : CanisterMemoryAggregatedData,
  'timeMillis' : bigint,
}
export interface Hub {
  'addElements' : (arg_0: string, arg_1: Template) => Promise<Result_3>,
  'airdrop' : (arg_0: AirdropObject) => Promise<Result>,
  'allPayments' : () => Promise<Array<[Principal, Array<SubAccount__1>]>>,
  'allSettlements' : () => Promise<Array<[TokenIndex, Settlement]>>,
  'balance' : (arg_0: BalanceRequest) => Promise<BalanceResponse>,
  'balance_ledger' : () => Promise<ICP>,
  'bearer' : (arg_0: TokenIdentifier__2) => Promise<Result_5>,
  'clearPayments' : (arg_0: Principal, arg_1: Array<SubAccount__1>) => Promise<
      undefined
    >,
  'collectCanisterMetrics' : () => Promise<undefined>,
  'createAccessory' : (
      arg_0: string,
      arg_1: Array<TokenIdentifier__2>,
      arg_2: Array<number>,
      arg_3: [] | [Option],
    ) => Promise<Result_6>,
  'extensions' : () => Promise<Array<Extension>>,
  'getCanisterMetrics' : (arg_0: GetMetricsParameters) => Promise<
      [] | [CanisterMetrics]
    >,
  'getContractInfo' : () => Promise<ContractInfo>,
  'getInventory' : () => Promise<Inventory>,
  'getMetadata' : () => Promise<ContractMetadata>,
  'getMinter' : () => Promise<Array<Principal>>,
  'getOwnership' : () => Promise<
      Array<[AccountIdentifier__2, Array<TokenIndex>]>
    >,
  'getRecipes' : () => Promise<Array<[string, Recipe]>>,
  'getRegistry' : () => Promise<Array<[TokenIndex, AccountIdentifier__2]>>,
  'getStats' : () => Promise<Array<string>>,
  'http_request' : (arg_0: Request) => Promise<Response>,
  'init' : (arg_0: Array<Principal>, arg_1: ContractMetadata) => Promise<
      undefined
    >,
  'init_cap' : () => Promise<Result>,
  'list' : (arg_0: ListRequest) => Promise<Result_2>,
  'listings' : () => Promise<Array<[TokenIndex, Listing, Metadata__1]>>,
  'lock' : (
      arg_0: string,
      arg_1: bigint,
      arg_2: AccountIdentifier__2,
      arg_3: SubAccount__1,
    ) => Promise<Result_5>,
  'metadata' : (arg_0: TokenIdentifier__2) => Promise<Result_4>,
  'mint' : (arg_0: string, arg_1: AccountIdentifier__2) => Promise<Result_3>,
  'modifyRecipe' : (arg_0: string, arg_1: Recipe) => Promise<Result>,
  'payments' : () => Promise<[] | [Array<SubAccount__1>]>,
  'process' : () => Promise<undefined>,
  'removeAccessory' : (arg_0: string, arg_1: string) => Promise<Result>,
  'settle' : (arg_0: string) => Promise<Result_2>,
  'settlements' : () => Promise<
      Array<[TokenIndex, AccountIdentifier__2, bigint]>
    >,
  'showAdmins' : () => Promise<Array<Principal>>,
  'supply' : () => Promise<bigint>,
  'transactions' : () => Promise<Array<Transaction>>,
  'transfer' : (arg_0: TransferRequest) => Promise<TransferResponse>,
  'transfer_ledger' : (arg_0: ICP, arg_1: Principal) => Promise<TransferResult>,
  'updateAccessories' : () => Promise<undefined>,
  'updateAdmins' : (arg_0: Principal, arg_1: boolean) => Promise<Result_1>,
  'updateAdminsData' : (arg_0: Principal, arg_1: boolean) => Promise<Result_1>,
  'verification' : () => Promise<undefined>,
  'wallet_available' : () => Promise<bigint>,
  'wallet_receive' : () => Promise<undefined>,
  'wearAccessory' : (arg_0: string, arg_1: string) => Promise<Result>,
  'whoami' : () => Promise<Principal>,
}
export interface ICP { 'e8s' : bigint }
export type Inventory = Array<AssetInventory>;
export interface ListRequest {
  'token' : TokenIdentifier__1,
  'from_subaccount' : [] | [SubAccount__2],
  'price' : [] | [bigint],
}
export interface Listing {
  'locked' : [] | [Time],
  'seller' : Principal,
  'price' : bigint,
}
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
export type Metadata__1 = {
    'fungible' : {
      'decimals' : number,
      'metadata' : [] | [Array<number>],
      'name' : string,
      'symbol' : string,
    }
  } |
  { 'nonfungible' : { 'metadata' : [] | [Array<number>] } };
export type MetricsGranularity = { 'hourly' : null } |
  { 'daily' : null };
export interface NumericEntity {
  'avg' : bigint,
  'max' : bigint,
  'min' : bigint,
  'first' : bigint,
  'last' : bigint,
}
export type Option = boolean;
export type Recipe = Array<string>;
export type Recipe__1 = Array<string>;
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
export type Result_2 = { 'ok' : null } |
  { 'err' : CommonError };
export type Result_3 = { 'ok' : string } |
  { 'err' : string };
export type Result_4 = { 'ok' : Metadata } |
  { 'err' : CommonError__1 };
export type Result_5 = { 'ok' : AccountIdentifier__2 } |
  { 'err' : CommonError };
export type Result_6 = { 'ok' : TokenIdentifier__2 } |
  { 'err' : string };
export interface Settlement {
  'subaccount' : SubAccount__2,
  'seller' : Principal,
  'buyer' : AccountIdentifier__1,
  'price' : bigint,
}
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
export type SubAccount__1 = Array<number>;
export type SubAccount__2 = Array<number>;
export type Template = {
    'Accessory' : {
      'after_wear' : string,
      'before_wear' : string,
      'recipe' : Recipe__1,
    }
  } |
  { 'LegendaryAccessory' : Array<number> } |
  { 'Material' : Array<number> };
export type Time = bigint;
export type TokenIdentifier = string;
export type TokenIdentifier__1 = string;
export type TokenIdentifier__2 = string;
export type TokenIndex = number;
export interface Transaction {
  'token' : TokenIdentifier__1,
  'time' : Time,
  'seller' : Principal,
  'buyer' : AccountIdentifier__1,
  'price' : bigint,
}
export type TransferError = {
    'TxTooOld' : { 'allowed_window_nanos' : bigint }
  } |
  { 'BadFee' : { 'expected_fee' : ICP } } |
  { 'TxDuplicate' : { 'duplicate_of' : BlockIndex } } |
  { 'TxCreatedInFuture' : null } |
  { 'InsufficientFunds' : { 'balance' : ICP } };
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
export type TransferResult = { 'Ok' : BlockIndex } |
  { 'Err' : TransferError };
export type UpdateCallsAggregatedData = Array<bigint>;
export type User = { 'principal' : Principal } |
  { 'address' : AccountIdentifier };
export interface _SERVICE extends Hub {}
