<script lang="ts">
  import Header from "@components/shared/Header.svelte";
  import Footer from "@components/shared/Footer.svelte";
  import Join from "@components/shared/Join.svelte";
  import Newsletter from "@components/shared/Newsletter.svelte";

  type AccessoriesCategory = {
    categoryName: string;
    items: string[];
  };

  const accessories: AccessoriesCategory[] = [
    {
      categoryName: "Hat",
      items: ["assassin-hood", "astro-helmet", "helicap", "magic-hood", "marshall-hat", "mortaboard-hat", "ninja-headband", "shinobi-hat"],
    },
    {
      categoryName: "Eyes",
      items: ["cronic-eyepatch", "dfinity-eyemask", "lab-glasses", "monocle", "punk-glasses", "sunglasses"],
    },
    {
      categoryName: "Face",
      items: ["boring-mask", "evil-mask", "gas-mask", "juggalo-facemask", "kitsune-mask", "facemask", "oni-face-mask", "punk-mask"],
    },
    {
      categoryName: "Body",
      items: ["assassin-cap", "astro-suit", "bootcamp-soldier", "cronic-tshirt", "devil-jacket", "helicap-tshirt", "lab-coat", "magic-cap", "shinobi-suit", "street-jacket", "yakuza-suit"],
    },
    {
      categoryName: "Misc",
      items: ["cronic-hypnose", "cronic-wallpaper", "snowfall", "sunrise"],
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

  <p>Materials can be earn during missions or are given out as prizes via the monthly airdrops.</p>
  <p>
    You can also trade both accessories and materials through the <a href="https://entrepot.app/marketplace/icpsquad2" target="_blank">Entrepot marketplace</a>.
  </p>

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
</style>
