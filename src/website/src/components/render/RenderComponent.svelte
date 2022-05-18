<script lang="ts">
  export let name: string;
  export let layers: [number];
  export let category: string;

  const zoom = {
    mouth: "255 350 300 300",
    eyes: "200 150 400 400",
    nose: "300 360 200 200",
    ears: "70 220 300 300",
  };
</script>

<svg
  viewBox={zoom[category] ? zoom[category] : "0 0 800 800"}
  xmlns="http://www.w3.org/2000/svg"
>
  {#each layers as layer}
    <use xlink:href="#{name}-{layer}" />
  {/each}
</svg>
