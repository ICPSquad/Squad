export const idlFactory = ({ IDL }) => {
  const DetailValue = IDL.Rec();
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
    'tags' : IDL.Vec(IDL.Text),
    'description' : IDL.Text,
    'restricted' : IDL.Opt(IDL.Vec(IDL.Principal)),
    'url_icon' : IDL.Text,
    'validation' : MissionValidation,
    'points' : IDL.Nat,
  });
  const Result_2 = IDL.Variant({ 'ok' : IDL.Nat, 'err' : IDL.Text });
  const Result_1 = IDL.Variant({ 'ok' : IDL.Null, 'err' : IDL.Text });
  const Result__1_1 = IDL.Variant({ 'ok' : IDL.Null, 'err' : IDL.Text });
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
  const Collection__1 = IDL.Record({
    'name' : IDL.Text,
    'contractId' : IDL.Principal,
  });
  DetailValue.fill(
    IDL.Variant({
      'I64' : IDL.Int64,
      'U64' : IDL.Nat64,
      'Vec' : IDL.Vec(DetailValue),
      'Slice' : IDL.Vec(IDL.Nat8),
      'Text' : IDL.Text,
      'True' : IDL.Null,
      'False' : IDL.Null,
      'Float' : IDL.Float64,
      'Principal' : IDL.Principal,
    })
  );
  const Event = IDL.Record({
    'time' : IDL.Nat64,
    'operation' : IDL.Text,
    'details' : IDL.Vec(IDL.Tuple(IDL.Text, DetailValue)),
    'caller' : IDL.Principal,
  });
  const MissionStatus = IDL.Variant({
    'Ended' : IDL.Null,
    'Running' : IDL.Null,
    'Pending' : IDL.Null,
  });
  const Time = IDL.Int;
  const Mission__1 = IDL.Record({
    'id' : IDL.Nat,
    'status' : MissionStatus,
    'title' : IDL.Text,
    'tags' : IDL.Vec(IDL.Text),
    'description' : IDL.Text,
    'created_at' : Time,
    'restricted' : IDL.Opt(IDL.Vec(IDL.Principal)),
    'url_icon' : IDL.Text,
    'ended_at' : IDL.Opt(Time),
    'validation' : MissionValidation,
    'started_at' : IDL.Opt(Time),
    'points' : IDL.Nat,
  });
  const Activity = IDL.Record({
    'buy' : IDL.Tuple(IDL.Nat, IDL.Nat),
    'burn' : IDL.Nat,
    'mint' : IDL.Nat,
    'sell' : IDL.Tuple(IDL.Nat, IDL.Nat),
    'collection_involved' : IDL.Nat,
    'accessory_minted' : IDL.Nat,
    'accessory_burned' : IDL.Nat,
  });
  const Date = IDL.Tuple(IDL.Nat, IDL.Nat, IDL.Nat);
  const ExtendedEvent = IDL.Record({
    'collection' : IDL.Principal,
    'time' : IDL.Nat64,
    'operation' : IDL.Text,
    'details' : IDL.Vec(IDL.Tuple(IDL.Text, DetailValue)),
    'caller' : IDL.Principal,
  });
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
  const Mission = IDL.Record({
    'id' : IDL.Nat,
    'status' : MissionStatus,
    'title' : IDL.Text,
    'tags' : IDL.Vec(IDL.Text),
    'description' : IDL.Text,
    'created_at' : Time,
    'restricted' : IDL.Opt(IDL.Vec(IDL.Principal)),
    'url_icon' : IDL.Text,
    'ended_at' : IDL.Opt(Time),
    'validation' : MissionValidation,
    'started_at' : IDL.Opt(Time),
    'points' : IDL.Nat,
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
  const Collection = IDL.Record({
    'name' : IDL.Text,
    'contractId' : IDL.Principal,
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
    'cron_activity' : IDL.Func([], [Result_1], []),
    'cron_events' : IDL.Func([], [Result_2], []),
    'cron_round' : IDL.Func([], [Result__1_1], []),
    'cron_stats' : IDL.Func([], [Result_1], []),
    'cron_style_score' : IDL.Func([], [], []),
    'cron_users' : IDL.Func([], [Result_1], []),
    'delete_job' : IDL.Func([IDL.Nat], [], []),
    'delete_mission' : IDL.Func([IDL.Nat], [Result_1], []),
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
    'get_all_collections' : IDL.Func(
        [],
        [IDL.Vec(IDL.Tuple(Collection__1, IDL.Principal))],
        ['query'],
      ),
    'get_all_daily_events' : IDL.Func(
        [],
        [IDL.Vec(IDL.Tuple(IDL.Principal, IDL.Vec(Event)))],
        [],
      ),
    'get_completed_missions' : IDL.Func(
        [IDL.Principal],
        [IDL.Vec(IDL.Tuple(Mission__1, Time))],
        ['query'],
      ),
    'get_cumulative_activity' : IDL.Func(
        [IDL.Principal, IDL.Opt(Time), IDL.Opt(Time)],
        [Activity],
        ['query'],
      ),
    'get_daily_activity' : IDL.Func(
        [IDL.Principal, Date],
        [IDL.Opt(Activity)],
        ['query'],
      ),
    'get_daily_events_user' : IDL.Func(
        [IDL.Principal],
        [IDL.Vec(ExtendedEvent)],
        [],
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
    'get_leaderboard_simplified' : IDL.Func(
        [IDL.Nat],
        [IDL.Opt(IDL.Vec(IDL.Tuple(IDL.Principal, IDL.Nat)))],
        ['query'],
      ),
    'get_missions' : IDL.Func([], [IDL.Vec(Mission)], ['query']),
    'get_round' : IDL.Func([], [IDL.Opt(Round)], ['query']),
    'is_admin' : IDL.Func([IDL.Principal], [IDL.Bool], ['query']),
    'manually_add_winners' : IDL.Func(
        [IDL.Nat, IDL.Vec(IDL.Principal)],
        [Result_1],
        [],
      ),
    'my_completed_missions' : IDL.Func(
        [],
        [IDL.Vec(IDL.Tuple(IDL.Nat, Time))],
        ['query'],
      ),
    'register_collection' : IDL.Func([Collection], [Result_1], []),
    'set_job_status' : IDL.Func([IDL.Bool], [], []),
    'start_mission' : IDL.Func([IDL.Nat], [Result_1], []),
    'start_round' : IDL.Func([], [Result__1], []),
    'stop_mission' : IDL.Func([IDL.Nat], [Result_1], []),
    'stop_round' : IDL.Func([], [Result__1], []),
    'verify_mission' : IDL.Func([IDL.Nat], [Result], []),
  });
  return ICPSquadHub;
};
export const init = ({ IDL }) => {
  return [IDL.Principal, IDL.Principal, IDL.Principal, IDL.Principal];
};
