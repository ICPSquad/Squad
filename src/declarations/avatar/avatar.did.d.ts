import type { Principal } from '@dfinity/principal';
export interface Accessory {
  'content' : string,
  'name' : string,
  'slot' : string,
  'layer' : number,
}
export type AccountIdentifier = string;
export type AccountIdentifier__1 = string;
export type AccountIdentifier__2 = string;
export interface AvatarInformations {
  'svg' : string,
  'tokenIdentifier' : string,
}
export interface AvatarPreview {
  'avatar_svg' : string,
  'slots' : Slots,
  'token_identifier' : TokenIdentifier__3,
}
export interface AvatarRequest {
  'components' : Array<ComponentRequest>,
  'colors' : Array<{ 'color' : Color, 'spot' : string }>,
}
export type Balance = bigint;
export interface BalanceRequest { 'token' : TokenIdentifier__1, 'user' : User }
export type BalanceResponse = { 'ok' : Balance } |
  { 'err' : CommonError__1 };
export type CanisterCyclesAggregatedData = Array<bigint>;
export type CanisterHeapMemoryAggregatedData = Array<bigint>;
export type CanisterMemoryAggregatedData = Array<bigint>;
export interface CanisterMetrics { 'data' : CanisterMetricsData }
export type CanisterMetricsData = { 'hourly' : Array<HourlyMetricsData> } |
  { 'daily' : Array<DailyMetricsData> };
export type Color = [number, number, number, number];
export type CommonError = { 'InvalidToken' : TokenIdentifier__1 } |
  { 'Other' : string };
export type CommonError__1 = { 'InvalidToken' : TokenIdentifier__1 } |
  { 'Other' : string };
export interface Component {
  'content' : string,
  'name' : string,
  'layer' : number,
}
export interface ComponentRequest { 'name' : string, 'layer' : number }
export interface DailyMetricsData {
  'updateCalls' : bigint,
  'canisterHeapMemorySize' : NumericEntity,
  'canisterCycles' : NumericEntity,
  'canisterMemorySize' : NumericEntity,
  'timeMillis' : bigint,
}
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
export interface HttpRequest {
  'url' : string,
  'method' : string,
  'body' : Array<number>,
  'headers' : Array<HeaderField>,
}
export interface HttpResponse {
  'body' : Array<number>,
  'headers' : Array<HeaderField>,
  'streaming_strategy' : [] | [HttpStreamingStrategy],
  'status_code' : number,
}
export type HttpStreamingStrategy = {
    'Callback' : {
      'token' : StreamingCallbackToken,
      'callback' : StreamingCallback,
    }
  };
export interface ListRequest {
  'token' : TokenIdentifier__2,
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
export interface MintRequest { 'to' : User, 'metadata' : AvatarRequest }
export interface NumericEntity {
  'avg' : bigint,
  'max' : bigint,
  'min' : bigint,
  'first' : bigint,
  'last' : bigint,
}
export type Result = { 'ok' : null } |
  { 'err' : string };
export type Result_1 = {
    'ok' : Array<[TokenIndex, [] | [Listing], [] | [Array<number>]]>
  } |
  { 'err' : CommonError };
export type Result_2 = { 'ok' : null } |
  { 'err' : CommonError };
export type Result_3 = { 'ok' : string } |
  { 'err' : string };
export type Result_4 = { 'ok' : AvatarInformations } |
  { 'err' : string };
export type Result_5 = { 'ok' : Metadata } |
  { 'err' : CommonError__1 };
export type Result_6 = { 'ok' : AccountIdentifier__2 } |
  { 'err' : CommonError };
export type Result_7 = { 'ok' : AvatarPreview } |
  { 'err' : string };
export interface Settlement {
  'subaccount' : SubAccount__2,
  'seller' : Principal,
  'buyer' : AccountIdentifier__1,
  'price' : bigint,
}
export interface Slots {
  'Hat' : [] | [string],
  'Body' : [] | [string],
  'Eyes' : [] | [string],
  'Face' : [] | [string],
  'Misc' : [] | [string],
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
export type SubAccount = Array<number>;
export type SubAccount__1 = Array<number>;
export type SubAccount__2 = Array<number>;
export type Time = bigint;
export type TokenIdentifier = string;
export type TokenIdentifier__1 = string;
export type TokenIdentifier__2 = string;
export type TokenIdentifier__3 = string;
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
export interface erc721_token {
  'acceptCycles' : () => Promise<undefined>,
  'addAdmin' : (arg_0: Principal) => Promise<Result>,
  'addLegendary' : (arg_0: string, arg_1: string) => Promise<Result_3>,
  'addListAccessory' : (arg_0: Array<Accessory>) => Promise<Result_3>,
  'addListComponent' : (arg_0: Array<[string, Component]>) => Promise<Result_3>,
  'allPayments' : () => Promise<Array<[Principal, Array<SubAccount__1>]>>,
  'allSettlements' : () => Promise<Array<[TokenIndex, Settlement]>>,
  'availableCycles' : () => Promise<bigint>,
  'balance' : (arg_0: BalanceRequest) => Promise<BalanceResponse>,
  'bearer' : (arg_0: TokenIdentifier) => Promise<Result_6>,
  'clearPayments' : (arg_0: Principal, arg_1: Array<SubAccount__1>) => Promise<
      undefined
    >,
  'collectCanisterMetrics' : () => Promise<undefined>,
  'draw' : (arg_0: TokenIdentifier) => Promise<Result>,
  'extensions' : () => Promise<Array<Extension>>,
  'getAllComponents' : () => Promise<Array<[string, Component]>>,
  'getAvatarInfos' : () => Promise<Result_7>,
  'getCanisterMetrics' : (arg_0: GetMetricsParameters) => Promise<
      [] | [CanisterMetrics]
    >,
  'getMinter' : () => Promise<Array<Principal>>,
  'getRegistry' : () => Promise<Array<[TokenIndex, AccountIdentifier__2]>>,
  'howManyEquipped' : () => Promise<bigint>,
  'http_request' : (arg_0: HttpRequest) => Promise<HttpResponse>,
  'list' : (arg_0: ListRequest) => Promise<Result_2>,
  'listings' : () => Promise<Array<[TokenIndex, Listing, Metadata__1]>>,
  'lock' : (
      arg_0: TokenIdentifier,
      arg_1: bigint,
      arg_2: AccountIdentifier__2,
      arg_3: SubAccount__1,
    ) => Promise<Result_6>,
  'metadata' : (arg_0: TokenIdentifier) => Promise<Result_5>,
  'mint' : (arg_0: MintRequest) => Promise<Result_4>,
  'mintLegendary' : (arg_0: string, arg_1: AccountIdentifier__2) => Promise<
      Result_3
    >,
  'modify_style' : (arg_0: string) => Promise<string>,
  'payments' : () => Promise<[] | [Array<SubAccount__1>]>,
  'removeMouth' : (arg_0: TokenIdentifier) => Promise<Result>,
  'settle' : (arg_0: TokenIdentifier) => Promise<Result_2>,
  'settlements' : () => Promise<
      Array<[TokenIndex, AccountIdentifier__2, bigint]>
    >,
  'showFullSvg' : (arg_0: TokenIdentifier) => Promise<[] | [string]>,
  'showListAccessory' : () => Promise<Array<[string, Accessory]>>,
  'showSvg' : (arg_0: TokenIdentifier) => Promise<[] | [string]>,
  'supply' : () => Promise<bigint>,
  'tokenIdentifier' : (arg_0: TokenIndex) => Promise<TokenIdentifier>,
  'tokens_ext' : (arg_0: AccountIdentifier__2) => Promise<Result_1>,
  'transactions' : () => Promise<Array<Transaction>>,
  'transfer' : (arg_0: TransferRequest) => Promise<TransferResponse>,
  'updateAdminsData' : (arg_0: Principal, arg_1: boolean) => Promise<Result>,
  'wearAccessory' : (
      arg_0: TokenIdentifier,
      arg_1: string,
      arg_2: Principal,
    ) => Promise<Result>,
}
export interface _SERVICE extends erc721_token {}
