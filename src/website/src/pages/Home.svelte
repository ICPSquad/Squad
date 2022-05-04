<script lang="ts">
  import Header from "../components/shared/Header.svelte";
  import Footer from "../components/shared/Footer.svelte";
  import AvatarWall from "@components/home/AvatarWall.svelte";
  import { Link } from "svelte-routing";
</script>

<div class="background">
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
        <Link to="/create-avatar">
          <button> Create Avatar → </button>
        </Link>
        <button class="secondary"> Learn More </button>
      </div>
    </div>
  </main>
</div>
<Footer />

<style lang="scss">
  @use "../styles" as *;
  main {
    --page-feature-color: #{$green};
    min-height: 100vh;
  }
  .hero-section {
    display: grid;
    grid-template-columns: 1fr 1fr;
    grid-column-gap: 40px;
  }
  .background {
    background-image: url("/assets/home-hero-background.png");
    background-size: cover;
    background-repeat: no-repeat;
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
    font-size: 1.41rem;
    margin-bottom: 50px;
  }
  button {
    margin-bottom: 20px;
  }
</style>
