export const idlFactory = ({ IDL }) => {
  const Reward = IDL.Variant({ 'Points' : IDL.Nat });
  const CustomValidation = IDL.Record({
    'args' : IDL.Vec(IDL.Nat8),
    'method_name' : IDL.Text,
    'canister' : IDL.Principal,
  });
  const ManualValidation = IDL.Record({
    'moderators' : IDL.Vec(IDL.Principal),
  });
  const AutomaticValidation = IDL.Record({ 'canister' : IDL.Principal });
  const MissionValidation = IDL.Variant({
    'Internal' : IDL.Null,
    'Custom' : CustomValidation,
    'Manual' : ManualValidation,
    'Automatic' : AutomaticValidation,
  });
  const CreateMission = IDL.Record({
    'title' : IDL.Text,
    'description' : IDL.Text,
    'rewards' : IDL.Vec(Reward),
    'restricted' : IDL.Opt(IDL.Vec(IDL.Principal)),
    'url_icon' : IDL.Text,
    'validation' : MissionValidation,
  });
  const Result_2 = IDL.Variant({ 'ok' : IDL.Nat, 'err' : IDL.Text });
  const Result__1_1 = IDL.Variant({ 'ok' : IDL.Null, 'err' : IDL.Text });
  const Result_1 = IDL.Variant({ 'ok' : IDL.Null, 'err' : IDL.Text });
  const GetLogMessagesFilter = IDL.Record({
    'analyzeCount' : IDL.Nat32,
    'messageRegex' : IDL.Opt(IDL.Text),
    'messageContains' : IDL.Opt(IDL.Text),
  });
  const Nanos = IDL.Nat64;
  const GetLogMessagesParameters = IDL.Record({
    'count' : IDL.Nat32,
    'filter' : IDL.Opt(GetLogMessagesFilter),
    'fromTimeNanos' : IDL.Opt(Nanos),
  });
  const GetLatestLogMessagesParameters = IDL.Record({
    'upToTimeNanos' : IDL.Opt(Nanos),
    'count' : IDL.Nat32,
    'filter' : IDL.Opt(GetLogMessagesFilter),
  });
  const CanisterLogRequest = IDL.Variant({
    'getMessagesInfo' : IDL.Null,
    'getMessages' : GetLogMessagesParameters,
    'getLatestMessages' : GetLatestLogMessagesParameters,
  });
  const CanisterLogFeature = IDL.Variant({
    'filterMessageByContains' : IDL.Null,
    'filterMessageByRegex' : IDL.Null,
  });
  const CanisterLogMessagesInfo = IDL.Record({
    'features' : IDL.Vec(IDL.Opt(CanisterLogFeature)),
    'lastTimeNanos' : IDL.Opt(Nanos),
    'count' : IDL.Nat32,
    'firstTimeNanos' : IDL.Opt(Nanos),
  });
  const LogMessagesData = IDL.Record({
    'timeNanos' : Nanos,
    'message' : IDL.Text,
  });
  const CanisterLogMessages = IDL.Record({
    'data' : IDL.Vec(LogMessagesData),
    'lastAnalyzedMessageTimeNanos' : IDL.Opt(Nanos),
  });
  const CanisterLogResponse = IDL.Variant({
    'messagesInfo' : CanisterLogMessagesInfo,
    'messages' : CanisterLogMessages,
  });
  const MetricsGranularity = IDL.Variant({
    'hourly' : IDL.Null,
    'daily' : IDL.Null,
  });
  const GetMetricsParameters = IDL.Record({
    'dateToMillis' : IDL.Nat,
    'granularity' : MetricsGranularity,
    'dateFromMillis' : IDL.Nat,
  });
  const UpdateCallsAggregatedData = IDL.Vec(IDL.Nat64);
  const CanisterHeapMemoryAggregatedData = IDL.Vec(IDL.Nat64);
  const CanisterCyclesAggregatedData = IDL.Vec(IDL.Nat64);
  const CanisterMemoryAggregatedData = IDL.Vec(IDL.Nat64);
  const HourlyMetricsData = IDL.Record({
    'updateCalls' : UpdateCallsAggregatedData,
    'canisterHeapMemorySize' : CanisterHeapMemoryAggregatedData,
    'canisterCycles' : CanisterCyclesAggregatedData,
    'canisterMemorySize' : CanisterMemoryAggregatedData,
    'timeMillis' : IDL.Int,
  });
  const NumericEntity = IDL.Record({
    'avg' : IDL.Nat64,
    'max' : IDL.Nat64,
    'min' : IDL.Nat64,
    'first' : IDL.Nat64,
    'last' : IDL.Nat64,
  });
  const DailyMetricsData = IDL.Record({
    'updateCalls' : IDL.Nat64,
    'canisterHeapMemorySize' : NumericEntity,
    'canisterCycles' : NumericEntity,
    'canisterMemorySize' : NumericEntity,
    'timeMillis' : IDL.Int,
  });
  const CanisterMetricsData = IDL.Variant({
    'hourly' : IDL.Vec(HourlyMetricsData),
    'daily' : IDL.Vec(DailyMetricsData),
  });
  const CanisterMetrics = IDL.Record({ 'data' : CanisterMetricsData });
  const AccountIdentifier = IDL.Text;
  const TokenIdentifier__1 = IDL.Text;
  const Job = IDL.Record({
    'interval' : IDL.Int,
    'method_name' : IDL.Text,
    'canister' : IDL.Principal,
    'last_time' : IDL.Int,
  });
  const Name = IDL.Text;
  const TokenIdentifier = IDL.Text;
  const StyleScore = IDL.Nat;
  const EngagementScore = IDL.Nat;
  const TotalScore = IDL.Nat;
  const Leaderboard__1 = IDL.Vec(
    IDL.Tuple(
      IDL.Principal,
      IDL.Opt(Name),
      IDL.Opt(TokenIdentifier),
      IDL.Opt(StyleScore),
      IDL.Opt(EngagementScore),
      TotalScore,
    )
  );
  const MissionStatus = IDL.Variant({
    'Ended' : IDL.Null,
    'Running' : IDL.Null,
    'Pending' : IDL.Null,
  });
  const Time = IDL.Int;
  const Mission = IDL.Record({
    'id' : IDL.Nat,
    'status' : MissionStatus,
    'title' : IDL.Text,
    'creator' : IDL.Principal,
    'description' : IDL.Text,
    'created_at' : Time,
    'rewards' : IDL.Vec(Reward),
    'restricted' : IDL.Opt(IDL.Vec(IDL.Principal)),
    'url_icon' : IDL.Text,
    'ended_at' : IDL.Opt(Time),
    'validation' : MissionValidation,
    'started_at' : IDL.Opt(Time),
  });
  const Leaderboard = IDL.Vec(
    IDL.Tuple(
      IDL.Principal,
      IDL.Opt(Name),
      IDL.Opt(TokenIdentifier),
      IDL.Opt(StyleScore),
      IDL.Opt(EngagementScore),
      TotalScore,
    )
  );
  const Round = IDL.Record({
    'id' : IDL.Nat,
    'leaderboard' : IDL.Opt(Leaderboard),
    'end_date' : IDL.Opt(Time),
    'start_date' : Time,
  });
  const Result__1 = IDL.Variant({ 'ok' : IDL.Nat, 'err' : IDL.Text });
  const Result = IDL.Variant({ 'ok' : IDL.Bool, 'err' : IDL.Text });
  const ICPSquadHub = IDL.Service({
    'acceptCycles' : IDL.Func([], [], []),
    'add_admin' : IDL.Func([IDL.Principal], [], []),
    'add_job' : IDL.Func([IDL.Principal, IDL.Text, IDL.Int], [], []),
    'availableCycles' : IDL.Func([], [IDL.Nat], ['query']),
    'collectCanisterMetrics' : IDL.Func([], [], []),
    'create_mission' : IDL.Func([CreateMission], [Result_2], []),
    'cron_round' : IDL.Func([], [Result__1_1], []),
    'cron_style_score' : IDL.Func([], [], []),
    'delete_job' : IDL.Func([IDL.Nat], [], []),
    'delete_mission' : IDL.Func([IDL.Nat], [Result_1], []),
    'fix' : IDL.Func([], [], []),
    'getCanisterLog' : IDL.Func(
        [IDL.Opt(CanisterLogRequest)],
        [IDL.Opt(CanisterLogResponse)],
        ['query'],
      ),
    'getCanisterMetrics' : IDL.Func(
        [GetMetricsParameters],
        [IDL.Opt(CanisterMetrics)],
        ['query'],
      ),
    'get_holders' : IDL.Func(
        [],
        [
          IDL.Vec(
            IDL.Tuple(
              AccountIdentifier,
              IDL.Nat,
              IDL.Opt(IDL.Principal),
              IDL.Opt(IDL.Text),
              IDL.Opt(IDL.Text),
              IDL.Opt(TokenIdentifier__1),
            )
          ),
        ],
        [],
      ),
    'get_jobs' : IDL.Func([], [IDL.Vec(IDL.Tuple(IDL.Nat, Job))], ['query']),
    'get_leaderboard' : IDL.Func([], [IDL.Opt(Leaderboard__1)], ['query']),
    'get_missions' : IDL.Func([], [IDL.Vec(Mission)], ['query']),
    'get_round' : IDL.Func([], [IDL.Opt(Round)], ['query']),
    'is_admin' : IDL.Func([IDL.Principal], [IDL.Bool], ['query']),
    'my_completed_missions' : IDL.Func(
        [],
        [IDL.Vec(IDL.Tuple(IDL.Nat, Time))],
        [],
      ),
    'reset_score' : IDL.Func([], [], []),
    'set_job_status' : IDL.Func([IDL.Bool], [], []),
    'start_mission' : IDL.Func([IDL.Nat], [Result_1], []),
    'start_round' : IDL.Func([], [Result__1], []),
    'stop_round' : IDL.Func([], [Result__1], []),
    'verify_mission' : IDL.Func([IDL.Nat], [Result], []),
  });
  return ICPSquadHub;
};
export const init = ({ IDL }) => {
  return [IDL.Principal, IDL.Principal, IDL.Principal, IDL.Principal];
};
