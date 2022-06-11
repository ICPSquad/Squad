<script lang="ts">
  export let id: Number = 0;
  export let title: string = "Show your style 😎";
  export let description: string = "Mint one accessory to complete this mission.";
  export let reward: string = "100 points";
  //   export let start_date: Number = 0;
  //   export let end_date: Number = 0;
</script>

<div class="card">
  <div class="header">
    <h3>{title}</h3>
  </div>
  <div class="description">
    <p>Task : {description}</p>
  </div>
  <div class="rewards">
    <p>Reward: {reward}</p>
  </div>
  <div class="rewards">
    <p>Remaining time : 30 days.</p>
  </div>
  <div class="validation">
    <button> Validate </button>
  </div>
</div>

<style lang="scss">
  @use "../../styles" as *;

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
