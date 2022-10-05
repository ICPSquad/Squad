import Result "mo:base/Result";
import Time "mo:base/Time";

import Canistergeek "mo:canistergeek/canistergeek";

import Cap "../cap";
import Ext "../ext";
import Items "../items";

module {

  public type AccountIdentifier = Text;
  public type Airdrop = [Text];

  public type Reward = {
    collection : Principal;
    category : TypeReward;
    date : Time.Time;
    amount : Nat;
  };

  public type TypeReward = {
    #Material : NFT;
    #NFT : NFT;
    #Token : Token;
    #Other;
  };

  type URL = Text;
  public type Token = {
    name : Text;
    decimals : Nat8;
  };

  public type NFT = {
    name : Text;
    identifier : Text;
  };

  public type UpgradeData = {
    recorded_rewards : [(AccountIdentifier, [Reward])];
  };

  public type Dependencies = {
    _Logs : Canistergeek.Logger;
    _Ext : Ext.Factory;
    _Items : Items.Factory;
    _Cap : Cap.Factory;
    cid : Principal;
  };

  public type Interface = {
    preupgrade() : UpgradeData;
    postupgrade(?UpgradeData) : ();
    airdropRewards([(AccountIdentifier, Airdrop)]) : ();
    getRecordedRewards(Principal) : ?[Reward];
  };

};
