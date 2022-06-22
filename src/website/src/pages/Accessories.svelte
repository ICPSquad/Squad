<script lang="ts">
  import Header from "@components/shared/Header.svelte";
  import Footer from "@components/shared/Footer.svelte";
  import Link from "@src/components/shared/LinkButton.svelte";
  import Join from "@components/shared/Join.svelte";
  import Newsletter from "@components/shared/Newsletter.svelte";

  type AccessoriesCategory = {
    categoryName: string;
    items: string[];
  };

  const accessories: AccessoriesCategory[] = [
    {
      categoryName: "Hat",
      items: ["shinobi-hat", "helicap", "assassin-hood", "astro-helmet", "ninja-headband", "marshall-hat", "magic-hood", "mortaboard-hat"],
    },
    {
      categoryName: "Eyes",
      items: ["monocle", "lab-glasses", "sunglasses", "dfinity-eyemask", "punk-glasses", "cronic-eyepatch"],
    },
    {
      categoryName: "Face",
      items: ["boring-mask", "juggalo-facemask", "oni-face-mask", "facemask", "gas-mask", "kitsune-mask", "evil-mask", "punk-mask"],
    },
    {
      categoryName: "Body",
      items: ["helicap-tshirt", "assassin-cape", "lab-coat", "shinobi-suit", "yakuza-suit", "devil-jacket", "street-jacket", "magic-cape", "astro-suit", "cronic-tshirt", "bootcamp-soldier"],
    },
    {
      categoryName: "Misc",
      items: ["snowfall", "sunrise", "cronic-hypnose", "cronic-wallpaper"],
    },
  ];
</script>

<Header />
<div class="page-header">
  <h1>Accessories</h1>
</div>
<div class="container">
  <p>Equip your avatar with accessories to customize your style and increase your chance of winning rewards.</p>
  <p>To create an accessory, you need to combine materials.</p>

  <img class="accessories-diagram" src="/assets/accessories-diagram.png" alt="How materials can be turned into accessories" />

  <p>Materials can be earned during missions or are given out as prizes via the monthly airdrops.</p>
  <p>
    You can also trade both accessories and materials through the <a href="https://entrepot.app/marketplace/icpsquad2" target="_blank">Entrepot marketplace</a>.
  </p>
  <div class="action">
    <Link to="/create-accessory">
      <button> Create </button>
    </Link>
  </div>

  <h2>AVAILABLE ACCESSORIES</h2>
  <div class="grid">
    {#each accessories as category}
      <h3>{category.categoryName}</h3>
      {#each category.items as item}
        <img src="/assets/accessories/{category.categoryName.toLowerCase()}/{item}/{item}-minified.svg" alt={item} />
      {/each}
    {/each}
  </div>
</div>

<Join />
<Newsletter />
<Footer />

<style lang="scss">
  @use "../styles" as *;

  h1,
  h3,
  a {
    --page-feature-color: #{$blue};
  }

  .container {
    display: flex;
    flex-direction: column;
    align-items: center;
    padding-bottom: 100px;
  }

  h2,
  p {
    text-align: center;
  }

  h2 {
    margin-top: 60px;
  }

  h3 {
    grid-column: span 4;
    text-align: center;
    text-transform: uppercase;
    color: var(--page-feature-color);
    margin-top: 40px;
  }

  .grid {
    display: grid;
    grid-template-columns: 1fr 1fr 1fr 1fr;
    grid-gap: 40px;
  }

  img.accessories-diagram {
    width: 100%;
    max-width: 900px;
    margin: 60px 0;
  }

  @media (max-width: 800px) {
    .grid {
      grid-template-columns: 1fr 1fr;
      grid-gap: 20px;
    }

    h3 {
      grid-column: span 2;
    }
  }

  .action {
    display: flex;
    flex-direction: row;
    width: 100%;
    align-items: center;
    margin: 40px auto;
  }
</style>
