<script>
  import Discord from "@src/icons/Discord.svelte";
  import Twitter from "@src/icons/Twitter.svelte";
  import Toast from "@src/components/shared/Toast.svelte";

  let email = "";

  let message = "";

  const handleSubmit = () => {
    message = "You are subscribed!";
    setTimeout(function () {
      message = "";
    }, 2000);
  };
</script>

<section>
  <div class="container">
    <h2>GET THE LATEST UPDATES</h2>
    <p>Subscribe to our newsletter to be the first to know about all things dSquad, the Internet Computer,new opportunities to earn NFTs, ICP and other prizes and take part in community events.</p>

    <div class="form-container">
      <input bind:value={email} id="email" type="email" required placeholder="Email address" />
      <button on:click={handleSubmit}> Subscribe </button>
    </div>

    <div class="social-icons">
      <a class="discord" href="https://discord.gg/9DjDzf38WR" target="_blank">
        <Discord width={40} />
      </a>
      <a href="https://twitter.com/ICPSquadNFT" target="_blank">
        <Twitter width={40} />
      </a>
    </div>
  </div>
</section>
<Toast />

<style lang="scss">
  @use "../../styles" as *;

  .container {
    max-width: 800px;
    text-align: center;
    display: flex;
    flex-direction: column;
    align-items: center;
  }

  .form-container {
    width: 100%;
    max-width: 500px;
    margin: 40px 0;
    input {
      border: 1px solid $grey;
      width: 100%;
      text-align: center;
      padding: 12px;
      background-color: transparent;
      border-top-left-radius: 12px;
      border-top-right-radius: 12px;
      font-size: 18px;
      color: $white;
      box-shadow: none;
      outline: none;
    }
    button {
      border-top-left-radius: 0;
      border-top-right-radius: 0;
      background-color: $blue;
      width: 100%;
    }
  }

  .social-icons {
    margin-top: 20px;
    display: flex;
    flex-direction: row;
    align-items: center;
    .discord {
      margin-right: 20px;
    }
  }
</style>
