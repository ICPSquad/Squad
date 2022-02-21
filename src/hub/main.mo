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

let this = actor {


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
        assert(_isAdmin(caller));
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


    /////////////////
    // MANAGEMENT //
    ////////////////

    let dfxIdentityPrincipalSeb : Principal = Principal.fromText("dv5tj-vdzwm-iyemu-m6gvp-p4t5y-ec7qa-r2u54-naak4-mkcsf-azfkv-cae");
    let internetIdentityPrincipalSeb : Principal = Principal.fromText ("7djq5-fyci5-b7ktq-gaff6-m4m6b-yfncf-pywb3-r2l23-iv3v4-w2lcl-aqe");
    let internetIdentityPrincipalSeb_local : Principal = Principal.fromText("otgm5-k6dim-kjitv-7qlzk-72rd5-3hrec-fwaks-mogju-hn7o7-6ocnv-6ae");

    stable var admins : [Principal] = [dfxIdentityPrincipalSeb, internetIdentityPrincipalSeb, internetIdentityPrincipalSeb_local]; 

    private func _isAdmin (p: Principal) : Bool {
        return(Utils.contains<Principal>(admins, p, Principal.equal))
    };

    // Any admin can add others as admin
    public shared(msg) func addAdmin (p : Principal) : async Result.Result<(), Text> {
        if (_isAdmin(msg.caller)) {
            admins := Array.append<Principal>(admins, [p]);
            return #ok ();
        } else {
            return #err ("You are not authorized !");
        }

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
        assert(_isAdmin(caller));
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
        assert(_isAdmin(caller) or caller == Principal.fromActor(this));
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
        assert(_isAdmin(caller));
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
        assert(_isAdmin(caller));
        switch(users.get(p)){
            case(null) return null;
            case(?user) return ?user;
        };
    };


    // Allow us to whitelist people and add people who have issue with the payment flow. 
    // @auth : admin
    public shared({caller}) func addUser ( p : Principal, user : User) : async Result.Result<(),Text> {
        assert(_isAdmin(caller));
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
        assert(_isAdmin(caller));
        switch(users.get(p)){
            case(null) return #err("No user found for principal : " #Principal.toText(p));
            case(?someone){
                users.put(p, user);
                return #ok;
            };
        };
    };

    // Allow us to remove people form the list 
    //@auth : admin
    public shared({caller}) func removeUser(p : Principal) : async Result.Result<Text,Text> {
        assert(_isAdmin(caller));
        switch(users.remove(p)){
            case(null) return #err("No user found with this principal : " # Principal.toText(p));
            case(?user) return #ok("User with principal : " # Principal.toText(p) # " has been removed.");
        };
    };


    // To query our database and extract data. 
    // @auth : admin 
    public shared({caller}) func getInformations() : async [(Principal,User)] {
        assert(_isAdmin(caller));
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

    ///////////////
    // HEARTBEAT //
    ///////////////

    // A count represents one second
    stable var count = 0;

    public query func showCount() : async Nat {
        count;
    };

    public func resetCount() : async () {
        count := 0;
    };

    system func heartbeat () : async () {
        count += 1;
        //  Every 5min
        if(count % 300 == 0){
            await collectCanisterMetrics();
        };
        //  Every day 
        if(count % 86_400 == 0){
            await (verification());
        };
        //  Every week (and ten seconds!)
        if(count % 604_810 == 0) {
            await (audit());
            await (recipe());
            count := 0
        };
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
        assert(caller == Principal.fromActor(this));
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
        assert(caller == Principal.fromActor(this));
        subaccounts_robber;
    };

    //Process to the paiement of the concerned subbaccounts

    // public shared ({caller}) func process () : async () {
    //     assert(caller == Principal.fromActor(this));
    //     for (subaccount in subaccounts_robber.vals()){
    //         await (_sendBackFrom(subaccount));
    //     };
    //     subaccounts_robber := [];
    // };


    /////////////
    // AUDITS //
    ////////////

    public type Audit = {time : Int; new_users : Int; new_icps : Ledger.ICP; new_avatar : Int; new_items : Int};
    stable var audits : [Audit] = [];

    //Value : 19th of January at 8PM - Paris Time
    stable var users_nb = users.size();
    stable var icps = {e8s = 3_499_650_000 : Nat64};
    stable var avatars = 3_368;
    stable var items = 5_419;

    //Run an internal audits and updates values
    //@auth : canister
    public shared ({caller}) func audit () : async () {
        //Get updated values
        let new_value_users = users.size();
        let new_value_icps = await balance();
        let new_value_avatar = await actorAvatar.supply();
        let new_value_items = await actorItems.supply();

        //Remove trap warning for ICPs
        let value : Int = (Nat64.toNat(new_value_icps.e8s)) - (Nat64.toNat(icps.e8s));
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
        icps := new_value_icps;
        avatars := new_value_avatar;
        items := new_value_items;
        return;
    };  

    //Send list of all audits
    //@auth : admin
    public shared query ({caller}) func show_audits () : async [Audit] {
        assert(_isAdmin(caller));
        audits;
    };
    
    /////////////
    // RECIPE //
    ///////////
    
    let principal_wallet : Principal = Principal.fromText("rj53v-z27so-pkgug-6rcn4-3axje-ecooy-w26n2-ios6v-wxfrg-knwaj-jae");

    //Send recipe of the week to the wallet
    //@auth : canister
    public shared ({caller}) func recipe() : async () {
        assert(caller == Principal.fromActor(this));
        let balance : Ledger.ICP = await actorLedger.account_balance({
            account = _myAccountIdentifier(null);
        });
        let amount = balance.e8s;
        let amount_minus_fee = amount - 10_000;
        let result = await(transfer({e8s = amount_minus_fee}, principal_wallet));
        return;
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

    ///////////////////////////
    // ACTIVITY & TRACKING ///
    /////////////////////////

    let Transaction = {
        token : TokenIdentifier;
        seller : Principal;
        price : Nat64;
        buyer : AccountIdentifier;
        time : Time;
    };

    let 

    let EXTActivityInterface = actor {
        transactions : query () -> async [Transaction];
        listings : query () -> async[(TokenIndex, Listing, Metadata)];
    };



};