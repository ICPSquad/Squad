<script lang="ts">
  import AvatarWall from "@components/home/AvatarWall.svelte";
  import LinkButton from "@components/shared/LinkButton.svelte";
  import { avatarActor } from "@src/api/actor";

  let number;

  let updateNumber = async () => {
    const data = await avatarActor().get_number_users();
    number = Number(data);
  };
  updateNumber();
</script>

<div class="container">
  <div class="hero-section">
    <AvatarWall />
    <div class="content">
      <div class="squad-number">
        <div><strong>{number ? number : "5288"}</strong> SQUAD MEMBERS</div>
        <img id="avatar-collage" src="/assets/avatar-collage.png" alt="Collage of ICP Squad Avatars" />
      </div>
      <h2>Join the revolution</h2>
      <p class="large">
        A new chapter of the Internet is opening. Start by minting your avatar, then take part in the adventure and get rewarded as your explore a new wave of decentralized applications.
      </p>
      <div class="buttons">
        <LinkButton to="/create-avatar">
          <button> Create Avatar → </button>
        </LinkButton>
        <a href="#create" class="button secondary"> Learn More </a>
      </div>
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
  h2 {
    text-align: left;
    margin-top: 40px;
    text-transform: uppercase;
  }
  p.large {
    font-size: 1.4rem;
    margin-bottom: 50px;
  }
  button {
    margin-bottom: 20px;
  }
  button,
  a {
    width: 100%;
    max-width: 100%;
  }
  .content {
    display: grid;
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
      justify-items: center;
      width: 100%;
    }

    .buttons {
      width: 100%;
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
    button,
    a {
      margin-bottom: 10px;
      width: 100%;
      max-width: 100%;
    }
  }
</style>
