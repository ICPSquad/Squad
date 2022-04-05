import type { Principal } from '@dfinity/principal';
export interface Accessory {
  'content' : string,
  'name' : string,
  'slot' : string,
  'layer' : number,
}
export type AccountIdentifier = string;
export type AccountIdentifier__1 = string;
export interface AvatarInformations {
  'svg' : string,
  'tokenIdentifier' : string,
}
export interface AvatarPreview {
  'avatar_svg' : string,
  'slots' : Slots__1,
  'token_identifier' : TokenIdentifier__2,
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
export type Category = { 'LegendaryCharacter' : null } |
  { 'AccessoryComponent' : null } |
  { 'AvatarComponent' : null };
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
export type ComponentCategory = { 'Avatar' : null } |
  { 'Accessory' : null } |
  { 'Other' : null };
export interface ComponentRequest { 'name' : string, 'layer' : number }
export interface Component__1 {
  'name' : string,
  'layers' : Array<bigint>,
  'category' : ComponentCategory,
}
export interface DailyMetricsData {
  'updateCalls' : bigint,
  'canisterHeapMemorySize' : NumericEntity,
  'canisterCycles' : NumericEntity,
  'canisterMemorySize' : NumericEntity,
  'timeMillis' : bigint,
}
export type Extension = string;
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
  'addAccessory' : (arg_0: string, arg_1: Accessory) => Promise<Result_9>,
  'addComponent_new' : (arg_0: string, arg_1: Component__1) => Promise<Result>,
  'addListAccessory' : (arg_0: Array<Accessory>) => Promise<Result_9>,
  'addListComponent' : (arg_0: Array<[string, Component]>) => Promise<Result_9>,
  'add_admin' : (arg_0: Principal) => Promise<undefined>,
  'availableCycles' : () => Promise<bigint>,
  'balance' : (arg_0: BalanceRequest) => Promise<BalanceResponse>,
  'balance_new' : (arg_0: BalanceRequest) => Promise<BalanceResponse>,
  'bearer' : (arg_0: TokenIdentifier) => Promise<Result_8>,
  'bearer_new' : (arg_0: TokenIdentifier) => Promise<Result_8>,
  'changeCSS' : (arg_0: string) => Promise<undefined>,
  'collectCanisterMetrics' : () => Promise<undefined>,
  'copy' : () => Promise<undefined>,
  'details' : (arg_0: TokenIdentifier) => Promise<Result_7>,
  'details_new' : (arg_0: TokenIdentifier) => Promise<Result_7>,
  'draw' : (arg_0: TokenIdentifier) => Promise<Result>,
  'eventsSize' : () => Promise<bigint>,
  'extensions' : () => Promise<Array<Extension>>,
  'getAllAccessories' : () => Promise<Array<[string, Accessory]>>,
  'getAllComponents' : () => Promise<Array<[string, Component]>>,
  'getAvatarInfos' : () => Promise<Result_6>,
  'getAvatarInfos_new' : () => Promise<Result_5>,
  'getCanisterLog' : (arg_0: [] | [CanisterLogRequest]) => Promise<
      [] | [CanisterLogResponse]
    >,
  'getCanisterMetrics' : (arg_0: GetMetricsParameters) => Promise<
      [] | [CanisterMetrics]
    >,
  'getRegistry' : () => Promise<Array<[TokenIndex, AccountIdentifier__1]>>,
  'getRegistry_new' : () => Promise<Array<[TokenIndex, AccountIdentifier__1]>>,
  'getTokens' : () => Promise<Array<[TokenIndex, Metadata]>>,
  'getTokens_new' : () => Promise<Array<[TokenIndex, Metadata]>>,
  'http_request' : (arg_0: Request) => Promise<Response>,
  'init_cap' : () => Promise<Result>,
  'is_admin' : (arg_0: Principal) => Promise<boolean>,
  'metadata' : (arg_0: TokenIdentifier) => Promise<Result_4>,
  'mint' : (arg_0: MintRequest) => Promise<Result_3>,
  'modify_style' : (arg_0: string) => Promise<string>,
  'removeAccessory' : (
      arg_0: TokenIdentifier,
      arg_1: string,
      arg_2: Principal,
    ) => Promise<Result>,
  'showFullSvg' : (arg_0: TokenIdentifier) => Promise<[] | [string]>,
  'test' : () => Promise<undefined>,
  'test_hex' : () => Promise<Array<AccountIdentifier__1>>,
  'tokens' : (arg_0: AccountIdentifier__1) => Promise<Result_1>,
  'tokens_ext' : (arg_0: AccountIdentifier__1) => Promise<Result_2>,
  'tokens_ext_new' : (arg_0: AccountIdentifier__1) => Promise<Result_2>,
  'tokens_new' : (arg_0: AccountIdentifier__1) => Promise<Result_1>,
  'transfer' : (arg_0: TransferRequest) => Promise<TransferResponse>,
  'upload' : (arg_0: Array<number>) => Promise<undefined>,
  'uploadClear' : () => Promise<undefined>,
  'uploadFinalize' : (arg_0: string, arg_1: Meta, arg_2: string) => Promise<
      Result
    >,
  'verificationEvents' : () => Promise<undefined>,
  'wearAccessory' : (
      arg_0: TokenIdentifier,
      arg_1: string,
      arg_2: Principal,
    ) => Promise<Result>,
}
export type LayerId = bigint;
export interface Listing {
  'subaccount' : [] | [SubAccount],
  'locked' : [] | [Time],
  'seller' : Principal,
  'price' : bigint,
}
export interface LogMessagesData { 'timeNanos' : Nanos, 'message' : string }
export type Memo = Array<number>;
export interface Meta {
  'name' : string,
  'tags' : Array<Tag>,
  'description' : string,
  'category' : Category,
}
export type Metadata = {
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
export type Nanos = bigint;
export interface NumericEntity {
  'avg' : bigint,
  'max' : bigint,
  'min' : bigint,
  'first' : bigint,
  'last' : bigint,
}
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
export type Result_1 = { 'ok' : Array<TokenIndex> } |
  { 'err' : CommonError };
export type Result_2 = {
    'ok' : Array<[TokenIndex, [] | [Listing], [] | [Array<number>]]>
  } |
  { 'err' : CommonError };
export type Result_3 = { 'ok' : AvatarInformations } |
  { 'err' : string };
export type Result_4 = { 'ok' : Metadata } |
  { 'err' : CommonError__1 };
export type Result_5 = { 'ok' : AvatarPreviewNew } |
  { 'err' : string };
export type Result_6 = { 'ok' : AvatarPreview } |
  { 'err' : string };
export type Result_7 = { 'ok' : [AccountIdentifier__1, [] | [Listing]] } |
  { 'err' : CommonError };
export type Result_8 = { 'ok' : AccountIdentifier__1 } |
  { 'err' : CommonError };
export type Result_9 = { 'ok' : string } |
  { 'err' : string };
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
export type StreamingStrategy = {
    'Callback' : {
      'token' : StreamingCallbackToken,
      'callback' : StreamingCallback,
    }
  };
export type SubAccount = Array<number>;
export type Tag = string;
export type Time = bigint;
export type TokenIdentifier = string;
export type TokenIdentifier__1 = string;
export type TokenIdentifier__2 = string;
export type TokenIndex = number;
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
