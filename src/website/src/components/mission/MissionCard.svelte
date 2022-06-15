<script lang="ts">
  import { createEventDispatcher } from "svelte";
  export let title: string = "Show your style 😎";
  export let description: string = "Mint one accessory to complete this mission.";
  export let reward: string = "100 points";
  export let completed: BigInt[] = [];
  export let url_icon: string = "https://pbs.twimg.com/profile_images/1437609679413293057/ykp1GcEw_400x400.jpg";
  export let id: BigInt = BigInt(1);

  $: isCompleted = completed.includes(id);

  let dispatch = createEventDispatcher();
  const handleClick = () => {
    if (isCompleted) {
      return;
    }
    dispatch("validateMission", id);
  };
</script>

<div class="card">
  <div class="header">
    <h3>{title}</h3>
    <div class="image">
      <img src={url_icon} alt="MISSION ICON" />
    </div>
  </div>
  <div class="description">
    <p>Task : {description}</p>
  </div>
  <div class="rewards">
    <p>Reward : {reward}</p>
  </div>
  <div class="validation">
    <button class={isCompleted ? "completed" : ""} on:click={handleClick}> {isCompleted ? "Completed" : "Validate"} </button>
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
    margin-bottom: 20px;
  }

  img {
    height: 65px;
    border-radius: 50%;
  }

  .card {
    background-color: $verydarkgrey;
    border-radius: 10px;
    display: flex;
    padding: 30px 40px;
    margin-bottom: 20px;
    flex-direction: column;
    justify-content: space-around;
  }
</style>
