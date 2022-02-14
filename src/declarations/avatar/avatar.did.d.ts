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
  'slots' : Slots__1,
  'token_identifier' : TokenIdentifier__3,
}
export interface AvatarPreviewNew {
  'body_name' : string,
  'layers' : Array<[LayerId, string]>,
  'slots' : Slots,
  'style' : string,
  'token_identifier' : TokenIdentifier,
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
export type LayerId = bigint;
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
export type Result_1 = { 'ok' : Array<TokenIndex> } |
  { 'err' : CommonError };
export type Result_2 = { 'ok' : null } |
  { 'err' : CommonError };
export type Result_3 = { 'ok' : string } |
  { 'err' : string };
export type Result_4 = { 'ok' : AvatarInformations } |
  { 'err' : string };
export type Result_5 = { 'ok' : Metadata } |
  { 'err' : CommonError__1 };
export type Result_6 = { 'ok' : AccountIdentifier } |
  { 'err' : CommonError };
export type Result_7 = { 'ok' : AvatarPreviewNew } |
  { 'err' : string };
export type Result_8 = { 'ok' : AvatarPreview } |
  { 'err' : string };
export type Result_9 = { 'ok' : [AccountIdentifier, [] | [Listing]] } |
  { 'err' : CommonError };
export interface Settlement {
  'subaccount' : SubAccount__2,
  'seller' : Principal,
  'buyer' : AccountIdentifier__2,
  'price' : bigint,
}
export interface Slots {
  'Hat' : [] | [string],
  'Body' : [] | [string],
  'Eyes' : [] | [string],
  'Face' : [] | [string],
  'Misc' : [] | [string],
}
export interface Slots__1 {
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
  'buyer' : AccountIdentifier__2,
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
    'err' : { 'CannotNotify' : AccountIdentifier__1 } |
      { 'InsufficientBalance' : null } |
      { 'InvalidToken' : TokenIdentifier__1 } |
      { 'Rejected' : null } |
      { 'Unauthorized' : AccountIdentifier__1 } |
      { 'Other' : string }
  };
export type UpdateCallsAggregatedData = Array<bigint>;
export type User = { 'principal' : Principal } |
  { 'address' : AccountIdentifier__1 };
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
  'details' : (arg_0: TokenIdentifier) => Promise<Result_9>,
  'draw' : (arg_0: TokenIdentifier) => Promise<Result>,
  'eventsSize' : () => Promise<bigint>,
  'extensions' : () => Promise<Array<Extension>>,
  'getAllAccessories' : () => Promise<Array<[string, Accessory]>>,
  'getAllComponents' : () => Promise<Array<[string, Component]>>,
  'getAvatarInfos' : () => Promise<Result_8>,
  'getAvatarInfos_new' : () => Promise<Result_7>,
  'getCanisterMetrics' : (arg_0: GetMetricsParameters) => Promise<
      [] | [CanisterMetrics]
    >,
  'getMinter' : () => Promise<Array<Principal>>,
  'getRegistry' : () => Promise<Array<[TokenIndex, AccountIdentifier]>>,
  'getTokens' : () => Promise<Array<[TokenIndex, Metadata__1]>>,
  'howManyEquipped' : () => Promise<bigint>,
  'http_request' : (arg_0: HttpRequest) => Promise<HttpResponse>,
  'init_cap' : () => Promise<Result>,
  'list' : (arg_0: ListRequest) => Promise<Result_2>,
  'listings' : () => Promise<Array<[TokenIndex, Listing, Metadata__1]>>,
  'lock' : (
      arg_0: TokenIdentifier,
      arg_1: bigint,
      arg_2: AccountIdentifier,
      arg_3: SubAccount__1,
    ) => Promise<Result_6>,
  'metadata' : (arg_0: TokenIdentifier) => Promise<Result_5>,
  'mint' : (arg_0: MintRequest) => Promise<Result_4>,
  'mintLegendary' : (arg_0: string, arg_1: AccountIdentifier) => Promise<
      Result_3
    >,
  'modify_style' : (arg_0: string) => Promise<string>,
  'payments' : () => Promise<[] | [Array<SubAccount__1>]>,
  'removeAccessory' : (
      arg_0: TokenIdentifier,
      arg_1: string,
      arg_2: Principal,
    ) => Promise<Result>,
  'removeMouth' : (arg_0: TokenIdentifier) => Promise<Result>,
  'reset' : () => Promise<bigint>,
  'reset_data' : () => Promise<Array<[TokenIdentifier, string]>>,
  'saveAccessories' : () => Promise<[bigint, bigint]>,
  'settle' : (arg_0: TokenIdentifier) => Promise<Result_2>,
  'settlements' : () => Promise<Array<[TokenIndex, AccountIdentifier, bigint]>>,
  'showFullSvg' : (arg_0: TokenIdentifier) => Promise<[] | [string]>,
  'showSvg' : (arg_0: TokenIdentifier) => Promise<[] | [string]>,
  'stats' : () => Promise<
      [bigint, bigint, bigint, bigint, bigint, bigint, bigint]
    >,
  'supply' : () => Promise<bigint>,
  'tokenIdentifier' : (arg_0: TokenIndex) => Promise<TokenIdentifier>,
  'tokens' : (arg_0: AccountIdentifier) => Promise<Result_1>,
  'transactions' : () => Promise<Array<Transaction>>,
  'transfer' : (arg_0: TransferRequest) => Promise<TransferResponse>,
  'transform_data' : () => Promise<bigint>,
  'transform_show' : () => Promise<Array<[AccountIdentifier, string]>>,
  'updateAdminsData' : (arg_0: Principal, arg_1: boolean) => Promise<Result>,
  'verificationEvents' : () => Promise<undefined>,
  'wearAccessory' : (
      arg_0: TokenIdentifier,
      arg_1: string,
      arg_2: Principal,
    ) => Promise<Result>,
}
export interface _SERVICE extends erc721_token {}
