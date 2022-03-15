import Array "mo:base/Array";
import Blob "mo:base/Blob";
import HashMap "mo:base/HashMap";
import Int "mo:base/Int";
import Iter "mo:base/Iter";
import Nat "mo:base/Int64";
import Nat64 "mo:base/Nat64";
import Option "mo:base/Option";
import Principal "mo:base/Principal";
import Result "mo:base/Result";
import Text "mo:base/Text";
import Time "mo:base/Time";
import Cycles "mo:base/ExperimentalCycles";
import List "mo:base/List";
import Nat8 "mo:base/Nat8";
import Buffer "mo:base/Buffer";
import AccountIdentifier "../dependencies/util/AccountIdentifier";
import Hex "../dependencies/util/Hex";
import Ledger "../dependencies/Ledger/ledger";
import LedgerCandid "../dependencies/Ledger/ledgerCandid";
import Users "types/users";
import Utils "utils";
import AvatarModule "types/avatar";
import AirdropModule "types/airdrop";
import Inventory "types/inventory";
import Canistergeek "../dependencies/canistergeek/canistergeek";
import InvoiceType "../invoice/Types";
import Logs "Logs";
import LogsTypes "Logs/types";
import Admins "Admins";


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
        assert(_admins.isAdmin(caller));
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
        assert(caller == Principal.fromActor(this));
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
        invoice_id : Nat;
        account_to_send : Text; // The invoice canister always send the destination account as text.
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
        ) : async Result.Result<Text, Text> {
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
                                invoice_id = invoice.id;
                                account_to_send = account;
                            };  
                            _registrations.put(caller, registration);
                            return #ok(account);
                        };
                        case(_) {
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
                id = registration.invoice_id;
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
        #NotConfirmed : Registration ;
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
                return #NotConfirmed(registration);
            };
        };
        return #NotRegistered;
    };

    private func verify_registration(p : Principal) : async Result.Result<(), Text> {
        switch(_registrations.get(p)){
            case(null) return #err("No registration found for this principal");
            case(?registration){
                try {
                switch(await INVOICE.verify_invoice({ id = registration.invoice_id })){
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
                        let event : Event = {
                            time = Nat64.fromIntWrap(Time.now());
                            operation = "verify_invoice";
                            details = [("User", #Principal(p))];
                            caller = Principal.fromActor(this);
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
   

};