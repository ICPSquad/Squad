# The engage-to-earn mechanism

The goal of this paper is to define what is the inner working of the engagement mechanism that will work accross different dapps.

## Open Internet Service for scores

Requirements :

- Minimum integration needed for our partners.
- Any app should be free to rank or score its users according to it's own rules.
- Only trusted canisters should be implemented into the scheme; to open the service to potential miscellanous actors the **actor model** should be implemented (which is not the case here). <br/> More details : https://www.joachim-breitner.de/blog/789-Zero-downtime_upgrades_of_Internet_Computer_canisters
- Support two types of scoring system : numerical and hierarchical.

# Main canister : ICP Squad

- Admins functionnalities
- Register method to register a dApp/
- Query method to get the scores (to print the leaderboard).
- Update method to distribute the prizes.

```
type App = {
    name : Text;
    canister : Principal;
};
```

```
type Score = {
    #Value : Nat;
    #Rank : Nat;
};

```

Here's the interface of the ICP Squad canister.

```
register : shared (App) -> async ();
getMegaScores : shared () -> async [(Principal, Score)];
distribute : () -> async Result<(), Error>;
```

# Dapp canister

The app needs to incorporate a scoring system, at least a minimal one (ie associate a Principal with a specific value). <br/> We have currently two kinds of system possible.

- Value : A value is provided. The value can represents anything of value/interest for the dApp. For example for Gigaverse it will correspond to the amount of ICP spent on their platform.
- Rank : A rank is provided. Building on the fact that the platform might implement it's own leaderboard/ranking system.

The app needs to implement an interface with the getScores method

```
getScores : shared () -> async [(Principal, Score)];
getScoreVersion : shared () -> async Nat;
```

⚠️ If the payload is heavier than 5MB; this implementation might break and cause scaling issues. <br/> I believe it is enough to build a proof of concept around it, but a new schema/model will ultimately be necessary.

Test :
A candid encoded list of 10 (Principal,Score) tupple is taking only 364 bytes. (Assuming scores are values 10_000 of type Nat).
Taking an average of 3.65 bytes per tupple, considering the 5MB limit of intercanister calls.
This means this architecture could in theory scale up to more than 1 million tupples... others IC-limits will be reached before those figures.
