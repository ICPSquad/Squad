<script>
  export let name;
  export let category;

  //TODO recipe when hover
</script>

<div>
  <img src={`assets/accessories/${category}/${name}/${name}-card.svg`} alt="Accessory Card" />
</div>

<style>
  img {
    width: 200px;
  }
</style>
