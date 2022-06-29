# dSquad : SDK for gamifying an app. (Find a good name)

## Requirements.

- Each app has full control over their canisters.
- Can scale to more than 4GB of events and metrics.
- Can upgrade and manage the fleet.
- Should avoid the await pattern that causes non-upgreadeable canister.
- Central canister to the architecture to keep meta informations and query all others.
- Motoko package.
- Certificate available (like CAP)

## Interface.

```
type DetailValue = variant {
  I64 : int64;
  U64 : nat64;
  Vec : vec DetailValue;
  Slice : vec nat8;
  TokenIdU64 : nat64;
  Text : text;
  True;
  False;
  Float : float64;
  Principal : principal;
};

type Event = {
    time : Nat64;
    caller : Principal;
    operation : Text;
    details : [(Text, DetailValue)];
};
```

insert_event(e : Event);

insert_many_events(e : [Event]);

get_score(p : Principal);

get_events_user(p : Principal, t1, t2);

get_events(t1, t2) -> List of events;

get_size(t1, t2) -> (Number of total events);

- Design of missions will take place inside our canister : dApps will be able to publish events, based on the informations we can query this and design missions.

## Scoring system

Each dApp should be able to customize their own scoring system.
A external dApp can choose to use the events and create the score of an user based on this but we can also imagine another system where the dApp would diretly expose an API to query the score :

```
get_score(p : Principal , t1 : Time.Time, t2 : Time.Time)
```

The function to calculate the score will be completely customizable and written by the dApp itself.

## Trust issue

If the dApp has control over the canister, how do we ensure that we can trust it ?

- We can use one-shoot messages and creates an interface on our side to receive events and scores. However this increases friction and reduce readability.

Question : Should we use a certificate to certify the events and scores, storing everything in a TreeMap and recomputing the new hash at every change.
