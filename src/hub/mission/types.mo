import Result "mo:base/Result";
import Time "mo:base/Time";

import Canistergeek "mo:canistergeek/canistergeek";

import Admins "../admins";
import Cap "../cap";
module {

  public type Mission = {
    id : Nat;
    title : Text;
    description : Text;
    url_icon : Text;
    created_at : Time.Time;
    started_at : ?Time.Time;
    ended_at : ?Time.Time;
    restricted : ?[Principal];
    validation : MissionValidation;
    status : MissionStatus;
    points : Nat;
    tags : [Text];
  };

  public type CreateMission = {
    title : Text;
    description : Text;
    url_icon : Text;
    restricted : ?[Principal];
    validation : MissionValidation;
    points : Nat;
    tags : [Text];
  };

  public type MissionValidation = {
    #Automatic : AutomaticValidation;
    #Custom : CustomValidation;
    #Manual : ManualValidation;
    #Internal;
  };

  /* 
        The automatic validation involved calling a standardised API to validate the mission
        We call the endpoint verify_mission : (id : Nat, caller : Principal) -> async Bool in the provided canister.
        The verification process is processed by the canister (need to trust it).
    */
  public type AutomaticValidation = {
    canister : Principal;
  };

  /* 
        The manual validation process involved trusting a list of moderators that can validate principals 
        They are responsible for ending the mission and providing a list of winners.
    */
  public type ManualValidation = {
    moderators : [Principal];
  };

  /* 
        This custom validation process allow for a more customised API to validate a mission.
        We call the provided canister, with the provided method and arguments to validate the mission.
    */
  public type CustomValidation = {
    canister : Principal;
    method_name : Text;
    args : Blob;
  };

  /* 
        This internal validation process allow the Hub canister to directly verify a mission.
        This is mostly used in coordination with the CAP module.
    */

  public type MissionStatus = {
    #Pending;
    #Running;
    #Ended;
  };

  public type Dependencies = {
    cid_avatar : Principal;
    _Admins : Admins.Admins;
    _Logs : Canistergeek.Logger;
    _Cap : Cap.Factory;
  };

  public type UpgradeData = {
    next_mission_id : Nat;
    missions : [(Nat, Mission)];
    winners : [(Nat, [Principal])];
    completedMissions : [(Principal, [(Nat, Time.Time)])];
  };

  public type Interface = {

    /* 
            Creates a mission.
            @ok : Returns the id of the mission
            @err : Returns an error message
        */
    createMission : (mission : CreateMission, caller : Principal) -> Result.Result<Nat, Text>;

    /* Start a mission */
    startMission : (id : Nat) -> Result.Result<(), Text>;

    /* Verifiy a mission */
    verifyMission : (id : Nat, caller : Principal) -> async Result.Result<(), Text>;
    // Rewards ?

    /* Delete a mission by id */
    delete_mission : (id : Nat) -> Result.Result<(), Text>;

    /* End a mission by id */
    end_mission : (id : Nat, winners : ?[Principal]) -> Result.Result<(), Text>;
  };
};
