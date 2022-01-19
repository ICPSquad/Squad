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


let this = actor {

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
    let actorNFT = actor ("jmuqr-yqaaa-aaaaj-qaicq-cai") : actor {
        mint : shared MintRequest -> async Result.Result<AvatarInformation,Text>;
        generateAccounts : shared [Principal] -> async ();
        getAllAvatar : shared () -> async [(TokenIdentifier,?Principal)];
    };

    // Mint 
    // @pre : _mintVerification (user is a member/ user doesn't already have an avatar minted)
    public shared(msg) func mintRequest (request : MintRequest) : async AvatarResponse {
        switch (_mintVerification(request, msg.caller)) {
            case (#err(msg)) return #err(msg);
            case (#ok) {
                // We prevent users from sending multiples mintRequest and abusing the system causes this function is not atomic by adding a fake token identifier -> _mintVerification will now send an error. 
                _addAvatar("-1", msg.caller);
                switch(await actorNFT.mint(request)){
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

    let actorMaterial = actor ("po6n2-uiaaa-aaaaj-qaiua-cai") : actor {
        airdrop : shared (AirdropObject) -> async Result.Result<(), Text>;
        getAllInventory : shared ([Principal]) -> async [(Principal,Inventory)];
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
                                switch(await actorMaterial.airdrop(airdrop_object)){
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
    public func balance () : async Ledger.ICP {
        await actorLedger.account_balance({
            account = _myAccountIdentifier(null);
        });
    };

    // Transfer amount of ICP from this canister subaccount0 to the specified Principal (as text) subaccount0.
    // @auth : admin

    public shared ({caller}) func transfer (amount : Ledger.ICP, receiver : Principal) : async Ledger.TransferResult {
        assert(_isAdmin(caller));
        let account_raw : [Nat8] = AccountIdentifier.fromPrincipal_raw(receiver, null);
        await actorLedger.transfer({
            memo = 1;
            amount = amount;
            fee = { e8s = 10_000};
            from_subaccount = null;
            to = account_raw;
            created_at_time = ?{timestamp_nanos = Nat64.fromIntWrap(Time.now())};
        });
    };


    // Verify that a transaction really happened by asking the candid ledger needs : Height/Sender/Receiver/Amount.
    // ⚠️ Needs to be called when the transaction is still fresh. Ledger only keeps the last 1000 blocks before archive.


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

    // Types and useful 
    public type WhiteListRequest = Users.WhiteListRequest; 
    public type JoiningError = Users.JoiningError;
    private let AMOUNT  = {e8s = Nat64.fromNat(100000000)};
    private let sa_zero : [Nat8] = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];


    // Track errors during the joining process. 
    stable var errorsJoiningEntries : [(Time,JoiningError)] = [];
    let errorsJoining : HashMap.HashMap<Time,JoiningError> = HashMap.fromIter(errorsJoiningEntries.vals(), 0, Int.equal, Int.hash);

    public shared query ({caller}) func showJoiningErrors() : async [(Time,JoiningError)] {
        assert(_isAdmin(caller));
        return(Iter.toArray(errorsJoining.entries()));
    };

    // User send 1 ICP to a random subaccount and sends the corresponding [Nat8] representation 
    // We then check the balance by asking the ledger canister. This methods prevents using the proxy for the Candid interface and is significantly faster.
    // For 10 000 ICP we will loose 1 ICP in transfer fees.
    // ⚠️ Subaccount must be different than 0 (otherwise the check balance would be compromised)
    public shared ({caller}) func join (request : WhiteListRequest, subaccount : [Nat8]) : async Result.Result<(), Text> {
        // Check that subaccount is not the subaccount0!
        if (Array.equal<Nat8>(sa_zero, subaccount, Nat8.equal)){
            let error : JoiningError = {
                caller = caller;
                error_message = "Cannot use the subbacount0 as receiver";
                request_associated = ?request;
            };
            errorsJoining.put(Time.now(), error);
            return #err("Cannot use the subbacount0 as receiver");
        };

        // Check payment 
        if(not (await _checkPayment(subaccount))){
             let error : JoiningError = {
                caller = caller;
                error_message = "No payment found";
                request_associated = ?request;
            };
            errorsJoining.put(Time.now(), error);
            return #err("No payment found");
        };

        // Send the ICP back to the main account, do not await so still keep a trace of the subaccount.
        ignore(_sendBackFrom(subaccount));
        payments_address := Array.append<SubAccount>(payments_address, [subaccount]);
        
        if (caller == Principal.fromText("2vxsx-fae")) {
            let error : JoiningError = {
                caller = caller;
                error_message = "The anonymous principal cannot join";
                request_associated = ?request;
            };
            errorsJoining.put(Time.now(), error);
            return #err("Cannot register the anonymous principal");
        };

        if (caller != request.principal){
            let error : JoiningError = {
                caller = caller;
                error_message = "Cannot register for someone else";
                request_associated = ?request;
            };
            errorsJoining.put(Time.now(), error);
            return #err("Cannot register for someone else");
        };

        if (request.wallet != "Stoic" and request.wallet != "Plug") {
            let error : JoiningError = {
                caller = caller;
                error_message = "Wallet not supported";
                request_associated = ?request;
            };
            errorsJoining.put(Time.now(), error);
            return #err("Wallet not supported : " # request.wallet);
        };

        switch(users.get(caller)){
            case(?user) { 
                let error : JoiningError = {
                    caller = caller;
                    error_message = "Already an user associated with this principal.";
                    request_associated = ?request;
                };
                errorsJoining.put(Time.now(), error);
                return #err("There is already an user associated with this principal : " # Principal.toText(caller));
            };
            case(null) {
                let new_user : User = _createUserFromRequest(request);
                users.put(caller, new_user);
                return #ok;
            };
        };
    };

    // A list of subaccounts that are supposed to have send their ICPs back to the main account
    // Because we don't await on the TransferResult of the previous methods we keep track of them to regularly run check on their balance. 👮‍♀️
    // @auth : admin
    stable var payments_address : [SubAccount] = [];        
    public shared ({caller}) func verificationPayments () : async [SubAccount] {
        assert(_isAdmin(caller));
        var subaccount_robber : [SubAccount] = [];
        for (subaccount in payments_address.vals()){
            let account_to_check = {account = _myAccountIdentifier(?subaccount)};
            let balance = await actorLedger.account_balance(account_to_check);
            let amount = balance.e8s;
            if(amount > 0) {
                subaccount_robber := Array.append<SubAccount>(subaccount_robber, [subaccount]);
            };
        };
        payments_address := subaccount_robber;
        return (subaccount_robber);
    };
 
    // This function is used internally everytime a new user join, to send back ICPs from the corresponding subaccount to the main account
    private func _sendBackFrom (subaccount : SubAccount) : async () { 
        let result_transfer = await actorLedger.transfer({
            memo = 1;
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
    
    // Convert a request to a new user profile. Level_1 only starting from now.
    private func _createUserFromRequest (request : WhiteListRequest) : User {
        let new_user = {
            wallet = request.wallet;
            email = request.email;
            discord = request.discord;
            twitter = request.twitter;
            rank = ?Nat64.fromNat(users.size());
            height = ?request.height;
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
    //@atuh : admin
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
        errorsMintingEntries := Iter.toArray(errorsMinting.entries());
        errorsJoiningEntries := Iter.toArray(errorsJoining.entries());
    };

    system func postupgrade() {
       usersEntries := [];
       errorsMintingEntries := [];
       errorsJoiningEntries := [];
    };


    ////////////////////////
    // CYCLES MANAGEMENT //
    //////////////////////

    public func acceptCycles() : async () {
        let available = Cycles.available();
        let accepted = Cycles.accept(available);
        assert (accepted == available);
    };

    public query func availableCycles() : async Nat {
        return Cycles.balance();
    };

};