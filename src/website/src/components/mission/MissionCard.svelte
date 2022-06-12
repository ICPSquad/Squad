<script lang="ts">
  import { createEventDispatcher } from "svelte";
  export let title: string = "Show your style 😎";
  export let description: string = "Mint one accessory to complete this mission.";
  export let reward: string = "100 points";
  export let completed: BigInt[] = [];
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

  .card {
    width: 100%;
    height: 500px;
    background-color: $verydarkgrey;
    border-radius: 10px;
    display: flex;
    padding: 20px 40px;
    flex-direction: column;
    justify-content: space-around;
  }
</style>
