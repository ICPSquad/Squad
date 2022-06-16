<script lang="ts">
  import Header from "@components/shared/Header.svelte";
  import Footer from "@components/shared/Footer.svelte";
  import Join from "@components/shared/Join.svelte";
  import Newsletter from "@components/shared/Newsletter.svelte";
</script>

<Header />
<div class="page-header">
  <h1>Roadmap</h1>
</div>
<div class="container skinny">
  <p>
    This is still a long way ahead, we will have to work hard to get there but eventually we would like to turn the game into an open internet service run by a DAO (Decentralised Autonomous
    Organisation) using the SNS which will gamify & unify the entire Internet Computer ecosystem, and provide an incentive tool any project can use to drive engagement for their dApps.
  </p>
  <p>
    This means that eventually, dSquad will become a collaborative digital art platform where projects can distribute branded virtual merchandise that has utility for their dApp. This will give
    developers the ability to quickly attract new users from the community.
  </p>
  <p>For users, it simply means the Internet Computer will be a blockchain where anyone can easily start earning rewards just by using dApps built on it.</p>
  <div class="season">
    <img class="s0" src="/avatars/pink-woman-2.png" alt="dSquad Avatar" />
    <div class="text">
      <h2>Season 0 (current)</h2>
      <div>
        <ul>
          <li class="done">
            Basics MVP features ✅
            <ul>
              <li class="done">Avatar & accessories minting</li>
              <li class="done">Dynamic artwork & avatar / accessory layering</li>
              <li class="done">Leaderboard and missions</li>
              <li class="done">Accessory burning & rewards</li>
            </ul>
          </li>
          <li>Early economy stabilisation and experimentation (Ongoing).</li>
          <li>Activity tracking & missions with partners (Ongoing).</li>
          <li>dSquad Neuron rewards (Ongoing).</li>
          <li>Legendary accessory auctions (Ongoing).</li>
        </ul>
      </div>
    </div>
  </div>
  <div class="season">
    <img class="s1" src="/avatars/purple-man-2.png" alt="dSquad Avatar" />
    <div class="text">
      <h2>Season 1</h2>
      <div>
        <ul>
          <li>Artwork refresh & supplemental artwork improvement.</li>
          <li>Properties and multi-level character minting opened & applied to leaderboard.</li>
          <li>More advanced economy, gameplay features, & integrations.</li>
          <li>More advanced accessories bonus and properties.</li>
          <li>
            Advanced features for reactive art released (Artwork which changes based on external ecosystem and user states (like a hat which shows the icon of whatever social media website you posted
            on within the last 30 minutes, or a background that switches scenes depending on the time in your timezone).
          </li>
          <li>Events (Bootcamp, real world meetup & contests).</li>
          <li>Open activity tracking integrations via SDK.</li>
          <li>Planning for DAO begins.</li>
          <li>Contest for season 2 theme and artist.</li>
        </ul>
      </div>
    </div>
  </div>
  <div class="season">
    <div class="question-mark">?</div>
    <div class="text">
      <h2>Season 2+</h2>
      <div>
        <ul>
          <li>Introduction of a completely new artwork & theme by a new artist.</li>
          <li>Advanced mission types</li>
          <li>Open mission integrations via SDK.</li>
          <li>Work implementing DAO starts.</li>
          <li>Transition to a 100% permissionless (though community managed) Open Internet Service for dApp gamification and digital merchandise by any builder in the ecosystem.</li>
          <li>Transition to a 100% community owned DAO & token airdrop.</li>
          <li>Accessories lending/borrowing activated.</li>
          <li>Roadmap opened up to the community, with new features, artwork and season-wide goals introduced every season, planning for a new season starting every 6 months.</li>
        </ul>
      </div>
    </div>
  </div>
</div>

<Join />
<Newsletter />
<Footer />

<style lang="scss">
  @use "../styles" as *;

  h1,
  h3 {
    --page-feature-color: #{$green};
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

  p {
    text-align: center;
  }

  li.done {
    color: $green;
  }

  .season {
    --offset: 150px;
    --padding: 40px;
    margin-top: 60px;
    background-color: $verydarkgrey;
    width: calc(100% - var(--offset));
    padding: var(--padding);
    border-radius: 20px;
    margin-left: var(--offset);
    p {
      text-align: left;
    }
    img,
    .question-mark {
      position: absolute;
      width: 300px;
      height: 300px;
      border-radius: 50%;
      margin-left: calc((var(--offset) * -1) - var(--padding));
      border: 4px solid $pink;
      &.s1 {
        border-color: $blue;
      }
    }
    .text {
      padding-left: var(--offset);
    }
    .question-mark {
      display: flex;
      justify-content: center;
      align-items: center;
      border-color: $green;
      background-color: $black;
      color: $green;
      font-size: 150px;
    }
  }

  @media (max-width: 800px) {
    .season {
      --offset: 0px;
      display: flex;
      flex-direction: column;
      align-items: center;

      img,
      .question-mark {
        position: relative;
        width: 200px;
        height: 200px;
        margin-left: 0;
        margin-bottom: 40px;
      }
    }
  }
</style>
