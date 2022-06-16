<script lang="ts">
  import Header from "@components/shared/Header.svelte";
  import Footer from "@components/shared/Footer.svelte";
  import Join from "@components/shared/Join.svelte";
  import Newsletter from "@components/shared/Newsletter.svelte";
  import LegendaryAvatar from "@src/components/shared/LegendaryAvatar.svelte";
  import LinkButton from "@src/components/shared/LinkButton.svelte";

  const legendaries = [
    {
      svg: "Dukakis.svg",
      name: "Dukakis Tejada",
      role: "Founder",
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
      role: "Cofounder & CEO",
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
      role: "Cofounder & CTO",
      links: [
        {
          label: "Twitter",
          url: "https://twitter.com/ThuillierSbast3",
        },
        {
          label: "Distrikt",
          url: "https://az5sd-cqaaa-aaaae-aaarq-cai.ic0.app/u/Seb",
        },
        {
          label: "seb.icp.page",
          url: "https://seb.icp.page",
        },
      ],
    },
    {
      svg: "Arun.svg",
      name: "Arun Nair",
      role: "Chief artist",
      links: [
        {
          label: "Twitter",
          url: "https://twitter.com/_arunarts",
        },
      ],
    },
    {
      svg: "Andrew.svg",
      name: "Andrew Sellen",
      role: "Frontend developer",
      links: [
        {
          label: "Twitter",
          url: "https://twitter.com/_arunarts",
        },
      ],
    },
  ];
</script>

<Header />
<div class="page-header">
  <h1>About Us</h1>
</div>
<div class="container skinny">
  <p><span class="bolt"> dSquad </span> is the first Engage-to-Earn NFT game that rewards you with NFTs and tokens for engaging with Internet Computer dapps.</p>
  <div class="boxes">
    <div class="box">
      <h3>FOR COLLECTORS</h3>
      <p>Start by minting your own dSquad avatar NFT, then get rewarded with NFTs, ICP and other prizes as you explore the Internet Computer.</p>
      <LinkButton to="/create-avatar">
        <button class="create">Create Avatar →</button>
      </LinkButton>
    </div>
    <div class="box">
      <h3>FOR IC DAPPS</h3>
      <p>We can incentivize our users to join your community, follow your social media accounts, and regularly engage with your platform.</p>
      <LinkButton to="/partners">
        <button class="partnerships">More about partnerships →</button>
      </LinkButton>
    </div>
  </div>
  <h2>OUR TEAM</h2>
  <p>We are a team of early passionate about the Internet Computer and the NFTs.</p>
  <p>
    This project started as a community <a href="https://www.dfinitycommunity.com/icp-squad-engage-to-earn-nft-game/" target="_blank"> initiative </a> on the blog platform and quickly turned into its own
    project with a dedicated team.
  </p>
  <p />
</div>
<div class="container team">
  <h2>MEMBERS</h2>
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

  h1,
  h3 {
    --page-feature-color: #{$blue};
  }

  .container {
    display: flex;
    flex-direction: column;
    align-items: center;
    padding-bottom: 100px;
    &.skinny {
      max-width: 1000px;
      margin-bottom: 0;
      padding-bottom: 0;
    }
    &.team {
      padding-top: 0;
    }
  }

  h2,
  p {
    text-align: center;
  }

  h2 {
    margin-top: 60px;
  }

  div.boxes {
    display: grid;
    grid-template-columns: 1fr 1fr;
    grid-gap: 40px;
    margin: 60px 0;

    .box {
      background-color: $verydarkgrey;
      padding: 40px;

      h3 {
        text-align: center;
      }

      button {
        margin-top: 40px;
        color: $black;

        &.create {
          background-color: $green;
        }

        &.partnerships {
          background-color: $yellow;
        }
      }
    }
  }

  .grid {
    display: grid;
    grid-template-columns: 1fr 1fr 1fr;
    grid-gap: 40px;
  }

  @media (max-width: 600px) {
    div.boxes {
      grid-template-columns: 100%;
    }

    .grid {
      grid-template-columns: 1fr 1fr;
      grid-gap: 20px;
    }
  }

  .bolt {
    font-size: 2em;
    font-weight: bold;
  }
</style>
