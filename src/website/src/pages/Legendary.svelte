<script>
  import Header from "@components/shared/Header.svelte";
  import Footer from "@components/shared/Footer.svelte";
  import Join from "@components/shared/Join.svelte";
  import Newsletter from "@components/shared/Newsletter.svelte";
  import LegendaryAvatar from "@src/components/shared/LegendaryAvatar.svelte";

  const legendaries = [
    {
      svg: "Dukakis.svg",
      name: "Dukakis Tejada",
      role: "Role Name",
      links: [
        {
          label: "Twitter",
          url: "https://twitter.com/DukakisTejada",
        },
        {
          label: "Distrikt",
          url: "https://az5sd-cqaaa-aaaae-aaarq-cai.ic0.app/u/dukakistejada",
        },
      ],
    },
    {
      svg: "Isaac.svg",
      name: "Isaac Valadez",
      role: "Role name",
      links: [
        {
          label: "Twitter",
          url: "https://twitter.com/IsaacValadez55",
        },
        {
          label: "Distrikt",
          url: "https://t.co/ttN8iOHnns",
        },
        {
          label: "isaac.icp.page",
          url: "https://isaac.icp.page",
        },
      ],
    },
    {
      svg: "Seb.svg",
      name: "Seb Thuillier",
      role: "Lead developer",
      links: [
        {
          label: "Twitter",
          url: "https://twitter.com/ThuillierSbast3",
        },
      ],
    },
  ];
</script>

<Header />
<div class="page-header">
  <h1>Legendary Avatars</h1>
</div>
<div class="container">
  <p>Those avatars are unique, made for you and cannot be minted again.</p>
  <p>
    Get you hands on those through meaningful contributions or special events.
  </p>
  <h2>LEGENDARY AVATAR WALL</h2>
  <div class="grid">
    {#each legendaries as legendary}
      <LegendaryAvatar {legendary} />
    {/each}
  </div>
</div>
<Join />
<Newsletter />
<Footer />

<style lang="scss">
  @use "../styles" as *;

  h1 {
    --page-feature-color: #{$yellow};
  }

  h2,
  p {
    text-align: center;
  }

  h2 {
    margin-top: 60px;
    margin-bottom: 60px;
  }

  .grid {
    display: grid;
    grid-template-columns: 1fr 1fr 1fr;
    grid-gap: 40px;
  }

  @media (max-width: 600px) {
    .grid {
      grid-template-columns: 1fr 1fr;
      grid-gap: 20px;
    }
  }
</style>
