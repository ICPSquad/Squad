<script>
  import Header from "../components/Header.svelte";
  import Footer from "../components/Footer.svelte";
  import AvatarWall from "../components/AvatarWall.svelte";
</script>

<Header />
<main class="container">
  <div class="hero-section">
    <AvatarWall />
    <div class="content">
      <div class="squad-number">
        <div><strong>5,238</strong> SQUAD MEMBERS</div>
        <img
          id="avatar-collage"
          src="/assets/avatar-collage.png"
          alt="Collage of ICP Squad Avatars"
        />
      </div>
      <h1>Join the squad</h1>
      <p class="large">
        Start by minting your own ICP Squad avatar NFT, then get rewarded with
        NFTs, ICP and other prizes as you explore the Internet Computer.
      </p>
      <button> Create Avatar → </button>
      <button class="secondary"> Learn More </button>
    </div>
  </div>
</main>
<Footer />

<style lang="scss">
  @use "./src/styles" as *;

  main {
    --page-feature-color: #{$green};
    min-height: 100vh;
  }

  .hero-section {
    display: grid;
    grid-template-columns: 1fr 1fr;
    grid-column-gap: 40px;
  }

  .squad-number {
    display: flex;
    align-items: center;

    #avatar-collage {
      height: 50px;
      margin-left: 20px;
    }
  }

  h1 {
    text-align: left;
    margin-top: 40px;
  }

  p.large {
    margin-bottom: 40px;
  }

  button {
    margin-bottom: 20px;
  }
</style>
