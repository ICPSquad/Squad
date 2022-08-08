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
        name : Text;
        category : TypeReward;
        collection : Principal;
        date : Time.Time;
        amount : Nat;
        identifier : ?Text;
    };

    public type TypeReward = {
        #NFT;
        #Token;
        #Other;
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
        getRecordedRewards(Principal) : ?[Reward]
    };





}