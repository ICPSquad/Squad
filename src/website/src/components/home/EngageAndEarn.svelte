<script>
  import Link from "@src/components/shared/LinkButton.svelte";
</script>

<section>
  <div class="container">
    <h2>ENGAGE & EARN</h2>
    <p>Engage with Internet Computer applications and win prizes for exploring this vibrant ecosystem.</p>

    <img src="/assets/engage-and-earn.png" alt="ICP Squad Avatars circling around Dfinity logo" />

    <Link to="/create-avatar">
      <button> Create Avatar → </button>
    </Link>
  </div>
</section>

<style lang="scss">
  @use "../../styles" as *;

  section {
    background-color: $verydarkgrey;
  }

  .container {
    max-width: 800px;
    text-align: center;
    display: flex;
    flex-direction: column;
    align-items: center;
  }

  .button {
    max-width: 600px;
    background-color: $yellow;
    color: $black;
  }

  img {
    width: 600px;
    margin: 20px 0 60px;
  }
</style>
