import Array "mo:base/Array";
import Buffer "mo:base/Buffer";
import Iter "mo:base/Iter";
import Nat "mo:base/Nat";
import Prim "mo:prim";
import Result "mo:base/Result";
import Text "mo:base/Text";
import Time "mo:base/Time";
import TrieMap "mo:base/TrieMap";

import Ext "mo:ext/Ext";

import Cap "../Cap";
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

        public func preupgrade () : UpgradeData {
            return({
                recorded_rewards = Iter.toArray(recordedRewards.entries());
            })
        };

        public func postupgrade(ud : ?UpgradeData) : () {
            switch(ud){
                case(? ud){
                    for((account, rewards) in ud.recorded_rewards.vals()){
                        recordedRewards.put(account, rewards);
                    };
                };
                case(null){};
            };
        };

        // 1 : Create the token (with EXT)
        // 2 : Assign the corresponding material to the token
        // 3 : Report event to CAP
        // 4 : Record events into the TrieMap
        // 5 : Log a summary of the airdrop
        public func airdropRewards(
            data : [(AccountIdentifier, Airdrop)]
        ) : () {
            var error_count : Nat = 0;
            var success_count : Nat = 0;
            for((account, airdrop) in data.vals()){
                let r : Buffer.Buffer<Reward> = Buffer.Buffer(0);
                for(name in airdrop.vals()){
                    // Mint a token and assign the ownership to the account (no need to convert / calculate the subaccount)
                    let tokenIndex = _Ext.mintAccount(account);
                    let tokenIdentifier = Ext.TokenIdentifier.encode(cid, tokenIndex);
                    // Associate an item to this Token
                    switch(_Items.mint(name, tokenIndex)){
                        case(#ok()){
                            success_count += 1;
                        };
                        case(#err(_)){
                            error_count += 1;
                        };
                    };
                    let reward : Reward = {
                        name;
                        category = #NFT;
                        collection = cid;
                        date = Time.now();
                        amount = 1;
                        identifier = ?tokenIdentifier;
                    };
                    r.add(reward);
                    // Report the mint event to CAP
                    let event : Cap.IndefiniteEvent = {
                        operation = "mint";
                        details = [
                        ("token", #Text(tokenIdentifier)),
                        ("name", #Text(name)),
                        ("to", #Text(account)),
                        ("airdrop", #Text(""))
                        ];
                        caller = cid;
                    };
                    _Cap.insertEvent(event);
                };
                // Record the events into the TrieMap
                switch(recordedRewards.get(account)){
                    case(null){
                        recordedRewards.put(account, r.toArray());
                    };
                    case(? rewards){
                        recordedRewards.put(account, Array.append<Reward>(rewards, r.toArray()));
                    };
                };
            };
            _Logs.logMessage("TASK :: airdrop has been completed :: SUCCESS : " # Nat.toText(success_count) # " ERROR : " # Nat.toText(error_count));
        };

        public func getRecordedRewards(p : Principal) : ?[Reward] {
            let account_identifier = Text.map(Ext.AccountIdentifier.fromPrincipal(p, null), Prim.charToLower);
            switch(recordedRewards.get(account_identifier)){
                case(null){
                    return null;
                };
                case(? rewards){
                    return ?rewards;
                };
            };
        };
    };   
};