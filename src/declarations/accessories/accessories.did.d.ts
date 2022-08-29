import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';

export interface AccessoryInventory {
  'tokenIdentifier' : string,
  'name' : string,
  'equipped' : boolean,
}
export type AccountIdentifier = string;
export type AccountIdentifier__1 = string;
export type AccountIdentifier__2 = string;
export type Airdrop = Array<string>;
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
export type CommonError__2 = { 'InvalidToken' : TokenIdentifier__1 } |
  { 'Other' : string };
export interface DailyMetricsData {
  'updateCalls' : bigint,
  'canisterHeapMemorySize' : NumericEntity,
  'canisterCycles' : NumericEntity,
  'canisterMemorySize' : NumericEntity,
  'timeMillis' : bigint,
}
export type DetailsResponse = {
    'ok' : [AccountIdentifier__1, [] | [Listing__1]]
  } |
  { 'err' : CommonError__2 };
export type Disbursement = [
  TokenIndex__1,
  AccountIdentifier__1,
  SubAccount__1,
  bigint,
];
export interface EntrepotTransaction {
  'token' : TokenIdentifier__2,
  'time' : Time,
  'seller' : Principal,
  'buyer' : AccountIdentifier__1,
  'price' : bigint,
}
export interface ExtListing {
  'locked' : [] | [Time],
  'seller' : Principal,
  'price' : bigint,
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
  'acceptCycles' : ActorMethod<[], undefined>,
  'add_admin' : ActorMethod<[Principal], undefined>,
  'add_template' : ActorMethod<[string, Template], Result_7>,
  'airdrop_rewards' : ActorMethod<
    [Array<[AccountIdentifier__2, Airdrop]>],
    undefined,
  >,
  'availableCycles' : ActorMethod<[], bigint>,
  'balance' : ActorMethod<[BalanceRequest], BalanceResponse>,
  'bearer' : ActorMethod<[TokenIdentifier], Result_6>,
  'can_settle' : ActorMethod<[Principal, TokenIdentifier__1], Result__1_2>,
  'checkInventory' : ActorMethod<[Principal], Result_5>,
  'collectCanisterMetrics' : ActorMethod<[], undefined>,
  'create_accessory' : ActorMethod<[string, bigint], Result__1_1>,
  'cron_burned' : ActorMethod<[], undefined>,
  'cron_disbursements' : ActorMethod<[], undefined>,
  'cron_events' : ActorMethod<[], undefined>,
  'cron_settlements' : ActorMethod<[], undefined>,
  'cron_verification' : ActorMethod<[], undefined>,
  'delete_item' : ActorMethod<[string], Result>,
  'details' : ActorMethod<[TokenIdentifier], DetailsResponse>,
  'disbursement_pending_count' : ActorMethod<[], bigint>,
  'disbursement_queue_size' : ActorMethod<[], bigint>,
  'extensions' : ActorMethod<[], Array<Extension>>,
  'getCanisterLog' : ActorMethod<
    [[] | [CanisterLogRequest]],
    [] | [CanisterLogResponse],
  >,
  'getCanisterMetrics' : ActorMethod<
    [GetMetricsParameters],
    [] | [CanisterMetrics],
  >,
  'getInventory' : ActorMethod<[], Result_5>,
  'getRegistry' : ActorMethod<[], Array<[TokenIndex, AccountIdentifier__2]>>,
  'getTokens' : ActorMethod<[], Array<[TokenIndex, Metadata]>>,
  'get_avatar_equipped' : ActorMethod<
    [TokenIdentifier],
    [] | [TokenIdentifier],
  >,
  'get_items' : ActorMethod<[], Array<[string, Array<TokenIndex>]>>,
  'get_materials' : ActorMethod<
    [Principal, boolean],
    Array<[TokenIndex, string]>,
  >,
  'get_name' : ActorMethod<[TokenIndex], [] | [string]>,
  'get_pending_transactions' : ActorMethod<
    [],
    Array<[TokenIndex, Transaction]>,
  >,
  'get_recipes' : ActorMethod<[], Array<[string, Recipe__1]>>,
  'get_recorded_rewards' : ActorMethod<[Principal], [] | [Array<Reward>]>,
  'get_stats_items' : ActorMethod<[], Array<[string, Supply, [] | [Floor]]>>,
  'get_templates' : ActorMethod<[], Array<[string, Template]>>,
  'http_request' : ActorMethod<[Request], Response>,
  'is_admin' : ActorMethod<[Principal], boolean>,
  'is_owner_account' : ActorMethod<[AccountIdentifier__2, TokenIndex], boolean>,
  'list' : ActorMethod<[ListRequest], ListResponse>,
  'listings' : ActorMethod<[], ListingResponse>,
  'lock' : ActorMethod<
    [TokenIdentifier, bigint, AccountIdentifier__2, Array<number>],
    LockResponse,
  >,
  'metadata' : ActorMethod<[TokenIdentifier], Result_4>,
  'mint' : ActorMethod<[string, Principal], Result>,
  'payments' : ActorMethod<[], [] | [Array<SubAccount__2>]>,
  'purge_pending_transactions' : ActorMethod<[], undefined>,
  'read_disbursements' : ActorMethod<[], Array<Disbursement>>,
  'remove_accessory' : ActorMethod<
    [TokenIdentifier, TokenIdentifier],
    Result__1,
  >,
  'remove_admin' : ActorMethod<[Principal], undefined>,
  'setMaxMessagesCount' : ActorMethod<[bigint], undefined>,
  'settle' : ActorMethod<[TokenIdentifier], Result_3>,
  'stats' : ActorMethod<
    [],
    [bigint, bigint, bigint, bigint, bigint, bigint, bigint],
  >,
  'tokenId' : ActorMethod<[TokenIndex], string>,
  'tokens' : ActorMethod<[AccountIdentifier__2], Result_2>,
  'tokens_ext' : ActorMethod<[AccountIdentifier__2], Result_1>,
  'transactions' : ActorMethod<[], Array<EntrepotTransaction>>,
  'transactions_new' : ActorMethod<[], Array<[bigint, Transaction]>>,
  'transactions_new_size' : ActorMethod<[], bigint>,
  'transfer' : ActorMethod<[TransferRequest], TransferResponse>,
  'update_accessories' : ActorMethod<[], undefined>,
  'wear_accessory' : ActorMethod<[TokenIdentifier, TokenIdentifier], Result>,
}
export type Inventory = Array<ItemInventory>;
export type ItemInventory = { 'Accessory' : AccessoryInventory } |
  { 'Material' : MaterialInventory };
export interface ListRequest {
  'token' : TokenIdentifier__2,
  'from_subaccount' : [] | [SubAccount__1],
  'price' : [] | [bigint],
}
export type ListResponse = { 'ok' : null } |
  { 'err' : CommonError__2 };
export interface Listing {
  'subaccount' : [] | [SubAccount],
  'locked' : [] | [Time],
  'seller' : Principal,
  'price' : bigint,
}
export type ListingResponse = Array<[TokenIndex__1, ExtListing, Metadata__1]>;
export interface Listing__1 {
  'subaccount' : [] | [SubAccount__1],
  'locked' : [] | [Time],
  'seller' : Principal,
  'price' : bigint,
}
export type LockResponse = { 'ok' : AccountIdentifier__1 } |
  { 'err' : CommonError__2 };
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
export type Result_3 = { 'ok' : null } |
  { 'err' : CommonError };
export type Result_4 = { 'ok' : Metadata } |
  { 'err' : CommonError__1 };
export type Result_5 = { 'ok' : Inventory } |
  { 'err' : string };
export type Result_6 = { 'ok' : AccountIdentifier__2 } |
  { 'err' : CommonError };
export type Result_7 = { 'ok' : string } |
  { 'err' : string };
export type Result__1 = { 'ok' : null } |
  { 'err' : string };
export type Result__1_1 = { 'ok' : TokenIdentifier } |
  { 'err' : string };
export type Result__1_2 = { 'ok' : null } |
  { 'err' : CommonError__1 };
export interface Reward {
  'collection' : Principal,
  'date' : Time,
  'name' : string,
  'category' : TypeReward,
  'identifier' : [] | [string],
  'amount' : bigint,
}
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
export type TokenIdentifier = string;
export type TokenIdentifier__1 = string;
export type TokenIdentifier__2 = string;
export type TokenIndex = number;
export type TokenIndex__1 = number;
export interface Transaction {
  'id' : bigint,
  'to' : AccountIdentifier__1,
  'closed' : [] | [Time],
  'token' : TokenIdentifier__2,
  'initiated' : Time,
  'from' : AccountIdentifier__1,
  'memo' : [] | [Array<number>],
  'seller' : Principal,
  'bytes' : Array<number>,
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
export type TypeReward = { 'NFT' : null } |
  { 'Token' : null } |
  { 'Other' : null };
export type UpdateCallsAggregatedData = Array<bigint>;
export type User = { 'principal' : Principal } |
  { 'address' : AccountIdentifier };
export interface _SERVICE extends ICPSquadNFT {}
