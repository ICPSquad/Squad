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
  'cycles_burned_accessories' : bigint,
  'new_users' : bigint,
  'new_items' : bigint,
  'time' : bigint,
  'new_icps' : ICP,
  'cycles_burned_avatar' : bigint,
  'new_avatar' : bigint,
  'cycles_burned_hub' : bigint,
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
export type Color = [number, number, number, number];
export type ExtCoreUser = { 'principal' : Principal } |
  { 'address' : AccountIdentifier };
export interface ICP { 'e8s' : bigint }
export interface Infos {
  'subaccount_to_send' : Array<number>,
  'twitter' : [] | [string],
  'memo' : bigint,
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
export interface MintRequest { 'to' : ExtCoreUser, 'metadata' : AvatarRequest }
export type MintingError = { 'Avatar' : string } |
  { 'Verification' : string };
export interface PaymentError {
  'request_associated' : [] | [Infos__1],
  'error_message' : string,
  'caller' : Principal,
}
export type Result = { 'ok' : string } |
  { 'err' : string };
export type Result_1 = { 'ok' : bigint } |
  { 'err' : string };
export type Result_2 = { 'ok' : null } |
  { 'err' : string };
export type Status = { 'OG' : null } |
  { 'Staff' : null } |
  { 'Level1' : null } |
  { 'Level2' : null } |
  { 'Level3' : null } |
  { 'Legendary' : null };
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
export interface _SERVICE {
  'addAdmin' : (arg_0: Principal) => Promise<Result_2>,
  'addUser' : (arg_0: Principal, arg_1: User) => Promise<Result_2>,
  'airdrop' : () => Promise<AirdropResponse>,
  'audit' : () => Promise<undefined>,
  'balance' : () => Promise<ICP>,
  'checkRegistration' : () => Promise<boolean>,
  'confirm' : (arg_0: bigint) => Promise<Result_2>,
  'getInformations' : () => Promise<Array<[Principal, User]>>,
  'getRank' : (arg_0: Principal) => Promise<[] | [bigint]>,
  'isUserAuthorized' : () => Promise<Result_2>,
  'mintRequest' : (arg_0: MintRequest) => Promise<AvatarResponse>,
  'modifyUser' : (arg_0: Principal, arg_1: User) => Promise<Result_2>,
  'numberUsers' : () => Promise<bigint>,
  'prejoin' : (
      arg_0: string,
      arg_1: [] | [string],
      arg_2: [] | [string],
      arg_3: [] | [string],
      arg_4: SubAccount,
    ) => Promise<Result_1>,
  'process' : () => Promise<undefined>,
  'recipe' : () => Promise<undefined>,
  'removeUser' : (arg_0: Principal) => Promise<Result>,
  'showErrors' : () => Promise<Array<[Time, MintingError]>>,
  'showPaymentErrors' : () => Promise<Array<[Time, PaymentError]>>,
  'showPrejoins' : () => Promise<Array<[Principal, Infos]>>,
  'showUser' : (arg_0: Principal) => Promise<[] | [User]>,
  'show_audits' : () => Promise<Array<Audit>>,
  'transfer' : (arg_0: ICP, arg_1: Principal) => Promise<TransferResult>,
  'verification' : () => Promise<undefined>,
  'wallet_available' : () => Promise<bigint>,
  'wallet_receive' : () => Promise<undefined>,
}
