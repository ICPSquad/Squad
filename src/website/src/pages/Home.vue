<template>
  <div class="flex flex-col">
    <div>
      <h2
        class="
          py-12
          text-center
          font-marker
          text-gray-800
          lg:text-5xl
          md:text-3xl
          text-2xl
          font-bold
          mt-8
        "
      >
        Season 0 : <span> squad loading 🌍 </span>
      </h2>
    </div>
    <div
      class="
        flex flex-row
        md:px-24
        px-6
        w-full
        md:gap-x-12
        gap-x-6
        justify-around
      "
    >
      <div class="w-56 hidden lg:block" v-if="!isMobileRef">
        <img src="others/characters/Seb.svg" alt="Seb" class="rounded-2xl" />
      </div>
      <div class="w-60 hidden md:block" v-if="!isMobileRef">
        <img src="others/characters/Arun.svg" alt="Arun" class="rounded-2xl" />
      </div>
      <div class="w-64">
        <img src="others/characters/Business.svg" alt="" class="rounded-2xl" />
      </div>
      <div class="w-72">
        <img src="others/characters/Miss.svg" alt="" class="rounded-2xl" />
      </div>
      <div class="w-64">
        <img src="others/characters/Punk.svg" alt="" class="rounded-2xl" />
      </div>
      <div class="w-60 hidden md:block" v-if="!isMobileRef">
        <img
          src="others/characters/Isaac.svg"
          alt="Isaac"
          class="rounded-2xl"
        />
      </div>
      <div class="w-56 hidden lg:block" v-if="!isMobileRef">
        <img src="others/characters/Duke.svg" alt="Duke" class="rounded-2xl" />
      </div>
    </div>
    <div class="flex flex-row w-full justify-center">
      <h2
        class="
          text-center
          2xl:text-5xl
          lg:text-4xl
          md:text-3xl
          text-2xl text-gray-800
          md:my-12
          mt-6
          mb-6
        "
      >
        <span class="font-marker" :class="!updated ? 'animate-pulse' : ''">
          Members :
        </span>
        {{ numberOfMembers }}
      </h2>
    </div>
    <div class="flex flex-row justify-center">
      <router-link to="/preorder">
        <button
          class="
            lg:text-3xl
            md:text-2xl
            text-xl
            shadow-2xl
            font-marker
            text-white
            bg-pink-600
            rounded
            py-6
            px-8
            mb-8
            mt-4
            cursor-pointer
            mx-auto
          "
        >
          👉 Join
        </button>
      </router-link>
    </div>

    <div
      class="
        flex flex-col
        2xl:text-5xl
        lg:text-4xl
        md:text-3xl
        text-2xl
        font-semibold
        bg-gradient-to-l
        from-gray-600
        via-gray-900
        to-black
        text-white
        md:py-24 md:px-28
        py-8
        px-6
        justify-around
      "
    >
      <h3 class="text-center md:mb-16 mb-6 font-marker">
        The first engage-to-earn NFT game 🎯
      </h3>
      <div class="flex flex-row w-full justify-around items-center md:py-12">
        <p class="lg:text-4xl md:text-2xl text-xl">
          We believe the Internet Computer will change the world.
          <br />
          <br />
          Create your avatar, get involved, contribute to the expansion of the
          ecosystem and earn rewards.
          <br />
          <br />
        </p>
      </div>
    </div>
    <div
      class="
        flex flex-col
        2xl:text-5xl
        lg:text-4xl
        md:text-3xl
        text-2xl
        font-semibold
        text-gray-800
        md:py-24 md:px-28
        py-8
        px-6
        justify-around
      "
    >
      <h3 class="text-center md:mb-16 mb-6 font-marker">Your avatar. 🦸</h3>
      <div class="flex md:flex-row flex-col w-full justify-around items-center">
        <p class="lg:text-4xl md:text-2xl text-xl">
          A fully customizable NFT that you can use on different platforms
          across the Internet Computer.
          <br />
          <br />
          Take your time to choose among the multiples variations, colors and
          styles available.
          <br />
          <br />
          Your avatar : your creativity. 🎨
        </p>
        <div class="md:w-80 my-6 mx-6">
          <img src="Avatar-creativity.png" alt="Avatar" class="rounded-2xl" />
        </div>
      </div>
      <router-link to="/center">
        <button
          class="
            lg:text-3xl
            md:text-2xl
            text-xl
            shadow-2xl
            font-marker
            text-white
            bg-pink-600
            rounded
            py-6
            px-8
            mt-8
            cursor-pointer
            hidden
            md:block
            mx-auto
          "
        >
          Create 🖍
        </button>
      </router-link>
    </div>
    <div
      class="
        flex flex-col
        2xl:text-5xl
        lg:text-4xl
        md:text-3xl
        text-2xl
        font-semibold
        bg-gradient-to-l
        from-gray-600
        via-gray-900
        to-black
        text-white
        md:py-24 md:px-28
        py-8
        px-6
        justify-around
      "
    >
      <h3 class="text-center md:mb-16 mb-6 font-marker md:mt-16">
        Accessory 🎩
      </h3>
      <div class="flex md:flex-row flex-col w-full justify-around items-center">
        <p class="lg:text-4xl md:text-2xl text-xl mx-auto">
          Collect and wear special accessories to enhance your style.
          <br />
          <br />
          Increase your chances to win rewards and access special privileges.
          <br />
          <br />
        </p>
      </div>
      <div
        class="
          flex
          md:flex-row
          flex-col
          w-full
          justify-center
          items-center
          mt-8
          mb-8
          gap-x-40
        "
      >
        <div class="w-60">
          <img src="Accessory.svg" alt="Card" class="rounded-2xl" />
        </div>
        <div class="transform rotate-90 md:rotate-0 w-2/3 md:h-60 md:w-44 my-8">
          <img src="Arrow.svg" alt="Arrow" />
        </div>
        <div class="md:w-72 w-64">
          <helmet class="rounded-2xl"></helmet>
        </div>
      </div>
    </div>
    <div
      class="
        flex flex-col
        2xl:text-5xl
        lg:text-4xl
        md:text-3xl
        text-2xl
        font-semibold
        text-gray-800
        md:py-24 md:px-28
        py-8
        px-6
        justify-around
      "
    >
      <h3 class="text-center md:mb-16 mb-6 font-marker">Community 🫂</h3>
      <div class="flex flex-col items-center w-full">
        <p class="lg:text-4xl md:text-2xl text-xl mx-auto">
          Join a vibrant community of people who are passionate about the
          Internet Computer, all over the world.
          <br />
          <br />
          Community neuron, exclusive content, events, educational resources and
          more to come.
        </p>
        <a href="https://discord.gg/icpsquad" target="_blank">
          <button
            class="
              lg:text-3xl
              md:text-2xl
              text-xl
              shadow-2xl
              font-marker
              text-white
              bg-pink-600
              rounded
              py-6
              px-8
              md:mt-16
              mt-8
              cursor-pointer
            "
          >
            Join 👋
          </button>
        </a>
      </div>
    </div>
    <div
      class="
        flex flex-col
        2xl:text-5xl
        lg:text-4xl
        md:text-3xl
        text-2xl
        font-semibold
        bg-gradient-to-l
        from-gray-600
        via-gray-900
        to-black
        text-white
        md:py-24 md:px-28
        py-8
        px-6
        justify-around
      "
    >
      <h3 class="text-center md:mb-16 mb-6 font-marker md:mt-16">
        Legendary characters 🦄
      </h3>
      <div class="flex md:flex-row flex-col w-full items-center justify-around">
        <p class="lg:text-4xl md:text-2xl text-xl">
          Those avatars are unique, made for you and cannot be minted again.
          <br />
          <br />
          Get you hands on those through meaningful contributions or special
          events.
        </p>
        <div>
          <img
            src="others/characters/Igor.svg"
            alt="Igor"
            class="
              md:w-80
              w-2/3
              mx-auto
              rounded-2xl
              md:mb-16
              mb-8
              mt-6
              transform
              hover:scale-110
            "
          />
        </div>
      </div>
    </div>
  </div>
</template>
<script lang="ts">
import { defineComponent, ref } from "vue";

import Sidebar from "../components/Sidebar.vue";
import Helmet from "../animations/Helmet.vue";
import { Actor, HttpAgent } from "@dfinity/agent";
import { idlFactory } from "declarations/event/index";

export default defineComponent({
  setup() {
    const numberOfMembers = ref("∞");
    const updated = ref(false);

    let agent = new HttpAgent();
    let actor = Actor.createActor(idlFactory, {
      agent,
      canisterId: "p4y2d-yyaaa-aaaaj-qaixa-cai",
    });
    function updateNumberOfMembers() {
      actor.numberUsers().then((number) => {
        numberOfMembers.value = Number(number).toString();
        updated.value = true;
      });
    }

    updateNumberOfMembers();

    function isMobile() {
      let check = false;
      (function (a) {
        if (
          /(android|bb\d+|meego).+mobile|avantgo|bada\/|blackberry|blazer|compal|elaine|fennec|hiptop|iemobile|ip(hone|od)|iris|kindle|lge |maemo|midp|mmp|mobile.+firefox|netfront|opera m(ob|in)i|palm( os)?|phone|p(ixi|re)\/|plucker|pocket|psp|series(4|6)0|symbian|treo|up\.(browser|link)|vodafone|wap|windows ce|xda|xiino/i.test(
            a
          ) ||
          /1207|6310|6590|3gso|4thp|50[1-6]i|770s|802s|a wa|abac|ac(er|oo|s\-)|ai(ko|rn)|al(av|ca|co)|amoi|an(ex|ny|yw)|aptu|ar(ch|go)|as(te|us)|attw|au(di|\-m|r |s )|avan|be(ck|ll|nq)|bi(lb|rd)|bl(ac|az)|br(e|v)w|bumb|bw\-(n|u)|c55\/|capi|ccwa|cdm\-|cell|chtm|cldc|cmd\-|co(mp|nd)|craw|da(it|ll|ng)|dbte|dc\-s|devi|dica|dmob|do(c|p)o|ds(12|\-d)|el(49|ai)|em(l2|ul)|er(ic|k0)|esl8|ez([4-7]0|os|wa|ze)|fetc|fly(\-|_)|g1 u|g560|gene|gf\-5|g\-mo|go(\.w|od)|gr(ad|un)|haie|hcit|hd\-(m|p|t)|hei\-|hi(pt|ta)|hp( i|ip)|hs\-c|ht(c(\-| |_|a|g|p|s|t)|tp)|hu(aw|tc)|i\-(20|go|ma)|i230|iac( |\-|\/)|ibro|idea|ig01|ikom|im1k|inno|ipaq|iris|ja(t|v)a|jbro|jemu|jigs|kddi|keji|kgt( |\/)|klon|kpt |kwc\-|kyo(c|k)|le(no|xi)|lg( g|\/(k|l|u)|50|54|\-[a-w])|libw|lynx|m1\-w|m3ga|m50\/|ma(te|ui|xo)|mc(01|21|ca)|m\-cr|me(rc|ri)|mi(o8|oa|ts)|mmef|mo(01|02|bi|de|do|t(\-| |o|v)|zz)|mt(50|p1|v )|mwbp|mywa|n10[0-2]|n20[2-3]|n30(0|2)|n50(0|2|5)|n7(0(0|1)|10)|ne((c|m)\-|on|tf|wf|wg|wt)|nok(6|i)|nzph|o2im|op(ti|wv)|oran|owg1|p800|pan(a|d|t)|pdxg|pg(13|\-([1-8]|c))|phil|pire|pl(ay|uc)|pn\-2|po(ck|rt|se)|prox|psio|pt\-g|qa\-a|qc(07|12|21|32|60|\-[2-7]|i\-)|qtek|r380|r600|raks|rim9|ro(ve|zo)|s55\/|sa(ge|ma|mm|ms|ny|va)|sc(01|h\-|oo|p\-)|sdk\/|se(c(\-|0|1)|47|mc|nd|ri)|sgh\-|shar|sie(\-|m)|sk\-0|sl(45|id)|sm(al|ar|b3|it|t5)|so(ft|ny)|sp(01|h\-|v\-|v )|sy(01|mb)|t2(18|50)|t6(00|10|18)|ta(gt|lk)|tcl\-|tdg\-|tel(i|m)|tim\-|t\-mo|to(pl|sh)|ts(70|m\-|m3|m5)|tx\-9|up(\.b|g1|si)|utst|v400|v750|veri|vi(rg|te)|vk(40|5[0-3]|\-v)|vm40|voda|vulc|vx(52|53|60|61|70|80|81|83|85|98)|w3c(\-| )|webc|whit|wi(g |nc|nw)|wmlb|wonu|x700|yas\-|your|zeto|zte\-/i.test(
            a.substr(0, 4)
          )
        )
          check = true;
        //@ts-ignore
      })(navigator.userAgent || navigator.vendor || window.opera);
      return check;
    }

    const isMobileRef = ref<boolean>(isMobile());

    return {
      numberOfMembers,
      updated,
      isMobileRef,
    };
  },
  components: {
    Sidebar,
    Helmet,
  },
});
</script>
