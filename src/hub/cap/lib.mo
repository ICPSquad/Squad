import Array "mo:base/Array";
import Buffer "mo:base/Buffer";
import Error "mo:base/Error";
import Hash "mo:base/Hash";
import ITer "mo:base/Float";
import Int "mo:base/Int";
import Iter "mo:base/Iter";
import Nat "mo:base/Nat";
import Nat32 "mo:base/Nat32";
import Nat64 "mo:base/Nat64";
import Prim "mo:prim";
import Principal "mo:base/Principal";
import Text "mo:base/Text";
import Time "mo:base/Time";
import Result "mo:base/Result";
import TrieMap "mo:base/TrieMap";

import AccountIdentifier "mo:principal/AccountIdentifier";
import DateModule "mo:canistergeek/dateModule";
import Ext "mo:ext/Ext";

import Collection "../collection";
import Types "types";
module {

  public type UpgradeData = Types.UpgradeData;
  public type Event = Types.Event;
  public type ExtendedEvent = Types.ExtendedEvent;
  public type CapStats = Types.CapStats;
  public type Activity = Types.Activity;
  public type Collection = Collection.Collection;
  public type Date = (Nat, Nat, Nat);

  /////////////////
  // Utilities ///
  ///////////////

  func _dateEqual(date1 : Date, date2 : Date) : Bool {
    return date1.0 == date2.0 and date1.1 == date2.1 and date1.2 == date2.2;
  };

  func _dateHash(date : Date) : Hash.Hash {
    return Int.hash(date.0 * 100 + date.1 * 10 + date.2);
  };

  public func customEqual(a : (Date, Principal), b : (Date, Principal)) : Bool {
    return _dateEqual(a.0, b.0) and Principal.equal(a.1, b.1);
  };

  public func customHash(a : (Date, Principal)) : Hash.Hash {
    return _dateHash(a.0) ^ Principal.hash(a.1);
  };

  public func tupplePrincipalEqual(a : (Principal, Principal), b : (Principal, Principal)) : Bool {
    return Principal.equal(a.0, b.0) and Principal.equal(a.1, b.1);
  };

  public func tupplePrincipalHash(a : (Principal, Principal)) : Hash.Hash {
    return Principal.hash(a.0) ^ Principal.hash(a.1);
  };

  public class Factory(dependencies : Types.Dependencies) {

    //////////////
    /// State ///
    ////////////

    let BEGIN_TIME : Time.Time = 1655729084018865799;
    //(2022-06-20) ISO 8601
    let DAY_NANO = 24 * 60 * 60 * 1000 * 1000 * 1000;
    // 24 hours in nanoseconds

    let AVATAR_ACTOR = actor (Principal.toText(dependencies.cid_avatar)) : actor {
      get_infos_leaderboard : shared () -> async [(Principal, ?Text, ?Text)];
      get_infos_accounts : shared () -> async [(Principal, Ext.AccountIdentifier)];
    };

    let _Logs = dependencies._Logs;

    let bucket_accessory : Types.Bucket = actor (Principal.toText(dependencies.cid_bucket_accessory));
    let bucket_avatar : Types.Bucket = actor (Principal.toText(dependencies.cid_bucket_avatar));
    let cap_router : Types.Router = actor (Principal.toText(dependencies.cid_router));
    let dab : Types.Dab = actor (Principal.toText(dependencies.cid_dab));

    /* Recorded collection associated with their root bucket */
    let cids : TrieMap.TrieMap<Collection, Principal> = TrieMap.TrieMap<Collection, Principal>(Collection.equal, Collection.hash);

    public func entriesCids() : [(Collection, Principal)] {
      Iter.toArray(cids.entries());
    };

    /* Events recorded for an user */
    let events : TrieMap.TrieMap<(Date, Principal), [ExtendedEvent]> = TrieMap.TrieMap<(Date, Principal), [ExtendedEvent]>(customEqual, customHash);

    public func entriesEvents() : [((Date, Principal), [ExtendedEvent])] {
      Iter.toArray(events.entries());
    };

    /* Calculated scores to save cycles on computation */
    let scores : TrieMap.TrieMap<(Date, Principal), Nat> = TrieMap.TrieMap<(Date, Principal), Nat>(customEqual, customHash);

    public func entriesScores() : [((Date, Principal), Nat)] {
      Iter.toArray(scores.entries());
    };

    /* Cached events sorted per collection .*/
    let cached_events_per_collection : TrieMap.TrieMap<Principal, [Event]> = TrieMap.TrieMap<Principal, [Event]>(Principal.equal, Principal.hash);

    public func entriesCachedEventsPerCollections() : [(Principal, [Event])] {
      Iter.toArray(cached_events_per_collection.entries());
    };

    /* Cached events sorted per user . */
    let cached_events_per_user : TrieMap.TrieMap<Principal, Buffer.Buffer<ExtendedEvent>> = TrieMap.TrieMap<Principal, Buffer.Buffer<ExtendedEvent>>(Principal.equal, Principal.hash);

    public func entriesCachedEventsPerUser() : [(Principal, Buffer.Buffer<ExtendedEvent>)] {
      Iter.toArray(cached_events_per_user.entries());
    };

    public func preupgrade() : UpgradeData {
      return (
        {
          cids = Iter.toArray(cids.entries());
          events = Iter.toArray(events.entries());
          scores = Iter.toArray(scores.entries());
        },
      );
    };

    public func postupgrade(ud : ?UpgradeData) : () {
      switch (ud) {
        case (null) {};
        case (?ud) {
          for ((collection, cid) in ud.cids.vals()) {
            cids.put(collection, cid);
          };
          for (((date, principal), events_date) in ud.events.vals()) {
            events.put((date, principal), events_date);
          };
          for (((date, principal), score) in ud.scores.vals()) {
            scores.put((date, principal), score);
          };
        };
      };
    };

    ///////////
    // CRON //
    //////////

    public func cronEvents() : async Result.Result<(), Text> {
      var total : Nat = 0;
      for ((collection, cid) in cids.entries()) {
        try {
          let daily_events = await _getDailyEvents(cid);
          total += daily_events.size();
          cached_events_per_collection.put(cid, daily_events);
          _Logs.logMessage("CRON :: STATS :: " # collection.name # " :: " # Nat.toText(daily_events.size()));
        } catch e {
          _Logs.logMessage("CRON :: ERR :: " # collection.name # " :: " # Error.message(e));
          return #err(Error.message(e));
        };
      };
      return #ok();
    };

    public func cronUsers() : async Result.Result<(), Text> {
      // Query necessary informations to get a list of Principals and associated AccountIdentifier.
      let infos = await AVATAR_ACTOR.get_infos_accounts();
      let r : TrieMap.TrieMap<Ext.AccountIdentifier, Principal> = TrieMap.TrieMap<Ext.AccountIdentifier, Principal>(Text.equal, Text.hash);
      for (info in infos.vals()) {
        r.put(info.1, info.0);
      };
      // Utility function returning a Boolean indicating if a Principal is among our users.
      let is_user = func(p : Principal) : Bool {
        switch (Array.find<Principal>(Iter.toArray(r.vals()), func(x) { Principal.equal(p, x) })) {
          case (?some) { return true };
          case (null) { return false };
        };
      };
      // Used to keep track of the number of recorded events from our users.
      var total_operations_recorded : Nat = 0;
      // Used to assign events to users and increment the total number of recorded events.
      let f = func(e : ExtendedEvent) : () {
        switch (e.operation) {
          case ("sale") {
            let { to; from } = _saleDetails(e);
            switch (r.get(to)) {
              case (null) {};
              case (?p) {
                total_operations_recorded += 1;
                if (Principal.equal(p, Principal.fromText("udmjf-fyc6j-f7dnl-dw5bh-hh4wg-ln7iy-36pgp-mjocm-my4vc-r2irg-2ae"))) {
                  _Logs.logMessage("1");
                };
                _cacheEventUser(p, e);
              };
            };
            switch (r.get(from)) {
              case (null) {};
              case (?p) {
                total_operations_recorded += 1;
                _cacheEventUser(p, e);
              };
            };
          };
          case ("mint") {
            let p = e.caller;
            if (is_user(p)) {
              total_operations_recorded += 1;
              _cacheEventUser(p, e);
            };
          };
          case ("burn") {
            // TODO : hedge case if the burn event comes from our collection!
            if (e.collection == Principal.fromText("po6n2-uiaaa-aaaaj-qaiua-cai")) {
              let burner = _getBurner(e);
              switch (r.get(burner)) {
                case (null) {
                  _Logs.logMessage("WARNING :: " # "no account responsible for burn event was found ");
                };
                case (?p) {
                  total_operations_recorded += 1;
                  _cacheEventUser(p, e);
                };
              };
            } else {
              let user = e.caller;
              if (is_user(user)) {
                total_operations_recorded += 1;
                _cacheEventUser(user, e);
              };
            };
          };
          case ("transfer") {};
          case ("approve") {};
          case ("transferFrom") {};
          case ("approveFrom") {};
          case _ {
            _Logs.logMessage("WARNING :: " # "unknown operation " # e.operation);
          };
        };
      };

      let events = _getExtendedEventsDaily();
      for (event in events.vals()) {
        f(event);
      };
      _Logs.logMessage("CRON :: total of events : " # Nat.toText(events.size()) # " recorded : " # Nat.toText(total_operations_recorded));
      return #ok();
    };

    public func cronClean() : Result.Result<(), Text> {
      for ((p, cached) in cached_events_per_user.entries()) {
        let cached_events = cached.toArray();
        for (e in cached_events.vals()) {
          let date = switch (DateModule.Date.toDatePartsISO8601(Nat64.toNat(e.time * 1_000_000))) {
            case (null) {
              _Logs.logMessage("WARNING :: " # "unable to parse date " # Nat64.toText(e.time));
              return #err("Unable to parse date : " # Nat64.toText(e.time));
            };
            case (?date_parts) {
              date_parts;
            };
          };
          switch (events.get((date, p))) {
            case (null) {
              events.put((date, p), [e]);
            };
            case (?some) {
              // Check that the event is not already contained in the list to avoid doublons.
              if (not _isEventContained(e, some)) {
                events.put((date, p), Array.append<ExtendedEvent>(some, [e]));
              };
            };
          };
        };
      };
      // Reinitialize caches
      _emptyCacheCollection();
      _emptyCacheUsers();
      return #ok();
    };

    var last_date_cron : ?Date = null;
    public func cronScores() : async Result.Result<(), Text> {
      let current_date = switch (DateModule.Date.toDatePartsISO8601(Time.now())) {
        case (null) {
          _Logs.logMessage("ERR :: " # "unable to parse date " # Int.toText(Time.now()));
          return #err("Unable to parse date : " # Int.toText(Time.now()));
        };
        case (?date_parts) {
          date_parts;
        };
      };
      switch (last_date_cron) {
        case (null) {
          _Logs.logMessage("CRON :: STATS :: " # "settling scores for the first time");
        };
        case (?last_date_cron) {
          if (not _dateEqual(current_date, last_date_cron)) {
            switch (await _calculateScores(last_date_cron)) {
              case (#err(_)) {
                return #err("Unable to calculate scores from previous day");
              };
              case (#ok) {
                _Logs.logMessage("CRON :: STATS :: " # "scores settled from past day");
              };
            };
          };
        };
      };
      switch (await _calculateScores(current_date)) {
        case (#err(_)) {
          return #err("Unable to calculate scores from current day");
        };
        case (#ok) {
          _Logs.logMessage("CRON :: STATS :: " # "scores settled from current day");
          last_date_cron := ?current_date;
          return #ok();
        };
      };
    };

    ////////////////////////////
    // CONFIG & REGISTRATION //
    ///////////////////////////

    public func registerCollection(collection : Collection) : async Result.Result<(), Text> {
      let cid = collection.contractId;
      try {
        let result = await cap_router.get_token_contract_root_bucket(
          {
            canister = cid;
            witness = false;
          },
        );
        switch (result.canister) {
          case (?cid_bucket) {
            cids.put(collection, cid_bucket);
          };
          case (null) {
            return #err("ERR :: no bucket to register found");
          };
        };
      } catch e {
        return #err(Error.message(e));
      };
      return #ok();
    };

    public func registerAllCollections() : async Result.Result<(), Text> {
      let collections : [Types.NFT_CANISTER] = await dab.get_all();
      for (collection in collections.vals()) {
        let obj : Collection = {
          name = collection.name;
          contractId = collection.principal_id;
        };
        // Check that the collection is not already registered!
        switch (cids.get(obj)) {
          case (?some) {};
          case (null) {
            try {
              switch (await registerCollection(obj)) {
                case (#ok()) {
                  _Logs.logMessage("CONFIG :: new collection registered :: NAME :  " # obj.name # " :: CONTRACT ID : " # Principal.toText(obj.contractId));
                };
                case (#err(e)) {
                  _Logs.logMessage("ERR :: no bucket found for : " # obj.name);
                };
              };
            } catch e {
              _Logs.logMessage("ERR :: trying to register a collection :: " # Error.message(e));
            };
          };
        };
      };
      return #ok();
    };

    public func isCollectionIntegrated(p : Principal) : Bool {
      for (collection in cids.keys()) {
        if (collection.contractId == p) {
          return true;
        };
      };
      return false;
    };

    ///////////////////////////////
    ////    API & MISSIONS  //////
    /////////////////////////////

    /* Returns the total engagement score of the principal between T1 & T2 */
    public func getScore(p : Principal, t1 : ?Time.Time, t2 : ?Time.Time) : Nat {
      let dates = _getDatesBetween(t1, t2);
      var total : Nat = 0;
      for (date in dates.vals()) {
        switch (scores.get((date, p))) {
          case (null) {};
          case (?some) {
            total += some;
          };
        };
      };
      total;
    };

    /*  */
    public func getNumberCollectionsInteracted(p : Principal, t1 : ?Time.Time, t2 : ?Time.Time) : Nat {
      let dates = _getDatesBetween(t1, t2);
      var total : Nat = 0;
      let r : Buffer.Buffer<ExtendedEvent> = Buffer.Buffer<ExtendedEvent>(0);
      for (date in dates.vals()) {
        switch (events.get(date, p)) {
          case (null) {};
          case (?some) {
            // Add all events into the buffer
            for (e in some.vals()) {
              r.add(e);
            };
          };
        };
      };
      let collections = _getCollectionsInteracted(r.toArray());
      collections.size();
    };

    public func getDailyEvents(p : Principal, date : Date) : ?[ExtendedEvent] {
      switch (events.get(date, p)) {
        case (null) {
          return null;
        };
        case (?some) {
          return ?some;
        };
      };
    };

    public func getDailyScore(p : Principal, date : Date) : ?Nat {
      switch (scores.get(date, p)) {
        case (null) {
          return null;
        };
        case (?some) {
          return ?some;
        };
      };
    };

    public func getDailyActivity(p : Principal, date : Date) : ?Activity {
      switch (events.get((date, p))) {
        case (null) {
          return null;
        };
        case (?some) {
          return ?_getActivity(some, p);
        };
      };
    };

    /////////////////
    //  MISSIONS  //
    ///////////////

    public func numberMintAccessory(
      p : Principal,
      t1 : ?Time.Time,
      t2 : ?Time.Time,
    ) : Nat {
      var total : Nat = 0;
      let dates = _getDatesBetween(t1, t2);
      for (date in dates.vals()) {
        switch (events.get(date, p)) {
          case (null) {};
          case (?list_events) {
            for (e in list_events.vals()) {
              if (_isEventMintAccessory(e)) {
                total += 1;
              };
            };
          };
        };
      };
      total;
    };

    public func numberBurnAccessory(
      p : Principal,
      t1 : ?Time.Time,
      t2 : ?Time.Time,
    ) : Nat {
      var total : Nat = 0;
      let dates = _getDatesBetween(t1, t2);
      for (date in dates.vals()) {
        switch (events.get(date, p)) {
          case (null) {};
          case (?list_events) {
            for (e in list_events.vals()) {
              if (_isEventBurnAccessory(e)) {
                total += 1;
              };
            };
          };
        };
      };
      total;
    };

    /////////////////
    //    FIX     //
    ///////////////

    public func populateEvents(
      p : Principal,
      collected_events : [ExtendedEvent],
    ) : Result.Result<(), Text> {
      let r = TrieMap.TrieMap<Date, [ExtendedEvent]>(_dateEqual, _dateHash);
      for (e in collected_events.vals()) {
        let date = _getDate(e);
        switch (r.get(date)) {
          case (null) {
            r.put(date, [e]);
          };
          case (?some) {
            r.put(date, Array.append<ExtendedEvent>(some, [e]));
          };
        };
      };
      for ((date, list_events) in r.entries()) {
        events.put((date, p), list_events);
      };
      return #ok();
    };

    public func calculateScore(
      p : Principal,
      t1 : ?Time.Time,
      t2 : ?Time.Time,
    ) : Result.Result<(), Text> {
      let dates = _getDatesBetween(t1, t2);
      for (date in dates.vals()) {
        switch (events.get(date, p)) {
          case (null) {};
          case (?some) {
            let score = _getScore(some, p);
            scores.put((date, p), score);
          };
        };
      };
      return #ok();
    };

    ////////////////
    // UTILITIES //
    ///////////////

    /* Returns the natural number corresponding to the latest page for the specified bucket */
    func _getLatestPage(cid : Principal) : async Nat {
      let bucket : Types.Bucket = actor (Principal.toText(cid));
      let size = await bucket.size();
      let latest_page = Nat64.div(size, 64 : Nat64);
      Nat64.toNat(latest_page);
    };

    /* Returns a list of the daily events for the specified bucket  */
    func _getDailyEvents(cid : Principal) : async [Types.Event] {
      let latest_page = await _getLatestPage(cid);
      let bucket : Types.Bucket = actor (Principal.toText(cid));
      var r : Buffer.Buffer<Types.Event> = Buffer.Buffer(0);
      var is_over : Bool = false;
      var count : Nat = 0;
      label l while (not is_over) {
        // Verify that the page to query is not under 0.
        let page_to_query = Int.sub(latest_page, count);
        _Logs.logMessage("QUERY :: " # "page to query : " # Int.toText(page_to_query));
        if (page_to_query < 0) {
          break l;
        };
        let result = await bucket.get_transactions(
          {
            page = ?Nat32.fromNat(Int.abs(page_to_query));
            witness = false;
          },
        );
        // Calculate the Time only after the await otherwise we might be too far in the past for some recent events.
        let now = Time.now();
        let yesterday = now - DAY_NANO;
        let events = result.data;
        for (event in events.vals()) {
          // Time for event recorded in CAP are in milliseconds (10^(-3) seconds)
          let time : Nat = Nat64.toNat(event.time) * 1_000_000;
          // Only keep the events from the past 24 hours BUT only exit the loop if we encounter an event from before yesterday. If we encounter an event "in the future" we do nothing.
          if (time > yesterday and time <= now) {
            r.add(event);
          } else if (time < yesterday) {
            is_over := true;
          };
        };
        count := count + 1;
        // Add a security to stop the loop if the page number is too high (ie too many events in one day for one collection).
        if (count > 10) {
          is_over := true;
          _Logs.logMessage("ERR :: getDailyEvents :: " # Principal.toText(cid) # " :: " # "more than 10 pages.");
        };
      };
      return (r.toArray());
    };

    /* Returns (from, to, icps) from a sale event (assuming the informations are available) */
    func _saleDetails(
      event : Types.Event,
    ) : { to : Text; from : Text; price : Nat64 } {
      let details = event.details;
      var from : Text = "";
      var to : Text = "";
      var price : Nat64 = 0;
      for ((key, value) in details.vals()) {
        switch (key) {
          case ("from") {
            switch (value) {
              case (#Text(message)) {
                from := message;
              };
              case (#Principal(p)) {
                from := Text.map(Ext.AccountIdentifier.fromPrincipal(p, null), Prim.charToLower);
              };
              case _ {
                _Logs.logMessage("WARNING :: saleDetails :: " # "from :: " # "unknown type");
              };
            };
          };
          case ("to") {
            switch (value) {
              case (#Text(message)) {
                to := message;
              };
              case (#Principal(p)) {
                to := Text.map(Ext.AccountIdentifier.fromPrincipal(p, null), Prim.charToLower);
              };
              case _ {};
            };
          };
          case ("price") {
            switch (value) {
              case (#U64(message)) {
                price := message;
              };
              case _ {};
            };
          };
          case _ {};
        };
      };
      return ({ to; from; price });
    };

    /* Returns an extended event from an event & the collection involved */
    func _toExtendedEvent(
      event : Types.Event,
      collection : Principal,
    ) : ExtendedEvent {
      return (
        {
          operation = event.operation;
          time = event.time;
          details = event.details;
          caller = event.caller;
          collection = collection;
        },
      );
    };

    /* Add a new collection to a list of collections if the collection is not already in the list */
    func _addCollectionToInvolvedCollections(
      involved_collections : [Principal],
      collection : Principal,
    ) : [Principal] {
      switch (Array.find<Principal>(involved_collections, func(x) { Principal.equal(x, collection) })) {
        case (null) {
          return Array.append<Principal>(involved_collections, [collection]);
        };
        case (?_) {
          return involved_collections;
        };
      };
    };

    func _emptyCacheCollection() : () {
      for (p in cached_events_per_collection.keys()) {
        cached_events_per_collection.delete(p);
      };
    };

    func _emptyCacheUsers() : () {
      for (p in cached_events_per_user.keys()) {
        cached_events_per_user.delete(p);
      };
    };

    /* 
            Returns the array of dates between (optional) T1 and T2 
            T2 > T1 otherwise this function will trap
            If T1 is not specified, it will return the array of dates between the BEGIN_TIME and T2.
            If T2 is not specified, it will return the array of dates between T1 and the current time.
        */
    func _getDatesBetween(t1 : ?Time.Time, t2 : ?Time.Time) : [Date] {
      var buffer : Buffer.Buffer<Date> = Buffer.Buffer<Date>(0);
      let start = switch (t1) {
        case (?t1) { t1 };
        case (null) { BEGIN_TIME };
      };
      let end = switch (t2) {
        case (?t2) { t2 };
        case (null) { Time.now() };
      };
      if (start > end) {
        assert (false);
        return [];
      };
      let date_start = switch (DateModule.Date.toDatePartsISO8601(start)) {
        case (null) {
          assert (false);
          (0, 0, 0);
        };
        case (?date_parts) {
          date_parts;
        };
      };
      buffer.add(date_start);
      let ONE_DAY_NANOS : Nat = 86_400_000_000_000;
      var next_day = start + ONE_DAY_NANOS;
      var count = 0;
      while (next_day <= end and count < 100) {
        let date = switch (DateModule.Date.toDatePartsISO8601(next_day)) {
          case (null) {
            assert (false);
            (0, 0, 0);
          };
          case (?date_parts) {
            date_parts;
          };
        };
        buffer.add(date);
        next_day += ONE_DAY_NANOS;
        count += 1;
      };
      return buffer.toArray();
    };

    /* Returns the AccountIdentifier responsible from burning an accessory assuming the event is a Burn event from the accessory collection */
    func _getBurner(event : ExtendedEvent) : Ext.AccountIdentifier {
      let details = event.details;
      for ((key, value) in details.vals()) {
        switch (key) {
          case ("from") {
            switch (value) {
              case (#Text(account)) {
                return account;
              };
              case _ {};
            };
          };
          case _ {};
        };
      };
      return "";
    };

    /* Returns a list of all the (extended) events of the day */
    func _getExtendedEventsDaily() : [ExtendedEvent] {
      let r : Buffer.Buffer<ExtendedEvent> = Buffer.Buffer<ExtendedEvent>(0);
      for ((cid, events) in cached_events_per_collection.entries()) {
        for (event in events.vals()) {
          let extended_event = _toExtendedEvent(event, cid);
          r.add(extended_event);
        };
      };
      r.toArray();
    };

    /* Cache the event for this user */
    func _cacheEventUser(p : Principal, e : ExtendedEvent) : () {
      switch (cached_events_per_user.get(p)) {
        case (null) {
          let r = Buffer.Buffer<ExtendedEvent>(0);
          r.add(e);
          cached_events_per_user.put(p, r);
        };
        case (?buffer) {
          buffer.add(e);
        };
      };
    };

    func _calculateScores(date : Date) : async Result.Result<(), Text> {
      let infos = await AVATAR_ACTOR.get_infos_accounts();
      let principals : Buffer.Buffer<Principal> = Buffer.Buffer<Principal>(0);
      for (info in infos.vals()) {
        principals.add(info.0);
      };
      ignore (principals.toArray());
      for (p in principals.vals()) {
        switch (events.get(date, p)) {
          case (null) {};
          case (?some) {
            let score = _getScore(some, p);
            scores.put((date, p), score);
          };
        };
      };
      return #ok;
    };

    func _getScore(events : [ExtendedEvent], p : Principal) : Nat {
      let activity = _getActivity(events, p);
      return _activityToScore(activity);
    };

    /* 
            Returns the stats from a list of events 
            (Buy, BuyICPs, Sell, SellICPs, Mint, Burn)
        */
    func _getActivity(events : [ExtendedEvent], p : Principal) : Activity {
      var buy_nb : Nat = 0;
      var buy_icps : Nat = 0;
      var sell_nb : Nat = 0;
      var sell_icps : Nat = 0;
      var mint_nb : Nat = 0;
      var burn_nb : Nat = 0;
      let account = Text.map(Ext.AccountIdentifier.fromPrincipal(p, null), Prim.charToLower);
      for (e in events.vals()) {
        switch (e.operation) {
          case ("sale") {
            let { to; from; price } = _saleDetails(e);
            if (to == account) {
              buy_nb += 1;
              buy_icps := buy_icps + Nat64.toNat(price);
            } else if (from == account) {
              sell_nb += 1;
              sell_icps := sell_icps + Nat64.toNat(price);
            } else {
              _Logs.logMessage("ERR :: event doesn't correspond to the principal");
            };
          };
          case ("mint") {
            mint_nb += 1;
          };
          case ("burn") {
            burn_nb += 1;
          };
          case (_) {};
        };
      };
      return (
        {
          buy = (buy_nb, buy_icps);
          sell = (sell_nb, sell_icps);
          mint = mint_nb;
          burn = burn_nb;
        },
      );
    };

    func _activityToScore(activity : Activity) : Nat {
      var score : Nat = 0;
      if (activity.mint > 0) {
        score += 3;
      };
      let nb_transactions = activity.buy.0 + activity.sell.0;
      let icps_transactions = activity.buy.1 + activity.sell.1;
      if (nb_transactions > 0) {
        if (icps_transactions < 100_000_000 and icps_transactions > 0) {
          score += 1;
        };
        if (icps_transactions >= 100_000_000 and icps_transactions < 1_000_000_000) {
          score += 2;
        };
        if (icps_transactions >= 1_000_000_000) {
          score += 3;
        };
      };
      score;
    };

    func _getCollectionsInteracted(events : [ExtendedEvent]) : [Principal] {
      var collections : [Principal] = [];
      for (e in events.vals()) {
        switch (Array.find<Principal>(collections, func(x) { Principal.equal(e.collection, x) })) {
          case (?some) {};
          case (null) {
            collections := Array.append<Principal>(collections, [e.collection]);
          };
        };
      };
      collections;
    };

    func _isEventContained(e : ExtendedEvent, list : [ExtendedEvent]) : Bool {
      let time = e.time;
      for (event in list.vals()) {
        if (event.time == time) {
          return true;
        };
      };
      false;
    };

    func _getDate(e : Event) : Date {
      let time = Nat64.toNat(e.time * 1_000_000);
      let date = switch (
        DateModule.Date.toDatePartsISO8601(time),
      ) {
        case (null) {
          assert (false);
          (0, 0, 0);
        };
        case (?date_parts) {
          date_parts;
        };
      };
      date;
    };

    func _getName(e : Event) : ?Text {
      let details = e.details;
      for ((key, value) in details.vals()) {
        if (key == "name") {
          switch (value) {
            case (#Text(name)) {
              return ?name;
            };
            case _ {};
          };
        };
      };
      _Logs.logMessage("WARNING :: name not found for event");
      null;
    };

    func _isEventMintAccessory(
      e : ExtendedEvent,
    ) : Bool {
      let materials = ["Cloth", "Wood", "Glass", "Metal", "Circuit", "Dfinity-stone", "Cronic-essence", "Punk-essence"];
      if (e.operation != "mint" or e.collection != Principal.fromText("po6n2-uiaaa-aaaaj-qaiua-cai")) {
        return false;
      };
      switch (_getName(e)) {
        case (null) {
          return false;
        };
        case (?name) {
          for (material in materials.vals()) {
            if (material == name) {
              return false;
            };
          };
          return true;
        };
      };
    };

    func _isEventBurnAccessory(
      e : ExtendedEvent,
    ) : Bool {
      let materials = ["Cloth", "Wood", "Glass", "Metal", "Circuit", "Dfinity-stone", "Cronic-essence", "Punk-essence"];
      if (e.operation != "burn" or e.collection != Principal.fromText("po6n2-uiaaa-aaaaj-qaiua-cai")) {
        return false;
      };
      switch (_getName(e)) {
        case (null) {
          return false;
        };
        case (?name) {
          for (material in materials.vals()) {
            if (material == name) {
              return false;
            };
          };
          return true;
        };
      };
    };

  };
};
