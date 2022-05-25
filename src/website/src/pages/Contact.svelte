<script lang="ts">
  import Header from "@components/shared/Header.svelte";
  import Footer from "@components/shared/Footer.svelte";
  import Join from "@components/shared/Join.svelte";
  import Newsletter from "@components/shared/Newsletter.svelte";
  import LegendaryAvatar from "@src/components/shared/LegendaryAvatar.svelte";
  import PartnershipsForm from "@src/components/partnerships/PartnershipsForm.svelte";
  import Link from "@src/components/shared/LinkButton.svelte";
</script>

<Header />
<div class="page-header">
  <h1>Contact</h1>
</div>
<div class="container skinny">
  <p>
    Before contacting us, please check if the answer to your question is in our
    Frequently Asked Questions (FAQs)
  </p>

  <Link to="/faqs">
    <button class="faqs">FAQs →</button>
  </Link>

  <p>If you still need assistance, please contact us on our Discord.</p>

  <a href="https://discord.gg/SqtQ3UJR" target="_blank" class="button secondary"
    >JOIN ICP SQUAD DISCORD</a
  >
  <h3>Partnership Enquiries</h3>
  <p>
    We can incentivize our users to join your community, follow your social
    media accounts, and regularly engage with your platform.
  </p>
  <Link to="/partners">
    <button class="partners">GET IN TOUCH ABOUT PARTNERING →</button>
  </Link>
</div>
<Join />
<Newsletter />
<Footer />

<style lang="scss">
  @use "../styles" as *;

  h1,
  h3,
  a,
  button {
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
    }
  }

  button {
    background-color: var(--page-feature-color);
    color: $black;
    margin-top: 20px;
    margin-bottom: 60px;
    &.partners {
      background-color: $yellow;
    }
  }

  h3,
  p {
    text-align: center;
  }

  h3 {
    margin-top: 100px;
    text-transform: uppercase;
  }
</style>
