<script lang="ts">
  import AvatarWall from "@components/home/AvatarWall.svelte";
  import { Link } from "svelte-routing";
</script>

<div class="container">
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

      <a href="#create" class="button secondary"> Learn More </a>
    </div>
  </div>
</div>

<style lang="scss">
  @use "../../styles" as *;

  div.container {
    --page-feature-color: #{$green};
    padding-bottom: 100px;
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
    font-size: 1.4rem;
    margin-bottom: 50px;
  }
  button {
    margin-bottom: 20px;
  }

  @media (max-width: 980px) {
    .container {
      padding-top: 0px;
    }

    .hero-section {
      grid-template-columns: 100%;
      justify-items: center;
    }

    .content {
      display: grid;
    }

    .squad-number {
      display: flex;
      flex-direction: column;
      align-items: center;
      grid-row-start: 5;
      margin-top: 20px;
      #avatar-collage {
        margin-left: 0;
        margin-top: 10px;
      }
    }

    h1 {
      text-align: center;
      margin-top: 20px;
    }
    p.large {
      text-align: center;
      font-size: 1rem;
      margin-bottom: 20px;
    }
    button {
      margin-bottom: 10px;
    }
  }
</style>
