import Result "mo:base/Result";
import Time "mo:base/Time";

import Canistergeek "mo:canistergeek/canistergeek";

import Cap "../Cap";
import Ext "../Ext";
import Items "../Items";

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
    #Material : Text;
    #NFT : Text;
    #Token : Text;
    #Other;
  };

  type URL = Text;
  public type Token = {
    name : Text;
    symbol : Text;
    decimals : Nat8;
    icon : ?URL;
  };

  public type NFT = {
    name : Text;
    symbol : Text;
    identifier : Text;
    icon : ?URL;
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
