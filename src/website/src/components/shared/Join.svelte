<script>
  import Discord from "@icons/Discord.svelte";
  import Twitter from "@icons/Twitter.svelte";
  import AvatarGrid from "@components/shared/AvatarGrid.svelte";
</script>

<section>
  <div class="container above-grid">
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
  }

  .below-grid {
    margin-top: 30px;
  }

  @media (max-width: 800px) {
    .above-grid {
      padding-bottom: 0px;
      margin-bottom: 20px;
    }

    .below-grid {
      padding-top: 0px;
      margin-top: 40px;
    }
  }
</style>
