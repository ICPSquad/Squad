<template>
  <connect v-if="!connected"></connect>
  <loading v-else-if="status === 'Loading'"></loading>
  <confirm v-else-if="status === 'NotConfirmed'" :invoice="invoice" @success="success"></confirm>
  <register v-else-if="status === 'NotRegistered'" @submit="submit" :pulse="pulse"></register>
  <member v-else-if="status === 'Member'"></member>
</template>

<script lang="ts">
import { defineComponent, computed, watch, ref } from "vue";
import { useStore } from "vuex";
import Connect from "./Connect.vue";
import Confirm from "./Confirm.vue";
import Member from "./Member.vue";
import Loading from "./Loading.vue";
import Register from "./Register.vue";
import { FormObject, InvoiceInfo } from "types/registration";

export default defineComponent({
  setup() {
    const store = useStore();
    const ledgerActor = computed(() => store.getters.getAuthenticatedActor_ledger);
    const hubActor = computed(() => store.getters.getAuthenticatedActor_hub);
    const invoice = ref<InvoiceInfo | null>(null);

    watch(hubActor, (_) => {
      if (ledgerActor.value && hubActor.value) {
        store.commit("setStatus", "Loading");
      }
      checkStatus();
    });

    async function checkStatus() {
      const actor = store.getters.getAuthenticatedActor_hub;
      console.log("Actor: ", actor);
      const result = await actor.check_status();
      console.log("Result: ", result);
      if (result.hasOwnProperty("Member")) {
        store.commit("setStatus", "Member");
      } else if (result.hasOwnProperty("NotRegistered")) {
        store.commit("setStatus", "NotRegistered");
      } else if (result.hasOwnProperty("NotConfirmed")) {
        invoice.value = result.NotConfirmed;
        store.commit("setStatus", "NotConfirmed");
      } else {
        throw new Error("Unknown status");
      }
    }

    const pulse = ref(false);
    async function sendRegistration(form: FormObject) {
      const wallet = store.getters.getWallet;
      const actor = store.getters.getAuthenticatedActor_hub;
      const result = await actor.register(wallet, form.email != null ? [form.email] : [], form.discord != null ? [form.email] : [], form.twitter != null ? [form.twitter] : []);
      pulse.value = false;
      console.log("Result: ", result);
      if (result.hasOwnProperty("err")) {
        alert(result.err);
      } else {
        invoice.value = result.ok;
        store.commit("setStatus", "NotConfirmed");
      }
    }

    function submit(e) {
      pulse.value = true;
      const form = {
        email: e.email,
        twitter: e.twitter,
        discord: e.discord,
      };
      sendRegistration(form);
    }

    function success() {
      store.commit("setStatus", "Member");
    }

    return {
      status: computed(() => store.getters.getStatus),
      connected: computed(() => store.getters.getAuthenticatedActor_hub != null && store.getters.getAuthenticatedActor_hub != null),
      submit,
      pulse,
      invoice,
      success,
    };
  },
  components: {
    Connect,
    Member,
    Loading,
    Register,
    Confirm,
  },
  inheritAttrs: false,
});
</script>
