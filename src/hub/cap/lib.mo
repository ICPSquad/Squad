import Array "mo:base/Array";
import Buffer "mo:base/Buffer";
import Error "mo:base/Error";
import Hash "mo:base/Hash";
import Int "mo:base/Int";
import Iter "mo:base/Iter";
import Nat "mo:base/Nat";
import Nat32 "mo:base/Nat32";
import Nat64 "mo:base/Nat64";
import Prim "mo:prim";
import Principal "mo:base/Principal";
import Result "mo:base/Result";
import Text "mo:base/Text";
import Time "mo:base/Time";
import TrieMap "mo:base/TrieMap";

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
    public type CumulativeActivity = Types.CumulativeActivity;
    public type Collection = Collection.Collection;
    public type Date = (Nat,Nat,Nat);

    /////////////////
    // Utilities ///
    ///////////////

    func _dateEqual(date1: Date, date2: Date) : Bool {
        return date1.0 == date2.0 and date1.1 == date2.1 and date1.2 == date2.2;
    };

    func _dateHash(date: Date) : Hash.Hash {
        return Int.hash(date.0 * 100 + date.1 * 10 + date.2);
    };

    public func customEqual(a : (Date, Principal), b : (Date, Principal)) : Bool {
        return _dateEqual(a.0, b.0) and Principal.equal(a.1, b.1);
    };

    public func customHash(a : (Date, Principal)) : Hash.Hash {
        return _dateHash(a.0) ^ Principal.hash(a.1);
    };


    public class Factory(dependencies : Types.Dependencies) {

        //////////////
        /// State ///
        ////////////
        
        // Tracking of activity has started on the 20th of June 2022
        let BEGIN_TIME : Time.Time = 1655729084018865799;
        let DAY_NANO = 24 * 60 * 60 * 1000 * 1000 * 1000;

        let AVATAR_ACTOR = actor(Principal.toText(dependencies.cid_avatar)) : actor {
            get_infos_leaderboard : shared () -> async [(Principal, ?Text, ?Text)];
            get_infos_accounts : shared () -> async [(Principal, Ext.AccountIdentifier)];
        };

        let bucket_accessory : Types.Bucket = actor(Principal.toText(dependencies.cid_bucket_accessory));
        let bucket_avatar : Types.Bucket = actor(Principal.toText(dependencies.cid_bucket_avatar));
        let cap_router : Types.Router = actor(Principal.toText(dependencies.cid_router));
        let dab : Types.Dab = actor(Principal.toText(dependencies.cid_dab));

        let _Logs = dependencies._Logs;

        /* Keep track of the root bucket for all registered collections.*/
        let cids : TrieMap.TrieMap<Collection, Principal> = TrieMap.TrieMap<Collection,Principal>(Collection.equal, Collection.hash);

        /* Keep track of the cids of the collection the user has interacted with.*/
        let cid_interacted_collections : TrieMap.TrieMap<Principal, [Principal]> = TrieMap.TrieMap<Principal,[Principal]>(Principal.equal, Principal.hash);

        /* Daily cached events for all collections.*/
        let daily_cached_events_per_collection : TrieMap.TrieMap<Principal, [Types.Event]> = TrieMap.TrieMap<Principal,[Types.Event]>(Principal.equal, Principal.hash);

        /* Daily cached events for all users. */
        let daily_cached_events_per_user : TrieMap.TrieMap<Principal, [Types.ExtendedEvent]> = TrieMap.TrieMap<Principal,[Types.ExtendedEvent]>(Principal.equal, Principal.hash);

        /* DEPRECEATED : Daily stats for all users. */
        let stats_daily : TrieMap.TrieMap<(Date, Principal), Types.CapStats> = TrieMap.TrieMap<(Date,Principal),Types.CapStats>(customEqual, customHash);

        /* Daily engagement score for all users. */
        let engagement_score_daily : TrieMap.TrieMap<(Date, Principal), Nat> = TrieMap.TrieMap<(Date,Principal), Nat>(customEqual, customHash);

        /* Daily tracking of activity for all users. */
        let tracking_activity_daily : TrieMap.TrieMap<(Date, Principal), Activity> = TrieMap.TrieMap<(Date,Principal), Activity>(customEqual, customHash);

        /* Interacted collections per user (cumulative) */
        let interacted_collections : TrieMap.TrieMap<Principal, [Principal]> = TrieMap.TrieMap<Principal, [Principal]>(Principal.equal, Principal.hash);

        public func preupgrade() : UpgradeData {
            return({
                cids = Iter.toArray(cids.entries());
                cid_interacted_collections = Iter.toArray(cid_interacted_collections.entries());
                daily_cached_events_per_collection = Iter.toArray(daily_cached_events_per_collection.entries());
                daily_cached_events_per_user = Iter.toArray(daily_cached_events_per_user.entries());
                stats_daily = Iter.toArray(stats_daily.entries());
                engagement_score_daily = Iter.toArray(engagement_score_daily.entries());
                tracking_activity_daily = Iter.toArray(tracking_activity_daily.entries());
            })
        };

        public func postupgrade(ud : ?UpgradeData) : () {
            switch(ud){
                case(null){};
                case(? ud){
                    for((collection, cid) in ud.cids.vals()){
                        cids.put(collection, cid);
                    };
                    for((user, collection) in ud.cid_interacted_collections.vals()){
                        cid_interacted_collections.put(user, collection);
                    };
                    for((p, events) in ud.daily_cached_events_per_collection.vals()){
                        daily_cached_events_per_collection.put(p, events);
                    };
                    for((p, extended_events) in ud.daily_cached_events_per_user.vals()){
                        daily_cached_events_per_user.put(p, extended_events);
                    };
                    // for(((date, collection), stats) in ud.stats_daily.vals()){
                    //     stats_daily.put((date, collection), stats);
                    // };
                    for(((date, user), score) in ud.engagement_score_daily.vals()){
                        engagement_score_daily.put((date, user), score);
                    };
                    for(((date, user), activity) in ud.tracking_activity_daily.vals()){
                        tracking_activity_daily.put((date, user), activity);
                    };
                };
            };
        };

        ///////////
        // CRON //
        //////////

        /* 
            Query all the cids and add the event of the day to the daily cache in the canister.
            @ok : Number of events added to the daily cache.
            @err : An error message.
        */
        public func cronEvents() : async Result.Result<Nat, Text> {
            var total_number : Nat = 0;
            for((collection, cid) in cids.entries()){
                try {
                    let daily_events = await getDailyEvents(cid);
                    total_number += daily_events.size();
                    daily_cached_events_per_collection.put(cid, daily_events);
                } catch e {
                    return #err(Error.message(e));
                };
            };
            return #ok(total_number);
        };

        /* Fill the daily events for each user by assigning events to users & update the list of interacted collections */
        public func cronUsers() : async Result.Result<(), Text> {
            let infos = await AVATAR_ACTOR.get_infos_accounts();
            let events = _getAllEventsExtendedDay();
            for((p, account) in infos.vals()){
                let event_specific_to_user = _filterEventsByUser(p, account, events);
                daily_cached_events_per_user.put(p, event_specific_to_user);
                // Update the list of interacted collections for the user.
                let interacted_collections : [Principal] = Array.map<ExtendedEvent, Principal>(event_specific_to_user, func(e : ExtendedEvent) : Principal {
                    return e.collection;
                });
                _addToInteractedCollections(p, interacted_collections);
            };
            _Logs.logMessage("CRON :: DAILY EVENTS FOR USERS & INTERACTED COLLECTIONS " # " :: " # Nat.toText(infos.size()) # " users");
            return #ok();
        };

        /* Update the daily events, activity and engagement scores for all users */
        public func cronStats () : async Result.Result<(), Text> {
            let date : Date = switch(DateModule.Date.nowToDatePartsISO8601()){
                case(null){
                    assert(false); 
                    (0,0,0);
                };
                case(? date) {date};
            };
            let infos = await AVATAR_ACTOR.get_infos_accounts();
            for ((p, account) in infos.vals()){
                switch(daily_cached_events_per_user.get(p)){
                    case(null){};
                    case(? events){
                        let activity = _getDailyActivity(p, account, events);
                        tracking_activity_daily.put((date,p), activity);
                        let daily_engagement_score = _getDailyEngagementScore(activity);
                        engagement_score_daily.put((date, p), daily_engagement_score);
                    };
                };
            };
            _Logs.logMessage("CRON :: ACTIVITY & ENGAGEMENT SCORE " # " :: " # Nat.toText(infos.size()) # " users");
            return #ok(());
        };

        //////////
        // API //
        ////////

        /* Returns the total engagement score of the principal between t1 and t2 by summing the engagement scores of all the days.*/
        public func getScore(p : Principal, dates : [Date]) : Nat {
            return _getSumEngagementScore(dates, p);
        };

        /* Returns the number of different collections the user has interacted with */
        public func numberCollectionsInteracted(p : Principal) : Nat {
            switch(interacted_collections.get(p)){
                case(null){
                    return 0;
                };
                case(? collections){
                    return collections.size();
                };
            };
        };  

        /* Returns the number of accessory the user has burned */
        public func numberBurn(p : Principal) : Nat {
            let activity = getCumulativeActivity(p,null,null);
            return activity.accessory_burned;
        };
        
        /* Returns the number of accessory the user has minted */
        public func numberMint(p : Principal) : Nat {
            let activity = getCumulativeActivity(p,null,null);
            return activity.accessory_minted;
        };

        public func getAllDailyEvents() : [(Principal, [Event])] {
            return (Iter.toArray(daily_cached_events_per_collection.entries()));
        };

        public func getDailyEventsUser(p : Principal) : [ExtendedEvent] {
            switch(daily_cached_events_per_user.get(p)){
                case(null){
                    return [];
                };
                case(? events){
                    return events;
                };
            };
        };

        /* Returns the (optional) recorded activity for the user at the specified time */
        public func getDailyActivity(p : Principal, time : Time.Time) : ?Activity {
            let date : Date = switch(DateModule.Date.nowToDatePartsISO8601()){
                case(null){
                    assert(false); 
                    (0,0,0);
                };
                case(? date) {date};
            };
            switch(tracking_activity_daily.get((date, p))){
                case(null){
                    return null;
                };
                case(? activity){
                    return ?activity;
                };
            };
        };

        /* Returns a cumulative activity calculated between t1 & t2 */
        public func getCumulativeActivity(p : Principal, t1 : ?Time.Time, t2 : ?Time.Time) : Activity {
            var number_buy : Nat = 0;
            var icps_buy : Nat = 0;
            var number_sell : Nat = 0;
            var icps_sell : Nat = 0;
            var number_mint : Nat = 0;
            var number_burn : Nat = 0;
            var accessory_burned : Nat = 0;
            var accessory_minted : Nat = 0;
            var collection_involved : Nat = 0;
            let dates = _getDatesBetween(t1, t2);
            for(date in dates.vals()){
                switch(tracking_activity_daily.get(date, p)){
                    case(null){};
                    case(? activity){
                        number_buy += activity.buy.0;
                        icps_buy += activity.buy.1;
                        number_sell += activity.sell.0;
                        icps_sell += activity.sell.1;
                        number_mint += activity.mint;
                        number_burn += activity.burn;
                        accessory_burned += activity.accessory_burned;
                        accessory_minted += activity.accessory_minted;
                        collection_involved += activity.collection_involved;
                    };
                };
            };
            return({
                buy = (number_buy, icps_buy);
                sell = (number_sell, icps_sell);
                mint = number_mint;
                burn = number_burn;
                accessory_burned;
                accessory_minted;
                collection_involved;
            })
        };

        public func registerCollection(collection : Collection) : async Result.Result<(), Text> {
            let cid = collection.contractId;
            try {
                let result = await cap_router.get_token_contract_root_bucket({
                    canister = cid;
                    witness = false;
                });
                switch(result.canister){
                    case(? cid_bucket){
                        cids.put(collection, cid_bucket);
                    };
                    case(null){
                        return #err("ERR :: no bucket to register found");
                    };
                };
            } catch e {
                return #err(Error.message(e));
            };
            return #ok();
        };

        /* Returns a boolean indicating if the user has ever minted one of the accessory among all the names */
        public func hasEverMinted(p : Principal, names : [Text]) : async Bool {
            try {
                let result = await bucket_accessory.get_user_transactions({
                page = null;
                user = p;
                witness = false;
                });
                let events = result.data;
                for(event in events.vals()){
                    // Check if the event is a mint event.
                    if(event.operation == "mint") {
                        // Check if the mint event is for one of the names.
                        for(name in names.vals()){
                            if(_isEventAbout(name, event)){
                                return true;
                            };
                        };
                    };
                };
            } catch e {
                _Logs.logMessage("ERR :: failed to query transactions for user : " # Principal.toText(p) # " and bucket : " # Principal.toText(dependencies.cid_bucket_accessory));
            };
            return false;
        };

        ////////////////
        // UTILITIES //
        ///////////////

        /* Calculates and returns the number of the last page for the specified bucket */
        func getLatestPage(cid : Principal) : async Nat {
            let bucket : Types.Bucket = actor(Principal.toText(cid));
            let size = await bucket.size();
            let latest_page = Nat64.div(size, 64 : Nat64);
            Nat64.toNat(latest_page);
        };

        /* Returns a list of the daily events for the specified bucket  */
        func getDailyEvents(cid : Principal) : async [Types.Event] {
            let latest_page = await getLatestPage(cid);
            let bucket : Types.Bucket = actor(Principal.toText(cid));
            var r : Buffer.Buffer<Types.Event> = Buffer.Buffer(0);
            var is_over : Bool = false;
            var count : Nat = 0;
            label l while(not is_over){
                // Verify that the page to query is not under 0.
                let page_to_query = Int.sub(latest_page, count);
                if(page_to_query < 0){
                    break l;
                };
                let result = await bucket.get_transactions({
                    page = ?Nat32.fromNat(Int.abs(page_to_query));
                    witness = false;
                });
                // Calculate the Time only after the await otherwise we might be too far in the past for some recent events.
                let now = Time.now();
                let yesterday = now - DAY_NANO;
                let events = result.data;
                for(event in events.vals()){
                    // Need to convert the types and multiply to convert to nanos.
                    let time : Nat = Nat64.toNat(event.time) * 1_000_000;
                    // Only keep the events from the past 24 hours BUT only exit the loop if we encounter an event from before yesterday. If we encounter an event "in the future" we do nothing.
                    if(time > yesterday and time <= now){
                        r.add(event);
                    } else if (time < yesterday){
                        is_over := true;
                    };
                };
                count := count + 1;
                // If we have reached the last page of the bucket, we are done.
                if(events.size() == 0){
                    is_over := true;
                };
                // Add a security to stop the loop if the page number is too high (ie too many events in one day for one collection).
                if(count > 100){
                    is_over := true;
                    _Logs.logMessage("ERROR :: getDailyEvents :: " # Principal.toText(cid) # " :: " # "More than 100 pages.");
                };
            };
            return(r.toArray());
        };

        /* Filter a list of events to only keep events that are relevant to the specified principal */
        func _filterEventsByUser(p : Principal, account : Ext.AccountIdentifier,  events : [Types.ExtendedEvent]) : [Types.ExtendedEvent] {
            let r : Buffer.Buffer<Types.ExtendedEvent> = Buffer.Buffer<Types.ExtendedEvent>(0);
            for(event in events.vals()){
                if(event.caller == p){
                    r.add(event);
                } else if (_isEventRelatedToAccount(account, event)){
                    r.add(event);
                };
            };
            r.toArray();
        };

        /* Returns the activity of the user based on the recorded events of the day */
        func _getDailyActivity(user : Principal, account : Ext.AccountIdentifier, events : [ExtendedEvent]) : Activity {
            var number_buy : Nat = 0;
            var icps_buy : Nat64 = 0;
            var number_sell : Nat = 0;
            var icps_sell : Nat64 = 0;
            var number_mint : Nat = 0;
            var number_burn : Nat = 0;
            var accessory_burned : Nat = 0;
            var accessory_minted : Nat = 0;
            var collections : [Principal] = [];
            for (event in events.vals()){
                collections := _addCollectionToInvolvedCollections(collections, event.collection);
                switch(event.operation){
                    case("sale"){
                        let {to; from; price} = _saleDetails(event);
                        if(to == account){
                            number_sell := number_sell + 1;
                            icps_sell := icps_sell + price;
                        } else if (from == account){
                            number_buy := number_buy + 1;
                            icps_buy := icps_buy + price;
                        }
                    };
                    case("mint"){
                        number_mint := number_mint + 1;
                        if(event.collection == Principal.fromText("po6n2-uiaaa-aaaaj-qaiua-cai") and _isEventAccessory(event)){
                            accessory_minted := accessory_minted + 1;
                        };
                    };
                    case("burn"){
                        number_burn := number_burn + 1;
                        if(event.collection == Principal.fromText("po6n2-uiaaa-aaaaj-qaiua-cai") and _isEventAccessory(event)){
                            accessory_burned := accessory_burned + 1;
                        };
                    };
                    case("approve"){};
                    case("transferFrom"){};
                    case(x) {
                        _Logs.logMessage("WARNING :: unknown operation: " # x);
                    };
                };
            };
            return({
                buy = (number_buy, Nat64.toNat(icps_buy));
                sell = (number_sell, Nat64.toNat(icps_sell));
                mint = number_mint;
                burn = number_burn;
                accessory_minted = accessory_minted;
                accessory_burned = accessory_burned;
                collection_involved = collections.size();
            });
        };

        /* 
            Returns an engagement score based from the daily activity.
            ⚠️ This is a very simple engagement score and should be improved with more data.
            If there is one buy (at least) with more than 1 ICP the user is considered engaged and the score is 1.
            If there is one sale (at least) with more than 1 ICP the user is considered engaged and the score is 1.
            If there is one mint (at least) the user is considered engaged and the score is 1.
            Otherwise the score is 0.
        */
        func _getDailyEngagementScore(stat : Activity) : Nat {
            // Check mint
            if(stat.mint > 0) {
                return 1;
            };
            if(stat.buy.0 > 0 and stat.buy.1 >= 100_000_000) {
                return 1;
            };
            if(stat.sell.0 > 0 and stat.sell.1 >= 100_000_000) {
                return 1;
            };
            return 0;
        };
        
        /* Returns (from, to, icps) from a sale event (assuming the informations are available) */
        func _saleDetails(
            event : Types.Event
        ) : {to : Text; from : Text; price : Nat64} {
            let details = event.details;
            var from : Text = "";
            var to : Text = "";
            var price : Nat64 = 0;
            for((key, value) in details.vals()){
                switch(key){
                    case("from"){
                        switch(value){
                            case(#Text(message)){
                                from := message;
                            };
                            case _ {};
                        };
                    };
                    case("to"){
                        switch(value){
                            case(#Text(message)){
                                to := message;
                            };
                            case _ {};
                        };
                    };
                    case("price"){
                        switch(value){
                            case(#U64(message)){
                                price := message;
                            };
                            case _ {};
                        };
                    };
                    case _ {};
                };
            };
            return ({to; from; price;});
        };

        /* Returns an extended event from an event and the collection involved */
        func _eventToExtendendEvent(
            event : Types.Event,
            collection : Principal
        ) : Types.ExtendedEvent {
            return({
                operation = event.operation;
                time = event.time;
                details = event.details;
                caller = event.caller;
                collection = collection;
            })
        };

        func _addToInteractedCollections(
            p : Principal,
            collections : [Principal]
        ) : () {
            switch(interacted_collections.get(p)){
                case(null){
                    interacted_collections.put(p, collections);
                };
                case(? already_collections){
                    let r : TrieMap.TrieMap<Principal,Bool> = TrieMap.TrieMap<Principal,Bool>(Principal.equal, Principal.hash);
                    for(c in already_collections.vals()){
                        r.put(c, true);
                    };
                    for(c in collections.vals()){
                        switch(r.get(c)){
                            case(null){
                                r.put(c, true);
                            };
                            case(? _){};
                        };
                    };
                    let total : [Principal] = Iter.toArray(r.keys());
                    interacted_collections.put(p, total);
                };
            };
        };

        /* Add a new collection to a list of collections if the collection is not already in the list */
        func _addCollectionToInvolvedCollections(
            involved_collections : [Principal],
            collection : Principal
        ) : [Principal] {
            switch(Array.find<Principal>(involved_collections, func(x) {Principal.equal(x, collection)})){
                case(null){
                    return Array.append<Principal>(involved_collections, [collection]);
                };
                case(? _){
                    return involved_collections;
                };
            };
        };

        /* Returns the sum of all engagement scores found for the provided dates and user */
        func _getSumEngagementScore(dates : [Date], p : Principal) : Nat {
            var sum : Nat = 0;
            for(date in dates.vals()){
                switch(engagement_score_daily.get(date, p)){
                    case(null) {};
                    case(? score) {
                        sum += score;
                    };
                };
            };
            return sum;
        };

        /* Takes T1 & T2 and returns the array of dates between T1 and T2 */
        func _getDatesBetween(t1 : ?Time.Time, t2 : ?Time.Time) : [Date] {
            var buffer : Buffer.Buffer<Date> = Buffer.Buffer<Date>(0);
            let start = switch(t1){
                case(? t1) {t1};
                case(null) {BEGIN_TIME};
            };
            let end = switch(t2){
                case(? t2) {t2};
                case(null) {Time.now()};
            };
            if(start > end){
                assert(false);
                return [];
            };
            let date_start = switch(DateModule.Date.toDatePartsISO8601(start)){
                case(null) {
                    assert(false);
                    (0, 0, 0);
                };
                case(? date_parts) {
                    date_parts;
                };
            };
            buffer.add(date_start);
            let ONE_DAY_NANOS : Nat = 86_400_000_000_000;
            var next_day = start + ONE_DAY_NANOS;
            var count = 0;
            while(next_day <= end and count < 100){
                let date = switch(DateModule.Date.toDatePartsISO8601(next_day)){
                    case(null) {
                        assert(false);
                        (0, 0, 0);
                    };
                    case(? date_parts) {
                        date_parts;
                    };
                };
                buffer.add(date);
                next_day += ONE_DAY_NANOS;
                count += 1;
            };
            return buffer.toArray();
        };

        /* Returns a boolean indicating if the event is related to an accessory.*/
        func _isEventAccessory(event : Event) : Bool {
            let details = event.details;
            let potential_materials_name : [Text] = ["Cloth", "Wood", "Glass", "Circuit", "Metal", "Dfinity-stone", "Cronic-essence", "Punk-essence"];
            for((key, value) in details.vals()){
                switch(key){
                    case("name"){
                        switch(value){
                            case(#Text(title)){
                                switch(Array.find<Text>(potential_materials_name, func(x) {x == title})){
                                    case(null){
                                        return true
                                    };
                                    case(? _){
                                        return false;
                                    };
                                };
                            };
                            case _ {};
                        };
                    };
                    case _ {};
                };
            };
            return false;
        };

        /* Returns a boolean indicating if an event is involving an Account */
        func _isEventRelatedToAccount(account : Ext.AccountIdentifier, event : Event) : Bool {
            let details = event.details;
            for((key, value) in details.vals()){
                switch(key){
                    case("from"){
                        switch(value){
                            case(#Text(account)){
                                return true;
                            };
                            case _ {};
                        };
                    };
                    case("to"){
                        switch(value){
                            case(#Text(account)){
                                return true;
                            };
                            case _ {};
                        };
                    };
                    case _ {};
                };
            };
            return false;
        };

        /* Returns a boolean indicating if an event is related to a given name by looking over the available details and finding the name */
        func _isEventAbout(
            name : Text,
            event : Types.Event
            ) : Bool {
            let details = event.details;
            for((key, value) in details.vals()){
                if(key == "name"){
                    switch(value){
                        case(#Text(message)){
                            return (message == name);
                        };
                        case _ {
                            return false;
                        };
                    };
                };
            };
            return false;
        };

        /* Returns a boolean indicating if an event was performed during the (optional) given time interval. */
        func _isTimeBound(
            event : Time.Time,
            time_start : ?Time.Time,
            time_end : ?Time.Time
            ) : Bool {
            switch(time_start){
                case(? start){
                    if(event < start){
                        return false;
                    };
                };
                case(null){};
            };
            switch(time_end){
                case(? end){
                    if(event > end){
                        return false;
                    };
                };
                case(null){};
            };
            return true;
        };

        /* Returns a boolean indicating if a sale was perfomed by the given account */
        func _isSaleFrom(
            event : Types.Event,
            account : Ext.AccountIdentifier
        ) : Bool {
            let details = event.details;
            for((key, value) in details.vals()){
                if(key == "from"){
                    switch(value){
                        case(#Text(message)){
                            return (message == account);
                        };
                        case _ {
                            return false;
                        };
                    };
                };
            };
            return false;
        };

        /* Returns a list of all the (extended) events of the day */
        func _getAllEventsExtendedDay() : [Types.ExtendedEvent] {
            let r : Buffer.Buffer<Types.ExtendedEvent> = Buffer.Buffer<Types.ExtendedEvent>(0);
            for((cid, events) in daily_cached_events_per_collection.entries()){
                for(event in events.vals()){
                    let extended_event = _eventToExtendendEvent(event, cid);
                    r.add(extended_event);
                };
            };
            r.toArray();
        };
    };
};