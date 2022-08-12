import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';

export type AccountIdentifier = string;
export interface Activity {
  'buy' : [bigint, bigint],
  'burn' : bigint,
  'mint' : bigint,
  'sell' : [bigint, bigint],
  'collection_involved' : bigint,
  'accessory_minted' : bigint,
  'accessory_burned' : bigint,
}
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
export interface Collection__1 { 'name' : string, 'contractId' : Principal }
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
export type Date = [bigint, bigint, bigint];
export type DetailValue = { 'I64' : bigint } |
  { 'U64' : bigint } |
  { 'Vec' : Array<DetailValue> } |
  { 'Slice' : Array<number> } |
  { 'Text' : string } |
  { 'True' : null } |
  { 'False' : null } |
  { 'Float' : number } |
  { 'Principal' : Principal };
export type EngagementScore = bigint;
export interface Event {
  'time' : bigint,
  'operation' : string,
  'details' : Array<[string, DetailValue]>,
  'caller' : Principal,
}
export interface ExtendedEvent {
  'collection' : Principal,
  'time' : bigint,
  'operation' : string,
  'details' : Array<[string, DetailValue]>,
  'caller' : Principal,
}
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
  'create_mission' : ActorMethod<[CreateMission], Result_2>,
  'cron_activity' : ActorMethod<[], Result_1>,
  'cron_events' : ActorMethod<[], Result_2>,
  'cron_round' : ActorMethod<[], Result__1_1>,
  'cron_stats' : ActorMethod<[], Result_1>,
  'cron_style_score' : ActorMethod<[], undefined>,
  'cron_users' : ActorMethod<[], Result_1>,
  'delete_job' : ActorMethod<[bigint], undefined>,
  'delete_mission' : ActorMethod<[bigint], Result_1>,
  'getCanisterLog' : ActorMethod<
    [[] | [CanisterLogRequest]],
    [] | [CanisterLogResponse],
  >,
  'getCanisterMetrics' : ActorMethod<
    [GetMetricsParameters],
    [] | [CanisterMetrics],
  >,
  'get_all_collections' : ActorMethod<[], Array<[Collection__1, Principal]>>,
  'get_all_daily_events' : ActorMethod<[], Array<[Principal, Array<Event>]>>,
  'get_completed_missions' : ActorMethod<
    [Principal],
    Array<[Mission__1, Time]>,
  >,
  'get_cumulative_activity' : ActorMethod<
    [Principal, [] | [Time], [] | [Time]],
    Activity,
  >,
  'get_daily_activity' : ActorMethod<[Principal, Date], [] | [Activity]>,
  'get_daily_events_user' : ActorMethod<[Principal], Array<ExtendedEvent>>,
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
  'get_leaderboard' : ActorMethod<[], [] | [Leaderboard]>,
  'get_leaderboard_simplified' : ActorMethod<
    [bigint],
    [] | [Array<[Principal, bigint]>],
  >,
  'get_missions' : ActorMethod<[], Array<Mission>>,
  'get_round' : ActorMethod<[], [] | [Round]>,
  'get_specified_leaderboard' : ActorMethod<[bigint], [] | [Leaderboard]>,
  'is_admin' : ActorMethod<[Principal], boolean>,
  'is_collection_integrated' : ActorMethod<[Principal], boolean>,
  'manually_add_winners' : ActorMethod<[bigint, Array<Principal>], Result_1>,
  'my_completed_missions' : ActorMethod<[], Array<[bigint, Time]>>,
  'register_all_collections' : ActorMethod<[], Result_1>,
  'register_collection' : ActorMethod<[Collection], Result_1>,
  'set_job_status' : ActorMethod<[boolean], undefined>,
  'start_mission' : ActorMethod<[bigint], Result_1>,
  'start_round' : ActorMethod<[], Result__1>,
  'stop_mission' : ActorMethod<[bigint], Result_1>,
  'stop_round' : ActorMethod<[], Result__1>,
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
export interface Mission__1 {
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
export type Result_1 = { 'ok' : null } |
  { 'err' : string };
export type Result_2 = { 'ok' : bigint } |
  { 'err' : string };
export type Result__1 = { 'ok' : bigint } |
  { 'err' : string };
export type Result__1_1 = { 'ok' : null } |
  { 'err' : string };
export interface Round {
  'id' : bigint,
  'leaderboard' : [] | [Leaderboard__1],
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
