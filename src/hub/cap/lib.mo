import Array "mo:base/Array";
import Buffer "mo:base/Buffer";
import Error "mo:base/Error";
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

import Ext "mo:ext/Ext";

import Collection "../collection";
import Types "types";
module {

    public type UpgradeData = Types.UpgradeData;
    public type Collection = Collection.Collection;


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

        /* 
            Keep track of the root bucket for all registered collections.
         */
        let cids : TrieMap.TrieMap<Collection, Principal> = TrieMap.TrieMap<Collection,Principal>(Collection.equal, Collection.hash);

        /* 
            Keep track of the cids of the collection the user has interacted with.
        */
        let cid_interacted_collections : TrieMap.TrieMap<Principal, [Principal]> = TrieMap.TrieMap<Principal,[Principal]>(Principal.equal, Principal.hash);

        /* 
            Daily cached events for all collections.
        */
        let daily_cached_events_per_collection : TrieMap.TrieMap<Principal, [Types.Event]> = TrieMap.TrieMap<Principal,[Types.Event]>(Principal.equal, Principal.hash);

        /* 
            Daily cached events for all users.
         */
        let daily_cached_events_per_user : TrieMap.TrieMap<Principal, [Types.ExtendedEvent]> = TrieMap.TrieMap<Principal,[Types.ExtendedEvent]>(Principal.equal, Principal.hash);


        /* 
            Daily cached stats for all users. 
        */

        let daily_cached_stats_per_user : TrieMap.TrieMap<Principal, Types.CapStats> = TrieMap.TrieMap<Principal,Types.CapStats>(Principal.equal, Principal.hash);


        /* 
            All time cached stats for all users.
        */

        let engagement_stats_per_user : TrieMap.TrieMap<Principal, Types.CapStats> = TrieMap.TrieMap<Principal, Types.CapStats>(Principal.equal, Principal.hash);

        public func preupgrade() : UpgradeData {
            return({
                cids = Iter.toArray(cids.entries());
                cid_interacted_collections = Iter.toArray(cid_interacted_collections.entries());
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
            label l while(not is_over and count < 100){
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
                        let caller = event.caller;
                        let extended_event = _eventToExtendendEvent(event, cid);
                        switch(daily_cached_events_per_user.get(caller)){
                            case(null){
                                daily_cached_events_per_user.put(caller, [extended_event]);
                            };
                            case(? events){
                                daily_cached_events_per_user.put(caller, Array.append<Types.ExtendedEvent>(events, [extended_event]));
                            };
                        };
                        r.add(event);
                    } else if (time < yesterday){
                        is_over := true;
                    };
                };
                count := count + 1;
                // Add a security to stop the loop if the page number is too high or empty.
                if(events.size() == 0){
                    is_over := true;
                };
            };
            return(r.toArray());
        };


        /* 
            Update the daily stats for all users.
         */
        public func cronStats () : Result.Result<(), Text> {
            for((user, events) in daily_cached_events_per_user.entries()){
                let stats = _getDailyStats(user, events);
                daily_cached_stats_per_user.put(user, stats);
            };
            return #ok(());
        };

        /* 
            Returns the stat object from the list of events of the specified user.
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


        


        //////////
        // API //
        ////////


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
                // TODO : When Promise.all. Currently this might take a long time to perfom 😢
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
                            case(#Nat64(message)){
                                price := message;
                            };
                            case _ {};
                        };
                    };
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
            _Logs.logMessage("Could not find the ICP amount of the sale event : " # Principal.toText(collection));
            return 0;
        };

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


    };
}