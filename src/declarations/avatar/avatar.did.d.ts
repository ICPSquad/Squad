import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';

export type AccountIdentifier = string;
export type AccountIdentifier__1 = string;
export interface AvatarRendering {
  'mouth' : string,
  'background' : string,
  'ears' : string,
  'eyes' : string,
  'hair' : string,
  'cloth' : string,
  'nose' : string,
  'slots' : Slots__1,
  'style' : Style,
  'profile' : string,
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
  'acceptCycles' : ActorMethod<[], undefined>,
  'add_admin' : ActorMethod<[Principal], undefined>,
  'associate_legendary' : ActorMethod<[string, TokenIdentifier], Result>,
  'availableCycles' : ActorMethod<[], bigint>,
  'balance' : ActorMethod<[BalanceRequest], BalanceResponse>,
  'bearer' : ActorMethod<[TokenIdentifier], Result_7>,
  'burn' : ActorMethod<[TokenIdentifier], Result>,
  'calculate_style_score' : ActorMethod<[], undefined>,
  'changeStyle' : ActorMethod<[string], undefined>,
  'collectCanisterMetrics' : ActorMethod<[], undefined>,
  'create_profile' : ActorMethod<
    [
      [] | [string],
      [] | [string],
      [] | [string],
      [] | [string],
      TokenIdentifier,
    ],
    Result,
  >,
  'cron_default_avatar' : ActorMethod<[], undefined>,
  'cron_events' : ActorMethod<[], undefined>,
  'cron_scores' : ActorMethod<[], undefined>,
  'delete_component' : ActorMethod<[string], Result>,
  'delete_file' : ActorMethod<[string], Result>,
  'details' : ActorMethod<[TokenIdentifier], Result_6>,
  'draw' : ActorMethod<[TokenIdentifier], Result>,
  'extensions' : ActorMethod<[], Array<Extension>>,
  'getCanisterLog' : ActorMethod<
    [[] | [CanisterLogRequest]],
    [] | [CanisterLogResponse],
  >,
  'getCanisterMetrics' : ActorMethod<
    [GetMetricsParameters],
    [] | [CanisterMetrics],
  >,
  'getRegistry' : ActorMethod<[], Array<[TokenIndex, AccountIdentifier__1]>>,
  'getTokens' : ActorMethod<[], Array<[TokenIndex, Metadata]>>,
  'get_admins' : ActorMethod<[], Array<Principal>>,
  'get_all_users' : ActorMethod<[], Array<[Principal, UserData]>>,
  'get_avatar_infos' : ActorMethod<
    [],
    [[] | [TokenIdentifier], [] | [AvatarRendering]],
  >,
  'get_avatars' : ActorMethod<[], Array<TokenIdentifier>>,
  'get_components' : ActorMethod<[], Array<[string, Component]>>,
  'get_infos_accounts' : ActorMethod<
    [],
    Array<[Principal, AccountIdentifier__1]>,
  >,
  'get_infos_holders' : ActorMethod<
    [],
    Array<
      [
        Principal,
        [] | [AccountIdentifier__1],
        [] | [string],
        [] | [string],
        [] | [TokenIdentifier],
      ]
    >,
  >,
  'get_infos_leaderboard' : ActorMethod<
    [],
    Array<[Principal, [] | [Name__3], [] | [TokenIdentifier]]>,
  >,
  'get_number_users' : ActorMethod<[], bigint>,
  'get_score' : ActorMethod<[TokenIdentifier], [] | [bigint]>,
  'get_slot' : ActorMethod<[TokenIdentifier], [] | [Slots]>,
  'get_stats' : ActorMethod<[], Array<[Name__2, Stars__1]>>,
  'get_style_score' : ActorMethod<[], Array<[TokenIdentifier, StyleScore]>>,
  'get_user' : ActorMethod<[], [] | [UserData]>,
  'has_ticket' : ActorMethod<[Principal], boolean>,
  'http_request' : ActorMethod<[Request], Response>,
  'is_admin' : ActorMethod<[Principal], boolean>,
  'metadata' : ActorMethod<[TokenIdentifier], Result_5>,
  'mint' : ActorMethod<[MintInformation, [] | [bigint]], MintResult>,
  'mint_legendary' : ActorMethod<[string, Principal], Result>,
  'mint_ticket' : ActorMethod<[Principal], Result_4>,
  'modify_profile' : ActorMethod<
    [
      [] | [string],
      [] | [string],
      [] | [string],
      [] | [string],
      TokenIdentifier,
    ],
    Result,
  >,
  'registerComponent' : ActorMethod<[string, Component], Result>,
  'removeAccessory' : ActorMethod<[TokenIdentifier, string, Principal], Result>,
  'remove_admin' : ActorMethod<[Principal], undefined>,
  'report_burned_accessory' : ActorMethod<
    [string, TokenIdentifier, TokenIndex],
    Result__1,
  >,
  'setMaxMessagesCount' : ActorMethod<[bigint], undefined>,
  'set_default_avatar' : ActorMethod<[TokenIdentifier], Result>,
  'show_user' : ActorMethod<[Principal], [] | [UserData]>,
  'supply' : ActorMethod<[], bigint>,
  'tokens' : ActorMethod<[AccountIdentifier__1], Result_3>,
  'tokens_ext' : ActorMethod<[AccountIdentifier__1], Result_2>,
  'tokens_id' : ActorMethod<[AccountIdentifier__1], Result_1>,
  'tokens_ids' : ActorMethod<[], Array<TokenIdentifier>>,
  'transfer' : ActorMethod<[TransferRequest], TransferResponse>,
  'upload' : ActorMethod<[Array<number>], undefined>,
  'uploadClear' : ActorMethod<[], undefined>,
  'uploadFinalize' : ActorMethod<[string, Meta, string], Result>,
  'upload_stats' : ActorMethod<[Stats], undefined>,
  'wearAccessory' : ActorMethod<[TokenIdentifier, string, Principal], Result>,
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
export type Name__3 = string;
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
export type Result_4 = { 'ok' : TokenIndex } |
  { 'err' : string };
export type Result_5 = { 'ok' : Metadata } |
  { 'err' : CommonError__1 };
export type Result_6 = { 'ok' : [AccountIdentifier__1, [] | [Listing]] } |
  { 'err' : CommonError };
export type Result_7 = { 'ok' : AccountIdentifier__1 } |
  { 'err' : CommonError };
export type Result__1 = { 'ok' : null } |
  { 'err' : null };
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
export type Stars = bigint;
export type Stars__1 = bigint;
export type Stats = Array<[Name, Stars]>;
export type StreamingCallback = ActorMethod<
  [StreamingCallbackToken],
  StreamingCallbackResponse,
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
export type Style = { 'Old' : string } |
  { 'Colors' : Colors };
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
