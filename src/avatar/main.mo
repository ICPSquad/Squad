import Array "mo:base/Array";
import Blob "mo:base/Blob";
import Buffer "mo:base/Buffer";
import Cycles "mo:base/ExperimentalCycles";
import Hash "mo:base/Hash";
import Int "mo:base/Int";
import Iter "mo:base/Iter";
import Nat "mo:base/Nat";
import Option "mo:base/Option";
import Prim "mo:prim";
import Principal "mo:base/Principal";
import Result "mo:base/Result";
import Text "mo:base/Text";
import Time "mo:base/Time";
import TrieMap "mo:base/TrieMap";

import AccountIdentifier "mo:principal/AccountIdentifier";
import Canistergeek "mo:canistergeek/canistergeek";
import Ext "mo:ext/Ext";
import Root "mo:cap/Root";

import Admins "admins";
import Assets "assets";
import Avatar "avatar";
import Cap "cap";
import ExtModule "ext";
import Http "http";
import Invoice "invoice";
import SVG "utils/svg";
import Scores "scores";
import Tickets "tickets";
import Users "users";

shared ({ caller = creator }) actor class ICPSquadNFT() = this {

  let cid = Principal.fromText("jmuqr-yqaaa-aaaaj-qaicq-cai");
  let accessory_cid = Principal.fromText("po6n2-uiaaa-aaaaj-qaiua-cai");
  let invoice_cid = Principal.fromText("if27l-eyaaa-aaaaj-qaq5a-cai");
  let cid_hub = Principal.fromText("p4y2d-yyaaa-aaaaj-qaixa-cai");

  ///////////
  // TYPES //
  ///////////

  public type Time = Time.Time;
  public type Result<A, B> = Result.Result<A, B>;

  ///////////
  // ADMIN //
  ///////////

  stable var master : Principal = creator;

  stable var _AdminsUD : ?Admins.UpgradeData = null;
  let _Admins = Admins.Admins(creator);

  public query func is_admin(p : Principal) : async Bool {
    _Admins.isAdmin(p);
  };

  public shared ({ caller }) func add_admin(p : Principal) : async () {
    _Admins.addAdmin(p, caller);
    _Monitor.collectMetrics();
    _Logs.logMessage("CONFIG :: Added admin : " # Principal.toText(p) # " by " # Principal.toText(caller));
  };

  public shared ({ caller }) func delete_admin(p : Principal) : async () {
    assert (caller == master);
    _Monitor.collectMetrics();
    _Admins.removeAdmin(p, caller);
    _Logs.logMessage("CONFIG :: Removed admin : " # Principal.toText(p) # " by " # Principal.toText(caller));
  };

  //////////////
  // CYCLES  //
  /////////////

  public func acceptCycles() : async () {
    let available = Cycles.available();
    let accepted = Cycles.accept(available);
    assert (accepted == available);
  };

  public query func availableCycles() : async Nat {
    return Cycles.balance();
  };

  ///////////////
  // METRICS ///
  /////////////

  stable var _MonitorUD : ?Canistergeek.UpgradeData = null;
  private let _Monitor : Canistergeek.Monitor = Canistergeek.Monitor();

  /**
    * Returns collected data based on passed parameters.
    * Called from browser.
    * @auth : admin
    */
  public query ({ caller }) func getCanisterMetrics(parameters : Canistergeek.GetMetricsParameters) : async ?Canistergeek.CanisterMetrics {
    assert (_Admins.isAdmin(caller));
    _Monitor.getMetrics(parameters);
  };

  /**
    * Force collecting the data at current time.
    * Called from browser or any canister "update" method.
    * @auth : admin 
    */
  public shared ({ caller }) func collectCanisterMetrics() : async () {
    assert (_Admins.isAdmin(caller));
    _Monitor.collectMetrics();
  };

  ////////////
  // LOGS ///
  //////////

  stable var _LogsUD : ?Canistergeek.LoggerUpgradeData = null;
  private let _Logs : Canistergeek.Logger = Canistergeek.Logger();

  /**
    * Returns collected log messages based on passed parameters.
    * Called from browser.
    * @auth : admin
    */
  public query ({ caller }) func getCanisterLog(request : ?Canistergeek.CanisterLogRequest) : async ?Canistergeek.CanisterLogResponse {
    assert (_Admins.isAdmin(caller));
    _Logs.getLog(request);
  };

  public shared ({ caller }) func setMaxMessagesCount(n : Nat) : async () {
    assert (_Admins.isAdmin(caller));
    _Logs.setMaxMessagesCount(n);
  };

  ////////////
  // ASSET //
  ///////////

  public type FilePath = Assets.FilePath;
  public type File = Assets.File;

  stable var _AssetsUD : ?Assets.UpgradeData = null;
  let _Assets = Assets.Assets();

  public shared ({ caller }) func upload(
    bytes : [Nat8],
  ) : async () {
    assert (_Admins.isAdmin(caller));
    _Monitor.collectMetrics();
    _Assets.upload(bytes);
  };

  public shared ({ caller }) func uploadFinalize(
    contentType : Text,
    meta : Assets.Meta,
    filePath : Text,
  ) : async Result<(), Text> {
    assert (_Admins.isAdmin(caller));
    _Monitor.collectMetrics();
    switch (_Assets.uploadFinalize(contentType, meta, filePath)) {
      case (#ok(())) {
        _Logs.logMessage("TASK :: Uploaded file: " # filePath);
        return #ok(());
      };
      case (#err(message)) {
        _Logs.logMessage("ERR :: Failed to upload file: " # filePath);
        return #err(message);
      };
    };
  };

  public shared ({ caller }) func uploadClear() : async () {
    assert (_Admins.isAdmin(caller));
    _Monitor.collectMetrics();
    _Assets.uploadClear();
  };

  public shared ({ caller }) func delete_file(
    filePath : Text,
  ) : async Result<(), Text> {
    assert (_Admins.isAdmin(caller));
    _Monitor.collectMetrics();
    _Assets.delete(filePath);
  };

  ///////////////
  // Avatar ////
  /////////////

  public type MintInformation = Avatar.MintInformation;
  public type Colors = Avatar.Colors;
  public type MintResult = Result<TokenIdentifier, Text>;
  public type AvatarRendering = Avatar.AvatarRendering;

  stable var _AvatarUD : ?Avatar.UpgradeData = null;
  let _Avatar = Avatar.Factory(
    {
      _Admins = _Admins;
      _Assets = _Assets;
      _Logs = _Logs;
    },
  );

  public shared ({ caller }) func registerComponent(
    name : Text,
    component : Avatar.Component,
  ) : async Result<(), Text> {
    assert (_Admins.isAdmin(caller));
    _Monitor.collectMetrics();
    switch (_Avatar.addComponent(name, component)) {
      case (#ok(())) {
        _Logs.logMessage("TASK :: Added component: " # name);
        return #ok(());
      };
      case (#err(message)) {
        _Logs.logMessage("ERR :: Failed to add component: " # name);
        return #err(message);
      };
    };
  };

  public shared ({ caller }) func delete_component(
    name : Text,
  ) : async Result<(), Text> {
    assert (_Admins.isAdmin(caller));
    _Monitor.collectMetrics();
    _Avatar.deleteComponent(name);
  };

  public shared ({ caller }) func get_components() : async [(Text, Avatar.Component)] {
    assert (_Admins.isAdmin(caller));
    _Monitor.collectMetrics();
    return _Avatar.getComponents();
  };

  public shared ({ caller }) func changeStyle(
    style : Text,
  ) : async () {
    assert (_Admins.isAdmin(caller));
    _Monitor.collectMetrics();
    _Avatar.changeCSS(style);
    _Logs.logMessage("CONFIG :: Changed CSS");
  };

  public shared ({ caller }) func draw(
    tokenId : TokenIdentifier,
  ) : async Result<(), Text> {
    assert (_Admins.isAdmin(caller));
    _Monitor.collectMetrics();
    _Avatar.drawAvatar(tokenId);
  };

  /* 
        Associate a legendary avatar artwork with the given tokenIdentifier. Do NOT create the token 
        @auth : admin
     */
  public shared ({ caller }) func associate_legendary(
    name : Text,
    token : TokenIdentifier,
  ) : async Result<(), Text> {
    assert (_Admins.isAdmin(caller));
    _Monitor.collectMetrics();
    switch (_Avatar.createLegendary(name, token)) {
      case (#err(_)) {
        _Logs.logMessage("ERR :: Failed to associate legendary : " # name # " with token: " # token);
        return #err("Failed to associate legendary : " # name # " with token : " # token);
      };
      case (#ok(_)) {
        _Logs.logMessage("TASK :: Associated legendary : " # name # " with token : " # token);
        return #ok;
      };
    };
  };

  public shared ({ caller }) func burn(
    token : TokenIdentifier,
  ) : async Result<(), Text> {
    assert (_Admins.isAdmin(caller));
    _Monitor.collectMetrics();
    let index = switch (Ext.TokenIdentifier.decode(token)) {
      case (#err(_)) {
        _Logs.logMessage("ERR :: Failed to decode token: " # token);
        return #err("Failed to decode token: " # token);
      };
      case (#ok(p, index)) {
        assert (p == cid);
        _Ext.burn(index);
        _Avatar.burn(token);
        let event = {
          operation = "burn";
          details = [("token", #Text(token)), ("from", #Text(Principal.toText(caller)))];
          caller = caller;
        };
        ignore (_Cap.registerEvent(event));
        _Logs.logMessage("TASK :: Burned avatar: " # token # " by : " # Principal.toText(caller));
        return #ok;
      };
    };
  };

  public shared ({ caller }) func mint(
    info : MintInformation,
    invoice_id : ?Nat,
  ) : async MintResult {
    _Monitor.collectMetrics();
    switch (invoice_id) {
      case (null) {
        switch (_Users.getUser(caller)) {
          case (null) return #err("No user found");
          case (?user) {
            if (user.minted) {
              return #err("User already minted");
            };
          };
        };
      };
      case (?id) {
        switch (await _Invoice.verifyInvoice(id, caller)) {
          case (#ok) {};
          case (#err) {
            return #err("Error during invoice verification");
          };
        };
      };
    };
    switch (_Ext.mint({ to = #principal(caller); metadata = null })) {
      case (#err(#Other(e))) return #err(e);
      case (#err(#InvalidToken(e))) return #err(e);
      case (#ok(index)) {
        let tokenId = Ext.TokenIdentifier.encode(cid, index);
        switch (_Avatar.createAvatar(info, tokenId)) {
          case (#ok) {
            _Logs.logMessage("TASK :: Created avatar: " # tokenId # "by " # Principal.toText(caller));
            let receiver = Text.map(Ext.AccountIdentifier.fromPrincipal(caller, null), Prim.charToLower);
            ignore (
              _Cap.registerEvent(
                {
                  operation = "mint";
                  details = [("token", #Text(tokenId)), ("to", #Text(receiver))];
                  caller = caller;
                },
              ),
            );
            // Delete the coupon in case the user has one (assume the reduction was applied...!)
            switch (_Tickets.getTicket(caller)) {
              case (null) {};
              case (?tokenIndex) {
                _Tickets.deleteTicket(tokenIndex);
              };
            };
            _Users.welcome(caller, invoice_id, tokenId);
            return #ok(tokenId);
          };
          case (#err(e)) {
            _Logs.logMessage("ERR :: Avatar creation failed for token: " # tokenId);
            return #err(e);
          };
        };
      };
    };
  };

  public shared ({ caller }) func mint_legendary(
    name : Text,
    recipient : Principal,
  ) : async Result<(), Text> {
    assert (_Admins.isAdmin(caller));
    _Monitor.collectMetrics();
    switch (_Ext.mint({ to = #principal(recipient); metadata = null })) {
      case (#err(#Other(e))) return #err(e);
      case (#err(#InvalidToken(e))) return #err(e);
      case (#ok(index)) {
        let tokenId = Ext.TokenIdentifier.encode(cid, index);
        switch (_Avatar.createLegendary(name, tokenId)) {
          case (#ok) {
            _Logs.logMessage("TASK :: Created legendary : " # name # " with identifier : " # tokenId);
            let receiver = Text.map(Ext.AccountIdentifier.fromPrincipal(caller, null), Prim.charToLower);
            ignore (
              _Cap.registerEvent(
                {
                  operation = "mint";
                  details = [("token", #Text(tokenId)), ("to", #Text(receiver))];
                  caller = caller;
                },
              ),
            );
            return #ok;
          };
          case (#err(e)) {
            return #err(e);
          };
        };
      };
    };
  };

  public shared ({ caller }) func wearAccessory(
    tokenId : TokenIdentifier,
    name : Text,
    p : Principal,
  ) : async Result<(), Text> {
    assert (_Admins.isAdmin(caller) or caller == accessory_cid);
    _Monitor.collectMetrics();
    switch (_Ext.balance({ user = #principal(p); token = tokenId })) {
      case (#err(_)) {
        return #err("Error trying to access EXT balance : " # tokenId);
      };
      case (#ok(n)) {
        switch (n) {
          case (0) {
            _Logs.logMessage("ERR :: " # " Caller :  " #Principal.toText(p) # " doesnt own : " # tokenId);
            return #err("Caller :  " #Principal.toText(caller) # " doesn't own : " # tokenId);
          };
          case (1) {
            _Avatar.wearAccessory(tokenId, name);
          };
          case _ {
            return #err("Unexpected value for balance : " # Nat.toText(n));
          };
        };
      };
    };
  };

  public shared ({ caller }) func removeAccessory(
    tokenId : TokenIdentifier,
    name : Text,
    p : Principal,
  ) : async Result<(), Text> {
    assert (caller == accessory_cid);
    _Monitor.collectMetrics();
    switch (_Ext.balance({ user = #principal(p); token = tokenId })) {
      case (#err(_)) {
        return #err("Error trying to access EXT balance : " # tokenId);
      };
      case (#ok(n)) {
        switch (n) {
          case (0) {
            _Logs.logMessage("ERR :: " # " Caller :  " #Principal.toText(p) # " doesnt own : " # tokenId);
            return #err("Caller :  " #Principal.toText(p) # " doesn't own : " # tokenId);
          };
          case (1) {
            _Avatar.removeAccessory(tokenId, name);
          };
          case _ {
            return #err("Unexpected value for balance : " # Nat.toText(n));
          };
        };
      };
    };
  };

  public shared ({ caller }) func get_slot(token : TokenIdentifier) : async ?Avatar.Slots {
    assert (_Admins.isAdmin(caller));
    _Monitor.collectMetrics();
    return _Avatar.getSlot(token);
  };

  public shared ({ caller }) func set_default_avatar(tokenId : TokenIdentifier) : async Result<(), Text> {
    _Monitor.collectMetrics();
    _Users.setDefaultAvatar(caller, tokenId);
  };

  public shared query ({ caller }) func get_avatar_infos() : async (?TokenIdentifier, ?AvatarRendering) {
    switch (_Users.getDefaultAvatar(caller)) {
      case (null) {
        let account = Text.map(Ext.AccountIdentifier.fromPrincipal(caller, null), Prim.charToLower);
        switch (_Ext.defaultToken(account)) {
          case (null) {
            return (null, null);
          };
          case (?tokenIdentifier) {
            let rendering = _Avatar.getAvatarRendering(tokenIdentifier);
            return (?tokenIdentifier, rendering);
          };
        };
      };
      case (?tokenId) {
        let avatar_rendering = _Avatar.getAvatarRendering(tokenId);
        return (?tokenId, avatar_rendering);
      };
    };
  };

  public shared ({ caller }) func inspect_avatar(tokenId : TokenIdentifier) : async ?Avatar.Avatar {
    assert (_Admins.isAdmin(caller));
    _Monitor.collectMetrics();
    return _Avatar.getAvatar(tokenId);
  };

  public shared query ({ caller }) func check_avatar_infos(p : Principal) : async (?TokenIdentifier, ?AvatarRendering) {
    assert (_Admins.isAdmin(caller));
    switch (_Users.getDefaultAvatar(p)) {
      case (null) {
        return (null, null);
      };
      case (?tokenId) {
        let avatar_rendering = _Avatar.getAvatarRendering(tokenId);
        return (?tokenId, avatar_rendering);
      };
    };
  };

  public shared ({ caller }) func report_burned_accessory(
    name : Text,
    avatar : TokenIdentifier,
    accessory : TokenIndex,
  ) : async Result.Result<(), ()> {
    assert (_Admins.isAdmin(caller) or caller == accessory_cid);
    _Monitor.collectMetrics();
    switch (_Avatar.removeAccessory(avatar, Text.map(name, Prim.charToLower))) {
      case (#err(_)) {
        _Logs.logMessage("ERR :: " # "accessory " # name # " not removed from avatar " # avatar);
        return #err;
      };
      case (#ok) {
        _Logs.logMessage("EVENT :: accessory " # name # " removed from avatar " # avatar);
        return #ok;
      };
    };
  };

  ///////////////////
  // EXT - ERC721 //
  /////////////////

  type AccountIdentifier = Ext.AccountIdentifier;
  type SubAccount = Ext.SubAccount;
  type User = Ext.User;
  type Balance = Ext.Balance;
  type TokenIdentifier = Ext.TokenIdentifier;
  type TokenIndex = Ext.TokenIndex;
  type Extension = Ext.Extension;
  type CommonError = Ext.CommonError;
  type BalanceRequest = Ext.Core.BalanceRequest;
  type BalanceResponse = Ext.Core.BalanceResponse;
  type TransferRequest = Ext.Core.TransferRequest;
  type TransferResponse = Ext.Core.TransferResponse;

  stable var _ExtUD : ?ExtModule.UpgradeData = null;
  let _Ext = ExtModule.Factory(
    {
      cid = cid;
      _Logs = _Logs;
      _Avatar = _Avatar;
    },
  );

  public shared ({ caller }) func transfer(request : TransferRequest) : async TransferResponse {
    _Monitor.collectMetrics();
    switch (_Ext.transfer(caller, request)) {
      case (#err(#Other(e))) return #err(#Other(e));
      case (#err(#InvalidToken(token))) return #err(#InvalidToken(token));
      case (#ok(index)) {
        let from = Text.map(Ext.User.toAccountIdentifier(request.from), Prim.charToLower);
        let to = Text.map(Ext.User.toAccountIdentifier(request.to), Prim.charToLower);
        ignore (
          _Cap.registerEvent(
            {
              operation = "transfer";
              details = [("token", #Text(request.token)), ("from", #Text(from)), ("to", #Text(to))];
              caller = caller;
            },
          ),
        );
        return #ok(index);
      };
      case (#err(_)) return #err(#Other("Unknown error"));
    };
  };

  public query func extensions() : async [Extension] {
    _Ext.extensions();
  };

  public query func supply() : async Nat {
    _Ext.size();
  };

  public query func getRegistry() : async [(TokenIndex, AccountIdentifier)] {
    _Ext.getRegistry();
  };

  public query func getTokens() : async [(TokenIndex, Ext.Common.Metadata)] {
    _Ext.getTokens();
  };

  public query func metadata(tokenId : TokenIdentifier) : async Result<Ext.Common.Metadata, Ext.CommonError> {
    _Ext.metadata(tokenId);
  };

  public query func tokens(aid : AccountIdentifier) : async Result<[TokenIndex], CommonError> {
    _Ext.tokens(aid);
  };

  public query func tokens_ext(aid : AccountIdentifier) : async Result<[(TokenIndex, ?ExtModule.Listing, ?Blob)], CommonError> {
    _Ext.tokens_ext(aid);
  };

  public query func tokens_id(aid : AccountIdentifier) : async Result<[TokenIdentifier], CommonError> {
    switch (_Ext.tokens(aid)) {
      case (#err(e)) return #err(e);
      case (#ok(tokens)) {
        return (#ok(Array.map<TokenIndex, Text>(tokens, func(x) { Ext.TokenIdentifier.encode(cid, x) })));
      };
    };
  };

  public query func tokens_ids() : async [TokenIdentifier] {
    let registry = _Ext.getRegistry();
    return Array.map<(TokenIndex, AccountIdentifier), TokenIdentifier>(registry, func(x) { Ext.TokenIdentifier.encode(cid, x.0) });
  };

  public query func balance(request : BalanceRequest) : async BalanceResponse {
    _Ext.balance(request);
  };

  public query func bearer(tokenId : TokenIdentifier) : async Result<AccountIdentifier, CommonError> {
    _Ext.bearer(tokenId);
  };

  public query func details(tokenId : TokenIdentifier) : async Result<(AccountIdentifier, ?ExtModule.Listing), CommonError> {
    _Ext.details(tokenId);
  };

  //////////
  // CAP //
  /////////

  stable var _CapUD : ?Cap.UpgradeData = null;
  let _Cap = Cap.Factory(
    {
      _Logs = _Logs;
      _Admins = _Admins;
      cid = cid;
      overrideRouterId = null;
      provideRootBucketId = ?"ffu6n-ciaaa-aaaaj-qaotq-cai";
    },
  );

  ///////////
  // HTTP //
  //////////

  let _HttpHandler = Http.HttpHandler(
    {
      _Admins = _Admins;
      _Assets = _Assets;
      _Avatar = _Avatar;
    },
  );

  public query func http_request(request : Http.Request) : async Http.Response {
    _HttpHandler.request(request);
  };

  //////////////
  // Users ////
  /////////////

  public type Name = Users.Name;
  public type UserData = Users.User;

  stable var _UsersUD : ?Users.UpgradeData = null;
  private let _Users : Users.Users = Users.Users(
    {
      cid = cid;
      _Logs = _Logs;
      _Ext = _Ext;
      _Avatar;
    },
  );

  public shared ({ caller }) func create_profile(
    username : ?Text,
    email : ?Text,
    discord : ?Text,
    twitter : ?Text,
    default_avatar : TokenIdentifier,
  ) : async Result<(), Text> {
    _Monitor.collectMetrics();
    let account = Text.map(Ext.AccountIdentifier.fromPrincipal(caller, null), Prim.charToLower);
    let request = {
      user = #address(account);
      token = default_avatar;
    };
    switch (_Users.getUser(caller)) {
      case (null) {};
      case (?some) {
        return #err("Caller : " # Principal.toText(caller) # " already has a profile");
      };
    };
    switch (_Ext.balance(request)) {
      case (#err(e)) {
        return #err("Error trying to access EXT balance : " # default_avatar);
      };
      case (#ok(n)) {
        switch (n) {
          case (0) {
            return #err("Caller :  " #Principal.toText(caller) # " doesn' t own : " # default_avatar);
          };
          case (1) {};
          case _ {
            return #err(" Unexpected value for balance : " # Nat.toText(n));
          };
        };
      };
    };
    _Users.createUser(caller, username, email, discord, twitter, default_avatar);
  };

  public shared query ({ caller }) func get_user() : async ?UserData {
    _Users.getUser(caller);
  };

  public shared query ({ caller }) func get_avatars() : async [TokenIdentifier] {
    let account = Text.map(Ext.AccountIdentifier.fromPrincipal(caller, null), Prim.charToLower);
    switch (_Ext.tokens(account)) {
      case (#err(e)) return [];
      case (#ok(tokenIds)) {
        let tokenIdentifier = Array.map<TokenIndex, TokenIdentifier>(tokenIds, func(x) { Ext.TokenIdentifier.encode(cid, x) });
        return tokenIdentifier;
      };
    };
  };

  public shared ({ caller }) func modify_profile(
    username : ?Text,
    email : ?Text,
    discord : ?Text,
    twitter : ?Text,
    default_avatar : TokenIdentifier,
  ) : async Result<(), Text> {
    _Monitor.collectMetrics();
    _Users.modifyProfile(username, email, discord, twitter, default_avatar, caller);
  };

  public shared ({ caller }) func add_user(p : Principal) : async Result<(), Text> {
    assert (_Admins.isAdmin(caller));
    _Monitor.collectMetrics();
    _Users.register(p);
  };

  public shared ({ caller }) func get_all_users() : async [(Principal, UserData)] {
    assert (_Admins.isAdmin(caller));
    _Monitor.collectMetrics();
    _Users.getUsers();
  };

  public query func get_number_users() : async Nat {
    _Users.getNumberUsers();
  };

  public shared query ({ caller }) func get_infos_leaderboard() : async [(Principal, ?Name, ?TokenIdentifier)] {
    assert (_Admins.isAdmin(caller) or caller == cid_hub);
    _Monitor.collectMetrics();
    _Users.getInfosLeaderboard();
  };

  public shared query ({ caller }) func get_infos_accounts() : async [(Principal, AccountIdentifier)] {
    assert (_Admins.isAdmin(caller) or caller == cid_hub);
    _Monitor.collectMetrics();
    _Users.getInfosAccounts();
  };

  public shared query ({ caller }) func get_infos_holders() : async [(Principal, ?AccountIdentifier, ?Text, ?Text, ?TokenIdentifier)] {
    assert (_Admins.isAdmin(caller) or caller == cid_hub);
    _Monitor.collectMetrics();
    _Users.getInfosHolders();
  };

  /////////////
  // SCORES ///
  /////////////

  public type Stats = Scores.Stats;
  public type Stars = Scores.Stars;
  public type StyleScore = Scores.StyleScore;

  stable var _ScoresUD : ?Scores.UpgradeData = null;
  let _Scores = Scores.Factory(
    {
      cid = cid;
      accessory_cid = accessory_cid;
      _Logs = _Logs;
      _Avatar = _Avatar;
      _Ext = _Ext;
    },
  );

  public shared ({ caller }) func upload_stats(
    stats : Stats,
  ) : () {
    assert (_Admins.isAdmin(caller));
    _Monitor.collectMetrics();
    _Scores.uploadStats(stats);
  };

  public query func get_stats() : async [(Scores.Name, Stars)] {
    _Scores.getStats();
  };

  public shared ({ caller }) func calculate_style_score() : () {
    assert (_Admins.isAdmin(caller));
    _Monitor.collectMetrics();
    _Scores.calculateStyleScores();
  };

  public query func get_score(tokenId : TokenIdentifier) : async ?Nat {
    _Scores.getScore(tokenId);
  };

  public shared query ({ caller }) func get_style_score() : async [(TokenIdentifier, StyleScore)] {
    assert (_Admins.isAdmin(caller) or caller == cid_hub);
    _Scores.getStyleScores();
  };

  ////////////////
  // TICKETS ////
  //////////////

  stable var _TicketsUD : ?Tickets.UpgradeData = null;
  let _Tickets = Tickets.Factory(
    {
      _Ext;
      _Logs;
      cid;
    },
  );

  public query func has_ticket(p : Principal) : async Bool {
    _Tickets.hasTicket(p);
  };

  public shared ({ caller }) func mint_ticket(p : Principal) : async Result<TokenIndex, Text> {
    assert (_Admins.isAdmin(caller));
    _Monitor.collectMetrics();
    _Tickets.mintTicket(p);
  };

  ////////////////
  // INVOICE ////
  //////////////

  let _Invoice = Invoice.Factory(
    {
      _Tickets;
      invoice_cid = invoice_cid;
    },
  );

  //////////////
  // CRONIC ///
  /////////////

  public shared ({ caller }) func cron_events() : async () {
    assert (_Admins.isAdmin(caller) or caller == cid_hub);
    _Monitor.collectMetrics();
    await _Cap.cronEvents();
  };

  public shared ({ caller }) func cron_scores() : async () {
    assert (_Admins.isAdmin(caller) or caller == cid_hub);
    _Monitor.collectMetrics();
    _Scores.calculateStyleScores();
    _Logs.logMessage(" CRON : : Update style scores ");
  };

  public shared ({ caller }) func cron_default_avatar() : async () {
    assert (_Admins.isAdmin(caller) or caller == cid_hub);
    _Monitor.collectMetrics();
    _Users.cronDefaultAvatar();
    _Logs.logMessage(" CRON : : Update default avatar ");
  };

  /////////////
  // UPGRADE //
  /////////////

  system func preupgrade() {
    _Logs.logMessage(" PREUPGRADE : : avatar ");
    _MonitorUD := ?_Monitor.preupgrade();
    _LogsUD := ?_Logs.preupgrade();
    _AdminsUD := ?_Admins.preupgrade();
    _AssetsUD := ?_Assets.preupgrade();
    _AvatarUD := ?_Avatar.preupgrade();
    _ExtUD := ?_Ext.preupgrade();
    _ScoresUD := ?_Scores.preupgrade();
    _UsersUD := ?_Users.preupgrade();
    _CapUD := ?_Cap.preupgrade();
    _TicketsUD := ?_Tickets.preupgrade();
  };

  system func postupgrade() {
    _Logs.postupgrade(_LogsUD);
    _LogsUD := null;
    _Monitor.postupgrade(_MonitorUD);
    _MonitorUD := null;
    _Admins.postupgrade(_AdminsUD);
    _AdminsUD := null;
    _Assets.postupgrade(_AssetsUD);
    _AssetsUD := null;
    _Avatar.postupgrade(_AvatarUD);
    _AvatarUD := null;
    _Ext.postupgrade(_ExtUD);
    _ExtUD := null;
    _Scores.postupgrade(_ScoresUD);
    _ScoresUD := null;
    _Users.postupgrade(_UsersUD);
    _UsersUD := null;
    _Cap.postupgrade(_CapUD);
    _CapUD := null;
    _Tickets.postupgrade(_TicketsUD);
    _TicketsUD := null;
    _Logs.logMessage(" POSTUPGRADE : : avatar ");
  };
};
