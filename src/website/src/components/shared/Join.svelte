<script>
  import Discord from "@icons/Discord.svelte";
  import Twitter from "@icons/Twitter.svelte";
</script>

<section>
  <div class="container">
    <h2>JOIN ICP SQUAD</h2>
    <p>
      <!-- To do: replace number with actual -->
      Join 5,296 community members today.
    </p>
  </div>

  <div class="container">
    <p>
      Start by minting your avatar, then get rewarded as you explore the
      Internet Computer.
    </p>

    <a href="/create-avatar" class="button"> Create Avatar → </a>

    <div class="social">
      <a class="discord" href="https://discord.gg/SqtQ3UJR" target="_blank">
        <Discord />
      </a>
      <a href="https://twitter.com/ICPSquadNFT" target="_blank">
        <Twitter />
      </a>
    </div>
  </div>
</section>

<style lang="scss">
  @use "../../styles" as *;

  section {
    width: 100%;
    padding: 80px 0;
    text-align: center;
    display: flex;
    flex-direction: column;
    align-items: center;
    background-color: $verydarkgrey;
  }

  .container {
    text-align: center;
    display: flex;
    flex-direction: column;
    align-items: center;
  }

  .button {
    margin-top: 20px;
    max-width: 600px;
  }

  .social {
    margin-top: 40px;
    display: flex;
    justify-content: center;
    .discord {
      margin-right: 14px;
    }
  }
</style>
