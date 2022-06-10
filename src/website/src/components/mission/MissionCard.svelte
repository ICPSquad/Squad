<script lang="ts">
  export let id: Number = 0;
  export let title: string = "To the moon 🪐";
  export let description: string = "Mint the astro-suit & and the astro-helmet to complete this mission.";
  export let reward: string = "100 points ";
  //   export let start_date: Number = 0;
  //   export let end_date: Number = 0;
</script>

<div class="card">
  <div class="header">
    <h3>{title}</h3>
  </div>
  <div class="middle">
    <div class="description">
      Description : {description}
    </div>
    <div class="rewards">
      Reward : {reward}
    </div>
    <div class="validation">
      <button> Validate </button>
    </div>
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
    align-items: center;
  }

  button {
    width: 50%;
    margin: 40px auto;
  }
</style>
