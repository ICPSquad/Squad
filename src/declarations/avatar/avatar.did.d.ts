import type { Principal } from '@dfinity/principal';
export type AccountIdentifier = string;
export type AccountIdentifier__1 = string;
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
export type Colors = Array<{ 'color' : Color, 'spot' : string }>;
export type CommonError = { 'InvalidToken' : TokenIdentifier__1 } |
  { 'Other' : string };
export type CommonError__1 = { 'InvalidToken' : TokenIdentifier__1 } |
  { 'Other' : string };
export interface Component {
  'name' : string,
  'layers' : Array<bigint>,
  'category' : ComponentCategory,
}
export type ComponentCategory = { 'Avatar' : null } |
  { 'Accessory' : null } |
  { 'Other' : null };
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
  'add_admin' : (arg_0: Principal) => Promise<undefined>,
  'associate_legendary' : (arg_0: string, arg_1: TokenIdentifier) => Promise<
      Result
    >,
  'availableCycles' : () => Promise<bigint>,
  'balance' : (arg_0: BalanceRequest) => Promise<BalanceResponse>,
  'bearer' : (arg_0: TokenIdentifier) => Promise<Result_6>,
  'burn' : (arg_0: TokenIdentifier) => Promise<Result>,
  'calculate_style_score' : () => Promise<undefined>,
  'changeStyle' : (arg_0: string) => Promise<undefined>,
  'clean_blob' : () => Promise<undefined>,
  'collectCanisterMetrics' : () => Promise<undefined>,
  'delete' : (arg_0: string) => Promise<Result>,
  'delete_admin' : (arg_0: Principal) => Promise<undefined>,
  'details' : (arg_0: TokenIdentifier) => Promise<Result_5>,
  'draw' : (arg_0: TokenIdentifier) => Promise<Result>,
  'eventsSize' : () => Promise<bigint>,
  'extensions' : () => Promise<Array<Extension>>,
  'getCanisterLog' : (arg_0: [] | [CanisterLogRequest]) => Promise<
      [] | [CanisterLogResponse]
    >,
  'getCanisterMetrics' : (arg_0: GetMetricsParameters) => Promise<
      [] | [CanisterMetrics]
    >,
  'getRegistry' : () => Promise<Array<[TokenIndex, AccountIdentifier__1]>>,
  'getTokens' : () => Promise<Array<[TokenIndex, Metadata]>>,
  'get_all_users' : () => Promise<Array<[Principal, UserData]>>,
  'get_infos_leaderboard' : () => Promise<
      Array<[Principal, [] | [Name__2], [] | [TokenIdentifier]]>
    >,
  'get_number_users' : () => Promise<bigint>,
  'get_style_score' : () => Promise<Array<[TokenIdentifier, StyleScore]>>,
  'get_user' : () => Promise<[] | [UserData]>,
  'http_request' : (arg_0: Request) => Promise<Response>,
  'init_cap' : () => Promise<Result>,
  'is_admin' : (arg_0: Principal) => Promise<boolean>,
  'metadata' : (arg_0: TokenIdentifier) => Promise<Result_4>,
  'mint' : (arg_0: MintInformation, arg_1: [] | [bigint]) => Promise<
      MintResult
    >,
  'mint_test' : (arg_0: MintInformation) => Promise<MintResult>,
  'modify_user' : (arg_0: UserData) => Promise<Result>,
  'registerComponent' : (arg_0: string, arg_1: Component) => Promise<Result>,
  'removeAccessory' : (
      arg_0: TokenIdentifier,
      arg_1: string,
      arg_2: Principal,
    ) => Promise<Result>,
  'report_burned_accessory' : (
      arg_0: string,
      arg_1: TokenIdentifier,
      arg_2: TokenIndex,
    ) => Promise<undefined>,
  'supply' : () => Promise<bigint>,
  'tokens' : (arg_0: AccountIdentifier__1) => Promise<Result_3>,
  'tokens_ext' : (arg_0: AccountIdentifier__1) => Promise<Result_2>,
  'tokens_id' : (arg_0: AccountIdentifier__1) => Promise<Result_1>,
  'tokens_ids' : () => Promise<Array<TokenIdentifier>>,
  'transfer' : (arg_0: TransferRequest) => Promise<TransferResponse>,
  'upload' : (arg_0: Array<number>) => Promise<undefined>,
  'uploadClear' : () => Promise<undefined>,
  'uploadFinalize' : (arg_0: string, arg_1: Meta, arg_2: string) => Promise<
      Result
    >,
  'upload_stats' : (arg_0: Stats) => Promise<undefined>,
  'verificationEvents' : () => Promise<undefined>,
  'wearAccessory' : (
      arg_0: TokenIdentifier,
      arg_1: string,
      arg_2: Principal,
    ) => Promise<Result>,
}
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
export interface MintInformation {
  'mouth' : string,
  'background' : string,
  'ears' : string,
  'eyes' : string,
  'hair' : string,
  'cloth' : string,
  'nose' : string,
  'colors' : Colors,
  'profile' : string,
}
export type MintResult = { 'ok' : TokenIdentifier } |
  { 'err' : string };
export type Name = string;
export type Name__1 = string;
export type Name__2 = string;
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
export type Result_1 = { 'ok' : Array<TokenIdentifier> } |
  { 'err' : CommonError };
export type Result_2 = {
    'ok' : Array<[TokenIndex, [] | [Listing], [] | [Array<number>]]>
  } |
  { 'err' : CommonError };
export type Result_3 = { 'ok' : Array<TokenIndex> } |
  { 'err' : CommonError };
export type Result_4 = { 'ok' : Metadata } |
  { 'err' : CommonError__1 };
export type Result_5 = { 'ok' : [AccountIdentifier__1, [] | [Listing]] } |
  { 'err' : CommonError };
export type Result_6 = { 'ok' : AccountIdentifier__1 } |
  { 'err' : CommonError };
export type Stars = bigint;
export type Stats = Array<[Name, Stars]>;
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
export type StyleScore = bigint;
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
export interface UserData {
  'height' : [] | [bigint],
  'selected_avatar' : [] | [TokenIdentifier__2],
  'invoice_id' : [] | [bigint],
  'twitter' : [] | [string],
  'name' : [] | [Name__1],
  'rank' : [] | [bigint],
  'minted' : boolean,
  'email' : [] | [string],
  'account_identifier' : [] | [string],
  'discord' : [] | [string],
}
export interface _SERVICE extends ICPSquadNFT {}
