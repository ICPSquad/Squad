<template>
  <div class="flex flex-col flex-1 w-full bg-gradient-to-l from-gray-600 via-gray-900 to-black text-white justify-around">
    <!-- Invoice -->
    <div class="flex flex-col w-full items-center gap-y-4">
      <h2 class="text-3xl font-bold mb-4">Invoice</h2>
    </div>
    <div class="flex flex-col w-full items-center gap-y-4">
      <h2 class="md:text-xl text-sm">
        <i> <u> Id </u> </i> : {{ Number(invoice.id) }}
      </h2>
      <h2 class="md:text-xl text-sm">
        <i> <u> To </u> </i> : {{ invoice.account }}
      </h2>
      <h2 class="md:text-xl text-sm">
        <i> <u> Amount </u> </i> : {{ invoice.amount }} ICP
      </h2>
      <h2 class="md:text-xl text-sm">
        <i> <u> Expiration date </u> </i> : {{ new Date(Number(invoice.expiration) / 1000000).toLocaleString() }}
      </h2>
    </div>

    <!--  Pay -->
    <div class="flex md:flex-row flex-col items-center justify-around">
      <div class="flex flex-col items-center">
        <h2 class="md:text-xl text-sm">👉 Send funds from your wallet.</h2>
        <button class="text-2xl shadow-2xl font-marker text-white bg-pink-600 rounded py-6 px-14 mt-8" @click="pay" :class="pulsePay ? 'animate-pulse' : 'cursor-pointer hover:scale-95'">
          {{ messagePay }}
        </button>
      </div>
      <div class="flex flex-col items-center">
        <h2 class="md:text-xl text-sm">👉 If you have already send funds.</h2>
        <button class="text-2xl shadow-2xl font-marker text-white bg-pink-600 rounded py-6 px-14 mt-8" @click="validate" :class="pulseValidate ? 'animate-pulse' : 'cursor-pointer hover:scale-95'">
          {{ messageValidate }}
        </button>
      </div>
    </div>
    <p class="block mx-auto text-center">
      <a class="mb-12 text-2xl font-normal text-pink-600 hover:text-pink-300 text-center" href="https://discord.com/invite/icpsquad" target="_blank"> 🙋 Click here for support<br /> </a>
    </p>
  </div>
</template>

<script lang="ts">
import { defineComponent, ref } from "vue";
import { useStore } from "vuex";

export default defineComponent({
  props: {
    invoice: {
      type: Object,
      required: true,
    },
  },
  emits: ["success"],
  setup(props, context) {
    const store = useStore();
    const loading = ref<boolean>(false);
    const messagePay = ref<string>("Pay");
    const messageValidate = ref<string>("Validate");
    const pulsePay = ref<boolean>(false);
    const pulseValidate = ref<boolean>(false);

    const pay = async () => {
      if (loading.value) {
        return;
      }
      if (!confirm("You are about to pay 1 ICP from your wallet. .\n\n Are you sure?")) {
        return;
      }
      loading.value = true;
      messagePay.value = "Processing...";
      pulsePay.value = true;
      const wallet = store.getters.getWallet;
      console.log("Wallet: ", wallet);
      if (wallet === "Plug") {
        //@ts-ignore
        try {
          //@ts-ignore
          await window.ic.plug.requestTransfer({
            to: props.invoice.account,
            amount: Number(props.invoice.amount) * 100000000,
            memo: [],
          });
          messagePay.value = "Verification...";
          verify();
        } catch (e) {
          loading.value = false;
          messagePay.value = "Pay";
          pulsePay.value = false;
          alert("Error from Plug wallet.");
          throw e;
        }
      } else if (wallet === "Stoic") {
        const ledgerActor = store.getters.getAuthenticatedActor_ledger;
        let amount_e8s = Number(props.invoice.amount) * 100000000;
        const send_args = {
          to: props.invoice.account,
          fee: { e8s: BigInt(10000) },
          amount: { e8s: BigInt(amount_e8s) },
          from_subaccount: [],
          memo: BigInt(0),
          created_at_time: [],
        };
        try {
          await ledgerActor.send_dfx(send_args);
          messagePay.value = "Verification...";
          verify();
        } catch (e) {
          loading.value = false;
          pulsePay.value = false;
          messagePay.value = "Pay";
          alert("Error from Stoic wallet.");
          throw e;
        }
      } else {
        throw new Error("Unknown wallet");
      }
    };

    const verify = async () => {
      const actorHub = store.getters.getAuthenticatedActor_hub;
      const result = await actorHub.confirm_new();
      if (result.hasOwnProperty("err")) {
        loading.value = false;
        messagePay.value = "Pay";
        pulsePay.value = false;
        alert(result.err);
      } else {
        loading.value = false;
        pulsePay.value = false;
        context.emit("success");
      }
    };

    const validate = async () => {
      if (loading.value) {
        return;
      }
      if (!confirm("This command is used in case you have already send funds, but the transaction hasn't been confirmed yet .\n\nAre you sure?")) {
        return;
      }
      loading.value;
      messageValidate.value = "Checking...";
      pulseValidate.value = true;
      const actorHub = store.getters.getAuthenticatedActor_hub;
      const result = await actorHub.confirm_new();
      if (result.hasOwnProperty("err")) {
        alert(result.err);
        loading.value = false;
        pulseValidate.value = false;
        messageValidate.value = "Validate";
      } else {
        context.emit("success");
      }
    };
    return {
      pay,
      messagePay,
      messageValidate,
      loading,
      validate,
      pulsePay,
      pulseValidate,
    };
  },
});
</script>
