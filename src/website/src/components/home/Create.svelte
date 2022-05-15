<section class="container" id="create">
  <h2>CREATE</h2>
  <p>
    Create your one-of-a-kind avatar NFT, which you can take into missions to
    earn NFTs and tokens. You’ll be able to customize basically all physical
    attributes of&nbsp;your&nbsp;avatar.
  </p>

  <div class="video">
    <!-- svelte-ignore a11y-media-has-caption -->
    <video src="/assets/create-avatar-demo.mp4" autoplay muted loop />
  </div>
  <a href="/create-avatar" class="button"> Create Avatar → </a>
</section>

<style lang="scss">
  @use "../../styles" as *;

  section {
    max-width: 800px;
    text-align: center;
    display: flex;
    flex-direction: column;
    align-items: center;
  }

  video {
    width: 100%;
    max-width: 660px;
  }

  .button {
    max-width: 600px;
  }

  .video {
    border: 5px solid $pink;
    box-shadow: 0 0 30px #d51d8150;
    filter: drop-shadow(0px 0px 8px #ffc5e7);
    margin: 20px 0 40px 0;
    border-radius: 10px;
    background-color: $black;
  }
</style>
