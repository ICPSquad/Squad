import Array "mo:base/Array";
import Blob "mo:base/Blob";
import Buffer "mo:base/Buffer";
import Cycles "mo:base/ExperimentalCycles";
import HashMap "mo:base/HashMap";
import Int "mo:base/Int";
import Iter "mo:base/Iter";
import List "mo:base/List";
import Nat "mo:base/Int64";
import Nat64 "mo:base/Nat64";
import Nat8 "mo:base/Nat8";
import Option "mo:base/Option";
import Principal "mo:base/Principal";
import Result "mo:base/Result";
import Text "mo:base/Text";
import Time "mo:base/Time";

import AccountIdentifier "../dependencies/util/AccountIdentifier";
import Admins "Admins";
import AirdropModule "types/airdrop";
import AvatarModule "types/avatar";
import Canistergeek "../dependencies/canistergeek/canistergeek";
import Hex "../dependencies/util/Hex";
import Inventory "types/inventory";
import InvoiceType "../invoice/Types";
import Ledger "../dependencies/Ledger/ledger";
import LedgerCandid "../dependencies/Ledger/ledgerCandid";
import Logs "Logs";
import LogsTypes "Logs/types";
import Users "types/users";
import Utils "utils";


shared ({caller = creator}) actor class Hub() = this {


    //////////////
    // METRICS //
    ////////////

    private let canistergeekMonitor = Canistergeek.Monitor();
    stable var _canistergeekMonitorUD: ? Canistergeek.UpgradeData = null;
    stable var adminsData : [Principal] = [Principal.fromText("whzaw-wqyku-y3ssi-nvyzq-m6iaq-aqh7x-v4a4e-ijlft-x4jjg-ymism-oae")];

    private func _isAdminData(p : Principal) : Bool {
        switch(Array.find<Principal>(adminsData, func(v) {return v == p})) {
            case (null) { false; };
            case (? v)  { true; };
        };
    };

    // Updates the access rights of one of the admin data.
    //@auth : admin
    public shared({caller}) func updateAdminsData(user : Principal, isAuthorized : Bool) : async Result.Result<(), Text> {
        assert(_admins.isAdmin(caller));
        switch(isAuthorized) {
            case (true) {
                adminsData := Array.append(
                    adminsData,
                    [user],
                );
            };
            case (false) {
                adminsData := Array.filter<Principal>(
                    adminsData, 
                    func(v) { v != user; },
                );
            };
        };
        #ok();
    };

    //  Returns collected data based on passed parameters. Called from browser.
    public query ({caller}) func getCanisterMetrics(parameters: Canistergeek.GetMetricsParameters): async ?Canistergeek.CanisterMetrics {
        assert(_isAdminData(caller));
        canistergeekMonitor.getMetrics(parameters);
    };

    //  Force collecting the data at current time. Called from browser or by heartbeat.
    public shared ({caller}) func collectCanisterMetrics(): async () {
        assert(_isAdminData(caller));
        canistergeekMonitor.collectMetrics();
    };


    type Time = Time.Time;
    public type User = Users.User;
    public type Status = Users.Status;
    public type ResultRequest = Users.ResultRequest;



    //////////////
    // ADMINS ///
    ////////////

    stable var stableAdmins : [Principal] = [creator];
    let _admins = Admins.Admins({
        admins = stableAdmins;
    });

    public query func is_admin(p : Principal) : async Bool {
        _admins.isAdmin(p);
    };

    public shared ({caller}) func add_admin(p : Principal) : async () {
        _admins.addAdmin(p, caller);
    };

    ////////////////////
    // USER DATABASE //
    ///////////////////
    
    stable var usersEntries : [(Principal,User)] = [];
    let users : HashMap.HashMap<Principal,User> = HashMap.fromIter(usersEntries.vals(),0,Principal.equal, Principal.hash);

    public query func numberUsers () : async Nat {
        return(users.size());
    };


    ///////////
    // MINT //
    //////////

    public type TokenIdentifier = Text;
    public type AccountIdentifier = Text;
    public type ExtCoreUser = {
        #address : AccountIdentifier; //No notification
        #principal : Principal; //defaults to sub account 0
    };
    public type ComponentRequest = {
        name : Text;
        layer : Nat8;
    };
    public type MintRequest = {
        to : ExtCoreUser;
        metadata : AvatarRequest;
    };

    public type Color =  AvatarModule.Color;
    public type AvatarRequest = AvatarModule.AvatarRequest;
    public type AvatarResponse = AvatarModule.AvatarResponse;
    public type AvatarInformation = AvatarModule.AvatarInformations;
    

    // Initialize actor for canister responsible of avatars 
    let actorAvatar = actor ("jmuqr-yqaaa-aaaaj-qaicq-cai") : actor {
        mint : shared MintRequest -> async Result.Result<AvatarInformation,Text>;
        supply : shared () -> async Nat;
        availableCycles : shared () -> async Nat;
        collectCanisterMetrics : shared () -> async ();
        verificationEvents : shared () -> async ();
        init_cap : shared () -> async Result.Result<(), Text>;
    };

    // Mint 
    // @pre : _mintVerification (user is a member/ user doesn't already have an avatar minted)
    public shared(msg) func mintRequest (request : MintRequest) : async AvatarResponse {
        switch (_mintVerification(request, msg.caller)) {
            case (#err(msg)) return #err(msg);
            case (#ok) {
                // We prevent users from sending multiples mintRequest and abusing the system causes this function is not atomic by adding a fake token identifier -> _mintVerification will now send an error. 
                _addAvatar("-1", msg.caller);
                switch(await actorAvatar.mint(request)){
                    case(#err(message)) {
                        // Remove the fake token identifier so user can try again. 
                        _removeAvatar(msg.caller);
                        return #err(message);
                    };
                    case(#ok(avatar_info)) {
                        let token_identifier = avatar_info.tokenIdentifier;
                        let svg = avatar_info.svg;

                        // Overwrite the fake tokenidentifier with the real one once mint has been effectued. 
                        _addAvatar(token_identifier, msg.caller);
                        return #ok(avatar_info);
                    };
                };
            };
        };
    };

      
    private func _mintVerification (mint : MintRequest, caller : Principal) : Result.Result<(), Text> {
        switch(users.get(caller)) {
            case (null)  {
                let error : MintingError = #Verification("Not a member");
                let time = Time.now();
                errorsMinting.put(time, error);
                return #err ("Not a member");
            };
            case (?user) {
                switch (user.avatar) {
                    case (?avatar) {
                        let error : MintingError = #Verification("An avatar already exists");
                        let time = Time.now();  
                        errorsMinting.put(time, error);
                        return #err ("An avatar already exists");
                    };
                    case (null) {
                        return #ok;
                    };
                };
            };
        };
    };

    

    // Log eventual errors during the minting process

    type MintingError =  {
        #Verification : Text;
        #Avatar : Text;
    };

    stable var errorsMintingEntries : [(Time,MintingError)] = [];
    let errorsMinting : HashMap.HashMap<Time,MintingError> = HashMap.fromIter(errorsMintingEntries.vals(), 0, Int.equal, Int.hash);

    // Return recorded errors during minting
    //@auth : admin
    public shared query ({caller}) func showErrors () : async [(Time,MintingError)] {
        assert(_admins.isAdmin(caller));
        let array = Iter.toArray(errorsMinting.entries());
        return array;
    };




    private func _userVerification (p : Principal) :  Result.Result<(),Text> {
        switch(users.get(p)){
            case(null) {
                return #err("You haven't registered.");
            };
            case(?user) {
                switch(user.avatar) {
                    case (?avatar) {
                        return #err("You have already minted your avatar.");  
                    };
                    case(null) {
                        return #ok;
                    };
                };
            };
        };
    };

    private func _addAvatar (token_identifier : Text, principal : Principal) : () {
        switch(users.get(principal)){
            case(null) return;
            case(?user) {
                let new_user : User = {
                wallet = user.wallet;
                email = user.email;
                discord = user.discord;
                twitter = user.twitter;
                height = user.height;
                rank = user.rank;
                avatar = ?token_identifier;
                airdrop = user.airdrop;
                status = user.status;
                };
                users.put(principal, new_user);
                return;
            };
        };
    };

    private func _removeAvatar (principal : Principal) : () {
        switch(users.get(principal)){
            case (null) return;
            case(?user) {
                let new_user : User = {
                    wallet = user.wallet;
                    email = user.email;
                    discord = user.discord;
                    twitter = user.twitter;
                    height = user.height;
                    rank = user.rank;
                    avatar = null;
                    airdrop = user.airdrop;
                    status = user.status;
                };
                users.put(principal, new_user);
                return;
            };
        };
    };



    //////////////
    // AIRDROP //
    ////////////


    // TOP 20 % (500) -> 2 accessory + 1 material
    // TOP 50 % (2500) -> 1 accessory + 1 material
    // TOP 100% (5000) -> 1 materials

    // possibleMaterials ->  ["Wood", "Glass", "Cloth", "Metal", "Circuit", "Dfinity-stone"];
    // possibleAccessory1 -> ["Dfinity-face-mask", "Gas-mask", "Lab-glasses", "Matrix-glasses", "Monocle", "Oni-half-mask" , "Dfinity-eyemask"];
    // possibleAccessory2 -> ["Helicap", "Marshall-hat", "Ninja-headband"];

    public type AirdropObject = AirdropModule.AirdropObject;
    public type AirdropResponse = Result.Result<AirdropObject, Text>;
    public type Inventory = Inventory.Inventory;

    let actorItems = actor ("po6n2-uiaaa-aaaaj-qaiua-cai") : actor {
        airdrop : shared (AirdropObject) -> async Result.Result<(), Text>;
        supply: shared () -> async Nat;
        availableCycles : shared () -> async Nat;
        collectCanisterMetrics : shared () -> async ();
        verificationEvents : shared () -> async ();
        init_cap : shared () -> async Result.Result<(), Text>;
    };

    //TODO replace 
    public shared(msg) func airdrop () : async AirdropResponse {
        let principal = msg.caller;
        switch(users.get(principal)){
            case(null) return #err("User not found.");
            case(?user){
                switch(user.airdrop){
                    case(?list) return #err("You have already been airdropped.");
                    case(null){
                        switch(user.rank){
                            case(null) return #err("You were not part of the preorder.");
                            case(?rank){
                                if(rank > 5000) {
                                    return #err("You were not part of the preorder.");
                                };
                                // WARNING This function will await so it can be spawned for multiples airdrops 
                                // We prevent that by temporary changing the user airdrop field so it will throw an error if the user try to call the function again while awaiting. 
                                let user_temp : User = {
                                    wallet = user.wallet;
                                    email = user.email;
                                    discord = user.discord;
                                    twitter = user.twitter;
                                    height = user.height;
                                    rank = user.rank;
                                    avatar = user.avatar;
                                    airdrop = ?["InProgress"];
                                    status = user.status;
                                };
                                users.put(principal, user_temp);
                                let airdrop_object = AirdropModule.airdropObjectFromRank(Nat64.toNat(rank), principal);
                                switch(await actorItems.airdrop(airdrop_object)){
                                    case(#err(message)){
                                        let new_user : User = {
                                            wallet = user.wallet;
                                            email = user.email;
                                            discord = user.discord;
                                            twitter = user.twitter;
                                            height = user.height;
                                            rank = user.rank;
                                            avatar = user.avatar;
                                            airdrop = null;
                                            status = user.status;
                                        };
                                        users.put(principal, new_user);
                                        return #err(message);
                                    };
                                    case(#ok){
                                        let list_airdrop = AirdropModule.aidropObjectToList(airdrop_object);
                                        let new_user : User = {
                                            wallet = user.wallet;
                                            email = user.email;
                                            discord = user.discord;
                                            twitter = user.twitter;
                                            height = user.height;
                                            rank = user.rank;
                                            avatar = user.avatar;
                                            airdrop = ?list_airdrop; 
                                            status = user.status;
                                        };
                                        users.put(principal, new_user);
                                        return #ok(airdrop_object);
                                    };
                                };
                            };
                        };
                    };
                };
            };
        };
    };


    // FRONTEND ENDPOINTS
    // TODO : Replace -> Wrap everything in one method

    public query func getRank (p : Principal) : async ?Nat{
        switch(users.get(p)){
            case(null) return null;
            case(?user) {
                switch(user.rank){
                    case(null) return null; 
                    case(?rank) {
                        return(?Nat64.toNat(rank));
                    };
                };
            };
        };
    };


    public shared query (msg) func isUserAuthorized () : async Result.Result<(), Text> {
        switch(_userVerification(msg.caller)){
            case(#err(message)){
                return #err(message);
            };
            case(#ok) {
                return #ok;
            };
        };
    };




    ///////////////
    // PAIEMENTS //
    //////////////

    // This canister is used to convert the protobuff interface of the ledger canister to a candid interface which can be used with Motoko.
    let actorCandidLedger : LedgerCandid.Interface = actor("uexzq-gqaaa-aaaaj-qabua-cai");
    let actorLedger : Ledger.Interface = actor ("ryjl3-tyaaa-aaaaa-aaaba-cai");
    type SubAccount = Ledger.SubAccount;

    // Generate AccountIdentifier as 32-byte array from corresponding subbacount of this canister.
    // The first 4-bytes is a big-endian encoding of CRC32 checksum of the last 28-bytes. 
    private func _myAccountIdentifier(subaccount : ?SubAccount) : [Nat8] {
        return((AccountIdentifier.fromPrincipal_raw(Principal.fromActor(this), subaccount)));
    };


    // Balance of this canister subaccount0 using the ledger canister. 
    public shared func balance () : async Ledger.ICP {
        await actorLedger.account_balance({
            account = _myAccountIdentifier(null);
        });
    };

    // Transfer amount of ICP from this canister subaccount0 to the specified Principal (as text) subaccount0.
    // @auth : admin

    public shared ({caller}) func transfer (amount : Ledger.ICP, receiver : Principal) : async Ledger.TransferResult {
        assert(_admins.isAdmin(caller) or caller == Principal.fromActor(this));
        let account_raw : [Nat8] = AccountIdentifier.fromPrincipal_raw(receiver, null);
        await actorLedger.transfer({
            memo = 1998;
            amount = amount;
            fee = { e8s = 10_000};
            from_subaccount = null;
            to = account_raw;
            created_at_time = ?{timestamp_nanos = Nat64.fromIntWrap(Time.now())};
        });
    };


    ///////////////
    // JOINING ///
    /////////////

    // Check if caller is already registered 
    public shared query ({caller}) func checkRegistration () : async Bool {
        switch(users.get(caller)){
            case(null) return false;
            case(?user) return true;
        };
    };

    private let AMOUNT  = {e8s = Nat64.fromNat(100000000)};
    private let sa_zero : [Nat8] = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];
    
    type Infos = Users.Infos;
    private stable var prejoinEntries : [(Principal, Infos)] = [];
    let prejoins : HashMap.HashMap<Principal, Infos> = HashMap.fromIter(prejoinEntries.vals(), 0, Principal.equal, Principal.hash);

    public shared query ({caller}) func showPrejoins () : async [(Principal, Infos)] {
        return(Iter.toArray(prejoins.entries()));
    };

    public type PaymentError = Users.PaymentError;
    private stable var errorsPaymentsEntries : [(Time,PaymentError)] = [];
    private let errorsPayments : HashMap.HashMap<Time,PaymentError> = HashMap.fromIter(errorsPaymentsEntries.vals(), 0, Int.equal, Int.hash);

    public shared ({caller}) func prejoin (wallet : Text, email : ?Text, discord : ?Text, twitter : ?Text, subaccount : SubAccount) : async Result.Result<Nat64, Text> {
        if (Array.equal<Nat8>(sa_zero, subaccount, Nat8.equal)){
            return #err("Cannot use the subbacount0 as receiver");
        };
        if(caller == Principal.fromText("2vxsx-fae")){
            return #err("Need to be authenticated");
        };
        if(Option.isSome(users.get(caller))){
            return #err("Already joined");
        };
        if (wallet != "Plug" and wallet != "Stoic") {
            return #err("Wallet not compatible");
        };
        let memo : Nat64 = Nat64.fromIntWrap(Time.now());
        let infos = {wallet = wallet; email = email; discord = discord; twitter = twitter; subaccount_to_send = subaccount; memo = memo;};
        subaccount_to_check := Array.append<SubAccount>(subaccount_to_check, [subaccount]);
        prejoins.put(caller, infos);
        return #ok(memo);
    };

    public shared({caller}) func confirm (height : Nat64) : async Result.Result<(), Text> {
        if(Principal.fromText("2vxsx-fae") == caller){
            return #err("Need to be authenticated");
        };
        if(Option.isSome(users.get(caller))){
            return #err("Already joined");
        };
        switch(prejoins.get(caller)){
            case(null) return #err("Need to prejoin before");
            case(?info) {
                if(await _checkPayment(info.subaccount_to_send)){
                    let user = _createNewUser(info, height);
                    users.put(caller, user);
                    prejoins.delete(caller);    
                    ignore(_sendBackFrom(info.subaccount_to_send));
                    return #ok;
                } else {
                    let error : PaymentError = {
                        caller = caller;
                        error_message = "No payment found";
                        request_associated = ?info;
                    };
                    errorsPayments.put(Time.now(), error);
                    return #err("Payment not found")
                };
            };
        };
    };

   
    

    public shared query ({caller}) func showPaymentErrors() : async [(Time,PaymentError)] {
        assert(_admins.isAdmin(caller));
        return(Iter.toArray(errorsPayments.entries()));
    };

    // This function is used internally everytime a new user join, to send back ICPs from the corresponding subaccount to the main account
    private func _sendBackFrom (subaccount : SubAccount) : async () { 
        let result_transfer = await actorLedger.transfer({
            memo = 666;
            amount = {e8s =  99990000}; //We need to remove the transfer fee 
            fee = {e8s = 10_000};
            from_subaccount = ?subaccount;
            to = _myAccountIdentifier(null);
            created_at_time = ?{timestamp_nanos = Nat64.fromIntWrap(Time.now())};
            });
        return ();
    };

    // This function check is subaccount are received the 1 ICP as a proof of payment!
    private func _checkPayment (subaccount : SubAccount) : async Bool {
        let account_to_check = {account = _myAccountIdentifier(?subaccount)};
        let balance = await actorLedger.account_balance(account_to_check);
        if (balance.e8s == 100_000_000) {
            return true;
        };
        return false;
    };
    
    private func _createNewUser (infos : Infos, height : Nat64) : User {
        let new_user = {
            wallet = infos.wallet;
            email = infos.email;
            discord = infos.discord;
            twitter = infos.twitter;
            rank = ?Nat64.fromNat(users.size());
            height = ?height;
            avatar = null;
            airdrop = null;
            status = #Level1;
        };
        return new_user;
    };


    ////////////
    // USERS //
    ///////////

    
    // Get user informations of the specified principal
    //@auth : admin
    public shared query ({caller}) func showUser (p : Principal) : async ?User {
        assert(_admins.isAdmin(caller));
        switch(users.get(p)){
            case(null) return null;
            case(?user) return ?user;
        };
    };


    // Allow us to whitelist people and add people who have issue with the payment flow. 
    // @auth : admin
    public shared({caller}) func addUser ( p : Principal, user : User) : async Result.Result<(),Text> {
        assert(_admins.isAdmin(caller));
        switch(users.get(p)){
            case(?user) return #err("An user already exists for this principal.");
            case(null) {
                users.put(p, user);
                return #ok;
            };
        };
    };

    //Allow us to modify entries for an already existing user
    //@auth : admin
    public shared ({caller}) func modifyUser (p : Principal, user : User) : async Result.Result<(),Text> {
        assert(_admins.isAdmin(caller));
        switch(users.get(p)){
            case(null) return #err("No user found for principal : " #Principal.toText(p));
            case(?someone){
                users.put(p, user);
                return #ok;
            };
        };
    };

    public shared({caller}) func modifyRank(p : Principal, new_rank : Nat64) : async Result.Result<(), Text> {
        assert(_admins.isAdmin(caller));
        switch(users.get(p)){
            case(null) return #err("No user found for principal : " #Principal.toText(p));
            case(?user){
                let new_user : User = { avatar = user.avatar; wallet = user.wallet; discord = user.discord; twitter = user.twitter; email = user.email; airdrop = user.airdrop; height = user.height; status = user.status; rank = ?new_rank};
                users.put(p, new_user);
                return #ok;
            };
        };
    };

    public shared({caller}) func modifyHeight(p : Principal, new_height : Nat64) : async Result.Result<(), Text> {
        assert(_admins.isAdmin(caller));
        switch(users.get(p)){
            case(null) return #err("No user found for principal : " #Principal.toText(p));
            case(?user){
                let new_user : User = { avatar = user.avatar; wallet = user.wallet; discord = user.discord; twitter = user.twitter; email = user.email; airdrop = user.airdrop; height = ?new_height; status = user.status; rank = user.rank};
                users.put(p, new_user);
                return #ok;
            };
        };
    };




    // Allow us to remove people form the list 
    //@auth : admin
    public shared({caller}) func removeUser(p : Principal) : async Result.Result<Text,Text> {
        assert(_admins.isAdmin(caller));
        switch(users.remove(p)){
            case(null) return #err("No user found with this principal : " # Principal.toText(p));
            case(?user) return #ok("User with principal : " # Principal.toText(p) # " has been removed.");
        };
    };


    // To query our database and extract data. 
    // @auth : admin 
    public shared({caller}) func getInformations() : async [(Principal,User)] {
        // assert(_admins.isAdmin(caller));
        return(Iter.toArray(users.entries()));
    };

    //////////////
    // UPGRADE //
    ////////////

    system func preupgrade() {
        usersEntries := Iter.toArray(users.entries());
        prejoinEntries := Iter.toArray(prejoins.entries());
        errorsMintingEntries := Iter.toArray(errorsMinting.entries());
        errorsPaymentsEntries := Iter.toArray(errorsPayments.entries());
    };

    system func postupgrade() {
       usersEntries := [];
       prejoinEntries := [];
       errorsMintingEntries := [];
       errorsPaymentsEntries := [];
    };


    ///////////////////
    // VERIFICATION //
    /////////////////

    // A list of subaccounts that are supposed to have send their ICPs back to the main account : we regularly run check on their balance. 👮‍♀️
    private stable var subaccount_to_check  : [SubAccount] = [];
    private stable var subaccounts_robber : [SubAccount] = [];

    //Check all subaccounts to see if their balance is non-null, returns the list of those were the balance is not null!
    //@auth : canister
    public shared ({caller}) func verification () : async () {
        assert(caller == Principal.fromActor(this) or _admins.isAdmin(caller));
        var robbers : [SubAccount] = [];
        for (subaccount in subaccount_to_check.vals()){
            let account_to_check = {account = _myAccountIdentifier(?subaccount)};
            let balance = await actorLedger.account_balance(account_to_check);
            let amount = balance.e8s;
            if(amount > 0) {
                subaccounts_robber := Array.append<SubAccount>(subaccounts_robber, [subaccount]);
            };
        };
        subaccount_to_check := [];
        return ();
    };

    public shared query ({caller}) func show_robbers() : async [SubAccount] {
        assert(caller == Principal.fromActor(this) or _admins.isAdmin(caller));
        subaccounts_robber;
    };

    //Process to the paiement of the concerned subbaccounts

    public shared ({caller}) func process () : async () {
        assert(caller == Principal.fromActor(this) or _admins.isAdmin(caller));
        for (subaccount in subaccounts_robber.vals()){
            await (_sendBackFrom(subaccount));
        };
        subaccounts_robber := [];
    };


    /////////////
    // AUDITS //
    ////////////

    public type Audit = {time : Int; new_users : Int; new_icps : Ledger.ICP; new_avatar : Int; new_items : Int};
    stable var audits : [Audit] = [];

    //Initial value : 14th of March at 7PM - Lisbon Time.
    stable var users_nb = 5_260;
    stable var icps = {e8s = 0 : Nat64};
    stable var avatars = 3_940;
    stable var items = 6_525;

    //Run an internal audits and updates values
    //@auth : canister
    public shared ({caller}) func audit() : async () {
        let new_value_users = users.size();
        let new_value_avatar = await actorAvatar.supply();
        let new_value_items = await actorItems.supply();
        switch(await INVOICE.get_balance({ token = ICP })){
            case(#ok(answer)){
                let value : Int = answer.balance - (Nat64.toNat(icps.e8s));
                //Remove trap warning for ICPs
                let value_converted : Nat64 = Nat64.fromNat(Int.abs(value));
                //Create the audit 
                let audit = {
                    time : Int = Time.now(); new_users = (new_value_users : Int - users_nb : Int); 
                    new_icps : Ledger.ICP = {e8s = value_converted};
                    new_avatar : Int = (new_value_avatar - avatars); 
                    new_items : Int = (new_value_items - items);
                };
                audits := Array.append<Audit>(audits, [audit]);
                users_nb := new_value_users;
                icps := { e8s = Nat64.fromNat(answer.balance) };
                avatars := new_value_avatar;
                items := new_value_items;
                return;
            };
            case(#err(e)) {
                return;
            }
        };
    };  

    //Send list of all audits.
    //@auth : admin
    public shared query ({caller}) func show_audits () : async [Audit] {
        assert(_admins.isAdmin(caller));
        audits;
    };
    
    /////////////
    // RECIPE //
    ///////////

    public type RecipeInfos = {
        block : Nat64;
        amount : Nat; //e8s
    };
    
    let principal_wallet : Principal = Principal.fromText("rj53v-z27so-pkgug-6rcn4-3axje-ecooy-w26n2-ios6v-wxfrg-knwaj-jae");
    let TEST_WALLET : InvoiceType.AccountIdentifier = #text("0b0a0d93991445d0b833084257bcb21a8dd4b42fec0f775d3bf7bd8e3751bc9a");

    //Send recipe of the week to the wallet specified.
    //@auth : canister.
    public shared ({caller}) func recipe() : async Result.Result<RecipeInfos, Text> {
        assert(caller == Principal.fromActor(this) or _admins.isAdmin(caller));
        switch(await INVOICE.get_balance({ token = ICP })){
            case(#ok(answer)){
                let transferArgs : InvoiceType.TransferArgs = {
                    amount = answer.balance;
                    token = ICP;
                    destination = TEST_WALLET;
                };
                switch(await INVOICE.transfer(transferArgs)){
                    case(#ok(height)) {
                        return #ok({
                            block = height.blockHeight;
                            amount = answer.balance;
                        });
                    };
                    case(#err(transfer_error)){
                        return #err("Error when transfering funds.");
                    };
                };
            };
            case(#err(e)) {
                return #err("Error when checking balance.");
            };
        };
    };


    ////////////////////////
    // CYCLES MANAGEMENT //
    //////////////////////

    public func wallet_receive() : async () {
        let available = Cycles.available();
        let accepted = Cycles.accept(available);
        assert (accepted == available);
    };

    public query func wallet_available() : async Nat {
        return Cycles.balance();
    };

    ////////////
    // LOGS ///
    ///////////

    public type Event = LogsTypes.Event;

    stable var stableEvents : [Event] = [];

    let _logs = Logs.Logs({
        events =  stableEvents;
    });

    public shared query ({caller}) func show_logs() : async List.List<Event>{
        assert(_admins.isAdmin(caller));
        return _logs.getLogs();
    };


    ///////////////
    // NEW API  //
    /////////////

    type CreateInvoiceArgs = InvoiceType.CreateInvoiceArgs;
    type CreateInvoiceResult = InvoiceType.CreateInvoiceResult;
    type GetInvoiceArgs = InvoiceType.GetInvoiceArgs;
    type GetInvoiceResult = InvoiceType.GetInvoiceResult;
    type GetBalanceArgs = InvoiceType.GetBalanceArgs;
    type GetBalanceResult = InvoiceType.GetBalanceResult;
    type VerifyInvoiceArgs = InvoiceType.VerifyInvoiceArgs;
    type VerifyInvoiceResult = InvoiceType.VerifyInvoiceResult;
    type TransferArgs = InvoiceType.TransferArgs;
    type TransferResult = InvoiceType.TransferResult;
    type Token = InvoiceType.Token;
    type Permissions = InvoiceType.Permissions;
    type Details = InvoiceType.Details;
    type TransferError = InvoiceType.TransferError;
    type GetBalanceErr = InvoiceType.GetBalanceErr;

    type InvoiceInterface = actor {
        create_invoice : shared(CreateInvoiceArgs) -> async CreateInvoiceResult;
        get_invoice : query (GetInvoiceArgs) -> async GetInvoiceResult;
        get_balance : shared (GetBalanceArgs) -> async GetBalanceResult;
        verify_invoice : shared(VerifyInvoiceArgs) -> async VerifyInvoiceResult;
        transfer :  shared(TransferArgs) -> async TransferResult;
    };

    type InfosNew = Users.InfosNew;
    type Registration = {
        time : Time;
        infos : InfosNew;
        invoice : InvoiceInfo;
    };
    type InvoiceInfo = {
        id : Nat;
        amount : Nat;
        account : Text;
        expiration : Time;
    };

    let INVOICE : InvoiceInterface = actor("if27l-eyaaa-aaaaj-qaq5a-cai");
    let ICP : Token = { symbol = "ICP" };

    private stable var _registrationsEntries : [(Principal, Registration)] = [];
    let _registrations : HashMap.HashMap<Principal, Registration> = HashMap.fromIter(_registrationsEntries.vals(), _registrationsEntries.size(), Principal.equal, Principal.hash);


    public shared ({caller}) func register (
        wallet : Text, 
        email : ?Text, 
        discord : ?Text, 
        twitter : ?Text
        ) : async Result.Result<InvoiceInfo, Text> {
        if(Principal.isAnonymous(caller)){
            return #err("You need to be authenticated.");
        };
        if(Option.isSome(users.get(caller))){
            return #err("You are already registered.");
        };
        if (wallet != "Plug" and wallet != "Stoic") {
            return #err("Your wallet is not compatible");
        };
        if(Option.isSome(_registrations.get(caller))){
            return #err("You already have a registration that is being processed.");
        };
        try {
            let args : CreateInvoiceArgs = {
                amount = 1;
                token = ICP;
                permissions = ?{ canGet = _admins.getStateStable(); canVerify = _admins.getStateStable() }; //TODO modify permissions
                details = null;
            };
            switch(await INVOICE.create_invoice(args)){
                case(#err(e)) {
                    let event : Event = {
                        time = Nat64.fromIntWrap(Time.now());
                        operation = "create_invoice";
                        details = [];
                        caller = caller;
                        category = #ErrorResult;
                    };
                    _logs.addLog(event);
                    return #err("Error when creating invoice. Please try again.");
                };
                case(#ok({invoice})){
                    switch(invoice.destination){
                        case(#text(account)){
                            let registration = {
                                time = Time.now();
                                infos = {
                                    wallet = wallet;
                                    email = email;
                                    discord = discord;
                                    twitter = twitter;
                                };
                                invoice = {
                                    id = invoice.id;
                                    amount = invoice.amount;
                                    account = account;
                                    expiration = invoice.expiration;
                                };
                            };  
                            _registrations.put(caller, registration);
                            return #ok(registration.invoice);
                        };
                        case(_) {
                            //  The invoice canister always return an account identier as text for this endpoint.
                            assert(false);  
                            return #err("Unreachable");
                        };
                    };
                };
            };
        } catch (e) {
            let event : Event = {
                time = Nat64.fromIntWrap(Time.now());
                operation = "create_invoice";
                details = [];
                caller = caller;
                category = #ErrorSystem;
            };
            _logs.addLog(event);
            throw e
        };
    };

    public shared ({caller}) func confirm_new() : async Result.Result<(), Text> {
        if(Principal.isAnonymous(caller)){
            return #err("You need to be authenticated.");
        };
        if(Option.isNull(_registrations.get(caller))){
            return #err("You don't have a registration.");
        };
        if(Option.isSome(users.get(caller))){
            return #err("You are already registered.");
        };
        ignore do ? {
            let registration = _registrations.get(caller) !;
            let args : VerifyInvoiceArgs = {
                id = registration.invoice.id;
            };
            try {
                switch(await INVOICE.verify_invoice(args)){
                    case(#ok(some)){
                        let new_user = {
                            wallet = registration.infos.wallet;
                            email = registration.infos.email;
                            discord = registration.infos.discord;
                            twitter = registration.infos.twitter;
                            rank = ?Nat64.fromNat(users.size());
                            height = null;
                            avatar = null;
                            airdrop = null;
                            status = #Level1;
                        };
                        users.put(caller, new_user);
                        _registrations.delete(caller);
                        return #ok;
                    };
                    case(#err(e)){
                        let event : Event = {
                            time = Nat64.fromIntWrap(Time.now());
                            operation = "verify_invoice";
                            details = [];
                            caller = caller;
                            category = #ErrorResult;
                        };
                        _logs.addLog(event);
                        return #err("Error when confirming your invoice. Make sure you've processed the payment and try again. If this issue persits, please contact us.");
                    };
                };
            } catch(e) {
                let event : Event = {
                    time = Nat64.fromIntWrap(Time.now());
                    operation = "verify_invoice";
                    details = [];
                    caller = caller;
                    category = #ErrorSystem;
                };
                _logs.addLog(event);
                throw e;
            };
        };
        assert(false);
        return #err("Unreacheable");
    };
    public type StatusRegistration = {
        #NotAuthenticated;
        #NotRegistered;
        #NotConfirmed : InvoiceInfo;
        #Member;
    };

    public query ({caller}) func check_status() : async StatusRegistration {
        if(Principal.isAnonymous(caller)){
            return #NotAuthenticated;
        };
        if(Option.isSome(users.get(caller))){
            return #Member;
        };
        if(Option.isSome(_registrations.get(caller))){
        ignore do ? {
                let registration = _registrations.get(caller)!;
                return #NotConfirmed(registration.invoice);
            };
        };
        return #NotRegistered;
    };

    private func verify_registration(p : Principal) : async Result.Result<(), Text> {
        switch(_registrations.get(p)){
            case(null) return #err("No registration found for this principal");
            case(?registration){
                try {
                switch(await INVOICE.verify_invoice({ id = registration.invoice.id })){
                    case(#ok(some)){
                        let new_user = {
                            wallet = registration.infos.wallet;
                            email = registration.infos.email;
                            discord = registration.infos.discord;
                            twitter = registration.infos.twitter;
                            rank = ?Nat64.fromNat(users.size());
                            height = null;
                            avatar = null;
                            airdrop = null;
                            status = #Level1;
                        };
                        users.put(p, new_user);
                        _registrations.delete(p);
                        let event : Event = {
                            time = Nat64.fromIntWrap(Time.now());
                            operation = "add_user";
                            details = [("User", #Principal(p))];
                            caller = Principal.fromActor(this) ;
                            category = #Operation;
                        };
                        return #ok;
                    };
                    case(#err(e)){
                        return #err("Error when confirming your invoice. Make sure you've processed the payment and try again. If this issue persits, please contact us.");
                    };
                };
            } catch(e) {
                let event : Event = {
                    time = Nat64.fromIntWrap(Time.now());
                    operation = "verify_invoice";
                    details = [("User", #Principal(p))];
                    caller = Principal.fromActor(this);
                    category = #ErrorSystem;
                };
                _logs.addLog(event);
                throw e;
            };
            };
        };
    };

    //  Called regularly to verify all pendings registrations. Drop registration older than 1 week.
    //  @auth : admin & canister
    public shared ({caller}) func verification_registrations() : async () {
        assert(_admins.isAdmin(caller) or caller == Principal.fromActor(this));
        for(user in _registrations.keys()){
            switch(await verify_registration(user)){
                case(#ok) {};
                case(#err(e)){
                    ignore do ? {
                        //  Drop registration older than 1 week.
                        let registration = _registrations.get(user)!;
                        if (Time.now() > registration.time + ONE_WEEK) {
                            _registrations.delete(user);
                        };
                    };
                };
            };
        };
    };


    ///////////////
    // HEARTBEAT //
    ///////////////

    // Cronic tasks planned for this canister ⏰

    // Every hour : collect metrics on all canisters (avatar, accessory & hub).
    // Every 6 hours : verify registration.
    // Every day : verify CAP registration and events on all canisters (avatar & accessory).
    // Every 7 days : audit & send recipe.

    let ONE_HOUR : Nat = 1_000_000_000 * 60 * 60;
    let ONE_DAY : Nat = ONE_HOUR * 24;
    let ONE_WEEK : Nat = ONE_DAY * 7;


    stable var time_canister = Time.now();
    stable var count_hour : Nat = 0;

    system func heartbeat() : async () {
        //  Every hour we increase the count by one. Does not depend on the number of blocks.
        if(Time.now() - time_canister > ONE_HOUR){
            time_canister := Time.now();
            count_hour += 1;
            //  Every 7 days 
            if(count_hour % 168 == 0) {
                //  Process audit. Do not await.
                ignore(audit());
                _logs.addLog({
                    time = Nat64.fromIntWrap(Time.now());
                    operation = "Audit";
                    details = [];
                    caller = Principal.fromActor(this);
                    category = #Cronic;
                });
                //  Process recipe of the week. Await.
                switch(await recipe()){
                    case(#ok(infos)){
                        _logs.addLog({
                            time = Nat64.fromIntWrap(Time.now());
                            operation = "recipe";
                            details = [("Block",#U64(infos.block)), ("Amount", #U64(Nat64.fromNat(infos.amount)))];
                            caller = Principal.fromActor(this);
                            category = #Cronic;
                        });
                    };
                    case(#err(e)){
                        _logs.addLog({
                            time = Nat64.fromIntWrap(Time.now());
                            operation = "recipe";
                            details = [("Err", #True)];
                            caller = Principal.fromActor(this);
                            category = #Cronic;
                        });
                    };
                };
            };
            //  Every day 
            if (count_hour % 24 == 0) {
                // Verification that CAP is initialized and process events.
                // Avatar
                switch(await actorAvatar.init_cap()){
                    case(#ok){
                        _logs.addLog({
                            time = Nat64.fromIntWrap(Time.now());
                            operation = "init_cap";
                            details = [("Canister", #Principal(Principal.fromText("jmuqr-yqaaa-aaaaj-qaicq-cai")))];
                            caller = Principal.fromActor(this);
                            category = #Cronic;
                        });
                        ignore(actorAvatar.verificationEvents());
                    };
                    case(#err(message)){
                        _logs.addLog({
                            time = Nat64.fromIntWrap(Time.now());
                            operation = "init_cap";
                            details = [("Canister", #Principal(Principal.fromText("jmuqr-yqaaa-aaaaj-qaicq-cai"))), ("Error", #Text(message))];
                            caller = Principal.fromActor(this);
                            category = #Cronic;
                        });
                    }
                };
                // Accessory
                switch(await actorItems.init_cap()){
                    case(#ok){
                        _logs.addLog({
                            time = Nat64.fromIntWrap(Time.now());
                            operation = "init_cap";
                            details = [("Canister", #Principal(Principal.fromText("po6n2-uiaaa-aaaaj-qaiua-cai")))];
                            caller = Principal.fromActor(this);
                            category = #Cronic;
                        });
                        ignore(actorItems.verificationEvents());
                    };
                    case(#err(message)){
                        _logs.addLog({
                            time = Nat64.fromIntWrap(Time.now());
                            operation = "init_cap";
                            details = [("Canister", #Principal(Principal.fromText("po6n2-uiaaa-aaaaj-qaiua-cai"))), ("Error", #Text(message))];
                            caller = Principal.fromActor(this);
                            category = #Cronic;
                        });
                    };
                };
            };
            //  Every 6 hours
            if(count_hour % 6 == 0){
                await (verification_registrations());
                _logs.addLog({
                    time = Nat64.fromIntWrap(Time.now());
                    operation = "verification_registrations";
                    details = [];
                    caller = Principal.fromActor(this);
                    category = #Cronic;
                });
            };
            // Every 1 hour
            ignore(actorAvatar.collectCanisterMetrics());
            ignore(actorItems.collectCanisterMetrics());
            ignore(collectCanisterMetrics());
        };
    };

    /// Winners 

    let winners : [Text] = [
    "409a1fd3468b823b6487fef34c9f63618c93f21d086c0b101959e5ad62d7dd68",
   "8488106ba7d8a1c7a5594b69b43580a0c2afd9b158693e10da4cbf9147bc0440",
   "7e6c6c188cac1bee498a70b0baf1eef42484abf37cf1ab25c17107d135b80fb7",
   "f29c81ac954aab6f6275bf11012629e3bafa4af6bfea99ec9bcc8135c6eaad22",
   "12f09926a1baf3ce852a1fa7046d19cbb1df5fd417950ee30cb676e0ad5dddb2",
   "df5afb82dddb6eb4b9373912ee09f6e1d55784c11eb0322c82a1192c93aceb14",
   "9374c095ba58b1dbced3b21cc08d2194cc90194f97a7c6a9d630b8cc7a7232b1",
   "3013ecb8e0776f6914a216b4ed310447542880c93765818a8dabcbc14c2aa0b8",
   "98d4009daf774ea5c32ef246f1e4202d404c01051346bda0c08cc5d5cff6cc3d",
   "3d125a0f3506d9a98fe952606e449227d65ffbe752c09b9b4407fab5da33c418",
   "d8b23223674cfd3637a0da61af0efdb0156e33b90dba34ac6d5190c68b172fed",
   "4fb5963ff6f62ebdb95832e098c02ee134bd556a97762073ac263a0608261de1",
   "d4553590e1b4b84faf3b1b91749c2c5f16a5459b5fec01065328988e2f11291f",
   "de3646106b8edb40cd2b666fea8cc9790980555b0f4432d922e4d09d470f4928",
   "44f9ff399b8623f1b861182088495c47923ae348eeb9a26350147b9b0175a3f4",
   "22239b378a431648ae42ea83274870fd7cfeaa77cc745822681f1132412fa9ea",
   "3496ccc519f4f67acbed07b7ab74757da29f720341f14506db945b64c34c5c43",
   "79ee5e1df165a3ce1209d0547ff7f098f9f8591f87b159191435929af0fc50fd",
   "7caaa9813fdd6afe7c592620cf8fac5fda59c2a7092d9e73b63c994686935c18",
   "b64b1a5cba1ab89058da54ab153b4df6ed2fa2fce67b65bac669eb1e1d5b5456",
   "beb23b0a9151a401b45bbaff31d354cc21a71f0ab297eefa230f718d4173f67f",
   "a174fc6cc3bbbedfad818bd55e5c560e518dfd1ae07aed32bb20f42909331125",
   "559c7b7e4f441a63879940321770d1ba3fedce2db7e150f8ab966afcd54b6820",
   "6972327a4d27f636b4ee419281d4e09096ea01259d99b14a4b87c5c5bf6d60ed",
   "bad4b430e7c37207bbccbfae84d7988eafa3a5134d4a38de96b1c89db2305ab8",
   "7cbf72cc98c771379fefe75c1058b4051aa2a6c1df9e80054e43158837befb80",
   "f83cd2085a4ec7cadfc1f64a872ed59119a5a19f1d57b2f387467e9c5f209980",
   "36117a4102b241effedeaaf3b7757967f994ec9fdfca1217b307716891ecdad7",
   "912eff28dbb364950d9210382df8461492f2eb9d24d162ace41af5639824f239",
   "651448ccd04e0b4b158d1ed20dfd85c2579f0c436f7c3cc5d8b609af18f4c0af",
   "6644e3a255d8a7d8c29f11374a72543c1543568d8988c2a3f5af5e2afb39fb9a",
   "a781539b7f9ed19ee31fe528387c15d3dd2dcdfde24397f1d91285c58dd6e2c8",
   "142089e646a464b62338c3b077d2c24b675565a67e068478463ac5de2c18dfe6",
   "3bba8d7304ea66a3f9cc1393abc9bf1e537df02ae9003b509ec962c91e735d5a",
   "52e3ae95365778915dd75e595584dd101b1e633af0b601f08e70a0bab87eacc5",
   "e040da9d2fcdebfa3b1ea3bbb6ca8eed614421e0e345eb790172c6b47d674680",
   "838772fcbcbbe82a0a710498d954d0b16e1b465438d3573ea9be57a89b2290c8",
   "8fa0166bcdb1b7f1de637b88661e8303eeebb023666c8893dfa260afaee9d524",
   "c60b9a71620abbf10f2e8733b03bd70af49ebcb385052dff8a70adf8759d52c1",
   "7ed274485973a7f234f190ec30b7553b39a39f3e888b5b5fd7766f15730c2575",
   "b4c9257239d54f35b48975698083aa495100fa5db3092a2f62a3ebe1cfbfb578",
   "1efc9b6f21af5fa1e703f7aa6352543bca1b1c5aa52936c7aa991d1f6ba8fda3",
   "4b3d496c927e5d1ee4117c35ffb1a400b278e5e6edb18928169b0651459e2367",
   "f2e20eb44cf1c8a785fa54ea9973f6f1c25e9769ea5c86a7747269e5c64576b6",
   "8bec41f5f07ae90bc6b08b682757f1bccb40b9ffe934358c6db8da50a7005180",
   "5cbaaabe251f68b86989040942edeeddaad3fa411b0ca9c528f3e68229654941",
   "527f4857f88275bfd38cf471c51f3506e68e9fc173e9223407ec250a99c80cde",
   "af61935ee4e7cb9231d00d9f0ed6cb58ada4c5887480c4a591022624a5cb7db9",
   "1939ae0d38e14a78290c822c2d98553fae16fff58fbc8dc48c399d7ae169a817",
   "ab8f4f9e1c720e220693d6a60274fbc50858b53a33b85014821a7c810e24fad4",
   "39294f6e8cba436a3ba706f3339995447024010079b7d611fddb68a63112acea",
   "0ea1ff7b51a93974a55af5981e4e76b9885885fdad73b689a23ac19e048d8166",
   "d5291591704b51b43b277d3f232d171bf6a6cd66338751ea8750415a28d1494b",
   "725330a2f9b046386f4b115f932075fba636ef3739d1a654118ea0f46f89446e",
   "43ffcf40708daa8b23c63f6d0bd232a84b23969a45a00e84f39975d3b9040e73",
   "65c5f34a3a20d4934272ac64fc48f7791224224c7c0b9166f41b943be8697ad9",
   "3a06858e7fb4ceac1f8f5b560cd34d361af4d9b7b48b4d7f1221b1ea62c7f1ca",
   "b775bca11d1dcbd6987d69d338170eaf195ab246ebc903348003fa1b7d45af73",
   "be8b11fb4053b84fd3eeaa721a20596b43229d03e8bbcf87272f6acc77919d85",
   "41459b9f397337145d074f152ae8019a97679f90c04ef08ee038149eed93c63f",
   "9991a4b861652d61f8acf88796f4bce82c51e3defbcce110c7da288b64e6ceb2",
   "4c98f9b42c5aa93c198d9a0374715db6e4348dddf75599636c0204cfe3e1f479",
   "e7c12112448b51f82ce46fc4f66b4ad293258da33f5561438d14f42bac6e8795",
   "eaf19248d3934d61e094ddb83dbd9f42908754177903167741ec89bc4265291c",
   "84f08faca1636aa9b04029c4ced67352721dab5b3d42cbc616ee0a2dbf3778d1",
   "abf6621cce696d670c28446a96916f9c1ed13c58f4cc3163061875a145fffd4e",
   "68ab1b3726c9b24075d66056684d1dac5cbdf38df79994a7ebbdb18eef76ce26",];



    public func get_principals() : async [(Principal, AccountIdentifier, ?Text)] {
        var buffer : Buffer.Buffer<(Principal,AccountIdentifier,?Text)> = Buffer.Buffer(0);
        for((principal,user) in users.entries()){
            let account = AccountIdentifier.fromPrincipal(principal, null);
            switch(Array.find<Text>(winners, func (x) { x == account})){
                case(null){};
                case(? some){
                    buffer.add((principal,account,user.twitter));
                };
            };
        };
        buffer.toArray();
    };

};