import type { Principal } from '@dfinity/principal';
export interface AccessoryInventory {
  'tokenIdentifier' : string,
  'name' : string,
  'equipped' : boolean,
}
export type AccountIdentifier = string;
export type AccountIdentifier__1 = string;
export type AccountIdentifier__2 = string;
export type Balance = bigint;
export interface BalanceRequest { 'token' : TokenIdentifier__1, 'user' : User }
export type BalanceResponse = { 'ok' : Balance } |
  { 'err' : CommonError__1 };
export type CanisterCyclesAggregatedData = Array<bigint>;
export type CanisterHeapMemoryAggregatedData = Array<bigint>;
export type CanisterLogFeature = { 'filterMessageByContains' : null } |
  { 'filterMessageByRegex' : null };
export interface CanisterLogMessages {
  'data' : Array<LogMessagesData>,
  'lastAnalyzedMessageTimeNanos' : [] | [Nanos],
}
export interface CanisterLogMessagesInfo {
  'features' : Array<[] | [CanisterLogFeature]>,
  'lastTimeNanos' : [] | [Nanos],
  'count' : number,
  'firstTimeNanos' : [] | [Nanos],
}
export type CanisterLogRequest = { 'getMessagesInfo' : null } |
  { 'getMessages' : GetLogMessagesParameters } |
  { 'getLatestMessages' : GetLatestLogMessagesParameters };
export type CanisterLogResponse = { 'messagesInfo' : CanisterLogMessagesInfo } |
  { 'messages' : CanisterLogMessages };
export type CanisterMemoryAggregatedData = Array<bigint>;
export interface CanisterMetrics { 'data' : CanisterMetricsData }
export type CanisterMetricsData = { 'hourly' : Array<HourlyMetricsData> } |
  { 'daily' : Array<DailyMetricsData> };
export type CommonError = { 'InvalidToken' : TokenIdentifier__1 } |
  { 'Other' : string };
export type CommonError__1 = { 'InvalidToken' : TokenIdentifier__1 } |
  { 'Other' : string };
export interface DailyMetricsData {
  'updateCalls' : bigint,
  'canisterHeapMemorySize' : NumericEntity,
  'canisterCycles' : NumericEntity,
  'canisterMemorySize' : NumericEntity,
  'timeMillis' : bigint,
}
export type Extension = string;
export type Floor = bigint;
export interface GetLatestLogMessagesParameters {
  'upToTimeNanos' : [] | [Nanos],
  'count' : number,
  'filter' : [] | [GetLogMessagesFilter],
}
export interface GetLogMessagesFilter {
  'analyzeCount' : number,
  'messageRegex' : [] | [string],
  'messageContains' : [] | [string],
}
export interface GetLogMessagesParameters {
  'count' : number,
  'filter' : [] | [GetLogMessagesFilter],
  'fromTimeNanos' : [] | [Nanos],
}
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
export interface ICPSquadNFT {
  'acceptCycles' : () => Promise<undefined>,
  'addTemplate' : (arg_0: string, arg_1: Template) => Promise<Result_7>,
  'add_admin' : (arg_0: Principal) => Promise<undefined>,
  'allPayments' : () => Promise<Array<[Principal, Array<SubAccount__1>]>>,
  'allSettlements' : () => Promise<Array<[TokenIndex, Settlement]>>,
  'availableCycles' : () => Promise<bigint>,
  'balance' : (arg_0: BalanceRequest) => Promise<BalanceResponse>,
  'bearer' : (arg_0: TokenIdentifier) => Promise<Result_6>,
  'burn' : (arg_0: TokenIdentifier) => Promise<Result>,
  'clearPayments' : (arg_0: Principal, arg_1: Array<SubAccount__1>) => Promise<
      undefined
    >,
  'collectCanisterMetrics' : () => Promise<undefined>,
  'create_accessory' : (arg_0: string, arg_1: bigint) => Promise<Result__1_3>,
  'details' : (arg_0: TokenIdentifier) => Promise<Result_5>,
  'eventsSize' : () => Promise<bigint>,
  'extensions' : () => Promise<Array<Extension>>,
  'getCanisterLog' : (arg_0: [] | [CanisterLogRequest]) => Promise<
      [] | [CanisterLogResponse]
    >,
  'getCanisterMetrics' : (arg_0: GetMetricsParameters) => Promise<
      [] | [CanisterMetrics]
    >,
  'getInventory' : () => Promise<Result_4>,
  'getRegistry' : () => Promise<Array<[TokenIndex, AccountIdentifier__2]>>,
  'getTokens' : () => Promise<Array<[TokenIndex, Metadata]>>,
  'get_recipes' : () => Promise<Array<[string, Recipe__1]>>,
  'get_stats_items' : () => Promise<
      Array<[string, Supply, [] | [Floor], [] | [LastSoldPrice]]>
    >,
  'get_templates' : () => Promise<Array<[string, Template]>>,
  'http_request' : (arg_0: Request) => Promise<Response>,
  'init_cap' : () => Promise<Result__1_1>,
  'is_admin' : (arg_0: Principal) => Promise<boolean>,
  'list' : (arg_0: ListRequest) => Promise<Result__1>,
  'listings' : () => Promise<Array<[TokenIndex, Listing__1, Metadata__1]>>,
  'lock' : (
      arg_0: string,
      arg_1: bigint,
      arg_2: AccountIdentifier__2,
      arg_3: SubAccount__1,
    ) => Promise<Result__1_2>,
  'metadata' : (arg_0: TokenIdentifier) => Promise<Result_3>,
  'mint' : (arg_0: string, arg_1: Principal) => Promise<Result>,
  'payments' : () => Promise<[] | [Array<SubAccount__1>]>,
  'remove_accessory' : (
      arg_0: TokenIdentifier,
      arg_1: TokenIdentifier,
    ) => Promise<Result__1_1>,
  'remove_admin' : (arg_0: Principal) => Promise<undefined>,
  'settle' : (arg_0: string) => Promise<Result__1>,
  'settlements' : () => Promise<
      Array<[TokenIndex, AccountIdentifier__2, bigint]>
    >,
  'stats' : () => Promise<
      [bigint, bigint, bigint, bigint, bigint, bigint, bigint]
    >,
  'tokenId' : (arg_0: TokenIndex) => Promise<string>,
  'tokens' : (arg_0: AccountIdentifier__2) => Promise<Result_2>,
  'tokens_ext' : (arg_0: AccountIdentifier__2) => Promise<Result_1>,
  'transactions' : () => Promise<Array<Transaction>>,
  'transfer' : (arg_0: TransferRequest) => Promise<TransferResponse>,
  'verificationEvents' : () => Promise<undefined>,
  'wear_accessory' : (
      arg_0: TokenIdentifier,
      arg_1: TokenIdentifier,
    ) => Promise<Result>,
}
export type Inventory = Array<ItemInventory>;
export type ItemInventory = { 'Accessory' : AccessoryInventory } |
  { 'Material' : MaterialInventory };
export type LastSoldPrice = bigint;
export interface ListRequest {
  'token' : TokenIdentifier__2,
  'from_subaccount' : [] | [SubAccount__2],
  'price' : [] | [bigint],
}
export interface Listing {
  'subaccount' : [] | [SubAccount],
  'locked' : [] | [Time__1],
  'seller' : Principal,
  'price' : bigint,
}
export interface Listing__1 {
  'locked' : [] | [Time],
  'seller' : Principal,
  'price' : bigint,
}
export interface LogMessagesData { 'timeNanos' : Nanos, 'message' : string }
export interface MaterialInventory {
  'tokenIdentifier' : string,
  'name' : string,
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
export type Nanos = bigint;
export interface NumericEntity {
  'avg' : bigint,
  'max' : bigint,
  'min' : bigint,
  'first' : bigint,
  'last' : bigint,
}
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
export type Result_1 = {
    'ok' : Array<[TokenIndex, [] | [Listing], [] | [Array<number>]]>
  } |
  { 'err' : CommonError };
export type Result_2 = { 'ok' : Array<TokenIndex> } |
  { 'err' : CommonError };
export type Result_3 = { 'ok' : Metadata } |
  { 'err' : CommonError__1 };
export type Result_4 = { 'ok' : Inventory } |
  { 'err' : string };
export type Result_5 = { 'ok' : [AccountIdentifier__2, [] | [Listing]] } |
  { 'err' : CommonError };
export type Result_6 = { 'ok' : AccountIdentifier__2 } |
  { 'err' : CommonError };
export type Result_7 = { 'ok' : string } |
  { 'err' : string };
export type Result__1 = { 'ok' : null } |
  { 'err' : CommonError };
export type Result__1_1 = { 'ok' : null } |
  { 'err' : string };
export type Result__1_2 = { 'ok' : AccountIdentifier__2 } |
  { 'err' : CommonError };
export type Result__1_3 = { 'ok' : TokenIdentifier } |
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
export type Supply = bigint;
export type Template = {
    'Accessory' : {
      'after_wear' : string,
      'before_wear' : string,
      'recipe' : Recipe,
    }
  } |
  { 'LegendaryAccessory' : Array<number> } |
  { 'Material' : Array<number> };
export type Time = bigint;
export type Time__1 = bigint;
export type TokenIdentifier = string;
export type TokenIdentifier__1 = string;
export type TokenIdentifier__2 = string;
export type TokenIndex = number;
export interface Transaction {
  'token' : TokenIdentifier__2,
  'time' : Time,
  'seller' : Principal,
  'buyer' : AccountIdentifier__1,
  'price' : bigint,
}
export interface TransferRequest {
  'to' : User,
  'token' : TokenIdentifier__1,
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
      { 'InvalidToken' : TokenIdentifier__1 } |
      { 'Rejected' : null } |
      { 'Unauthorized' : AccountIdentifier } |
      { 'Other' : string }
  };
export type UpdateCallsAggregatedData = Array<bigint>;
export type User = { 'principal' : Principal } |
  { 'address' : AccountIdentifier };
export interface _SERVICE extends ICPSquadNFT {}
