<script>
  import Discord from "@icons/Discord.svelte";
  import Twitter from "@icons/Twitter.svelte";
  import AvatarGrid from "@components/shared/AvatarGrid.svelte";
</script>

<section>
  <div class="container">
    <h2>JOIN ICP SQUAD</h2>
    <p>
      <!-- To do: replace number with actual -->
      Join 5,296 community members today.
    </p>
  </div>

  <AvatarGrid />

  <div class="container below-grid">
    <p>
      Start by minting your avatar, then get rewarded as you explore the
      Internet Computer.
    </p>

    <a href="/create-avatar" class="button"> Create Avatar → </a>
  </div>
</section>

<style lang="scss">
  @use "../../styles" as *;

  section {
    width: 100%;
    padding: 60px 0;
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

  .below-grid {
    margin-top: 30px;
  }
</style>
