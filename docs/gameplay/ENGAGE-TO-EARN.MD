# The engage-to-earn mechanism

The goal of this paper is to define what is the inner working of the engagement mechanism that will work accross different dapps.

Requirements :

- Minimum integration needed for our partners.
- Any app should be free to rank or score its users according to it's own rules.
- Support two types of scoring system : numerical and hierarchical.

# Main canister : ICP Squad

- Admins functionnalities
- Register method to register a dApp.
- Query method to get the scores (to print the leaderboard).

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
```

# Dapp canister

The app needs to incorporate a scoring system, at least a minimal one (ie associate a Principal with a specific value). <br/> We currently accept two kinds of systems.

- Value : A value is provided. The value can represents anything of value/interest for the dApp.
- Rank : A rank is provided. Building on the fact that the platform might implement it's own leaderboard/ranking system.

The app needs to implement an interface with the getScores method.

```
getScores : shared () -> async [(Principal, Score)];
getScoreVersion : shared () -> async Nat;
```

# Potential improvements

- If the payload is heavier than 5MB (intercanister size limit); this implementation might break and cause scaling issues. <br/> I believe it is enough to build a proof of concept around it, but a new schema/model will ultimately be necessary.
  <br/> <br/>
  A candid encoded list of 10 (Principal,Score) tupple is taking only 364 bytes. (Assuming scores are values 10_000 of type Nat). <br/>
  Taking an average of 3.65 bytes per tupple, considering the 5MB limit of intercanister calls.
  This means this architecture could in theory scale up to more than 1 million tupples... others IC-limits will be reached before those figures.

- Only trusted canisters should be implemented into the scheme; to open the service to potential miscellanous actors the **actor model** should be implemented. <br/> More details : https://www.joachim-breitner.de/blog/789-Zero-downtime_upgrades_of_Internet_Computer_canisters

- Build as an Open Internet Service where any service can register and publish their score.
