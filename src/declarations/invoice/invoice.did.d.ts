import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';

export type AccountIdentifier = { 'principal' : Principal } |
  { 'blob' : Array<number> } |
  { 'text' : string };
export interface AccountIdentifierToBlobErr {
  'kind' : { 'InvalidAccountIdentifier' : null } |
    { 'Other' : null },
  'message' : [] | [string],
}
export type AccountIdentifierToBlobResult = {
    'ok' : AccountIdentifierToBlobSuccess
  } |
  { 'err' : AccountIdentifierToBlobErr };
export type AccountIdentifierToBlobSuccess = Array<number>;
export type AccountIdentifier__1 = { 'principal' : Principal } |
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
export type Category = { 'AvatarMint' : null } |
  { 'Ticket' : null } |
  { 'AccessoryFee' : null };
export interface CreateInvoiceErr {
  'kind' : { 'InvalidDetails' : null } |
    { 'InvalidAmount' : null } |
    { 'InvalidDestination' : null } |
    { 'MaxInvoicesReached' : null } |
    { 'BadSize' : null } |
    { 'InvalidToken' : null } |
    { 'Other' : null },
  'message' : [] | [string],
}
export type CreateInvoiceResult = { 'ok' : CreateInvoiceSuccess } |
  { 'err' : CreateInvoiceErr };
export interface CreateInvoiceSuccess { 'invoice' : Invoice__1 }
export interface DailyMetricsData {
  'updateCalls' : bigint,
  'canisterHeapMemorySize' : NumericEntity,
  'canisterCycles' : NumericEntity,
  'canisterMemorySize' : NumericEntity,
  'timeMillis' : bigint,
}
export interface Details { 'meta' : Array<number>, 'description' : string }
export interface GetAccountIdentifierArgs {
  'principal' : Principal,
  'token' : Token,
}
export interface GetAccountIdentifierErr {
  'kind' : { 'InvalidToken' : null } |
    { 'Other' : null },
  'message' : [] | [string],
}
export type GetAccountIdentifierResult = {
    'ok' : GetAccountIdentifierSuccess
  } |
  { 'err' : GetAccountIdentifierErr };
export interface GetAccountIdentifierSuccess {
  'accountIdentifier' : AccountIdentifier,
}
export interface GetBalanceArgs { 'token' : Token }
export interface GetBalanceErr {
  'kind' : { 'NotFound' : null } |
    { 'InvalidToken' : null } |
    { 'Other' : null },
  'message' : [] | [string],
}
export type GetBalanceResult = { 'ok' : GetBalanceSuccess } |
  { 'err' : GetBalanceErr };
export interface GetBalanceSuccess { 'balance' : bigint }
export interface GetDestinationAccountIdentifierArgs {
  'token' : Token,
  'invoiceId' : bigint,
  'caller' : Principal,
}
export interface GetDestinationAccountIdentifierErr {
  'kind' : { 'InvalidToken' : null } |
    { 'InvalidInvoiceId' : null } |
    { 'Other' : null },
  'message' : [] | [string],
}
export type GetDestinationAccountIdentifierResult = {
    'ok' : GetDestinationAccountIdentifierSuccess
  } |
  { 'err' : GetDestinationAccountIdentifierErr };
export interface GetDestinationAccountIdentifierSuccess {
  'accountIdentifier' : AccountIdentifier,
}
export interface GetInvoiceArgs { 'id' : bigint }
export interface GetInvoiceErr {
  'kind' : { 'NotFound' : null } |
    { 'NotAuthorized' : null } |
    { 'InvalidInvoiceId' : null } |
    { 'Other' : null },
  'message' : [] | [string],
}
export type GetInvoiceResult = { 'ok' : GetInvoiceSuccess } |
  { 'err' : GetInvoiceErr };
export interface GetInvoiceSuccess { 'invoice' : Invoice__1 }
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
export interface Invoice {
  'acceptCycles' : ActorMethod<[], undefined>,
  'accountIdentifierToBlob' : ActorMethod<
    [AccountIdentifier__1],
    AccountIdentifierToBlobResult,
  >,
  'add_admin' : ActorMethod<[Principal], undefined>,
  'availableCycles' : ActorMethod<[], bigint>,
  'collectCanisterMetrics' : ActorMethod<[], undefined>,
  'create_invoice' : ActorMethod<[Category], CreateInvoiceResult>,
  'cron_balance' : ActorMethod<[], undefined>,
  'getCanisterLog' : ActorMethod<
    [[] | [CanisterLogRequest]],
    [] | [CanisterLogResponse],
  >,
  'getCanisterMetrics' : ActorMethod<
    [GetMetricsParameters],
    [] | [CanisterMetrics],
  >,
  'getDestinationAccountIdentifierPublic' : ActorMethod<
    [GetDestinationAccountIdentifierArgs],
    GetDestinationAccountIdentifierResult,
  >,
  'get_account_identifier' : ActorMethod<
    [GetAccountIdentifierArgs],
    GetAccountIdentifierResult,
  >,
  'get_balance' : ActorMethod<[GetBalanceArgs], GetBalanceResult>,
  'get_invoice' : ActorMethod<[GetInvoiceArgs], GetInvoiceResult>,
  'get_invoices_to_check' : ActorMethod<[], Array<[Principal, bigint]>>,
  'is_admin' : ActorMethod<[Principal], boolean>,
  'transfer' : ActorMethod<[TransferArgs], TransferResult>,
  'transfer_back_invoice' : ActorMethod<[bigint], Result>,
  'verify_invoice_accessory' : ActorMethod<
    [VerifyInvoiceArgs],
    VerifyInvoiceResult,
  >,
  'verify_invoice_avatar' : ActorMethod<
    [VerifyInvoiceArgs, Principal],
    VerifyInvoiceResult,
  >,
  'verify_invoice_ticket' : ActorMethod<
    [VerifyInvoiceArgs],
    VerifyInvoiceResult,
  >,
}
export interface Invoice__1 {
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
export type Time = bigint;
export interface Token { 'symbol' : string }
export interface TokenVerbose {
  'decimals' : bigint,
  'meta' : [] | [{ 'Issuer' : string }],
  'symbol' : string,
}
export interface TransferArgs {
  'destination' : AccountIdentifier,
  'token' : Token,
  'amount' : bigint,
}
export interface TransferError {
  'kind' : { 'InvalidDestination' : null } |
    { 'BadFee' : null } |
    { 'InvalidToken' : null } |
    { 'Other' : null } |
    { 'InsufficientFunds' : null },
  'message' : [] | [string],
}
export type TransferResult = { 'ok' : TransferSuccess } |
  { 'err' : TransferError };
export interface TransferSuccess { 'blockHeight' : bigint }
export type UpdateCallsAggregatedData = Array<bigint>;
export interface VerifyInvoiceArgs { 'id' : bigint }
export interface VerifyInvoiceErr {
  'kind' : { 'InvalidAccount' : null } |
    { 'TransferError' : null } |
    { 'NotFound' : null } |
    { 'NotAuthorized' : null } |
    { 'InvalidToken' : null } |
    { 'InvalidInvoiceId' : null } |
    { 'Other' : null } |
    { 'NotYetPaid' : null } |
    { 'Expired' : null },
  'message' : [] | [string],
}
export type VerifyInvoiceResult = { 'ok' : VerifyInvoiceSuccess } |
  { 'err' : VerifyInvoiceErr };
export type VerifyInvoiceSuccess = { 'Paid' : { 'invoice' : Invoice__1 } } |
  { 'AlreadyVerified' : { 'invoice' : Invoice__1 } };
export interface _SERVICE extends Invoice {}
