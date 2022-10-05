import type { Principal } from "@dfinity/principal";
export type AccountIdentifier = string;
export type AccountIdentifier__1 = string;
export interface AllowanceRequest {
  owner: User;
  subaccount: [] | [SubAccount];
  spender: Principal;
}
export interface ApproveRequest {
  subaccount: [] | [SubAccount];
  allowance: Balance;
  spender: Principal;
}
export type Balance = bigint;
export interface BalanceRequest {
  token: TokenIdentifier;
  user: User;
}
export type BalanceResponse = { ok: Balance } | { err: CommonError };
export type Balance__1 = bigint;
export type CommonError = { InsufficientBalance: null } | { InvalidToken: TokenIdentifier } | { Unauthorized: AccountIdentifier } | { Other: string };
export type CommonError__1 = { InsufficientBalance: null } | { InvalidToken: TokenIdentifier } | { Unauthorized: AccountIdentifier } | { Other: string };
export type Extension = string;
export interface Holder {
  balance: bigint;
  account: AccountIdentifier;
}
export interface HoldersRequest {
  offset: [] | [bigint];
  limit: [] | [bigint];
}
export type Memo = Array<number>;
export type Metadata =
  | {
      fungible: {
        decimals: number;
        ownerAccount: AccountIdentifier;
        metadata: [] | [Array<number>];
        name: string;
        symbol: string;
      };
    }
  | { nonfungible: { metadata: [] | [Array<number>] } };
export interface MintRequest {
  to: User;
  amount: Balance;
}
export interface Page {
  content: Array<Holder>;
  offset: bigint;
  limit: bigint;
  totalElements: bigint;
}
export type Result = { ok: bigint } | { err: CommonError };
export type Result_1 = { ok: Balance__1 } | { err: CommonError__1 };
export type Result_2 = { ok: boolean } | { err: CommonError__1 };
export type Result_3 = { ok: Metadata } | { err: CommonError__1 };
export type Result_4 = { ok: string } | { err: CommonError__1 };
export type Result_5 = { ok: Page } | { err: CommonError };
export type Result_6 = { ok: bigint } | { err: CommonError__1 };
export type SubAccount = Array<number>;
export type TokenIdentifier = string;
export interface TransferRequest {
  to: User;
  token: TokenIdentifier;
  notify: boolean;
  from: User;
  memo: Memo;
  subaccount: [] | [SubAccount];
  nonce: [] | [bigint];
  amount: Balance;
}
export type TransferResponse =
  | { ok: Balance }
  | {
      err:
        | { InsufficientAllowance: null }
        | { CannotNotify: AccountIdentifier }
        | { InsufficientBalance: null }
        | { InvalidToken: TokenIdentifier }
        | { Rejected: null }
        | { Unauthorized: AccountIdentifier }
        | { Other: string };
    };
export type User = { principal: Principal } | { address: AccountIdentifier };
export type User__1 = { principal: Principal } | { address: AccountIdentifier };
export default interface _SERVICE {
  allowance: (arg_0: AllowanceRequest) => Promise<Result_1>;
  approve: (arg_0: ApproveRequest) => Promise<Result_2>;
  balance: (arg_0: BalanceRequest) => Promise<BalanceResponse>;
  cycleAvailable: () => Promise<Result_6>;
  cycleBalance: () => Promise<Result_6>;
  extensions: () => Promise<Array<Extension>>;
  getFee: () => Promise<Result_1>;
  getRootBucketId: () => Promise<string>;
  holders: (arg_0: HoldersRequest) => Promise<Result_5>;
  logo: () => Promise<Result_4>;
  metadata: () => Promise<Result_3>;
  mint: (arg_0: MintRequest) => Promise<TransferResponse>;
  registry: () => Promise<Array<[AccountIdentifier__1, Balance__1]>>;
  setFee: (arg_0: Balance__1) => Promise<Result_2>;
  setFeeTo: (arg_0: User__1) => Promise<Result_2>;
  setLogo: (arg_0: string) => Promise<Result_2>;
  supply: () => Promise<Result_1>;
  totalHolders: () => Promise<Result>;
  transfer: (arg_0: TransferRequest) => Promise<TransferResponse>;
  transferFrom: (arg_0: TransferRequest) => Promise<TransferResponse>;
  txSize: () => Promise<bigint>;
}
