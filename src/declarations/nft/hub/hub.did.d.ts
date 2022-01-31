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
export interface JoiningError {
  'request_associated' : [] | [WhiteListRequest],
  'error_message' : string,
  'caller' : Principal,
}
export interface MintRequest { 'to' : ExtCoreUser, 'metadata' : AvatarRequest }
export type MintingError = { 'Avatar' : string } |
  { 'Verification' : string };
export type Result = { 'ok' : string } |
  { 'err' : string };
export type Result_1 = { 'ok' : null } |
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
export interface WhiteListRequest {
  'height' : bigint,
  'principal' : Principal,
  'twitter' : [] | [string],
  'email' : [] | [string],
  'discord' : [] | [string],
  'wallet' : string,
}
export interface WhiteListRequest__1 {
  'height' : bigint,
  'principal' : Principal,
  'twitter' : [] | [string],
  'email' : [] | [string],
  'discord' : [] | [string],
  'wallet' : string,
}
export interface _SERVICE {
  'addAdmin' : (arg_0: Principal) => Promise<Result_1>,
  'addUser' : (arg_0: Principal, arg_1: User) => Promise<Result_1>,
  'airdrop' : () => Promise<AirdropResponse>,
  'balance' : () => Promise<ICP>,
  'checkRegistration' : () => Promise<boolean>,
  'getInformations' : () => Promise<Array<[Principal, User]>>,
  'getRank' : (arg_0: Principal) => Promise<[] | [bigint]>,
  'isUserAuthorized' : () => Promise<Result_1>,
  'join' : (arg_0: WhiteListRequest__1, arg_1: Array<number>) => Promise<
      Result_1
    >,
  'mintRequest' : (arg_0: MintRequest) => Promise<AvatarResponse>,
  'modifyUser' : (arg_0: Principal, arg_1: User) => Promise<Result_1>,
  'numberUsers' : () => Promise<bigint>,
  'removeUser' : (arg_0: Principal) => Promise<Result>,
  'showErrors' : () => Promise<Array<[Time, MintingError]>>,
  'showJoiningErrors' : () => Promise<Array<[Time, JoiningError]>>,
  'showUser' : (arg_0: Principal) => Promise<[] | [User]>,
  'transfer' : (arg_0: ICP, arg_1: Principal) => Promise<TransferResult>,
  'verificationPayments' : () => Promise<Array<SubAccount>>,
  'wallet_available' : () => Promise<bigint>,
  'wallet_receive' : () => Promise<undefined>,
}
