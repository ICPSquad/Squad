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
  <h1>About Us</h1>
</div>
<div class="container skinny">
  <p>
    ICP Squad is the first Engage-to-Earn NFT game that rewards you with NFTs
    and tokens for engaging with Internet Computer dapps.
  </p>
  <div class="boxes">
    <div class="box">
      <h3>FOR COLLECTORS</h3>
      <p>
        Start by minting your own ICP Squad avatar NFT, then get rewarded with
        NFTs, ICP and other prizes as you explore the Internet Computer.
      </p>
      <LinkButton to="/create-avatar">
        <button class="create">Create Avatar →</button>
      </LinkButton>
    </div>
    <div class="box">
      <h3>FOR IC DAPPS</h3>
      <p>
        We can incentivize our users to join your community, follow your social
        media accounts, and regularly engage with your platform.
      </p>
      <LinkButton to="/partners">
        <button class="partnerships">More about partnerships →</button>
      </LinkButton>
    </div>
  </div>
  <h3>LONG TERM VISION</h3>
  <p>
    This is still a long way ahead but eventually, we would like to turn ICP
    Squad NFT into an open internet service run by a DAO using the SNS which
    will gamify & unify the entire Internet Computer ecosystem, and provide an
    incentive tool any project can use to drive engagement for their dapps.
  </p>
  <p>
    This means that eventually, ICP Squad NFT will become a collaborative
    digital art platform where projects can distribute branded virtual
    merchandise that has utility for their dapp. This will give developers the
    ability to quickly attract new users from the community.
  </p>
  <p>
    For users, it means the Internet Computer will be a blockchain where anyone
    can easily start earning rewards just by using dapps built on it.
  </p>
</div>
<div class="container team">
  <h2>OUR TEAM</h2>
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
</style>
