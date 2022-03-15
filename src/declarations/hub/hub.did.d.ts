import type { Principal } from '@dfinity/principal';
export type AccountIdentifier = string;
export interface AirdropObject {
  'recipient' : Principal,
  'accessory1' : [] | [string],
  'accessory2' : [] | [string],
  'material' : string,
}
export type AirdropResponse = { 'ok' : AirdropObject } |
  { 'err' : string };
export interface Audit {
  'new_users' : bigint,
  'new_items' : bigint,
  'time' : bigint,
  'new_icps' : ICP,
  'new_avatar' : bigint,
}
export interface AvatarInformations {
  'svg' : string,
  'tokenIdentifier' : string,
}
export interface AvatarRequest {
  'components' : Array<{ 'name' : string, 'layer' : number }>,
  'colors' : Array<{ 'color' : Color, 'spot' : string }>,
}
export type AvatarResponse = { 'ok' : AvatarInformations } |
  { 'err' : string };
export type BlockIndex = bigint;
export type CanisterCyclesAggregatedData = Array<bigint>;
export type CanisterHeapMemoryAggregatedData = Array<bigint>;
export type CanisterMemoryAggregatedData = Array<bigint>;
export interface CanisterMetrics { 'data' : CanisterMetricsData }
export type CanisterMetricsData = { 'hourly' : Array<HourlyMetricsData> } |
  { 'daily' : Array<DailyMetricsData> };
export type Color = [number, number, number, number];
export interface DailyMetricsData {
  'updateCalls' : bigint,
  'canisterHeapMemorySize' : NumericEntity,
  'canisterCycles' : NumericEntity,
  'canisterMemorySize' : NumericEntity,
  'timeMillis' : bigint,
}
export type DetailValue = { 'I64' : bigint } |
  { 'U64' : bigint } |
  { 'Vec' : Array<DetailValue> } |
  { 'Slice' : Array<number> } |
  { 'Text' : string } |
  { 'True' : null } |
  { 'False' : null } |
  { 'Float' : number } |
  { 'Principal' : Principal };
export interface Event {
  'time' : bigint,
  'operation' : string,
  'details' : Array<[string, DetailValue]>,
  'category' : LogCategory,
  'caller' : Principal,
}
export type ExtCoreUser = { 'principal' : Principal } |
  { 'address' : AccountIdentifier };
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
export interface Hub {
  'addUser' : (arg_0: Principal, arg_1: User) => Promise<Result>,
  'add_admin' : (arg_0: Principal) => Promise<undefined>,
  'airdrop' : () => Promise<AirdropResponse>,
  'audit' : () => Promise<undefined>,
  'balance' : () => Promise<ICP>,
  'checkRegistration' : () => Promise<boolean>,
  'collectCanisterMetrics' : () => Promise<undefined>,
  'confirm' : (arg_0: bigint) => Promise<Result>,
  'confirm_new' : () => Promise<Result>,
  'getCanisterMetrics' : (arg_0: GetMetricsParameters) => Promise<
      [] | [CanisterMetrics]
    >,
  'getInformations' : () => Promise<Array<[Principal, User]>>,
  'getRank' : (arg_0: Principal) => Promise<[] | [bigint]>,
  'isUserAuthorized' : () => Promise<Result>,
  'is_admin' : (arg_0: Principal) => Promise<boolean>,
  'mintRequest' : (arg_0: MintRequest) => Promise<AvatarResponse>,
  'modifyHeight' : (arg_0: Principal, arg_1: bigint) => Promise<Result>,
  'modifyRank' : (arg_0: Principal, arg_1: bigint) => Promise<Result>,
  'modifyUser' : (arg_0: Principal, arg_1: User) => Promise<Result>,
  'numberUsers' : () => Promise<bigint>,
  'prejoin' : (
      arg_0: string,
      arg_1: [] | [string],
      arg_2: [] | [string],
      arg_3: [] | [string],
      arg_4: SubAccount,
    ) => Promise<Result_3>,
  'process' : () => Promise<undefined>,
  'recipe' : () => Promise<Result_2>,
  'register' : (
      arg_0: string,
      arg_1: [] | [string],
      arg_2: [] | [string],
      arg_3: [] | [string],
    ) => Promise<Result_1>,
  'removeUser' : (arg_0: Principal) => Promise<Result_1>,
  'showErrors' : () => Promise<Array<[Time, MintingError]>>,
  'showPaymentErrors' : () => Promise<Array<[Time, PaymentError]>>,
  'showPrejoins' : () => Promise<Array<[Principal, Infos]>>,
  'showUser' : (arg_0: Principal) => Promise<[] | [User]>,
  'show_audits' : () => Promise<Array<Audit>>,
  'show_logs' : () => Promise<List>,
  'show_robbers' : () => Promise<Array<SubAccount>>,
  'status' : () => Promise<StatusRegistration>,
  'transfer' : (arg_0: ICP, arg_1: Principal) => Promise<TransferResult>,
  'updateAdminsData' : (arg_0: Principal, arg_1: boolean) => Promise<Result>,
  'verification' : () => Promise<undefined>,
  'verification_registrations' : () => Promise<undefined>,
  'wallet_available' : () => Promise<bigint>,
  'wallet_receive' : () => Promise<undefined>,
}
export interface ICP { 'e8s' : bigint }
export interface Infos {
  'subaccount_to_send' : Array<number>,
  'twitter' : [] | [string],
  'memo' : bigint,
  'email' : [] | [string],
  'discord' : [] | [string],
  'wallet' : string,
}
export interface InfosNew {
  'twitter' : [] | [string],
  'email' : [] | [string],
  'discord' : [] | [string],
  'wallet' : string,
}
export interface Infos__1 {
  'subaccount_to_send' : Array<number>,
  'twitter' : [] | [string],
  'memo' : bigint,
  'email' : [] | [string],
  'discord' : [] | [string],
  'wallet' : string,
}
export type List = [] | [[Event, List]];
export type LogCategory = { 'Result' : string } |
  { 'Operation' : null } |
  { 'Cronic' : null } |
  { 'ErrorSystem' : null } |
  { 'ErrorResult' : null };
export type MetricsGranularity = { 'hourly' : null } |
  { 'daily' : null };
export interface MintRequest { 'to' : ExtCoreUser, 'metadata' : AvatarRequest }
export type MintingError = { 'Avatar' : string } |
  { 'Verification' : string };
export interface NumericEntity {
  'avg' : bigint,
  'max' : bigint,
  'min' : bigint,
  'first' : bigint,
  'last' : bigint,
}
export interface PaymentError {
  'request_associated' : [] | [Infos__1],
  'error_message' : string,
  'caller' : Principal,
}
export interface RecipeInfos { 'block' : bigint, 'amount' : bigint }
export interface Registration {
  'invoice_id' : bigint,
  'time' : Time,
  'infos' : InfosNew,
  'account_to_send' : string,
}
export type Result = { 'ok' : null } |
  { 'err' : string };
export type Result_1 = { 'ok' : string } |
  { 'err' : string };
export type Result_2 = { 'ok' : RecipeInfos } |
  { 'err' : string };
export type Result_3 = { 'ok' : bigint } |
  { 'err' : string };
export type Status = { 'OG' : null } |
  { 'Staff' : null } |
  { 'Level1' : null } |
  { 'Level2' : null } |
  { 'Level3' : null } |
  { 'Legendary' : null };
export type StatusRegistration = { 'NotRegistered' : null } |
  { 'Member' : null } |
  { 'NotConfirmed' : Registration } |
  { 'NotAuthenticated' : null };
export type SubAccount = Array<number>;
export type Time = bigint;
export type TokenIdentifier = string;
export type TransferError = {
    'TxTooOld' : { 'allowed_window_nanos' : bigint }
  } |
  { 'BadFee' : { 'expected_fee' : ICP } } |
  { 'TxDuplicate' : { 'duplicate_of' : BlockIndex } } |
  { 'TxCreatedInFuture' : null } |
  { 'InsufficientFunds' : { 'balance' : ICP } };
export type TransferResult = { 'Ok' : BlockIndex } |
  { 'Err' : TransferError };
export type UpdateCallsAggregatedData = Array<bigint>;
export interface User {
  'height' : [] | [bigint],
  'status' : Status,
  'twitter' : [] | [string],
  'rank' : [] | [bigint],
  'email' : [] | [string],
  'airdrop' : [] | [Array<string>],
  'discord' : [] | [string],
  'wallet' : string,
  'avatar' : [] | [TokenIdentifier],
}
export interface _SERVICE extends Hub {}
