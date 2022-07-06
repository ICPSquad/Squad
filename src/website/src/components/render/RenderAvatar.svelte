<script lang="ts">
  import { componentToClass, profileToClass } from "@utils/style";
  import { getSortedComponents } from "@utils/layers";
  import type { AvatarComponents } from "@src/types/avatar";
  import type { AvatarColors } from "@src/types/color";
  export let avatarComponents: AvatarComponents;
  export let avatarColors: AvatarColors;
  $: components = getSortedComponents(avatarComponents);

  // List of hats that will trigger the hat version for the hairstyle when they are equipped.
  let hats = ["helicap", "marshall-hat", "mortaboard-hat", "shinobi-hat"];
</script>

<svg
  viewBox="0 0 800 800"
  xmlns="http://www.w3.org/2000/svg"
  class={profileToClass(avatarComponents.profile)}
  style="
--color_skin: rgb({avatarColors.skin[0]}, {avatarColors.skin[1]}, {avatarColors.skin[2]});
--color_clothes : rgb({avatarColors.clothes[0]}, {avatarColors.clothes[1]}, {avatarColors.clothes[2]});
--color_hairs_r : {avatarColors.hairs[0]};
--color_hairs_g : {avatarColors.hairs[1]};
--color_hairs_b : {avatarColors.hairs[2]};
--color_eyes_r : {avatarColors.eyes[0]};
--color_eyes_g : {avatarColors.eyes[1]};
--color_eyes_b : {avatarColors.eyes[2]};
--color_eyebrows_r : {avatarColors.eyebrows[0]};
--color_eyebrows_g : {avatarColors.eyebrows[1]};
--color_eyebrows_b : {avatarColors.eyebrows[2]};
--color_eyeliner_r : {avatarColors.eyeliner[0]};
--color_eyeliner_g : {avatarColors.eyeliner[1]};
--color_eyeliner_b : {avatarColors.eyeliner[2]};
--color_background_r : {avatarColors.background[0]};
--color_background_g : {avatarColors.background[1]};
--color_background_b : {avatarColors.background[2]};
--color_background_a : {avatarColors.background[3]};
"
>
  <style>
    .Punk-body .Punk-crying-eyes {
      clip-path: url(#Punk-head_svg__a);
    }
    .Miss-body .Punk-crying-eyes {
      transform: translateY(-0.5px) !important;
      clip-path: url(#_clip16_miss_head);
    }
    .Business-body .Punk-crying-eyes,
    .Business-body .Juggalo-facemask-40 {
      clip-path: url(#Punk-head_svg__a);
    }

    .Punk-body .Juggalo-facemask-40 {
      clip-path: url(#_clip9_punk_body);
    }
    .Miss-body .Juggalo-facemask-40 {
      clip-path: url(#_clip16_miss_head);
    }

    .Business-body .Punk.ears {
      transform: translateY(15px);
    }

    .Business-body .Miss.ears,
    .Business-body .Miss.mouth,
    .Business-body .Punk.mouth {
      transform: translateY(-10px);
    }

    .Business-body .Miss.eyes {
      transform: translateY(-20px);
    }

    .Business.nose {
      transform: translateY(-50px);
    }
    .Business-mouth {
      transform: translateY(-30px) !important;
    }

    .Punk.nose,
    .Miss.nose {
      transform: translateY(-10px);
    }

    .Business-body .clothing-3,
    .Business-body .clothing-4 {
      transform: scale(1.67, 1.67) translate(-160px, -321px);
    }

    .Punk-body .clothing-1,
    .Punk-body .clothing-2 {
      transform: scale(1, 0.94) translate(0px, 150px);
    }

    .Punk-body .clothing-3,
    .Punk-body .clothing-4 {
      transform: scale(1.21, 1.2) translate(-70px, -120px);
    }

    .Miss-body .clothing-1,
    .Miss-body .clothing-2 {
      transform: scale(1, 0.8) translate(0px, 303px);
    }

    .Punk-body .Business.ears {
      transform: translateY(-15px);
    }

    .Punk-body .Miss.ears {
      transform: translateY(-20px);
    }

    .Punk-body .Miss.eyes {
      transform: translateY(-10px);
    }

    .Punk-body .Business.mouth {
      transform: translateY(10px);
    }

    .Punk-body .Hair-1,
    .Punk-body .Hair-2,
    .Punk-body .Hair-2-base,
    .Punk-body .Hair-2-back,
    .Punk-body .Hair-2-base-back,
    .Punk-body .Hair-3,
    .Punk-body .Hair-4,
    .Punk-body .Hair-4-back,
    .Punk-body .Hair-5,
    .Punk-body .Hair-5-back,
    .Punk-body .Hair-6,
    .Punk-body .Hair-6-back,
    .Punk-body .Hair-6-base,
    .Punk-body .Hair-6-base-back,
    .Punk-body .Hair-10,
    .Punk-body .Hair-11,
    .Punk-body .Hair-12,
    .Punk-body .Hair-13,
    .Punk-body .Hair-13-back,
    .Punk-body .Hair-13-full,
    .Punk-body .Hair-13-top {
      transform: translateY(-17px);
    }

    .Punk-body .Hair-1-base {
      transform: scale(1.02, 1) translate(-8px, -17px);
    }

    .Miss-body .Punk.ears {
      transform: translateY(25px);
    }

    .Miss-body .Business.ears {
      transform: translateY(10px);
    }

    .Miss-body .Business.mouth,
    .Miss-body .Punk.mouth {
      transform: translateY(10px);
    }

    .Miss-body .Punk.eyes,
    .Miss-body .Business.eyes {
      transform: translateY(15px);
    }

    .Punk-body .Cronic-tshirt-40,
    .Punk-body .Helicap-tshirt-40,
    .Punk-body .Lab-coat-15,
    .Punk-body .Lab-coat-40,
    .Punk-body .Street-jacket-15,
    .Punk-body .Street-jacket-40 {
      transform: translate(0px, 100px);
    }

    .Punk-body .Devil-jacket-15,
    .Punk-body .Devil-jacket-30 {
      transform: scale(0.9) translate(43px, 150px);
    }

    .Business-body .Magic-cape-21 {
      transform: scale(1.2) translate(-65px, -185px);
    }
    .Business-body .Magic-cape-84 {
      transform: translate(0px, -20px);
    }

    .Miss-body .Magic-cape-21 {
      transform: scale(1.1) translate(-35.5px, -35px);
    }

    .Miss-body .Cronic-tshirt-40,
    .Miss-body .Devil-jacket-15,
    .Miss-body .Devil-jacket-30,
    .Miss-body .Helicap-tshirt-40,
    .Miss-body .Lab-coat-15,
    .Miss-body .Lab-coat-40,
    .Miss-body .Street-jacket-15,
    .Miss-body .Street-jacket-40 {
      transform: scale(0.82) translate(85px, 248px);
    }

    .Punk-body .Super-suit-40,
    .Punk-body .Yakuza-suit-15,
    .Punk-body .Yakuza-suit-30 {
      transform: translate(0px, 50px);
    }

    .Miss-body .Super-suit-40,
    .Miss-body .Yakuza-suit-15,
    .Miss-body .Yakuza-suit-30 {
      transform: scale(0.82) translate(85px, 210px);
    }

    .Business-body .Mortaboard-hat-85 {
      transform: scale(1.05) translate(-18px, -11px);
    }

    .Punk-body .Mortaboard-hat-85 {
      transform: scale(1.08) translate(-28.5px, -21px);
    }

    .Miss-body .Mortaboard-hat-85 {
      transform: scale(1.05) translate(-18px, -10px);
    }

    .Magic-cape-9,
    .Magic-cape-85 {
      visibility: hidden;
    }

    .Miss-body .Magic-cape-22 {
      transform: scale(0.82) translate(90px, 254px);
    }

    .Miss-body .Magic-cape-85,
    .Punk-body .Magic-cape-85 {
      transform: translate(0px, 30px);
    }

    .Punk-body .Magic-cape-22 {
      transform: scale(0.92) translate(35px, 160px);
    }

    .Business-body .Assassin-cape-21 {
      transform: translate(0, -10px);
    }

    .Punk-body .Assassin-cape-21,
    .Punk-body .Assassin-cape-23,
    .Punk-body .Assassin-cape-86 {
      transform: scale(0.85) translate(70px, 150px);
    }

    .Miss-body .Assassin-cape-21,
    .Miss-body .Assassin-cape-23,
    .Miss-body .Assassin-cape-86 {
      transform: scale(0.73) translate(150px, 320px);
    }

    .Miss-body .Bootcamp-soldier-40,
    .Miss-body .Bootcamp-soldier-15 {
      transform: scale(0.82) translate(85px, 250px);
    }

    .Punk-body .Bootcamp-soldier-40,
    .Punk-body .Bootcamp-soldier-15 {
      transform: scale(1) translate(0px, 70px);
    }

    .Punk-body .Shinobi-suit-99,
    .Punk-body .Shinobi-suit-15 {
      transform: scale(0.9) translate(50px, 100px);
    }

    .Miss-body .Shinobi-suit-99,
    .Miss-body .Shinobi-suit-15 {
      transform: scale(0.82) translate(85px, 180px);
    }

    .Magic-hood-9,
    .Magic-hood-85 {
      transform: translate(0px, -15px);
    }

    .Miss-body .Lab-glasses-76 {
      transform: translate(0px, 30px);
    }

    .Business-body .Astro-suit-85,
    .Business-body .Astro-suit-8 {
      transform: translate(0px, -12px);
    }

    .Miss-body .Astro-suit-85,
    .Miss-body .Astro-suit-8 {
      transform: scale(0.82) translate(85px, 180px);
    }

    .Punk-body .Astro-suit-85,
    .Punk-body .Astro-suit-8 {
      transform: scale(0.9) translate(50px, 100px);
    }
  </style>
  {#if avatarComponents.body}
    <style>
      .clothing {
        visibility: hidden;
      }
    </style>
  {/if}
  {#if hats.includes(avatarComponents.hat)}
    <style>
      #classic-hair-back {
        visibility: hidden;
      }
      #classic-hair-front {
        visibility: hidden;
      }
    </style>
  {:else}
    <style>
      #hat-hair-back {
        visibility: hidden;
      }
      #hat-hair-front {
        visibility: hidden;
      }
    </style>
  {/if}
  {#if avatarComponents.hat === "magic-hood" || avatarComponents.hat === "assassin-hood"}
    <style>
      .Hair {
        visibility: hidden;
      }
    </style>
  {/if}
  {#if avatarComponents.hat === "magic-hood" && avatarComponents.body === "magic-cape"}
    <style>
      .Magic-hood-85,
      .Magic-hood-9 {
        visibility: hidden;
      }
      .Magic-cape-85 {
        visibility: visible;
      }
    </style>
  {/if}
  {#if avatarComponents.hat === "magic-hood" && avatarComponents.body !== "magic-cape"}
    <style>
      .Ears {
        visibility: hidden;
      }
    </style>
  {/if}
  {#if avatarComponents.body === "assassin-cape"}
    {#if avatarComponents.hat === "assassin-hood"}
      <style>
        .Assassin-hood-85,
        .Assassin-hood-9 {
          visibility: hidden;
        }
      </style>
    {:else}
      <style>
        .Assassin-cape-9,
        .Assassin-cape-22,
        .Assassin-cape-85 {
          visibility: hidden;
        }
      </style>
    {/if}
  {/if}
  {#if avatarComponents.hat === "astro-helmet" && avatarComponents.hairs !== "hair-13"}
    <style>
      .Hair {
        clip-path: url(#astro-helmet-mask);
      }
    </style>
  {/if}
  {#if avatarComponents.body === "shinobi-suit"}
    {#if avatarComponents.hat === "magic-hood" || avatarComponents.hat === "assassin-hood"}
      <style>
        .Business-body .Shinobi-suit-99,
        .Business-body .Shinobi-suit-15 {
          transform: scale(1) translate(0px, 70px);
        }
        #business-profile-20 {
          visibility: hidden;
        }
      </style>
    {:else if avatarComponents.hat === "astro-helmet"}
      <style>
        .Business-body .Shinobi-suit-99,
        .Business-body .Shinobi-suit-15 {
          transform: scale(1.1) translate(-40px, -40px);
        }
        .Punk-body .Shinobi-suit-99,
        .Punk-body .Shinobi-suit-15 {
          transform: scale(1.1) translate(-40px, -40px);
        }

        .Miss-body .Shinobi-suit-99,
        .Miss-body .Shinobi-suit-15 {
          transform: scale(1.1) translate(-40px, -40px);
        }
      </style>
    {/if}
  {/if}
  {#if avatarComponents.hat && avatarComponents.hat !== "ninja-headband"}
    <style>
      #evil-mask-76 horns {
        visibility: hidden;
      }
      #Kitsune-mask-V2 #ears {
        visibility: hidden;
      }
    </style>
  {/if}
  {#if avatarComponents.hat === "marshall-hat" || avatarComponents.hat === "helicap" || avatarComponents.hat === "mortaboard-hat" || avatarComponents.hat === "shinobi-hat"}
    <style>
      .Hair-above {
        visibility: hidden;
      }
      #top-hair-15 {
        visibility: hidden;
      }
      .Hair-behind.Hair-13 {
        visibility: hidden;
      }
    </style>
  {/if}
  {#if avatarComponents.hat === "magic-hood" || avatarComponents.hat === "shinobi-hat"}
    <style>
      #energy-eyes {
        visibility: hidden;
      }
    </style>
  {/if}
  {#each components as component}
    <use xlink:href="#{component[0]}-{component[1]}" class={componentToClass(component[0], component[1])} />
  {/each}
</svg>
