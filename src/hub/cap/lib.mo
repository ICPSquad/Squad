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
    public type CapStats = Types.CapStats;
    public type Activity = Types.Activity;
    public type Collection = Collection.Collection;

    type Date = (Nat,Nat,Nat);

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

        let DAY_NANO = 24 * 60 * 60 * 1000 * 1000 * 1000;

        //////////////
        /// State ///
        ////////////

        let bucket_accessory : Types.Bucket = actor(Principal.toText(dependencies.cid_bucket_accessory));
        let bucket_avatar : Types.Bucket = actor(Principal.toText(dependencies.cid_bucket_avatar));

        let cap_router : Types.Router = actor(Principal.toText(dependencies.cid_router));
        let dab : Types.Dab = actor(Principal.toText(dependencies.cid_dab));

        let _Logs = dependencies._Logs;

        let AVATAR_ACTOR = actor(Principal.toText(dependencies.cid_avatar)) : actor {
            get_infos_leaderboard : shared () -> async [(Principal, ?Text, ?Text)];
        };
        

        /* 
            Keep track of the root bucket for all registered collections.
         */
        let cids : TrieMap.TrieMap<Collection, Principal> = TrieMap.TrieMap<Collection,Principal>(Collection.equal, Collection.hash);

        public func getCollections() : [(Collection, Principal)] {
            return Iter.toArray(cids.entries());
        };

        /* 
            Keep track of the cids of the collection the user has interacted with.
        */
        let cid_interacted_collections : TrieMap.TrieMap<Principal, [Principal]> = TrieMap.TrieMap<Principal,[Principal]>(Principal.equal, Principal.hash);

        public func getInteractedCollections() : [(Principal,[Principal])] {
            return Iter.toArray(cid_interacted_collections.entries());
        };

        /* 
            Daily cached events for all collections.
        */
        let daily_cached_events_per_collection : TrieMap.TrieMap<Principal, [Types.Event]> = TrieMap.TrieMap<Principal,[Types.Event]>(Principal.equal, Principal.hash);

        public func getDailyCachedEventsPerCollection() : [(Principal,[Types.Event])] {
            return Iter.toArray(daily_cached_events_per_collection.entries());
        };

        /* 
            Daily cached events for all users.
         */
        let daily_cached_events_per_user : TrieMap.TrieMap<Principal, [Types.ExtendedEvent]> = TrieMap.TrieMap<Principal,[Types.ExtendedEvent]>(Principal.equal, Principal.hash);

        public func getDailyCachedEventsPerUser() : [(Principal,[Types.ExtendedEvent])] {
            return Iter.toArray(daily_cached_events_per_user.entries());
        };

        /* 
            Daily stats for all users. 
        */

        let stats_daily : TrieMap.TrieMap<(Date, Principal), Types.CapStats> = TrieMap.TrieMap<(Date,Principal),Types.CapStats>(customEqual, customHash);

        public func getDailyCachedStatsPerUser() : [((Date,Principal),Types.CapStats)] {
            return Iter.toArray(stats_daily.entries());
        };

        /* 
            Daily engagement score for all users. 
        */

        let engagement_score_daily : TrieMap.TrieMap<(Date, Principal), Nat> = TrieMap.TrieMap<(Date,Principal), Nat>(customEqual, customHash);

        public func getDailyEngagementScore() : [((Date,Principal),Nat)] {
            return Iter.toArray(engagement_score_daily.entries());
        };

        /* 
            Tracking of activity for all users.
        */

        let tracking_activity_daily : TrieMap.TrieMap<(Date, Principal), Activity> = TrieMap.TrieMap<(Date,Principal), Activity>(customEqual, customHash);

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
                    for(((date, collection), stats) in ud.stats_daily.vals()){
                        stats_daily.put((date, collection), stats);
                    };
                    for(((date, user), score) in ud.engagement_score_daily.vals()){
                        engagement_score_daily.put((date, user), score);
                    };
                    for(((date, user), activity) in ud.tracking_activity_daily.vals()){
                        tracking_activity_daily.put((date, user), activity);
                    };
                };
            };
        };

        ///////////////////
        // Daily scores //
        /////////////////

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

        func getLatestPage(cid : Principal) : async Nat {
            let bucket : Types.Bucket = actor(Principal.toText(cid));
            let size = await bucket.size();
            let latest_page = Nat64.div(size, 64 : Nat64);
            Nat64.toNat(latest_page);
        };

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
    
        /* 
            Fill the daily events for each user by assigning events to users.
        */
        public func cronUsers() : async Result.Result<(), Text> {
            let infos = await AVATAR_ACTOR.get_infos_leaderboard();
            let users = Array.map<(Principal, ?Text, ?Text), Principal>(infos, func(x) {x.0});
            let events = _getAllEventsExtendedDay();
            for(p in users.vals()){
                let event_specific_to_user = _filterEventsByPrincipal(p, events);
                daily_cached_events_per_user.put(p, event_specific_to_user);
            };
            _Logs.logMessage("CRON :: DAILY EVENTS FOR USERS (Hub)");
            return #ok();
        };

        /* 
            Update the daily events, stats and engagement scores! for all users.
         */
        public func cronStats () : async Result.Result<(), Text> {
            let date : Date = switch(DateModule.Date.nowToDatePartsISO8601()){
                case(null){
                    assert(false); 
                    (0,0,0);
                };
                case(? date) {date};
            };
            
            for ((p, events) in daily_cached_events_per_user.entries()){
                let stats = _getDailyStats(p, events);
                let daily_engagement_score = _getDailyEngagementScore(stats);
                stats_daily.put((date,p), stats);
                engagement_score_daily.put((date, p), daily_engagement_score);
            };

            _Logs.logMessage("CRON :: STATS & ENGAGEMENT SCORE (Hub)");
            return #ok(());
        };

        /* 
            Returns the stats object from the list of events of the specified user.
         */
        func _getDailyStats(user : Principal, events : [Types.ExtendedEvent]) : Types.CapStats {
            let account_identifier = Text.map(Ext.AccountIdentifier.fromPrincipal(user, null), Prim.charToLower);
            var number_buy : Nat = 0;
            var icps_buy : Nat64 = 0;
            var number_sell : Nat = 0;
            var icps_sell : Nat64 = 0;
            var number_mint : Nat = 0;
            var collections : [Principal] = [];
            for(event in events.vals()){
                switch(event.operation){
                    case("sale"){
                        collections := _addCollectionToInvolvedCollections(collections, event.collection);
                        let {to; from; price} = _saleDetails(event);
                        if(to == account_identifier){
                            number_sell := number_sell + 1;
                            icps_sell := icps_sell + price;
                        } else if (from == account_identifier){
                            number_buy := number_buy + 1;
                            icps_buy := icps_buy + price;
                        } else {
                            // Do nothing.
                        };
                    };
                    case("mint"){
                        number_mint := number_mint + 1;
                        collections := _addCollectionToInvolvedCollections(collections, event.collection);
                    };
                    // Operations we don't care about.
                    case ("transfer") {};
                    case("burn"){};
                    case("approve"){};
                    case("transferFrom"){};
                    // In case of an unknown operation. For later.
                    case (x){
                        _Logs.logMessage("Unknown operation: " # x);
                    };
                };
            };
            return({
                buy = (number_buy, Nat64.toNat(icps_buy));
                sell = (number_sell, Nat64.toNat(icps_sell));
                mint = number_mint;
                collection_involved = collections.size();
            });
        };

        /* 
            Returns an engagement score based from the daily collected stat.
            ⚠️ This is a very simple engagement score and should be improved with more data.
            If there is one buy (at least) with more than 1 ICP the user is considered engaged and the score is 1.
            If there is one sale (at least) with more than 1 ICP the user is considered engaged and the score is 1.
            If there is one mint (at least) the user is considered engaged and the score is 1.
            Otherwise the score is 0.
        */
        func _getDailyEngagementScore(stat : Types.CapStats) : Nat {
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

        /* 
            Filter a list of events to only keep events that are relevant to the specified principal.
        */
        func _filterEventsByPrincipal(p : Principal, events : [Types.ExtendedEvent]) : [Types.ExtendedEvent] {
            let r : Buffer.Buffer<Types.ExtendedEvent> = Buffer.Buffer<Types.ExtendedEvent>(0);
            let account_identifier = Text.map(Ext.AccountIdentifier.fromPrincipal(p, null), Prim.charToLower);
            for(event in events.vals()){
                if(event.caller == p){
                    r.add(event);
                } else if (_isEventRelatedToAccount(account_identifier, event)){
                    r.add(event);
                };
            };
            r.toArray();
        };

        //////////
        // API //
        ////////

        /* 
            Returns the total engagement score of the principal between t1 and t2 by summing the engagement scores of all the days.
         */
        public func getScore(p : Principal, dates : [Date]) : Nat {
            return _getSumEngagementScore(dates, p);
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
                        return #err("No bucket found");
                    };
                };
            } catch e {
                return #err(Error.message(e));
            };
            return #ok();
        };

        public func updateUserInteractedCollections(user : Principal) : async Result.Result<Nat, Text> {
            try {
                let result = await cap_router.get_user_root_buckets({
                    user;
                    witness = false;
                });
                cid_interacted_collections.put(user, result.contracts);
                return #ok(result.contracts.size());
            } catch e {
                return #err(Error.message(e));
            };
        };

        /* 
            Returns the number of collections this user has any interaction with. 
         */
        public func numberCollectionsInteracted(user : Principal) : async Nat {
            let result = await cap_router.get_user_root_buckets({
                user;
                witness = false;
            });
            return(result.contracts.size());
        };  

        /*  
            Returns the number of operations (among those specified) the user has performed across all collections that he has interacted with.
            @param user : The user to perform the count on.
            @param operations : A list of operations to count.
            @param (opt) : To eventually specify a list of collections to look across. If null we check the interacted_collections TrieMap.
        */
        public func numberOperations(user : Principal, operations : [Text] , cid_buckets : ?[Principal]) : async Nat {
            let cids_to_check : [Principal] = switch(cid_buckets){
                case(? cids){cids};
                case(null){
                    switch(cid_interacted_collections.get(user)){
                        case(? cids){cids};
                        case(null){[]};
                    };
                };
            };
            var count : Nat = 0;
            for(cid in cids_to_check.vals()){
                // When Promise.all. Currently this might take a long time to perfom 😢
                let bucket : Types.Bucket = actor(Principal.toText(cid));
                try {
                    let result = await bucket.get_user_transactions({
                        page = null;
                        user;
                        witness = false;
                    });
                    let events = result.data;
                    for(event in events.vals()){
                        switch(Array.find<Text>(operations, func(x) {Text.equal(x, event.operation)} )){
                            case(null){};
                            case(? some){
                                count += 1;
                            };
                        };
                    };
                } catch e {
                    _Logs.logMessage("Error when querying transactions for user " # Principal.toText(user) # " and bucket " # Principal.toText(cid) # " : " # Error.message(e));
                };
            };
            return(count);
        };


        /* 
            Returns stats on the sale of the specified user (Number of sales, Total ICPs) the user has performed across all collections that he has interacted with.
            @param user : The user to perform the count on.
            @param (opt) : To eventually specify a list of collections to look across. If null we check the interacted_collections TrieMap.
            @param (opt) : To eventually specify a start date.
            @param (opt) : To eventually specify an end date.
            ⚠️ This function takes an extremely long time and is expensive.
         */
        public func statsSales(
            user : Principal, 
            cid_buckets : ?[Principal], 
            time_start : ?Time.Time,
            time_end : ?Time.Time
            ) : async Result.Result<(Nat, Nat), Text> {
            let potential_sale_nomenclature : [Text] = ["sale", "Sale", "Sell", "sell", "SALE", "SELL"];
            let account_identifier = Text.map(Ext.AccountIdentifier.fromPrincipal(user, null), Prim.charToLower);
            let cids_to_check : [Principal] = switch(cid_buckets){
                case(? cids){cids};
                case(null){
                    switch(cid_interacted_collections.get(user)){
                        case(? cids){cids};
                        case(null){[]};
                    };
                };
            };
            var count_number_of_sales : Nat = 0;
            var count_total_icps : Nat64 = 0;
            for(cid in cids_to_check.vals()){
                // Need to query all the pages until the last. 
                let bucket : Types.Bucket = actor(Principal.toText(cid));
                var is_page_empty : Bool = false;
                var page_number : Nat32 = 0;
                while(not is_page_empty){
                    try {
                        let result = await bucket.get_transactions({
                        page = ?page_number;
                        witness = false;
                        });
                        let events = result.data;
                        for(event in events.vals()){
                            if(_isTimeBound(Nat64.toNat(event.time), time_start, time_end)){
                                switch(Array.find<Text>(potential_sale_nomenclature, func(x) {Text.equal(x, event.operation)} )){
                                    case(null){};
                                    case(? some){
                                        if(_isSaleFrom(event, account_identifier)){
                                            count_number_of_sales += 1;
                                            count_total_icps += _getICPAmount(event, cid);
                                        };
                                    };
                                };
                            };
                        };
                        page_number += 1;
                        // We put a high limit at 100 on the number of pages we can query by precautionary measure. 
                        if(events.size() == 0 or page_number > 100){
                            is_page_empty := true;
                        };
                    } catch e {
                        _Logs.logMessage("Error when querying transactions for user " # Principal.toText(user) # " and bucket " # Principal.toText(cid) # " : " # Error.message(e));
                        return #err(Error.message(e));
                    };      
                };  
            };
            return #ok((count_number_of_sales, Nat64.toNat(count_total_icps)));
        };


        public func numberMint(caller : Principal, name : ?Text) : async Nat {
            // Query the list of events for this user from the CAP bucket.
            let result = await bucket_accessory.get_user_transactions({
                page = null;
                user = caller;
                witness = false;
            });
            let events = result.data;
            // Count the number of mint events (corresponding to the eventual accessories or to all).
            var count : Nat = 0;
            switch(name){
                case(null) {
                    // Count all the mint events.
                    for(event in events.vals()){
                        if(event.operation == "mint"){
                            count += 1;
                        };
                    };
                };
                case(? name){
                    // Count only the mint events corresponding to the given name.
                    for(event in events.vals()){
                        if(event.operation == "burn"){
                            if(_isEventAbout(name, event)){
                                count += 1;
                            };
                        };
                    };
                };
            };
            return count;
        };
        
        public func numberBurn(caller : Principal, name : ?Text) : async Nat {
            // Query the list of events for this user from the CAP bucket.
            let result = await bucket_accessory.get_user_transactions({
                page = null;
                user = caller;
                witness = false;
            });
            let events = result.data;
            // Count the number of burn events (corresponding to the eventual accessories or to all).
            var count : Nat = 0;
            switch(name){
                case(null) {
                    // Count all the burn events.
                    for(event in events.vals()){
                        if(event.operation == "burn"){
                            count += 1;
                        };
                    };
                };
                case(? name){
                    // Count only the burn events corresponding to the given name.
                     for(event in events.vals()){
                        if(event.operation == "burn"){
                            if(_isEventAbout(name, event)){
                                count += 1;
                            };
                        };
                    };
                };
            };
            return count;
        };

        public func numberBurnAccessory(caller : Principal, name : ?Text) : async Nat {
            // Query the list of events for this user from the CAP bucket.
            let result = await bucket_accessory.get_user_transactions({
                page = null;
                user = caller;
                witness = false;
            });
            let events = result.data;
            // Count the number of burn events (corresponding to the eventual accessories or to all).
            var count : Nat = 0;
            switch(name){
                case(null) {
                    // Count all the burn events.
                    for(event in events.vals()){
                        if(event.operation == "burn"){
                            if(_isEventAccessory(event)){
                                count += 1;
                            };
                        };
                    };
                };
                case(? name){
                    // Count only the burn events corresponding to the given name.
                     for(event in events.vals()){
                        if(event.operation == "burn"){
                            if(_isEventAbout(name, event)){
                                count += 1;
                            };
                        };
                    };
                };
            };
            return count;
        };

        /* 
            Returns the cumulative stats of the specified user. Tracking starts from the 20th of June 2022.
         */
        // 20th of June 2022
        let BEGIN_TIME : Time.Time = 1655729084018865799;
        public func getAllTimeStats(caller : Principal) : CapStats {
            let dates = _getDatesBetween(BEGIN_TIME, Time.now());
            var r : Buffer.Buffer<CapStats> = Buffer.Buffer(0);
            for(date in dates.vals()){
                switch(stats_daily.get(date, caller)){
                    case(null){};
                    case(? stats){
                        r.add(stats);
                    };
                };
            };
            let stats = r.toArray();
            return _getCumulativeStats(stats);
        };

        /////////////
        // Admins //
        ///////////

        public func getAllOperations() : async [(Text, Nat)] {
            let r = TrieMap.TrieMap<Text,Nat>(Text.equal, Text.hash);
            for((cid, events) in daily_cached_events_per_collection.entries()){
                for(event in events.vals()){
                    let operation = event.operation;
                    switch(r.get(operation)){
                        case(null){
                            r.put(operation, 1);
                        };
                        case(? nb){
                            r.put(operation, nb + 1);
                        };
                    };
                };
            };
            return Iter.toArray(r.entries());
        };


        public func registerAllCollections() : async Result.Result<(), Text> {
            let collections : [Types.NFT_CANISTER] = await dab.get_all();
            for(collection in collections.vals()){
                let obj : Collection = {
                    name = collection.name;
                    contractId = collection.principal_id;
                };
                switch(await registerCollection(obj)){
                    case(#ok()){};
                    case(#err(e)){
                        _Logs.logMessage("No bucket found for : " # Principal.toText(collection.principal_id));
                    };
                }
            };
            return #ok();
        };

        public func getStatsUser(p : Principal) : async [(Date, Types.CapStats)] {
            let r : Buffer.Buffer<(Date, Types.CapStats)> = Buffer.Buffer(0);
            for(((date, user), stats) in stats_daily.entries()){
                if(p == user){
                    r.add(date, stats);
                };
            };
            return r.toArray();
        };

        //////////////
        // Helpers //
        ////////////

        /*
            Returns a boolean indicating if an event is related to an accessory by looking over the available details and finding the name.  
        */
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


        /*
            Returns a boolean indicating if an event was performed during the (optional) given time interval. 
         */
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

        /* 
            Returns a boolean indicating if a sale was perfomed by the given account.
            Returns false if the event was not a sale or if the account was not the seller.
         */
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

        /* 
            Returns (from, to, icps) from a sale event.
        
         */
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


        /* 
            This function is an attempt to get the ICP price of a sale. 
            Different standards in the nomenclature are used so it's not guarantee to work in all cases.
            In case of a miss : log a message so we can fix it later.
         */
        func _getICPAmount(
            sale_event : Types.Event,
            collection : Principal
            ) : Nat64 {
            let details = sale_event.details;
            for((key, value) in details.vals()){
                if(key == "price" or key == "Price"){
                    switch(value){
                        case(#U64(value)){
                            return value;
                        };
                        case _ {};
                    };
                };
            };
            _Logs.logMessage("ERR :: Could not find the ICP amount of the sale event : " # Principal.toText(collection));
            return 0;
        };


        /* 
            Returns an extended event from an event and the collection involved.
         */
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

        /* 
            Add a new collection to a list of collections if the collection is not already in the list.
         */
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

        
        /* 
            Returns the sum of all engagement scores found for the provided dates and user.
         */
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

        /*
            Takes T1 & T2 and returns an array of dates between T1 and T2. 
         */
        func _getDatesBetween(start : Time.Time, end : Time.Time) : [Date] {
            if(end < start){
                assert(false);
                return [];
            };
            var buffer : Buffer.Buffer<Date> = Buffer.Buffer<Date>(0);
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
        
        /* 
            Returns the cumulative stats from a list of stats.
         */
        func _getCumulativeStats(stats : [CapStats]) : CapStats {
            var number_buy : Nat = 0;
            var icps_buy : Nat = 0;
            var number_sell : Nat = 0;
            var icps_sell : Nat = 0;
            var number_mint : Nat = 0;
            var involved_collections : Nat = 0;
            for(stat in stats.vals()){
                number_buy += stat.buy.0;
                icps_buy += stat.buy.1;
                number_sell += stat.sell.0;
                icps_sell += stat.sell.1;
                number_mint += stat.mint;
                involved_collections += stat.collection_involved;
            };
            return({
                buy = (number_buy, icps_buy);
                sell = (number_sell, icps_sell);
                mint = number_mint;
                collection_involved = involved_collections;
            });
        };

        /* 
            Returns a boolean indicating if the event is related to an accessory.
         */
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

    /* 
        Returns a boolean indicating if an event is involving an Account.
    */
    func _isEventRelatedToAccount(account : Ext.AccountIdentifier ,event : Event) : Bool {
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

    /* 
        Returns a list of all the (extended) events of the day.
    */
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