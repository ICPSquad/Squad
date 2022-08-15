<script>
  import Header from "@src/components/shared/Header.svelte";
  import Footer from "@src/components/shared/Footer.svelte";
  import Faq from "@src/components/faqs/Faq.svelte";
  const faqs = [
    {
      category: "GENERAL",
      articles: [
        {
          title: "What is dSquad ?",
          content: "<p>dSquad is the first Engage-to-Earn NFT game that rewards you with NFTs and tokens for engaging with Internet Computer dapps.</p>",
        },
        {
          title: "What is Engage-to-Earn?",
          content:
            "<p>The common Play-To-Earn concept used by other NFT games requires constant activity from one specific dapp created by the original developers. As a community project, we wanted to find a way to reward and incentivize all types of activity across the Internet Computer to drive engagement which benefits the entire ecosystem. We call this new gaming model “Engage-To-Earn,” allowing for assets that earn NFTs and ICPs for their owner.</p>",
        },
        {
          title: "How will Engage-to-Earn work?",
          content:
            "<p>dSquad NFTs are Avatar characters that can wear accessories (which are also NFTs), and just by owning a character you’ll have a chance to win an airdropped reward when you take actions Internet Computer (IC)-based dapps. Engage with IC-based dapps -> Collect NFT rewards and/or ICPs -> Trade/HODL -> Repeat.</p>",
        },
        {
          title: "How will you support the community?",
          content: `<p>dSquad is a contributor-run community with aspirations to eventually convert into a DAO. We want this project to be community-led from the very beginning. You can learn more about Dfinity Community
                <a target="_blank" href="https://drive.google.com/file/d/1yFqCSBOjr2sCmOtdsqTLxiZRp1iIDZMY/view?usp=sharing">here</a>.</p>`,
        },
        {
          title: "Why the Internet computer?",
          content:
            "<p>The Internet Computer provides many new and innovative features that can’t be done on any other blockchain. For example: The ability to validate wallet activity in a way that ensures user privacy without sacrificing accuracy and the ability to host NFT characters on the blockchain who can wear other NFTs representing accessories and clothing to change their image dynamically.</p>",
        },
        {
          title: "Are you planning to do anything about whales and bots?",
          content:
            "<p>Too many NFT projects are dominated by bots, large investors, and insiders who manipulate the market to benefit themselves unfairly. While we want to reward early adopters and contributors for making everything possible, our goal is to build a fair platform owned by and designed to benefit everyone. In this game, skill and planning are rewarded over deep pockets and sneaky loopholes.</p>",
        },
      ],
    },
    {
      category: "MY DSQUAD NFT AVATAR",
      articles: [
        {
          title: "What is an NFT?",
          content:
            "<p>A non-fungible token is a non-interchangeable unit of data stored on a blockchain, a form of digital ledger, that can be sold and traded. Types of NFT data units may be associated with digital files such as photos, videos, and audio.</p>",
        },
        {
          title: "Will I be getting any accessory with my avatar?",
          content: "<p>Current orders will only receive their avatar once it’s customized, accessories and elements was only an incentive during the pre-order process.</p>",
        },
        {
          title: "Can I sell my avatar?",
          content: "<p>For the moment avatar are mintable on our website for a fee of 1 ICP. We will allow the sale of avatars once season 0 is over and minting has been closed.</p>",
        },
        {
          title: "Can I sell my accessories?",
          content: `<p>You can currently sell the accessories you collect via
              <a href="https://entrepot.app/marketplace/icpsquad2">Entrepot</a>. We will list them on other NFT marketplaces in the future.</p>`,
        },
        {
          title: "Why can't I properly convert the SVG to other formats like JPG?",
          content:
            "<p>The SVG file has all of the artwork. A lot of online converters had issues with the CSS rules which are part of the images, and we are trying to figure out some kind of workaround. Those who have a vector editor on their computer (like Inkscape) should be able to export any resolution PNG from the downloaded SVG file. An easier route may be to open the SVG image in a browser, make it fullscreen, and then take a screenshot. </p>",
        },
      ],
    },
    {
      category: "HOW TO BUY A DSQUAD NFT",
      articles: [
        {
          title: "What’s the process to buy dSquad NFT?",
          content: `<p>For a step by step process on how to order and customize your dSquad avatar, please visit
              <a href="https://dsquad.gitbook.io/docs/create/avatar">this</a> link.</p>`,
        },
      ],
    },
    {
      category: "GAMEPLAY",
      articles: [
        {
          title: "How will the gameplay work?",
          content: `<p>For the latest updates on our gameplay, please check
              <a href="https://dsquad.gitbook.io/docs/">this</a> article.</p>`,
        },
      ],
    },
    {
      category: "CONNEXION ISSUES",
      articles: [
        {
          title: "I can't login to my account, what should I do?",
          content: `<p>Many reasons can cause login issues. Here's are a few things to check : <p>
                    <p> Enable cookies. </p>
                    <p> Enable cross-site tracking (blocked by default on Safari & Brave). </p>
                    <p> Remove Brave shield for this website if you are using Brave. </p>
                    <p> If you are still having issues, please follow the step for customer support. </p>
                    `,
        },
      ],
    },
    {
      category: "CUSTOMER SUPPORT",
      articles: [
        {
          title: "Where do I go for customer support?",
          content: `<p>We are currently only offering customer support via our Discord server. To receive customer support, please follow these steps:</p>
            <ul>
              <li>Join our Discord server.</li>
              <li>Head over to the #feedback channel, use the following format otherwise we won't be able to track your support ticket: request: " Your problem ". Our support team will check your support ticket and will reply within the next 48 hours. </li>
            </ul>`,
        },
      ],
    },
  ];
</script>

<Header />
<div class="page-header">
  <h1>FAQs</h1>
</div>
<main class="container">
  <aside class="categories">
    <h3>CATEGORIES</h3>
    {#each faqs as faqCategories}
      <a href={"#" + faqCategories.category}>
        <h4>{faqCategories.category}</h4>
      </a>
    {/each}
  </aside>
  <div class="faqs">
    {#each faqs as faqCategories}
      <h2 id={faqCategories.category}>{faqCategories.category}</h2>
      <div class="category-group">
        {#each faqCategories.articles as article}
          <Faq title={article.title}>
            {@html article.content}
          </Faq>
        {/each}
      </div>
    {/each}
  </div>
</main>
<Footer />

<style lang="scss">
  @use "../styles" as *;

  main,
  h1 {
    --page-feature-color: #{$green};
  }
  h2 {
    font-size: min(max(1.5rem, 3vw), 5rem); // Min, Variable, Max
  }
  h3,
  h4 {
    font-size: min(max(1rem, 1.2vw), 1.5rem); // Min, Variable, Max
  }
  h3 {
    color: $grey;
  }
  h4 {
    color: $lightgrey;
    cursor: pointer;
    &:hover {
      color: $white;
    }
  }
  main {
    display: grid;
    grid-template-columns: 1fr 2fr;
  }

  .categories {
    margin-bottom: 40px;
  }

  .category-group {
    margin-bottom: 80px;
  }

  @media (max-width: 800px) {
    main {
      grid-template-columns: 100%;
    }
  }
</style>
