<script lang="ts">
  import Header from "@components/shared/Header.svelte";
  import Footer from "@components/shared/Footer.svelte";
  import PartnershipsForm from "@src/components/partnerships/PartnershipsForm.svelte";
</script>

<Header />
<div class="page-header">
  <h1>Partners</h1>
</div>
<div class="container skinny">
  <p>We can incentivize our users to join your community, follow your social media accounts, and regularly engage with your platform.</p>
  <div class="boxes">
    <div class="box">
      <h3>GROW YOUR COMMUNITY</h3>
      <p>We can create custom missions to rewards & incentivise Squad members to try our and join your community.</p>
    </div>
    <div class="box">
      <h3>BOOST ACTIVITY</h3>
      <p>We integrate our NFT-based reward system with your platform and incentivise use of your application on an ongoing basis, hence driving engagement for your dapp.</p>
    </div>
  </div>
  <a href="#partner-form" class="button partner-cta">GET IN TOUCH ABOUT PARTNERING →</a>
</div>
<div class="current-partners">
  <div class="container skinny">
    <h3>CURRENT PARTNERS</h3>
    <div class="partner-logos">
      <a href="https://dfinity.org/" target="_blank">
        <img class="partner-logo" src="/assets/partners/dfinity.png" alt="Dfinity Logo" />
      </a>
      <a href="https://twitter.com/GigaverseLabs" target="_blank">
        <img class="partner-logo" src="/assets/partners/gigaverse.png" alt="Gigaverse Labs Logo" />
      </a>
      <a href="https://twitter.com/toniqlabs" target="_blank">
        <img class="partner-logo" src="/assets/partners/toniq.png" alt="Toniq Labs Logo" />
      </a>
      <a href="https://twitter.com/DscvrO" target="_blank">
        <img class="partner-logo dscvr" src="/assets/partners/dscvr.png" alt="DSCVR Logo" />
      </a>
    </div>
  </div>
</div>
<div id="partner-form" />
<PartnershipsForm />
<Footer />

<style lang="scss">
  @use "../styles" as *;

  h1,
  h3 {
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

  a.button {
    background-color: $yellow;
    color: $black;
  }

  p {
    text-align: center;
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

  @media (max-width: 600px) {
    div.boxes {
      grid-template-columns: 100%;
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
