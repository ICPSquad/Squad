<template>
  <div class="flex flex-col flex-1 w-full bg-gradient-to-l from-gray-600 via-gray-900 to-black lg:text-6xl md:text-4xl text-2xl font-semibold text-white justify-cente items-center">
    <h1 class="text-center md:mb-16 mt-8 mb-8">Registration</h1>

    <div class="flex flex-col justify-between items-center mb-8 mt-8 gap-y-8 w-full">
      <div>
        <label class="lg:text-4xl md:text-3xl text-2xl text-white mb-4 mr-8 block" for="email"> Email Address 📬</label>
        <input v-model="email" size="25" class="border-4 border-gray-800 rounded-xl p-2 outline-none focus:border-pink-600 md:text-3xl text-xl text-black font-bold" type="email" ref="emailField" />
      </div>
      <div>
        <label class="lg:text-4xl md:text-3xl text-2xl text-white mr-6 mb-4 block"> Twitter (or WeChat ID) 🐥</label>
        <input v-model="twitter" size="25" class="border-4 border-gray-800 rounded-xl p-2 outline-none focus:border-pink-600 md:text-3xl text-xl text-black font-bold" type="text" />
      </div>
      <div>
        <label class="lg:text-4xl md:text-3xl text-2xl text-white mr-4 block mb-4"> Discord Username 🎮</label>
        <input v-model="discord" size="25" class="border-4 border-gray-800 rounded-xl p-2 outline-none focus:border-pink-600 md:text-3xl text-xl text-black font-bold" type="text" />
      </div>
      <div>
        <label class="lg:text-2xl md:text-xl text-base text-white my-4 mr-4"> Enter the text in this image</label>
        <captcha class="my-4 mx-auto" @newCaptcha="changeCaptcha" />
        <input v-model="captchaText" size="10" class="border-4 border-gray-800 rounded-xl p-2 outline-none focus:border-pink-600 md:text-3xl text-xl text-black font-bold mb-8" type="text" />
      </div>

      <h3 class="mb-4 mx-auto lg:text-lg md:text-base text-sm font-normal text-white md:w-4/12 w-9/12">
        🚨 <strong>Only 1 entry allowed per person.</strong><br />There's no gameplay advantage to owning more than one character. Cheaters risk being banned from the game.<br />
      </h3>
      <button
        class="2xl:text-5xl lg:text-4xl md:text-3xl text-2xl shadow-2xl font-marker text-white bg-pink-600 rounded py-6 px-8 md:py-8 md:px-12 mt-8 mb-8 cursor-pointer max-w-2xl"
        :class="pulse ? 'animate-pulse' : ''"
        @click="verification"
      >
        {{ pulse ? "Wait..." : "Submit" }}
      </button>
      <h3 class="mb-8 mx-auto lg:text-base md:text-sm text-xs font-normal text-white md:w-4/12 w-9/12">
        ⚠️ <strong class="text-center">Disclaimer</strong> ⚠️<br />
        <u>Please do not invest money you cannot afford to lose!</u><br />
        The Internet Computer is still a new technology and NFT markets are unpredictable. The last thing we want is to have any of our dear supporters experience financial hardship due to unexpected
        delays or unpredictable market outcomes. Always do your own research and take accountability for managing your financial risk wisely. By submitting this form you agree to indemnify and hold
        ICP Squad harmless to the maximum extent permitted by applicable law, without limitation, from and against any and all losses. In other words, please don't try to sue us. We are just a bunch
        of nerds volunteering to build cool stuff for the Internet Computer, and a lawsuit would ruin all the fun.<br />
      </h3>
      <h3 class="mb-2 mt-8 mx-auto lg:text-xl md:text-lg text-base font-normal text-white text-center">Having trouble submitting the form?<br /></h3>
      <a class="mb-24 mx-auto lg:text-xl md:text-lg text-base font-normal text-pink-600 hover:text-pink-300 text-center" href="https://discord.com/invite/icpsquad" target="_blank">
        🙋 Click here for info and support<br />
      </a>
    </div>
  </div>
</template>

<script lang="ts">
import { defineComponent, ref } from "vue";
import Captcha from "../../components/Captcha.vue";

export default defineComponent({
  emits: ["submit"],
  props: {
    pulse: {
      type: Boolean,
      required: true,
    },
  },
  setup(props, context) {
    //User form
    const email = ref<string>("");
    const twitter = ref<string>("");
    const discord = ref<string>("");

    //Captcha
    const captchaText = ref<string>();
    const captchaValid = ref<string>();

    function ValidateCaptcha(): boolean {
      return captchaText.value === captchaValid.value;
    }

    function changeCaptcha(captcha: string) {
      captchaValid.value = captcha;
    }

    const verification = () => {
      if (!confirm("Do you confirm ?")) return;
      if (!ValidateCaptcha()) {
        alert("Captcha is not valid");
        return;
      }

      if (!email.value || !twitter.value || !discord.value) {
        if (!confirm("You haven't filled all the fields, it's not mandatory but it's recommended for a better experience. \nDo you want to continue anyway?")) {
          return;
        }
      }
      context.emit("submit", {
        email: email.value,
        twitter: twitter.value,
        discord: discord.value,
      });
      return;
    };
    return {
      verification,
      email,
      twitter,
      discord,
      changeCaptcha,
      captchaText,
    };
  },
  components: {
    Captcha,
  },
});
</script>
