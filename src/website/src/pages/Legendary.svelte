<script>
  import Header from "@components/shared/Header.svelte";
  import Footer from "@components/shared/Footer.svelte";
  import Join from "@components/shared/Join.svelte";
  import Newsletter from "@components/shared/Newsletter.svelte";
  import LegendaryAvatar from "@src/components/shared/LegendaryAvatar.svelte";

  const categories = ["Core team", "Dfinity community", "Motoko Bootcamp 2022", "Community", "Dfinity foundation", "Gigaverse labs"];

  const legendaries = [
    {
      svg: "Dukakis.svg",
      name: "Dukakis Tejada",
      role: "Founder",
      categorie: "Core team",
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
      categorie: "Core team",
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
      categorie: "Core team",
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
      categorie: "Core team",
      links: [
        {
          label: "Twitter",
          url: "https://twitter.com/_arunarts",
        },
      ],
    },
    {
      svg: "Dan.svg",
      name: "Daniel James",
      role: "Editor in chief",
      categorie: "Dfinity community",
      links: [
        {
          label: "Twitter",
          url: "https://twitter.com/ICPfan8",
        },
      ],
    },
    {
      svg: "Geoff.svg",
      name: "Geoffrey Miller",
      role: "Outreach lead",
      categorie: "Dfinity community",
      links: [
        {
          label: "Twitter",
          url: "https://twitter.com/ICPfan10",
        },
      ],
    },
    {
      svg: "Moses.svg",
      name: "Moses",
      role: "Community manager",
      categorie: "Dfinity community",
      links: [
        {
          label: "Twitter",
          url: "https://twitter.com/kylpeacock",
        },
      ],
    },
    {
      svg: "Sunny.svg",
      name: "Sunny",
      role: "Managing editor",
      categorie: "Dfinity community",
      links: [
        {
          label: "Twitter",
          url: "https://twitter.com/ICPfan9",
        },
        {
          label: "Distrikt",
          url: "https://az5sd-cqaaa-aaaae-aaarq-cai.ic0.app/u/sunny",
        },
      ],
    },
    {
      svg: "Alexa.svg",
      name: "Alexa smith",
      role: "Beacon fund manager",
      categorie: "Community",
      links: [
        {
          label: "Twitter",
          url: "https://twitter.com/beavskis",
        },
        {
          label: "Polychain",
          url: "https://polychain.capital/",
        },
      ],
    },
    {
      svg: "Andrew.svg",
      name: "Andrew Sellen",
      role: "1st place (intermediate)",
      categorie: "Motoko Bootcamp 2022",
      links: [
        {
          label: "Twitter",
          url: "https://twitter.com/AndrewSel",
        },
        {
          label: "Github",
          url: "https://github.com/andrewsel",
        },
      ],
    },
    {
      svg: "Peter.svg",
      name: "Peter Kneiszl",
      role: "1st place (beginner)",
      categorie: "Motoko Bootcamp 2022",
      links: [],
    },
    {
      svg: "Kyle.svg",
      name: "Kyle Peacock",
      role: "Software engineer",
      categorie: "Dfinity foundation",
      links: [
        {
          label: "Twitter",
          url: "https://twitter.com/kylpeacock",
        },
        {
          label: "Github",
          url: "https://github.com/krpeacock",
        },
      ],
    },
    {
      svg: "Paul.svg",
      name: "Paul Liu",
      role: "Technical lead",
      categorie: "Dfinity foundation",
      links: [
        {
          label: "Github",
          url: "https://github.com/ninegua",
        },
      ],
    },

    {
      svg: "Igor.svg",
      name: "Igor Lilic",
      role: "Developer partner",
      categorie: "Dfinity foundation",
      links: [
        {
          label: "Twitter",
          url: "https://twitter.com/ililic",
        },
      ],
    },
    {
      svg: "Anna.svg",
      name: "Anna Escher",
      role: "Communication team",
      categorie: "Dfinity foundation",
      links: [
        {
          label: "Twitter",
          url: "https://twitter.com/annescher",
        },
      ],
    },
    {
      svg: "Matthias.svg",
      name: "Matthias Broner",
      role: "Product market manager",
      categorie: "Dfinity foundation",
      links: [
        {
          label: "Twitter",
          url: "https://twitter.com/BronerMatthias",
        },
      ],
    },
    {
      svg: "Liz.svg",
      name: "Liz",
      role: "(Former) Growth team",
      categorie: "Dfinity foundation",
      links: [],
    },
    {
      svg: "Mike.svg",
      name: "Mike",
      role: "(Former) Community manager",
      categorie: "Dfinity foundation",
      links: [
        {
          label: "Twitter",
          url: "https://twitter.com/TheMikeHunte",
        },
      ],
    },

    {
      svg: "Quint.svg",
      name: "Quint",
      role: "Aviate labs",
      categorie: "Community",
      links: [
        {
          label: "Twitter",
          url: "https://twitter.com/q_uint8",
        },
        {
          label: "Github",
          url: "https://github.com/di-wu",
        },
      ],
    },
    {
      svg: "Jorgen.svg",
      name: "Jorgen",
      role: "Saga cards",
      categorie: "Community",
      links: [
        {
          label: "Twitter",
          url: "https://twitter.com/Jorgenbuilder",
        },
        {
          label: "Github",
          url: "https://github.com/jorgenbuilder",
        },
        {
          label: "Saga",
          url: "https://mobile.twitter.com/sagacards",
        },
      ],
    },
    {
      svg: "Anthony.svg",
      name: "Anthony",
      role: "Aedile",
      categorie: "Community",
      links: [
        {
          label: "Twitter",
          url: "https://twitter.com/AnthonyMQ23",
        },
        {
          label: "Github",
          url: "https://github.com/anthonymq",
        },
        {
          label: "Aedile",
          url: "https://vqdn4-miaaa-aaaaf-qaawa-cai.ic0.app/",
        },
      ],
    },
    {
      svg: "PaulY.svg",
      name: "Paul Young",
      role: "Motoko pionner",
      categorie: "Community",
      links: [
        {
          label: "Twitter",
          url: "https://twitter.com/py",
        },
        {
          label: "Github",
          url: "https://github.com/paulyoung",
        },
        {
          label: "Website",
          url: "https://paulyoung.wordpress.com/",
        },
      ],
    },
    {
      svg: "Austin.svg",
      name: "Austin",
      role: "Orygin CTO & ICDevs",
      categorie: "Community",
      links: [
        {
          label: "Twitter",
          url: "https://twitter.com/afat",
        },
        {
          label: "Github",
          url: "https://github.com/skilesare",
        },
        {
          label: "Origyn",
          url: "https://www.origyn.com/",
        },
        {
          label: "ICDevs",
          url: "https://icdevs.org/",
        },
      ],
    },
    {
      svg: "Stopakor.svg",
      name: "Stopakor",
      role: "Gigaverse",
      categorie: "Gigaverse labs",
      links: [
        {
          label: "Twitter",
          url: "https://twitter.com/kylpeacock",
        },
      ],
    },
    {
      svg: "TPunk.svg",
      name: "T-Punk",
      role: "Cofounder",
      categorie: "Gigaverse labs",
      links: [
        {
          label: "Twitter",
          url: "https://twitter.com/TPunk_NFT",
        },
      ],
    },
    {
      svg: "Grich.svg",
      name: "Grich",
      role: "Community engagement",
      categorie: "Gigaverse labs",
      links: [
        {
          label: "Twitter",
          url: "https://twitter.com/gigav_",
        },
      ],
    },

    {
      svg: "AIA.svg",
      name: "AIA",
      role: "",
      categorie: "Gigaverse labs",
      links: [
        {
          label: "Twitter",
          url: "https://twitter.com/TPunk_NFT",
        },
      ],
    },
    {
      svg: "Victor.svg",
      name: "Victor",
      role: "Social media manager",
      categorie: "Dfinity community",
      links: [
        {
          label: "Twitter",
          url: "https://twitter.com/VictorICPSquad",
        },
      ],
    },
    {
      svg: "Weed.svg",
      name: "Andrew weed",
      role: "Community figure",
      categorie: "Community",
      links: [
        {
          label: "Twitter",
          url: "https://twitter.com/weedpatchtwo",
        },
      ],
    },
  ];

  function filterByCategory(category, legendaries) {
    return legendaries.filter((legendary) => {
      return legendary.categorie === category;
    });
  }
</script>

<Header />
<div class="page-header">
  <h1>Legendary Avatars</h1>
</div>
<div class="container">
  <p>Those avatars are unique and crafted manually to reward special contributors.</p>
  <p>Get you hands on those through participation in special events.</p>
  {#each categories as category}
    <h2>{category}</h2>
    <div class="grid">
      {#each filterByCategory(category, legendaries) as legendary}
        <LegendaryAvatar {legendary} />
      {/each}
    </div>
  {/each}
</div>
<Join />
<Newsletter />
<Footer />

<style lang="scss">
  @use "../styles" as *;

  h1 {
    --page-feature-color: #{$yellow};
  }

  h2,
  p {
    text-align: center;
  }

  h2 {
    margin-top: 60px;
    margin-bottom: 60px;
  }

  .grid {
    display: grid;
    grid-template-columns: 1fr 1fr 1fr;
    grid-gap: 40px;
  }

  @media (max-width: 600px) {
    .grid {
      grid-template-columns: 1fr 1fr;
      grid-gap: 20px;
    }
  }
</style>
