<script lang="ts">
  export let name: string;
  export let layers: [number];
</script>

<svg viewBox="0 0 800 800" xmlns="http://www.w3.org/2000/svg" > 
  {#each layers as layer}
    <use xlink:href="#{name}-{layer}" />
  {/each}
</svg>
