<script>
  import Carat from "@icons/Carat.svelte";
  export let title = "";
  let open = false;

  // Seems like this is the only way to apply style on the
  // @html imported faqs
  const style = `<style> p { font-size: 1rem } </style>`;
</script>

<div class="faq">
  <div on:click={() => (open = !open)} class="faq-header">
    <h3>{title}</h3>
    <Carat rotate={open ? -90 : 90} />
  </div>
  {#if open}
    <article>
      {@html style}
      <slot />
    </article>
  {/if}
</div>

<style lang="scss">
  @use "../../styles" as *;
  h3 {
    margin-bottom: 0;
    font-size: min(max(1rem, 1.5vw), 1.8rem); // Min, Variable, Max
  }
  .faq {
    background-color: $verydarkgrey;
    padding: 20px;
    border-radius: 10px;
    color: $lightgrey;
    margin-bottom: 10px;
  }
  .faq-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    cursor: pointer;
  }
  article {
    margin-top: 30px;
  }
</style>
