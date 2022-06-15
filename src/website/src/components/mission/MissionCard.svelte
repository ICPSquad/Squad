<script lang="ts">
  import { createEventDispatcher } from "svelte";
  import type { Mission } from "@canisters/hub/hub.did.d";
  import { missionStatusToText } from "@utils/mission";
  import { setMessage } from "@src/store/toast";

  export let mission: Mission;
  export let completed: BigInt[] = [];
  $: isCompleted = completed.includes(mission.id);

  let dispatch = createEventDispatcher();
  const handleClick = () => {
    if (isCompleted) {
      setMessage("You have already validated this mission. You can only get the reward once, sorry.", "success", 3000);
      return;
    }
    if ("Pending" in mission.status || "Ended" in mission.status) {
      setMessage("It looks like this mission. Please wait for it to be available.", "error", 3000);
      return;
    }
    dispatch("validateMission", mission.id);
  };

  $: status = missionStatusToText(mission.status);
</script>

<div class="card">
  <div class="header">
    <h3>{mission.title}</h3>
    <div class="image">
      <img src={mission.url_icon} alt="MISSION ICON" />
    </div>
  </div>
  <div class="description">
    <p><span class="bold"> > Task :</span> {mission.description}</p>
  </div>
  <div class="rewards">
    <p><span class="bold"> > Rewards :</span> {mission.points} points.</p>
  </div>
  <div class="validation">
    {#if status != "Ended" && status != "Pending"}
      <button class={isCompleted ? "completed" : ""} on:click={handleClick}> {isCompleted ? "Completed" : "Validate"} </button>
    {/if}
  </div>
  <div class="status">
    <div class={"blob " + status} />
    <div class="text">{status}</div>
  </div>
</div>

<style lang="scss">
  @use "../../styles" as *;

  .completed {
    background-color: $green;
  }

  .header {
    display: flex;
    width: 100%;
    justify-content: space-between;
    align-items: center;
  }

  img {
    height: 65px;
    border-radius: 50%;
    margin-bottom: 10px;
  }

  .card {
    background-color: $verydarkgrey;
    border-radius: 10px;
    display: flex;
    padding: 30px 40px;
    flex-direction: column;
    justify-content: space-around;
  }

  .bold {
    font-weight: bold;
  }

  .validation {
    margin: 10px auto;
    width: 80%;
  }

  .status {
    margin: 20px 0;
    display: flex;
    align-items: center;
    justify-content: left;
    font-size: x-large;
  }

  .text {
    margin-left: 20px;
    font-weight: bold;
  }

  .blob {
    border-radius: 50%;
    margin: 10px;
    height: 20px;
    width: 20px;
    box-shadow: 0 0 0 0 rgba(0, 0, 0, 1);
    transform: scale(1);
  }

  .Running {
    background-color: $green;
    animation: pulse 2s infinite;
  }

  .Pending {
    background-color: $yellow;
    animation: pulse 5s infinite;
  }

  .Ended {
    background-color: red;
  }

  @keyframes pulse {
    0% {
      transform: scale(0.95);
      box-shadow: 0 0 0 0 rgba(0, 0, 0, 0.7);
    }

    70% {
      transform: scale(1);
      box-shadow: 0 0 0 10px rgba(0, 0, 0, 0);
    }

    100% {
      transform: scale(0.95);
      box-shadow: 0 0 0 0 rgba(0, 0, 0, 0);
    }
  }
</style>
