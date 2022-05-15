<script>
</script>

<section>
  <div class="container">
    <h2>COLLECT OR TRADE</h2>
    <p>
      Trade your Materials and Accessories NFTs on secondary markets, or keep
      them to increase your chances of&nbsp;winning&nbsp;rewards.
    </p>
    <div class="cols">
      <div class="col">
        <!-- To do: Add animation fade to an avatar wearing helmet -->
        <img src="/assets/materials.png" alt="Materials" />
        <h3>MATERIALS</h3>
        <p>
          Collect the Materials you need to mint new Accessories. Materials are
          given out as prizes and via airdrops.
        </p>
      </div>
      <div class="col">
        <img src="/assets/astro-helmet.png" alt="Astro Helmet" />
        <h3>ACCESSORIES</h3>
        <p>
          Add Accessories to your avatar to show your style and increase your
          chance of winning rewards.
        </p>
      </div>
    </div>
    <a href="/accessories" class="button"> More about accessories → </a>
  </div>
</section>

<style lang="scss">
  @use "../../styles" as *;

  .container {
    max-width: 800px;
    text-align: center;
    display: flex;
    flex-direction: column;
    align-items: center;
  }

  .button {
    max-width: 600px;
    background-color: $blue;
    color: $black;
  }

  img {
    height: 200px;
    margin-bottom: 40px;
  }

  .cols {
    margin: 40px 0;
    display: grid;
    grid-template-columns: 1fr 1fr;
    grid-gap: 40px;
  }

  .col {
    display: flex;
    flex-direction: column;
    justify-content: center;
    align-items: center;
  }

  @media (max-width: 680px) {
    .cols {
      grid-template-columns: 100%;
    }
  }
</style>
