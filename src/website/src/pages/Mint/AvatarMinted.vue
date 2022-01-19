<template>
  <div class="flex flex-col justify-around items-center">
    <h2
      class="
        text-center
        lg:text-4xl
        md:text-3xl
        text-2xl
        font-bold
        text-gray-800
        md:mt-16
        mt-8
      "
    >
      Congratulation! <br />
      Your avatar has been successfully minted 🎉
    </h2>
    <h3
      class="
        mx-auto
        text-center
        lg:text-3xl
        md:text-2xl
        text-xl
        font-bold
        mt-24
        text-gray-800
      "
    >
      Welcome into the squad 🫂
    </h3>
    <div
      class="flex md:flex-row flex-col items-center justify-around w-full mt-8"
    >
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
          mb-8
        "
      >
        <a
          class="twitter-share-button"
          target="_blank"
          href="https://twitter.com/intent/tweet?text=I%20just%20minted%20my%20@ICPSquadNFT%20avatar!%20[Upload%20your%20avatar%20here]"
          data-size="large"
        >
          Share</a
        >
      </button>
    </div>
    <div class="flex flex-col items-center">
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
        "
        @click="downloadSVG()"
      >
        Download
      </button>
    </div>
  </div>
</template>

<script>
import { defineComponent } from "vue";

export default defineComponent({
  props: ["svg"],
  setup(props) {
    function download(href, name) {
      var a = document.createElement("a");

      a.download = name;
      a.href = href;

      document.body.appendChild(a);
      a.click();
      document.body.removeChild(a);
    }

    function downloadSVG() {
      download(
        window.URL.createObjectURL(
          new Blob([props.svg], { type: "image/svg" })
        ),
        "Avatar.svg"
      );
    }

    return {
      downloadSVG,
    };
  },
});
</script>
