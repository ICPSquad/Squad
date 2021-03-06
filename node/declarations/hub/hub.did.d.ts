import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';

export type AccountIdentifier = string;
export interface AutomaticValidation { 'canister' : Principal }
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
export interface Collection { 'name' : string, 'contractId' : Principal }
export interface CreateMission {
  'title' : string,
  'tags' : Array<string>,
  'description' : string,
  'restricted' : [] | [Array<Principal>],
  'url_icon' : string,
  'validation' : MissionValidation,
  'points' : bigint,
}
export interface CustomValidation {
  'args' : Array<number>,
  'method_name' : string,
  'canister' : Principal,
}
export interface DailyMetricsData {
  'updateCalls' : bigint,
  'canisterHeapMemorySize' : NumericEntity,
  'canisterCycles' : NumericEntity,
  'canisterMemorySize' : NumericEntity,
  'timeMillis' : bigint,
}
export type EngagementScore = bigint;
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
  'acceptCycles' : ActorMethod<[], undefined>,
  'add_admin' : ActorMethod<[Principal], undefined>,
  'add_job' : ActorMethod<[Principal, string, bigint], undefined>,
  'availableCycles' : ActorMethod<[], bigint>,
  'collectCanisterMetrics' : ActorMethod<[], undefined>,
  'create_mission' : ActorMethod<[CreateMission], Result_1>,
  'cron_events' : ActorMethod<[], Result_1>,
  'cron_round' : ActorMethod<[], Result__1_1>,
  'cron_style_score' : ActorMethod<[], undefined>,
  'delete_job' : ActorMethod<[bigint], undefined>,
  'delete_mission' : ActorMethod<[bigint], Result_2>,
  'getCanisterLog' : ActorMethod<
    [[] | [CanisterLogRequest]],
    [] | [CanisterLogResponse],
  >,
  'getCanisterMetrics' : ActorMethod<
    [GetMetricsParameters],
    [] | [CanisterMetrics],
  >,
  'get_all_operations' : ActorMethod<[], Array<[string, bigint]>>,
  'get_holders' : ActorMethod<
    [],
    Array<
      [
        AccountIdentifier,
        bigint,
        [] | [Principal],
        [] | [string],
        [] | [string],
        [] | [TokenIdentifier__1],
      ]
    >,
  >,
  'get_jobs' : ActorMethod<[], Array<[bigint, Job]>>,
  'get_leaderboard' : ActorMethod<[], [] | [Leaderboard__1]>,
  'get_missions' : ActorMethod<[], Array<Mission>>,
  'get_number_operations' : ActorMethod<
    [Principal, Array<string>, [] | [Array<Principal>]],
    bigint,
  >,
  'get_round' : ActorMethod<[], [] | [Round]>,
  'get_stats_sales' : ActorMethod<
    [Principal, [] | [Array<Principal>], [] | [Time], [] | [Time]],
    Result_3,
  >,
  'is_admin' : ActorMethod<[Principal], boolean>,
  'manually_add_winners' : ActorMethod<[bigint, Array<Principal>], Result_2>,
  'my_completed_missions' : ActorMethod<[], Array<[bigint, Time]>>,
  'register_all_collections' : ActorMethod<[], Result_2>,
  'register_collection' : ActorMethod<[Collection], Result_2>,
  'set_job_status' : ActorMethod<[boolean], undefined>,
  'start_mission' : ActorMethod<[bigint], Result_2>,
  'start_round' : ActorMethod<[], Result__1>,
  'stop_mission' : ActorMethod<[bigint], Result_2>,
  'stop_round' : ActorMethod<[], Result__1>,
  'update_user_interacted_collections' : ActorMethod<[Principal], Result_1>,
  'verify_mission' : ActorMethod<[bigint], Result>,
}
export interface Job {
  'interval' : bigint,
  'method_name' : string,
  'canister' : Principal,
  'last_time' : bigint,
}
export type Leaderboard = Array<
  [
    Principal,
    [] | [Name],
    [] | [TokenIdentifier],
    [] | [StyleScore],
    [] | [EngagementScore],
    TotalScore,
  ]
>;
export type Leaderboard__1 = Array<
  [
    Principal,
    [] | [Name],
    [] | [TokenIdentifier],
    [] | [StyleScore],
    [] | [EngagementScore],
    TotalScore,
  ]
>;
export interface LogMessagesData { 'timeNanos' : Nanos, 'message' : string }
export interface ManualValidation { 'moderators' : Array<Principal> }
export type MetricsGranularity = { 'hourly' : null } |
  { 'daily' : null };
export interface Mission {
  'id' : bigint,
  'status' : MissionStatus,
  'title' : string,
  'tags' : Array<string>,
  'description' : string,
  'created_at' : Time,
  'restricted' : [] | [Array<Principal>],
  'url_icon' : string,
  'ended_at' : [] | [Time],
  'validation' : MissionValidation,
  'started_at' : [] | [Time],
  'points' : bigint,
}
export type MissionStatus = { 'Ended' : null } |
  { 'Running' : null } |
  { 'Pending' : null };
export type MissionValidation = { 'Internal' : null } |
  { 'Custom' : CustomValidation } |
  { 'Manual' : ManualValidation } |
  { 'Automatic' : AutomaticValidation };
export type Name = string;
export type Nanos = bigint;
export interface NumericEntity {
  'avg' : bigint,
  'max' : bigint,
  'min' : bigint,
  'first' : bigint,
  'last' : bigint,
}
export type Result = { 'ok' : boolean } |
  { 'err' : string };
export type Result_1 = { 'ok' : bigint } |
  { 'err' : string };
export type Result_2 = { 'ok' : null } |
  { 'err' : string };
export type Result_3 = { 'ok' : [bigint, bigint] } |
  { 'err' : string };
export type Result__1 = { 'ok' : bigint } |
  { 'err' : string };
export type Result__1_1 = { 'ok' : null } |
  { 'err' : string };
export interface Round {
  'id' : bigint,
  'leaderboard' : [] | [Leaderboard],
  'end_date' : [] | [Time],
  'start_date' : Time,
}
export type StyleScore = bigint;
export type Time = bigint;
export type TokenIdentifier = string;
export type TokenIdentifier__1 = string;
export type TotalScore = bigint;
export type UpdateCallsAggregatedData = Array<bigint>;
export interface _SERVICE extends ICPSquadHub {}
