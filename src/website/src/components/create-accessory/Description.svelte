<script lang="ts">
  export let description: string | undefined;
</script>

<div>
  <div class="description">
    <div class="left">
      <h3>Description</h3>
      <div class="text">
        {description}
      </div>
    </div>
  </div>
</div>

<style lang="scss">
  @use "./src/website/src/styles" as *;

  .description {
    background-color: $verydarkgrey;
    padding: 10px;
    margin: 10px auto;
    // min-height: 250px;
    // border: 2px solid $pink;
    border-radius: 10px;
  }

  h3 {
    color: var(--page-feature-color);
    text-align: center;
  }
  .text {
    font-size: 16px;
    color: $white;
  }
</style>
