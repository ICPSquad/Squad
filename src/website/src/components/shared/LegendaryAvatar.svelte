<script>
  export let legendary;
</script>

<div on:hover={() => (hover = true)} class="avatar">
  <div class="image">
    <img src={"/assets/legendaries/" + legendary.svg} alt={legendary.name + " ICP Squad Avatar"} />
    <div class="hover">
      {#each legendary.links as link}
        <a href={link.url} target="_blank" class="button legend-link">{link.label}</a>
      {/each}
    </div>
  </div>

  <h3>{legendary.name}</h3>
  <p>{legendary.role}</p>
</div>

<style lang="scss">
  @use "../../styles" as *;

  h3 {
    color: $yellow;
    text-transform: uppercase;
    text-align: center;
    margin-top: 12px;
    margin-bottom: 4px;
  }

  p {
    text-align: center;
  }

  .avatar {
    .image {
      position: relative;

      .hover {
        position: absolute;
        width: 100%;
        height: 100%;
        top: 0;
        left: 0;
        background-color: #000000cc;
        display: flex;
        flex-direction: column;
        justify-content: center;
        align-items: center;
        padding: 20px;
        opacity: 0;
        &:hover {
          opacity: 100;
        }
      }

      .legend-link {
        margin: 7px 0px;
        border: 1px solid $white;
        background-color: transparent;
        border-radius: 100px;
        &:hover {
          background-color: #00000033;
        }
      }
    }
  }
</style>
