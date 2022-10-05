import Array "mo:base/Array";
import Buffer "mo:base/Buffer";
import Iter "mo:base/Iter";
import Nat "mo:base/Nat";
import Prim "mo:prim";
import Principal "mo:base/Principal";
import Result "mo:base/Result";
import Text "mo:base/Text";
import Time "mo:base/Time";
import TrieMap "mo:base/TrieMap";

import Ext "mo:ext/Ext";

import Cap "../cap";
import Types "types";

module {

  public type Reward = Types.Reward;
  public type Airdrop = Types.Airdrop;
  public type AccountIdentifier = Types.AccountIdentifier;
  public type UpgradeData = Types.UpgradeData;

  public class Factory(dependencies : Types.Dependencies) : Types.Interface {

    let recordedRewards : TrieMap.TrieMap<AccountIdentifier, [Reward]> = TrieMap.TrieMap<AccountIdentifier, [Reward]>(Text.equal, Text.hash);

    let _Logs = dependencies._Logs;
    let _Ext = dependencies._Ext;
    let _Items = dependencies._Items;
    let _Cap = dependencies._Cap;
    let cid = dependencies.cid;

    public func preupgrade() : UpgradeData {
      return (
        {
          recorded_rewards = Iter.toArray(recordedRewards.entries());
        },
      );
    };

    public func postupgrade(ud : ?UpgradeData) : () {
      switch (ud) {
        case (?ud) {
          for ((account, rewards) in ud.recorded_rewards.vals()) {
            recordedRewards.put(account, rewards);
          };
        };
        case (null) {};
      };
    };

    public func recordICP(
      account : AccountIdentifier,
      amount : Nat,
    ) : () {
      let reward : Reward = {
        collection = Principal.fromText("ryjl3-tyaaa-aaaaa-aaaba-cai");
        category = #Token(
          {
            name = "ICP";
            decimals = 8;
            icon = null;
          },
        );
        date = Time.now();
        amount = amount;
      };
      _record(account, reward);
    };

    public func recordNFT(
      account : AccountIdentifier,
      collection : Principal,
      name : Text,
      identifier : Text,
    ) : () {
      let reward : Reward = {
        collection;
        category = #NFT(
          {
            name = name;
            identifier = identifier;
          },
        );
        date = Time.now();
        amount = 1;
      };
      _record(account, reward);
    };

    public func recordToken(
      account : AccountIdentifier,
      amount : Nat,
      name : Text,
      decimals : Nat8,
      collection : Principal,
    ) : () {
      let reward : Reward = {
        collection;
        category = #Token(
          {
            name;
            decimals;
          },
        );
        date = Time.now();
        amount;
      };
      _record(account, reward);
    };

    public func removeRecordNFT(
      account : AccountIdentifier,
      identifier : Text,
    ) : () {
      switch (recordedRewards.get(account)) {
        case (null) {};
        case (?rewards) {
          let new_rewards = Array.filter<Reward>(rewards, func(x) { _getIdentifier(x) == identifier });
          recordedRewards.put(account, new_rewards);
        };
      };
    };

    // 1 : Create the token (with EXT)
    // 2 : Assign the corresponding material to the token
    // 3 : Report event to CAP
    // 4 : Record events into the TrieMap
    // 5 : Log a summary of the airdrop
    public func airdropRewards(
      data : [(AccountIdentifier, Airdrop)],
    ) : () {
      var error_count : Nat = 0;
      var success_count : Nat = 0;
      for ((account, airdrop) in data.vals()) {
        let r : Buffer.Buffer<Reward> = Buffer.Buffer(0);
        for (name in airdrop.vals()) {
          // Mint a token and assign the ownership to the account (no need to convert / calculate the subaccount)
          let tokenIndex = _Ext.mintAccount(account);
          let tokenIdentifier = Ext.TokenIdentifier.encode(cid, tokenIndex);
          // Associate an item to this Token
          switch (_Items.mint(name, tokenIndex)) {
            case (#ok()) {
              success_count += 1;
            };
            case (#err(_)) {
              error_count += 1;
            };
          };
          let reward : Reward = {
            collection = Principal.fromText("po6n2-uiaaa-aaaaj-qaiua-cai");
            category = #NFT(
              {
                name;
                identifier = tokenIdentifier;
              },
            );
            date = Time.now();
            amount = 1;
          };
          r.add(reward);
          // Report the mint event to CAP
          // let event : Cap.IndefiniteEvent = {
          //   operation = "mint";
          //   details = [
          //     ("token", #Text(tokenIdentifier)),
          //     ("name", #Text(name)),
          //     ("to", #Text(account)),
          //     ("airdrop", #Text("")),
          //   ];
          //   caller = cid;
          // };
          // ignore (_Cap.registerEvent(event));
        };
        // Record the events into the TrieMap
        switch (recordedRewards.get(account)) {
          case (null) {
            recordedRewards.put(account, r.toArray());
          };
          case (?rewards) {
            recordedRewards.put(account, Array.append<Reward>(rewards, r.toArray()));
          };
        };
      };
      _Logs.logMessage("TASK :: airdrop has been completed :: SUCCESS : " # Nat.toText(success_count) # " ERROR : " # Nat.toText(error_count));
    };

    public func getRecordedRewards(p : Principal) : ?[Reward] {
      let account_identifier = Text.map(Ext.AccountIdentifier.fromPrincipal(p, null), Prim.charToLower);
      switch (recordedRewards.get(account_identifier)) {
        case (null) {
          return null;
        };
        case (?rewards) {
          return ?rewards;
        };
      };
    };

    public func deleteRecordedRewards(p : Principal) : () {
      let account_identifier = Text.map(Ext.AccountIdentifier.fromPrincipal(p, null), Prim.charToLower);
      recordedRewards.delete(account_identifier);
    };

    public func getAllRecordedRewards() : [(AccountIdentifier, [Reward])] {
      Iter.toArray(recordedRewards.entries());
    };

    func _record(
      account : AccountIdentifier,
      reward : Reward,
    ) : () {
      switch (recordedRewards.get(account)) {
        case (null) {
          recordedRewards.put(account, [reward]);
        };
        case (?some) {
          recordedRewards.put(account, Array.append<Reward>(some, [reward]));
        };
      };
    };

    func _getIdentifier(
      reward : Reward,
    ) : Text {
      switch (reward.category) {
        case (#Material(nft)) {
          return (nft.identifier);
        };
        case (#NFT(nft)) {
          return (nft.identifier);
        };
        case _ {
          return ("");
        };
      };
    };
  };
};
