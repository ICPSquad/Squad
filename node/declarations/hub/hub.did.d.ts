import type { Principal } from '@dfinity/principal';
export type AccountIdentifier = { 'principal' : Principal } |
  { 'blob' : Array<number> } |
  { 'text' : string };
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
export type Color = [number, number, number, number];
export type Colors = Array<{ 'color' : Color, 'spot' : string }>;
export interface DailyMetricsData {
  'updateCalls' : bigint,
  'canisterHeapMemorySize' : NumericEntity,
  'canisterCycles' : NumericEntity,
  'canisterMemorySize' : NumericEntity,
  'timeMillis' : bigint,
}
export interface Details { 'meta' : Array<number>, 'description' : string }
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
export interface HourlyMetricsData {
  'updateCalls' : UpdateCallsAggregatedData,
  'canisterHeapMemorySize' : CanisterHeapMemoryAggregatedData,
  'canisterCycles' : CanisterCyclesAggregatedData,
  'canisterMemorySize' : CanisterMemoryAggregatedData,
  'timeMillis' : bigint,
}
export interface ICPSquadHub {
  'acceptCycles' : () => Promise<undefined>,
  'add_admin' : (arg_0: Principal) => Promise<undefined>,
  'availableCycles' : () => Promise<bigint>,
  'backup_users' : () => Promise<UpgradeData>,
  'collectCanisterMetrics' : () => Promise<undefined>,
  'getCanisterLog' : (arg_0: [] | [CanisterLogRequest]) => Promise<
      [] | [CanisterLogResponse]
    >,
  'getCanisterMetrics' : (arg_0: GetMetricsParameters) => Promise<
      [] | [CanisterMetrics]
    >,
  'get_user' : () => Promise<[] | [User]>,
  'is_admin' : (arg_0: Principal) => Promise<boolean>,
  'mint' : (arg_0: MintInformation) => Promise<MintResult>,
  'modify_user' : (arg_0: User) => Promise<Result>,
  'whitelist' : (arg_0: Principal) => Promise<Result>,
}
export interface Invoice {
  'id' : bigint,
  'permissions' : [] | [Permissions],
  'creator' : Principal,
  'destination' : AccountIdentifier,
  'token' : TokenVerbose,
  'paid' : boolean,
  'verifiedAtTime' : [] | [Time],
  'amountPaid' : bigint,
  'expiration' : Time,
  'details' : [] | [Details],
  'amount' : bigint,
}
export interface LogMessagesData { 'timeNanos' : Nanos, 'message' : string }
export type MetricsGranularity = { 'hourly' : null } |
  { 'daily' : null };
export type MintErr = { 'Invoice' : Invoice } |
  { 'Anonymous' : null } |
  { 'AlreadyMinted' : null } |
  { 'AvatarCanisterErr' : string } |
  { 'Other' : string } |
  {
    'InvoiceCanisterErr' : {
      'kind' : { 'InvalidAccount' : null } |
        { 'InvalidDetails' : null } |
        { 'InvalidAmount' : null } |
        { 'InvalidDestination' : null } |
        { 'TransferError' : null } |
        { 'MaxInvoicesReached' : null } |
        { 'BadSize' : null } |
        { 'NotFound' : null } |
        { 'NotAuthorized' : null } |
        { 'InvalidToken' : null } |
        { 'InvalidInvoiceId' : null } |
        { 'Other' : null } |
        { 'NotYetPaid' : null } |
        { 'Expired' : null },
      'message' : [] | [string],
    }
  };
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
export type MintResult = { 'ok' : MintSuccess } |
  { 'err' : MintErr };
export interface MintSuccess { 'tokenId' : string }
export type Nanos = bigint;
export interface NumericEntity {
  'avg' : bigint,
  'max' : bigint,
  'min' : bigint,
  'first' : bigint,
  'last' : bigint,
}
export interface Permissions {
  'canGet' : Array<Principal>,
  'canVerify' : Array<Principal>,
}
export type Result = { 'ok' : null } |
  { 'err' : string };
export type Status = { 'Invoice' : Invoice } |
  { 'Member' : boolean } |
  { 'InProgress' : null };
export type Time = bigint;
export interface TokenVerbose {
  'decimals' : bigint,
  'meta' : [] | [{ 'Issuer' : string }],
  'symbol' : string,
}
export type UpdateCallsAggregatedData = Array<bigint>;
export interface UpgradeData { 'users' : Array<[Principal, User__1]> }
export interface User {
  'height' : [] | [bigint],
  'status' : Status,
  'twitter' : [] | [string],
  'rank' : [] | [bigint],
  'email' : [] | [string],
  'discord' : [] | [string],
}
export interface User__1 {
  'height' : [] | [bigint],
  'status' : Status,
  'twitter' : [] | [string],
  'rank' : [] | [bigint],
  'email' : [] | [string],
  'discord' : [] | [string],
}
export interface _SERVICE extends ICPSquadHub {}
