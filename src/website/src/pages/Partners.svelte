<script lang="ts">
  import Header from "@components/shared/Header.svelte";
  import Footer from "@components/shared/Footer.svelte";
  import Join from "@components/shared/Join.svelte";
  import Newsletter from "@components/shared/Newsletter.svelte";
  import LegendaryAvatar from "@src/components/shared/LegendaryAvatar.svelte";
  import PartnershipsForm from "@src/components/partnerships/PartnershipsForm.svelte";

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
  <h1>Partners</h1>
</div>
<div class="container skinny">
  <p>
    We can incentivize our users to join your community, follow your social
    media accounts, and regularly engage with your platform.
  </p>
  <div class="boxes">
    <div class="box">
      <h3>GROW YOUR COMMUNITY</h3>
      <p>
        We can create custom missions and rewards that incentivise squad members
        to try our and join your community.
      </p>
    </div>
    <div class="box">
      <h3>BOOST IN-DAPP ACTIVITY</h3>
      <p>
        We integrate our NFT-based reward system with your platform and
        incentivise use of your application on an ongoing basis, hence driving
        engagement for your dapp.
      </p>
    </div>
  </div>
  <button class="partner-cta">GET IN TOUCH ABOUT PARTNERING →</button>
</div>
<div class="current-partners">
  <div class="container skinny">
    <h3>CURRENT PARTNERS</h3>
    <div class="partner-logos">
      <img
        class="partner-logo"
        src="/assets/partners/dfinity.png"
        alt="Dfinity Logo"
      />
      <img
        class="partner-logo"
        src="/assets/partners/gigaverse.png"
        alt="Gigaverse Labs Logo"
      />
      <img
        class="partner-logo"
        src="/assets/partners/toniq.png"
        alt="Toniq Labs Logo"
      />
      <img
        class="partner-logo dscvr"
        src="/assets/partners/dscvr.png"
        alt="Dscvr Logo"
      />
    </div>
  </div>
</div>
<PartnershipsForm />
<Footer />

<style lang="scss">
  @use "../styles" as *;

  main,
  h1,
  h3,
  a,
  button {
    --page-feature-color: #{$yellow};
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

  .current-partners {
    background-color: $verydarkgrey;
    margin-top: 80px;
    .partner-logos {
      width: 100%;
      max-width: 800px;
      display: flex;
      flex-direction: row;
      justify-content: space-around;
      align-items: center;
      padding: 40px 0;
      .partner-logo {
        height: 100px;
        &.dscvr {
          height: 130px;
        }
      }
    }
  }

  button {
    background-color: var(--page-feature-color);
    color: $black;
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

    .current-partners {
      .partner-logos {
        width: 100%;
        max-width: 800px;
        display: flex;
        flex-direction: row;
        justify-content: space-around;
        align-items: center;
        padding: 40px 0;
        .partner-logo {
          height: 40px;
          &.dscvr {
            height: 55px;
          }
        }
      }
    }
  }
</style>
