<script>
  import AvatarZapAnimate from "./AvatarZapAnimate.svelte";
</script>

<div class="grid">
  <AvatarZapAnimate image="purple-woman" theme="pink" size={1} />
  <AvatarZapAnimate image="blue-woman" theme="purple" size={1} />
  <AvatarZapAnimate image="green-woman" theme="green" size={1} />
  <AvatarZapAnimate image="yellow-man" theme="yellow" size={1} />
  <AvatarZapAnimate image="purple-woman" theme="pink" size={1} />
  <AvatarZapAnimate image="blue-woman" theme="purple" size={1} />
  <AvatarZapAnimate image="green-woman" theme="green" size={1} />
  <AvatarZapAnimate image="yellow-man" theme="yellow" size={1} />
  <AvatarZapAnimate image="purple-woman" theme="pink" size={1} />
</div>

<style lang="scss">
  @use "./src/styles" as *;

  .grid {
    display: grid;
    grid-template-columns: 140px 140px 140px;
    grid-gap: 20px;
  }
</style>
