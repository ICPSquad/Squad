<script>
  import Discord from "@src/icons/Discord.svelte";
  import Twitter from "@src/icons/Twitter.svelte";
  import Toast from "@src/components/shared/Toast.svelte";

  let email = "";

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

    <form action="https://isaacvaladez.us14.list-manage.com/subscribe/post?u=d59b2a8b54b8dfa11092aa237&amp;id=ade621c380" method="post" class="form-container" target="_blank" novalidate>
      <input bind:value={email} id="email" type="email" required placeholder="Email address" />
      <!-- real people should not fill this in and expect good things - do not remove this or risk form bot signups-->
      <div style="position: absolute; left: -5000px;" aria-hidden="true">
        <input type="text" name="b_d59b2a8b54b8dfa11092aa237_ade621c380" tabindex="-1" value="" />
      </div>
      <input type="submit" value="Subscribe" name="subscribe" class="button" />
    </form>
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
    #email {
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
    .button {
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
