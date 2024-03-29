import Array "mo:base/Array";
import Blob "mo:base/Blob";
import Cycles "mo:base/ExperimentalCycles";
import Hash "mo:base/Hash";
import HashMap "mo:base/HashMap";
import Iter "mo:base/Iter";
import List "mo:base/List";
import Nat "mo:base/Nat";
import Nat64 "mo:base/Nat64";
import Option "mo:base/Option";
import Principal "mo:base/Principal";
import Result "mo:base/Result";
import Text "mo:base/Text";
import Time "mo:base/Time";

import Canistergeek "mo:canistergeek/canistergeek";

import A "./Account";
import Admins "admins";
import Hex "./Hex";
import ICP "./ICPLedger";
import T "./Types";
import U "./Utils";

shared ({ caller = creator }) actor class Invoice(
  ledger_cid : Principal,
  avatar_cid : Principal,
  accessory_cid : Principal,
  hub_cid : Principal,
  override_fee_avatar_e8s : ?Nat,
  override_fee_accessory_e8s : ?Nat,
) = this {

  ///////////
  // ADMIN //
  ///////////

  stable var master : Principal = creator;

  stable var _AdminsUD : ?Admins.UpgradeData = null;
  let _Admins = Admins.Admins(creator);

  public query func is_admin(p : Principal) : async Bool {
    _Admins.isAdmin(p);
  };

  public query func get_admins() : async [Principal] {
    _Admins.getAdmins();
  };

  public shared ({ caller }) func add_admin(p : Principal) : async () {
    _Admins.addAdmin(p, caller);
    _Monitor.collectMetrics();
    _Logs.logMessage("CONFIG :: Added admin : " # Principal.toText(p) # " by " # Principal.toText(caller));
  };

  public shared ({ caller }) func remove_admin(p : Principal) : async () {
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

  //////////////
  // LEDGER ///
  ////////////

  let _Ledger : ICP.Factory = ICP.Factory(ledger_cid);

  // #region Types
  type Details = T.Details;
  type Token = T.Token;
  type TokenVerbose = T.TokenVerbose;
  type AccountIdentifier = T.AccountIdentifier;
  type Invoice = T.Invoice;
  // #endregion

  let errInvalidToken = #err(
    {
      message = ?"This token is not yet supported. Currently, this canister supports ICP.";
      kind = #InvalidToken;
    },
  );

  /**
* Application State
*/

  // #region State
  stable var entries : [(Nat, Invoice)] = [];
  stable var invoiceCounter : Nat = 0;
  let invoices : HashMap.HashMap<Nat, Invoice> = HashMap.fromIter(Iter.fromArray(entries), entries.size(), Nat.equal, Hash.hash);
  entries := [];
  let MAX_INVOICES = 40_000;
  // To make sure we don't loose track of money.
  stable var invoices_to_check : List.List<(Principal, Nat)> = List.nil<(Principal, Nat)>();
  // #endregion

  /**
* Application Interface
*/

  // #region Create Invoice
  public type Category = {
    #AvatarMint;
    #AccessoryFee;
    #Ticket;
  };

  public shared ({ caller }) func create_invoice(category : Category) : async T.CreateInvoiceResult {
    let id : Nat = invoiceCounter;
    invoiceCounter += 1;

    if (id > MAX_INVOICES) {
      return #err(
        {
          message = ?"The maximum number of invoices has been reached.";
          kind = #MaxInvoicesReached;
        },
      );
    };

    let destinationResult : T.GetDestinationAccountIdentifierResult = getDestinationAccountIdentifier(
      {
        token = { symbol = "ICP" };
        invoiceId = id;
        caller;
      },
    );

    switch (destinationResult) {
      case (#err result) {
        #err(
          {
            message = ?"Invalid destination account identifier";
            kind = #InvalidDestination;
          },
        );
      };
      case (#ok result) {
        let destination : AccountIdentifier = result.accountIdentifier;
        // Add address to the list of addresses to check.
        invoices_to_check := List.push<(Principal, Nat)>((caller, id), invoices_to_check);
        let invoice : Invoice = switch (category) {
          case (#AvatarMint) {
            {
              id;
              creator = caller;
              details = ?{ description = "avatar"; meta = Blob.fromArray([0]) };
              permissions = null;
              // Permission system is already implemented through the assertion system.
              amount = Option.get(override_fee_avatar_e8s, 100_000_000);
              amountPaid = 0;
              token = getTokenVerbose({ symbol = "ICP" });
              verifiedAtTime = null;
              paid = false;
              // 1 week in nanoseconds
              expiration = Time.now() + (1000 * 60 * 60 * 24 * 7 * 1_000_000);
              destination = destination;
            };
          };
          case (#AccessoryFee) {
            {
              id;
              creator = caller;
              details = ?{ description = "accessory"; meta = Blob.fromArray([0]) };
              permissions = null;
              // Permission system is already implemented through the assertion system.
              amount = Option.get(override_fee_accessory_e8s, 50_000_000);
              amountPaid = 0;
              token = getTokenVerbose({ symbol = "ICP" });
              verifiedAtTime = null;
              paid = false;
              // 1 week in nanoseconds
              expiration = Time.now() + (1000 * 60 * 60 * 24 * 7 * 1_000_000);
              destination = destination;
            };
          };
          case (#Ticket) {
            {
              id;
              creator = caller;
              details = ?{ description = "ticket"; meta = Blob.fromArray([0]) };
              permissions = null;
              // Permission system is already implemented through the assertion system.
              amount = 50_000_000;
              amountPaid = 0;
              token = getTokenVerbose({ symbol = "ICP" });
              verifiedAtTime = null;
              paid = false;
              // 1 week in nanoseconds
              expiration = Time.now() + (1000 * 60 * 60 * 24 * 7 * 1_000_000);
              destination = destination;
            };
          };
        };
        _Logs.logMessage("INVOICE :: TASK :: created  : " # Nat.toText(id) # " by " # Principal.toText(caller) # " for amount : " # Nat.toText(invoice.amount));
        invoices.put(id, invoice);
        return (#ok({ invoice }));
      };
    };
  };

  func getTokenVerbose(token : Token) : TokenVerbose {
    switch (token.symbol) {
      case ("ICP") {
        {
          symbol = "ICP";
          decimals = 8;
          meta = ?{
            Issuer = "e8s";
          };
        };

      };
      case (_) {
        {
          symbol = "";
          decimals = 1;
          meta = ?{
            Issuer = "";
          };
        };
      };
    };
  };

  func areInputsValid(args : T.CreateInvoiceArgs) : Bool {
    let token = getTokenVerbose(args.token);

    var isValid = true;

    switch (args.details) {
      case null {};
      case (?details) {
        if (details.meta.size() > 32_000) {
          isValid := false;
        };
        if (details.description.size() > 256) {
          isValid := false;
        };
      };
    };

    switch (args.permissions) {
      case null {};
      case (?permissions) {
        if (permissions.canGet.size() > 256 or permissions.canVerify.size() > 256) {
          isValid := false;
        };
      };
    };

    return isValid;
  };

  // #region Get Destination Account Identifier
  func getDestinationAccountIdentifier(args : T.GetDestinationAccountIdentifierArgs) : T.GetDestinationAccountIdentifierResult {
    let token = args.token;
    switch (token.symbol) {
      case "ICP" {
        let canisterId = Principal.fromActor(this);

        let account = U.getICPAccountIdentifier(
          {
            principal = canisterId;
            subaccount = U.generateInvoiceSubaccount(
              {
                caller = args.caller;
                id = args.invoiceId;
              },
            );
          },
        );
        let hexEncoded = Hex.encode(Blob.toArray(account));
        let result : AccountIdentifier = #text(hexEncoded);
        #ok({ accountIdentifier = result });
      };
      case _ {
        errInvalidToken;
      };
    };
  };
  // #endregion
  // #region Get Destination Account Identifier (public)
  public func getDestinationAccountIdentifierPublic(args : T.GetDestinationAccountIdentifierArgs) : async T.GetDestinationAccountIdentifierResult {
    let token = args.token;
    switch (token.symbol) {
      case "ICP" {
        let canisterId = Principal.fromActor(this);

        let account = U.getICPAccountIdentifier(
          {
            principal = canisterId;
            subaccount = U.generateInvoiceSubaccount(
              {
                caller = args.caller;
                id = args.invoiceId;
              },
            );
          },
        );
        let hexEncoded = Hex.encode(Blob.toArray(account));
        let result : AccountIdentifier = #text(hexEncoded);
        #ok({ accountIdentifier = result });
      };
      case _ {
        errInvalidToken;
      };
    };
  };
  // #endregion

  // #region Get Invoice
  public shared query ({ caller }) func get_invoice(args : T.GetInvoiceArgs) : async T.GetInvoiceResult {
    assert (_Admins.isAdmin(caller));
    let invoice = invoices.get(args.id);
    switch invoice {
      case null {
        #err(
          {
            message = ?"Invoice not found";
            kind = #NotFound;
          },
        );
      };
      case (?i) {
        #ok({ invoice = i });
      };
    };
  };
  // #endregion

  // #region Get Balance
  public shared ({ caller }) func get_balance(args : T.GetBalanceArgs) : async T.GetBalanceResult {
    let token = args.token;
    let canisterId = Principal.fromActor(this);
    switch (token.symbol) {
      case "ICP" {
        let defaultAccount = Hex.encode(
          Blob.toArray(
            U.getDefaultAccount(
              {
                canisterId;
                principal = caller;
              },
            ),
          ),
        );
        let balance = await _Ledger.balance({ account = defaultAccount });
        switch (balance) {
          case (#err err) {
            #err(
              {
                message = ?"Could not get balance";
                kind = #NotFound;
              },
            );
          };
          case (#ok result) {
            #ok({ balance = result.balance });
          };
        };
      };
      case _ {
        errInvalidToken;
      };
    };
  };
  // #endregion

  public shared ({ caller }) func verify_invoice_avatar(args : T.VerifyInvoiceArgs, user : Principal) : async T.VerifyInvoiceResult {
    assert (caller == avatar_cid);
    let invoice = invoices.get(args.id);
    let canisterId = Principal.fromActor(this);

    switch (invoice) {
      case (null) {
        _Logs.logMessage("INVOICE :: ERR :: Invoice not found : " # Nat.toText(args.id));
        return #err({ message = ?"Invoice not found"; kind = #NotFound });
      };
      case (?invoice) {
        if (Option.isSome(invoice.verifiedAtTime)) {
          _Logs.logMessage("INVOICE :: ERR :: Already verified : " # Nat.toText(invoice.id));
          return #err({ message = ?"Invoice already verified"; kind = #Expired });
        };
        if (invoice.creator != user) {
          _Logs.logMessage("INVOICE :: ERR :: Not creator : " # Nat.toText(invoice.id));
          return #err({ message = ?"You do not have permission to verify this invoice"; kind = #NotAuthorized });
        };
        switch (invoice.details) {
          case (null) {
            _Logs.logMessage("INVOICE :: ERR :: No details : " # Nat.toText(invoice.id));
            return #err({ message = ?"Invoice has no details"; kind = #Other });
          };
          case (?details) {
            if (details.description != "avatar") {
              _Logs.logMessage("INVOICE :: ERR :: Not corresponding to an avatar : " # Nat.toText(invoice.id));
              return #err({ message = ?"Invoice is not for avatar"; kind = #Other });
            };
          };
        };
        switch (invoice.token.symbol) {
          case ("ICP") {
            switch (await _Ledger.verifyInvoice({ invoice; caller; canisterId })) {
              case (#err(e)) {
                switch (e.kind) {
                  case (#InvalidInvoiceId) {
                    _Logs.logMessage("INVOICE :: ERR :: Invalid invoice id : " # Nat.toText(invoice.id));
                    return #err({ message = ?"Invalid invoice id"; kind = #InvalidInvoiceId });
                  };
                  case (#NotFound) {
                    _Logs.logMessage("INVOICE :: ERR :: Invoice not found : " # Nat.toText(invoice.id));
                    return #err({ message = ?"Invoice not found"; kind = #NotFound });
                  };
                  case (#NotYetPaid) {
                    _Logs.logMessage("INVOICE :: ERR :: Not yet paid : " # Nat.toText(invoice.id));
                    return #err({ message = ?"Invoice not yet paid"; kind = #NotYetPaid });
                  };
                  case (#NotAuthorized) {
                    _Logs.logMessage("INVOICE :: ERR :: Not authorized : " # Nat.toText(invoice.id));
                    return #err({ message = ?"You do not have permission to verify this invoice"; kind = #NotAuthorized });
                  };
                  case (#Expired) {
                    _Logs.logMessage("INVOICE :: ERR :: Expired : " # Nat.toText(invoice.id));
                    return #err({ message = ?"Invoice expired"; kind = #Expired });
                  };
                  case (#TransferError) {
                    _Logs.logMessage("INVOICE :: ERR :: Transfer error : " # Nat.toText(invoice.id));
                    return #err({ message = ?"Transfer error"; kind = #TransferError });
                  };
                  case (#InvalidToken) {
                    _Logs.logMessage("INVOICE :: ERR :: Invalid token : " # Nat.toText(invoice.id));
                    return #err({ message = ?"Invalid token"; kind = #InvalidToken });
                  };
                  case (#InvalidAccount) {
                    _Logs.logMessage("INVOICE :: ERR :: Invalid account : " # Nat.toText(invoice.id));
                    return #err({ message = ?"Invalid account"; kind = #InvalidAccount });
                  };
                  case (#Other) {
                    _Logs.logMessage("INVOICE :: ERR :: Other : " # Nat.toText(invoice.id));
                    return #err({ message = ?"Other"; kind = #Other });
                  };
                };
              };
              case (#ok(value)) {
                switch (value) {
                  case (#AlreadyVerified(_)) {
                    _Logs.logMessage("INVOICE :: ERR :: Already verified : " # Nat.toText(invoice.id));
                    return #err({ message = ?"Invoice already verified"; kind = #Expired });
                  };
                  case (#Paid paidResult) {
                    let replaced = invoices.replace(invoice.id, paidResult.invoice);
                    _Logs.logMessage("INVOICE :: TASK ::  Verified for id " # Nat.toText(invoice.id));
                    _Logs.logMessage("INVOICE :: TASK :: Funds transfered  : " # Nat.toText(invoice.amount));
                    return #ok(#Paid { invoice = paidResult.invoice });
                  };
                };
              };
            };
          };
          case (_) return #err({ message = ?"Invalid token"; kind = #Other });
        };
      };
    };
  };

  public shared ({ caller }) func verify_invoice_accessory(args : T.VerifyInvoiceArgs) : async T.VerifyInvoiceResult {
    assert (caller == accessory_cid);
    let invoice = invoices.get(args.id);
    let canisterId = Principal.fromActor(this);

    switch (invoice) {
      case (null) {
        _Logs.logMessage("INVOICE :: ERR :: Invoice not found : " # Nat.toText(args.id));
        return #err({ message = ?"Invoice not found"; kind = #NotFound });
      };
      case (?invoice) {
        if (Option.isSome(invoice.verifiedAtTime)) {
          _Logs.logMessage("INVOICE :: ERR :: Already verified : " # Nat.toText(invoice.id));
          return #err({ message = ?"Invoice already verified"; kind = #Expired });
        };
        switch (invoice.details) {
          case (null) {
            _Logs.logMessage("INVOICE :: ERR :: No details : " # Nat.toText(invoice.id));
            return #err({ message = ?"Invoice has no details"; kind = #Other });
          };
          case (?details) {
            if (details.description != "accessory") {
              _Logs.logMessage("INVOICE :: ERR :: Not corresponding to an accessory : " # Nat.toText(invoice.id));
              return #err({ message = ?"Invoice is not for accessory"; kind = #Other });
            };
          };
        };
        switch (invoice.token.symbol) {
          case ("ICP") {
            switch (await _Ledger.verifyInvoice({ invoice; caller; canisterId })) {
              case (#err(_)) {
                _Logs.logMessage("INVOICE :: ERR :: Issue when calling the ledger canister : " # Nat.toText(invoice.id));
                return #err({ message = ?"Issue when calling the ledger canister"; kind = #Other });
              };
              case (#ok(value)) {
                switch (value) {
                  case (#AlreadyVerified(_)) {
                    _Logs.logMessage("INVOICE :: ERR :: Already verified : " # Nat.toText(invoice.id));
                    return #err({ message = ?"Invoice already verified"; kind = #Expired });
                  };
                  case (#Paid paidResult) {
                    let replaced = invoices.replace(invoice.id, paidResult.invoice);
                    _Logs.logMessage("INVOICE :: TASK :: Verified for id " # Nat.toText(invoice.id));
                    _Logs.logMessage("INVOICE :: TASK :: Funds transfered  : " # Nat.toText(invoice.amount));
                    return #ok(#Paid { invoice = paidResult.invoice });
                  };
                };
              };
            };
          };
          case (_) return #err({ message = ?"Invalid token"; kind = #Other });
        };
      };
    };
  };

  public shared ({ caller }) func verify_invoice_ticket(args : T.VerifyInvoiceArgs) : async T.VerifyInvoiceResult {
    assert (caller == accessory_cid);
    let invoice = invoices.get(args.id);
    let canisterId = Principal.fromActor(this);

    switch (invoice) {
      case (null) {
        _Logs.logMessage("INVOICE :: ERR :: Invoice not found : " # Nat.toText(args.id));
        return #err({ message = ?"Invoice not found"; kind = #NotFound });
      };
      case (?invoice) {
        if (Option.isSome(invoice.verifiedAtTime)) {
          _Logs.logMessage("INVOICE :: ERR :: Already verified : " # Nat.toText(invoice.id));
          return #err({ message = ?"Invoice already verified"; kind = #Expired });
        };
        switch (invoice.details) {
          case (null) {
            _Logs.logMessage("INVOICE :: ERR :: No details : " # Nat.toText(invoice.id));
            return #err({ message = ?"Invoice has no details"; kind = #Other });
          };
          case (?details) {
            if (details.description != "ticket") {
              _Logs.logMessage("INVOICE :: ERR :: Not corresponding to an accessory : " # Nat.toText(invoice.id));
              return #err({ message = ?"Invoice is not for accessory"; kind = #Other });
            };
          };
        };
        switch (invoice.token.symbol) {
          case ("ICP") {
            switch (await _Ledger.verifyInvoice({ invoice; caller; canisterId })) {
              case (#err(_)) {
                _Logs.logMessage("INVOICE :: ERR :: Issue when calling the ledger canister : " # Nat.toText(invoice.id));
                return #err({ message = ?"Issue when calling the ledger canister"; kind = #Other });
              };
              case (#ok(value)) {
                switch (value) {
                  case (#AlreadyVerified(_)) {
                    _Logs.logMessage("INVOICE :: ERR :: Already verified : " # Nat.toText(invoice.id));
                    return #err({ message = ?"Invoice already verified"; kind = #Expired });
                  };
                  case (#Paid paidResult) {
                    let replaced = invoices.replace(invoice.id, paidResult.invoice);
                    _Logs.logMessage("INVOICE :: TASK :: verified : " # Nat.toText(invoice.id));
                    _Logs.logMessage("INVOICE :: TASK :: funds transfered  : " # Nat.toText(invoice.amount));
                    return #ok(#Paid { invoice = paidResult.invoice });
                  };
                };
              };
            };
          };
          case (_) return #err({ message = ?"Invalid token"; kind = #Other });
        };
      };
    };
  };

  // #region Transfer
  public shared ({ caller }) func transfer(args : T.TransferArgs) : async T.TransferResult {
    let token = args.token;
    let accountResult = U.accountIdentifierToBlob(
      {
        accountIdentifier = args.destination;
        canisterId = ?Principal.fromActor(this);
      },
    );
    switch (accountResult) {
      case (#err err) {
        #err(
          {
            message = err.message;
            kind = #InvalidDestination;
          },
        );
      };
      case (#ok destination) {
        switch (token.symbol) {
          case "ICP" {
            let now = Nat64.fromIntWrap(Time.now());

            let transferResult = await _Ledger.transfer(
              {
                memo = 0;
                fee = {
                  e8s = 10000;
                };
                amount = {
                  // Total amount, minus the fee
                  e8s = Nat64.sub(Nat64.fromNat(args.amount), 10000);
                };
                from_subaccount = ?A.principalToSubaccount(caller);
                to = destination;
                created_at_time = null;
              },
            );
            switch (transferResult) {
              case (#ok result) {
                #ok(result);
              };
              case (#err err) {
                switch (err.kind) {
                  case (#BadFee _) {
                    #err(
                      {
                        message = err.message;
                        kind = #BadFee;
                      },
                    );
                  };
                  case (#InsufficientFunds _) {
                    #err(
                      {
                        message = err.message;
                        kind = #InsufficientFunds;
                      },
                    );
                  };
                  case _ {
                    #err(
                      {
                        message = err.message;
                        kind = #Other;
                      },
                    );
                  };
                };
              };
            };
          };
          case _ {
            errInvalidToken;
          };
        };
      };
    };
  };
  // #endregion

  public shared ({ caller }) func transfer_back_invoice(invoiceId : Nat) : async Result.Result<(), Text> {
    assert (_Admins.isAdmin(caller) or caller == Principal.fromActor(this));
    switch (invoices.get(invoiceId)) {
      case (null) {
        return #err("Invoice not found");
      };
      case (?invoice) {
        let destinationResult : T.GetDestinationAccountIdentifierResult = getDestinationAccountIdentifier(
          {
            token = { symbol = "ICP" };
            invoiceId;
            caller = invoice.creator;
          },
        );
        switch (destinationResult) {
          case (#ok(result)) {
            let destination : AccountIdentifier = result.accountIdentifier;
            let account = U.accountIdentifierToText(
              {
                accountIdentifier = destination;
                canisterId = ?Principal.fromActor(this);
              },
            );
            switch (account) {
              case (#err(e)) {
                return #err("Error calculating the account");
              };
              case (#ok(result)) {
                switch (await _Ledger.balance({ account = result })) {
                  case (#ok(success)) {
                    if (success.balance > 0) {
                      let subaccount = U.generateInvoiceSubaccount(
                        {
                          caller = invoice.creator;
                          id = invoiceId;
                        },
                      );
                      switch (
                        await _Ledger.transfer(
                          {
                            memo = 0;
                            fee = {
                              e8s = 10000;
                            };
                            amount = {
                              // Total amount, minus the fee
                              e8s = Nat64.sub(Nat64.fromNat(success.balance), 10000);
                            };
                            from_subaccount = ?subaccount;
                            // Send back the funds to main wallet.
                            to = U.getDefaultAccount({ canisterId = Principal.fromActor(this); principal = Principal.fromText("dv5tj-vdzwm-iyemu-m6gvp-p4t5y-ec7qa-r2u54-naak4-mkcsf-azfkv-cae") });
                            created_at_time = null;
                          },
                        ),
                      ) {
                        case (#ok(_)) {
                          _Logs.logMessage("INVOICE :: TASK :: refund completed  : " # Nat.toText(invoiceId));
                          return #ok;
                        };
                        case (#err(_)) {
                          return #err("Issue when calling the ledger canister");
                        };
                      };
                    };
                    return #err("No funds to refund");
                  };
                  case (#err(_)) {
                    return #err("Issue when querying the balance");
                  };
                };
              };
            };
          };
          case (#err(_)) return #err("Account not found");
        };
      };
    };
  };

  // #region get_account_identifier
  /*
    * Get Caller Identifier
    * Allows a caller to the accountIdentifier for a given principal
    * for a specific token.
    */
  public query func get_account_identifier(args : T.GetAccountIdentifierArgs) : async T.GetAccountIdentifierResult {
    let token = args.token;
    let principal = args.principal;
    let canisterId = Principal.fromActor(this);
    switch (token.symbol) {
      case "ICP" {
        let subaccount = U.getDefaultAccount({ principal; canisterId });
        let hexEncoded = Hex.encode(
          Blob.toArray(subaccount),
        );
        let result : AccountIdentifier = #text(hexEncoded);
        #ok({ accountIdentifier = result });
      };
      case _ {
        errInvalidToken;
      };
    };
  };
  // #endregion

  // #region Utils
  public func accountIdentifierToBlob(accountIdentifier : AccountIdentifier) : async T.AccountIdentifierToBlobResult {
    U.accountIdentifierToBlob(
      {
        accountIdentifier;
        canisterId = ?Principal.fromActor(this);
      },
    );
  };
  // #endregion

  let ONE_HOUR_NANOSECONDS = Nat64.fromIntWrap(1 * 60 * 60 * 1000 * 1000 * 1000);

  /* 
    Check the balance of all the accounts related to past invoices & iniatiate the transfer of funds if needed.
    @cronic : every 1 hour.
*/
  public shared ({ caller }) func cron_balance() : async () {
    assert (caller == hub_cid or _Admins.isAdmin(caller));
    if (List.size(invoices_to_check) == 0) {
      return;
    };
    // Keep track of empty account, to be refunded account & failed verifcation.
    var empty : List.List<(Principal, Nat)> = null;
    var refunded : List.List<(Principal, Nat)> = null;
    var failed : List.List<(Principal, Nat)> = null;

    let (tmp, remaining) = List.pop(invoices_to_check);
    var info = tmp;
    invoices_to_check := remaining;
    label queue while (Option.isSome(info)) ignore do ?{
      let account = U.getICPAccountIdentifier({ principal = Principal.fromActor(this); subaccount = U.generateInvoiceSubaccount({ caller = info!.0; id = info!.1 }) });
      let accountIdentifier : Text = Hex.encode(Blob.toArray(account));
      try {
        switch (await _Ledger.balance({ account = accountIdentifier })) {
          case (#ok(success)) {
            if (success.balance == 0) {
              empty := List.push<(Principal, Nat)>((info!.0, info!.1), empty);
            } else {
              _Logs.logMessage("INVOICE :: VERIF :: WARNING :: account is not empty for invoice : " # Nat.toText(info!.1));
              refunded := List.push<(Principal, Nat)>((info!.0, info!.1), refunded);
              switch (await transfer_back_invoice(info!.1)) {
                case (#ok(_)) {
                  _Logs.logMessage("INVOICE :: VERIF :: refund completed  : " # Nat.toText(info!.1));
                };
                case (#err(_)) {
                  _Logs.logMessage("INVOICE :: VERIF :: refund failed  : " # Nat.toText(info!.1));
                  failed := List.push<(Principal, Nat)>((info!.0, info!.1), failed);
                };
              };
            };
          };
          case (#err(e)) switch (e.kind) {
            case (#InvalidToken) {
              _Logs.logMessage("INVOICE :: VERIF :: invalid token for invoice : " # Nat.toText(info!.1));
              failed := List.push<(Principal, Nat)>((info!.0, info!.1), failed);
            };
            case (#InvalidAccount) {
              _Logs.logMessage("INVOICE :: VERIF :: invalid account for invoice : " # Nat.toText(info!.1));
              failed := List.push<(Principal, Nat)>((info!.0, info!.1), failed);
            };
            case (#NotFound) {
              _Logs.logMessage("INVOICE :: VERIF :: account not found for invoice : " # Nat.toText(info!.1));
              failed := List.push<(Principal, Nat)>((info!.0, info!.1), failed);
            };
            case (_) {
              _Logs.logMessage("INVOICE :: VERIF :: unknown error for invoice : " # Nat.toText(info!.1));
              failed := List.push<(Principal, Nat)>((info!.0, info!.1), failed);
            };
          };
        };
      } catch e {
        _Logs.logMessage("INVOICE :: VERIF :: Error when calling the ledger canister : " # Nat.toText(info!.1));
        failed := List.push<(Principal, Nat)>((info!.0, info!.1), failed);
      };
      let (tmp, remaining) = List.pop(invoices_to_check);
      info := tmp;
      invoices_to_check := remaining;
    };
    // Put back the invoices that failed to verify and those that should have been refunded.
    invoices_to_check := List.append<(Principal, Nat)>(failed, refunded);
  };

  public shared ({ caller }) func get_invoices_to_check() : async [(Principal, Nat)] {
    assert (_Admins.isAdmin(caller));
    return List.toArray(invoices_to_check);
  };

  // #region Upgrade Hooks
  system func preupgrade() {
    entries := Iter.toArray(invoices.entries());
    _LogsUD := ?_Logs.preupgrade();
    _AdminsUD := ?_Admins.preupgrade();
  };

  system func postupgrade() {
    _Logs.postupgrade(_LogsUD);
    _LogsUD := null;
    _Admins.postupgrade(_AdminsUD);
    _AdminsUD := null;
  };
  // #endregion

};
