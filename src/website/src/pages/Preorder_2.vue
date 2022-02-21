<template>
  <div class="flex flex-col flex-1" v-if="!connected">
    <div class="flex flex-col flex-1 h-full justify-around">
      <h2 class="text-center 2xl:text-5xl lg:text-4xl md:text-3xl text-2xl font-bold text-gray-800 font-marker mt-8">Welcome on board : inscription !</h2>

      <div class="flex lg:flex-row flex-col md:justify-around gap-x-8 gap-y-12 items-center py-8 lg:py-0">
        <div class="flex flex-col items-center h-100 md:gap-y-8 gap-y-4 lg:w-1/3 w-full md:mx-0 mx-4 justify-center">
          <h2 class="text-center 2xl:text-5xl lg:text-4xl md:text-3xl text-2xl font-bold text-gray-800 font-marker">1</h2>
          <div class="w-40 lg:w-64">
            <svg viewBox="0 0 24 24" version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
              <!-- Uploaded to SVGRepo https://www.svgrepo.com -->
              <title>ic_fluent_team_add_24_regular</title>
              <desc>Created with Sketch.</desc>
              <g id="🔍-Product-Icons" stroke="none" stroke-width="1" fill="none" fill-rule="evenodd">
                <g id="ic_fluent_team_add_24_regular" fill="#212121" fill-rule="nonzero">
                  <path
                    d="M17.5,12 C20.5375661,12 23,14.4624339 23,17.5 C23,20.5375661 20.5375661,23 17.5,23 C14.4624339,23 12,20.5375661 12,17.5 C12,14.4624339 14.4624339,12 17.5,12 Z M17.5,13.9992349 L17.4101244,14.0072906 C17.2060313,14.0443345 17.0450996,14.2052662 17.0080557,14.4093593 L17,14.4992349 L16.9996498,16.9992349 L14.4976498,17 L14.4077742,17.0080557 C14.2036811,17.0450996 14.0427494,17.2060313 14.0057055,17.4101244 L13.9976498,17.5 L14.0057055,17.5898756 C14.0427494,17.7939687 14.2036811,17.9549004 14.4077742,17.9919443 L14.4976498,18 L17.0006498,17.9992349 L17.0011076,20.5034847 L17.0091633,20.5933603 C17.0462073,20.7974534 17.207139,20.9583851 17.411232,20.995429 L17.5011076,21.0034847 L17.5909833,20.995429 C17.7950763,20.9583851 17.956008,20.7974534 17.993052,20.5933603 L18.0011076,20.5034847 L18.0006498,17.9992349 L20.5045655,18 L20.5944411,17.9919443 C20.7985342,17.9549004 20.9594659,17.7939687 20.9965098,17.5898756 L21.0045655,17.5 L20.9965098,17.4101244 C20.9594659,17.2060313 20.7985342,17.0450996 20.5944411,17.0080557 L20.5045655,17 L17.9996498,16.9992349 L18,14.4992349 L17.9919443,14.4093593 C17.9549004,14.2052662 17.7939687,14.0443345 17.5898756,14.0072906 L17.5,13.9992349 Z M14.2540247,10 C15.0885672,10 15.8169906,10.4543496 16.2054276,11.1291814 C15.6719841,11.2368176 15.1631195,11.409593 14.6865144,11.6387884 C14.5648628,11.550964 14.4153954,11.5 14.2540247,11.5 L9.75192738,11.5 C9.33771382,11.5 9.00192738,11.8357864 9.00192738,12.25 L9.00192738,16.4989513 C9.00192738,17.9098632 9.97557657,19.0933671 11.2876273,19.4142154 C11.4604353,19.9797789 11.7097452,20.5127963 12.0225923,21.0012092 L12.002976,21 C9.51711551,21 7.50192738,18.9848119 7.50192738,16.4989513 L7.50192738,12.25 C7.50192738,11.0073593 8.5092867,10 9.75192738,10 L14.2540247,10 Z M7.40645343,10.000271 C7.01177565,10.4116389 6.72426829,10.9266236 6.58881197,11.5003444 L4.25,11.5 C3.83578644,11.5 3.5,11.8357864 3.5,12.25 L3.5,14.99876 C3.5,16.3801567 4.61984327,17.5 6.00123996,17.5 C6.20123055,17.5 6.39573909,17.4765286 6.58216119,17.4321901 C6.66686857,17.9361103 6.82155533,18.416731 7.03486751,18.8640179 C6.70577369,18.9530495 6.35898976,19 6.00123996,19 C3.79141615,19 2,17.2085839 2,14.99876 L2,12.25 C2,11.059136 2.92516159,10.0843551 4.09595119,10.0051908 L4.25,10 L7.40645343,10.000271 Z M19.75,10 C20.9926407,10 22,11.0073593 22,12.25 L22.0008195,12.8103588 C20.8328473,11.6891263 19.2469007,11 17.5,11 L17.2548102,11.004539 L17.2548102,11.004539 C17.1009792,10.6291473 16.8766656,10.2891588 16.5994986,10.000271 L19.75,10 Z M18.5,4 C19.8807119,4 21,5.11928813 21,6.5 C21,7.88071187 19.8807119,9 18.5,9 C17.1192881,9 16,7.88071187 16,6.5 C16,5.11928813 17.1192881,4 18.5,4 Z M12,3 C13.6568542,3 15,4.34314575 15,6 C15,7.65685425 13.6568542,9 12,9 C10.3431458,9 9,7.65685425 9,6 C9,4.34314575 10.3431458,3 12,3 Z M5.5,4 C6.88071187,4 8,5.11928813 8,6.5 C8,7.88071187 6.88071187,9 5.5,9 C4.11928813,9 3,7.88071187 3,6.5 C3,5.11928813 4.11928813,4 5.5,4 Z M18.5,5.5 C17.9477153,5.5 17.5,5.94771525 17.5,6.5 C17.5,7.05228475 17.9477153,7.5 18.5,7.5 C19.0522847,7.5 19.5,7.05228475 19.5,6.5 C19.5,5.94771525 19.0522847,5.5 18.5,5.5 Z M12,4.5 C11.1715729,4.5 10.5,5.17157288 10.5,6 C10.5,6.82842712 11.1715729,7.5 12,7.5 C12.8284271,7.5 13.5,6.82842712 13.5,6 C13.5,5.17157288 12.8284271,4.5 12,4.5 Z M5.5,5.5 C4.94771525,5.5 4.5,5.94771525 4.5,6.5 C4.5,7.05228475 4.94771525,7.5 5.5,7.5 C6.05228475,7.5 6.5,7.05228475 6.5,6.5 C6.5,5.94771525 6.05228475,5.5 5.5,5.5 Z"
                    id="🎨-Color"
                  ></path>
                </g>
              </g>
            </svg>
          </div>
          <div class="text-center lg:text-2xl text-xl font-bold text-gray-800 w-2/3">
            Join the community 👥
            <br />
            <br />
            Fill out a few informations and pay your inscription
            <span class="font-extrabold text-purple-500 cursor-pointer" @click="messageFee"> fee</span>.
          </div>
        </div>
        <div class="flex flex-col items-center md:gap-y-14 gap-y-8 justify-around h-100 lg:w-1/3 w-full mx-4 md:mx-0">
          <h2 class="text-center 2xl:text-5xl lg:text-4xl md:text-3xl text-2xl font-bold text-gray-800 font-marker">2</h2>
          <div class="w-40 lg:w-64">
            <img src="others/characters/Miss.svg" alt="Miss" class="rounded-2xl" />
          </div>
          <div class="text-center lg:text-2xl text-xl font-bold text-gray-800 w-2/3">
            Mint your own avatar 🎨
            <br />
            <br />
            Receive your avatar in your wallet immediately!
          </div>
        </div>
        <div class="flex flex-col items-center md:gap-y-8 gap-y-4 justify-around h-100 lg:w-1/3 w-full mx-4 md:mx-0">
          <h2 class="text-center 2xl:text-5xl lg:text-4xl md:text-3xl text-2xl font-bold text-gray-800 font-marker">3</h2>
          <div class="w-40 lg:w-64">
            <img src="others/icons/engage.svg" alt="Engage" />
          </div>
          <div class="text-center lg:text-2xl text-xl font-bold text-gray-800 w-2/3">
            Start playing and earn
            <a href="https://www.dfinitycommunity.com/why-icp-squad-nfts-are-game-changer-for-internet-computer-dapps/" target="_blank" class="text-purple-500 font-extrabold"> rewards 💰 </a>
            (soon)
            <br />
            <br />
            Missions, contests , partnerships and more !
            <span class="font-extrabold text-purple-500 cursor-pointer" @click="messageDev"> * </span>
          </div>
        </div>
      </div>
    </div>
    <div
      class="flex flex-col flex-1 w-full bg-gradient-to-l from-gray-600 via-gray-900 to-black 2xl:text-5xl lg:text-4xl md:text-3xl text-2xl font-semibold text-white md:justify-around"
      v-if="!connected"
    >
      <h1 class="text-center mt-8 font-marker">Connect your wallet.</h1>

      <div class="flex flex-row justify-around mb-8">
        <button class="lg:text-3xl md:text-2xl text-xl shadow-2xl font-marker text-white bg-pink-600 rounded py-6 px-8 mt-8 cursor-pointer hidden md:block" @click="plug">Plug</button>
        <button class="lg:text-3xl md:text-2xl text-xl shadow-2xl font-marker text-white bg-pink-600 rounded py-6 px-8 mt-8 cursor-pointer" @click="stoic">Stoic</button>
      </div>
    </div>
  </div>
  <div
    v-else-if="connected && squad_member"
    class="flex flex-col flex-1 w-full bg-gradient-to-l from-gray-600 via-gray-900 to-black lg:text-6xl md:text-4xl text-2xl font-semibold text-white justify-around"
  >
    <h3 class="text-center md:mb-16 mt-8 mb-8 font-marker lg:text-5xl md:text- 3xl text-2xl">Already in the team !<br /></h3>
    <div class="w-full flex flex-row justify-around items-center">
      <router-link to="/">
        <button class="lg:text-3xl md:text-2xl text-xl shadow-2xl font-marker text-white bg-pink-600 rounded py-6 px-8 mt-8 cursor-pointer">Home 🏠</button>
      </router-link>
      <router-link to="/center">
        <button class="lg:text-3xl md:text-2xl text-xl shadow-2xl font-marker text-white bg-pink-600 rounded py-6 px-8 mt-8 cursor-pointer">Mint ⛏</button>
      </router-link>
    </div>
  </div>
  <div
    class="flex flex-col flex-1 w-full bg-gradient-to-l from-gray-600 via-gray-900 to-black lg:text-6xl md:text-4xl text-2xl font-semibold text-white justify-center"
    v-if="connected && !squad_member && !joined"
  >
    <h1 class="text-center md:mb-16 mt-8 mb-8 font-marker">Inscription 🔥</h1>

    <div class="flex flex-col justify-between items-center mb-8 mt-8 gap-y-8 w-full">
      <div>
        <div class="mb-4">
          <label class="lg:text-4xl md:text-3xl text-2xl text-white mb-8 mr-8" for="email"> Email Address 📬</label>
        </div>

        <input v-model="email" size="25" class="border-4 border-gray-800 rounded-xl p-2 outline-none focus:border-pink-600 md:text-3xl text-xl text-black font-bold" type="email" ref="emailField" />
      </div>
      <div class="mb-4">
        <div>
          <label class="lg:text-4xl md:text-3xl text-2xl text-white mb-8 mr-6"> Twitter (or WeChat ID) 🐥</label>
        </div>

        <input v-model="twitter" size="25" class="border-4 border-gray-800 rounded-xl p-2 outline-none focus:border-pink-600 md:text-3xl text-xl text-black font-bold" type="text" />
      </div>
      <div>
        <div class="mb-4">
          <label class="lg:text-4xl md:text-3xl text-2xl text-white mb-8 mr-4"> Discord Username 🎮</label>
        </div>

        <input v-model="discord" size="25" class="border-4 border-gray-800 rounded-xl p-2 outline-none focus:border-pink-600 md:text-3xl text-xl text-black font-bold" type="text" />
        <div class="flex flex-row mt-8 justify-center">
          <label class="lg:text-2xl md:text-xl text-base text-white my-4 mr-4"> Enter the text in this image</label>
        </div>
        <div>
          <captcha class="my-4" @newCaptcha="changeCaptcha" />
        </div>
        <div class="flex flex-row justify-center">
          <input v-model="captchaText" size="10" class="border-4 border-gray-800 rounded-xl p-2 outline-none focus:border-pink-600 md:text-3xl text-xl text-black font-bold mb-8" type="text" />
        </div>
      </div>
      <h3 class="mb-4 mx-auto lg:text-lg md:text-base text-sm font-normal text-white md:w-3/12 w-9/12">
        🚨 <strong>Only 1 entry allowed per person.</strong><br />There's no gameplay advantage to owning more than one character. Cheaters risk being banned from the game.<br />
      </h3>
      <button
        class="2xl:text-5xl lg:text-4xl md:text-3xl text-2xl shadow-2xl font-marker text-white bg-pink-600 rounded py-6 px-8 md:py-8 md:px-12 mt-8 mb-8 cursor-pointer max-w-2xl"
        @click="verification"
        :class="waiting ? 'animate-pulse' : ''"
      >
        {{ message }}
      </button>
      <h3 class="mb-8 mx-auto lg:text-base md:text-sm text-xs font-normal text-white md:w-3/12 w-9/12">
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
  <div
    v-else-if="connected && joined && !squad_member"
    class="flex flex-col flex-1 w-full bg-gradient-to-l from-gray-600 via-gray-900 to-black lg:text-6xl md:text-4xl text-2xl font-semibold text-white justify-around"
  >
    <h1 class="text-center md:mb-16 mt-8 mb-8 font-marker">Congratulation 🎉</h1>
    <h3 class="text-center md:mb-16 mt-8 mb-8 font-marker lg:text-5xl md:text- 3xl text-2xl">You've successfully joined the squad!<br /></h3>
    <div class="w-full flex flex-row justify-around items-center">
      <router-link to="/">
        <button class="lg:text-3xl md:text-2xl text-xl shadow-2xl font-marker text-white bg-pink-600 rounded py-6 px-8 mt-8 cursor-pointer">Home 🏠</button>
      </router-link>
      <router-link to="/center">
        <button class="lg:text-3xl md:text-2xl text-xl shadow-2xl font-marker text-white bg-pink-600 rounded py-6 px-8 mt-8 cursor-pointer">Mint ⛏</button>
      </router-link>
    </div>
  </div>
</template>

<script lang="ts">
import { computed, ref, watch } from "vue";
import Captcha from "../components/Captcha.vue";
import { useStore } from "vuex";
import { SubAccount } from "declarations/hub/hub.did.d";
import { idlFactory as idlFactory_hub } from "declarations/hub/index";
import { HttpAgent, Actor } from "@dfinity/agent";
//@ts-ignore
import { StoicIdentity } from "ic-stoic-identity";
import { createLedgerCanister } from "../utils/ledger";
import { HUB_CANISTER_ID, HOST, LEDGER_CANISTER_ID } from "../utils/const";
import { pay_plug, pay_stoic, getRandomSubaccount } from "../utils/payment";

export default {
  inheritAttrs: false,
  setup() {
    const store = useStore();
    const waiting = ref(false);
    const joined = ref(false);
    const squad_member = ref(false);

    const message = ref("Join");

    //User form
    const email = ref<string>("");
    const twitter = ref<string>("");
    const discord = ref<string>("");

    // Canister infos and payment

    const whitelist = [HUB_CANISTER_ID];
    const emailField = ref(null);
    const memo = ref<bigint>(BigInt(0));
    const height = ref<bigint>(BigInt(0));
    const subaccount = ref<SubAccount>([0]);

    //Stoic specifity
    let ledgerActor: any;

    //Captcha
    const captchaText = ref<string>();
    const captchaValid = ref<string>();

    const messageFee = () => {
      alert(
        "During your registration, you will be charged a fee of 1 ICP.\nInstead of selling our NFTs on a marketplace we choosed this method of funding! \nThis money will be put to good use to pay our artists, developers and fund the future of ICP Squad. \n\nThank you for your support!"
      );
    };

    const messageDev = () => {
      alert("Concept still in development, please stay tuned!");
    };

    function ValidateCaptcha(): boolean {
      return captchaText.value === captchaValid.value;
    }

    const plug = async () => {
      const result = await (window as any).ic?.plug?.requestConnect({
        whitelist,
        HOST,
      });
      if (!result) {
        return;
      }
      store.commit("setWallet", "Plug");
      let principal = await (window as any).ic?.plug?.agent.getPrincipal();
      store.commit("setPrincipal", principal);
      //@ts-ignore
      const actor_hub = await window.ic.plug.createActor({
        canisterId: HUB_CANISTER_ID,
        interfaceFactory: idlFactory_hub,
      });
      store.commit("setAuthenticatedActor_hub", actor_hub);
    };

    const stoic = async () => {
      try {
        StoicIdentity.load().then(async (identity: any) => {
          if (identity !== false) {
            //ID is a already connected wallet!
          } else {
            //No existing connection, lets make one!
            identity = await StoicIdentity.connect();
          }
          try {
            await identity.sign("a");
          } catch (e) {
            alert("Error logging in with stoic, please ensure cookies are enabled");
            return;
          }
          //Lets display the connected principal!
          console.log(identity.getPrincipal().toText());
          let principal = identity.getPrincipal();
          store.commit("setWallet", "Stoic");
          store.commit("setPrincipal", principal);

          //Create an actor canister
          const actor = Actor.createActor(idlFactory_hub, {
            agent: new HttpAgent({
              identity,
            }),
            canisterId: HUB_CANISTER_ID,
          });
          store.commit("setAuthenticatedActor_hub", actor);
          ledgerActor = createLedgerCanister(new HttpAgent({ identity }));
        });
      } catch (e) {
        alert(e);
        return;
      }
    };

    function changeCaptcha(captcha: string) {
      captchaValid.value = captcha;
    }

    const verification = () => {
      if (!ValidateCaptcha()) {
        alert("Captcha is not valid");
        return;
      }

      if (!email.value || !twitter.value || !discord.value) {
        if (!confirm("You haven't filled all the fields, it's not mandatory but it's recommended for a better experience. \nDo you want to continue anyway?")) {
          return;
        }
      }
      submit();
      return;
    };

    const payment = async () => {
      let wallet = store.getters.getWallet;
      console.log(wallet);
      let transaction;
      if (wallet == "Plug") {
        message.value = "Payment";
        transaction = await pay_plug(subaccount.value, memo.value, 100000000, "p4y2d-yyaaa-aaaaj-qaixa-cai");
      } else if (wallet == "Stoic") {
        message.value = "Payment";
        transaction = await pay_stoic(ledgerActor, subaccount.value, memo.value, 100000000, "p4y2d-yyaaa-aaaaj-qaixa-cai");
      } else {
        throw new Error("Wallet not compatible");
      }
      if (transaction.height == 0) {
        alert("Payment failed");
        message.value = "Error";
        waiting.value = false;
        return;
      } else {
        height.value = BigInt(transaction.height);
        message.value = "Wait...";
        finish();
      }
    };

    const finish = async () => {
      let actor = store.getters.getAuthenticatedActor_hub;
      let result = await actor.confirm(height.value);
      if (result.hasOwnProperty("err")) {
        alert(("Error while confirming your account :" + result.err) as string);
        waiting.value = false;
        message.value = "Error";
        return;
      } else {
        message.value = "Success";
        waiting.value = false;
        joined.value = true;
        return;
      }
    };

    const submit = async () => {
      if (waiting.value) {
        return;
      }
      waiting.value = true;
      message.value = "Sending...";
      const wallet = store.getters.getWallet;
      subaccount.value = getRandomSubaccount();
      if (!confirm("You are about to pay 1 ICP to finalize your inscription, do you confirm ?\nDo not refresh during the process!")) {
        return;
      }

      const actor = store.getters.getAuthenticatedActor_hub;
      message.value = "Joining...";

      const result_prejoin = await actor.prejoin(wallet, [email.value], [discord.value], [twitter.value], subaccount.value);
      if (result_prejoin.hasOwnProperty("err")) {
        alert("Error while prejoin, no payment was sent : " + JSON.stringify(result_prejoin.err));
        waiting.value = false;
        message.value = "Error";
        return;
      } else {
        memo.value = result_prejoin.ok;
        payment();
      }
    };

    const connected = computed(() => store.getters.isHubConnected);

    async function checkRegistration() {
      const registration = await store.getters.getAuthenticatedActor_hub.checkRegistration();
      if (registration) {
        squad_member.value = true;
      }
    }

    watch(connected, (value) => {
      if (connected.value) {
        checkRegistration();
      }
    });

    if (connected.value) {
      checkRegistration();
    }

    return {
      connected,
      joined,
      squad_member,
      waiting,
      message,
      plug,
      stoic,
      email,
      twitter,
      discord,
      verification,
      emailField,
      captchaText,
      changeCaptcha,
      messageFee,
      messageDev,
    };
  },
  components: {
    Captcha,
  },
};
</script>
