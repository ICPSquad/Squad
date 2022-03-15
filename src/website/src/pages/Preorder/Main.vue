<template>
  <connect v-if="!connected"></connect>
  <member v-else-if="connected && status === 'member'"></member>
  <loading v-if="connected && status === 'loading'"></loading>
</template>

<script lang="ts">
import { defineComponent, computed, watch } from "vue";
import { useStore } from "vuex";
import Connect from "./Connect.vue";
import Confirm from "./Connect.vue";
import Member from "./Member.vue";
import Loading from "./Loading.vue";

export default defineComponent({
  setup() {
    const store = useStore();
    const ledgerActor = computed(() => store.getters.getAuthenticatedActor_ledger);
    const hubActor = computed(() => store.getters.getAuthenticatedActor_hub);

    watch(ledgerActor, (_) => {
      if (ledgerActor.value && hubActor.value) {
        store.commit("setStatus", "loading");
      }
      checkStatus();
    });

    async function checkStatus() {
      const result = await store.getters.getAuthenticatedActor_hub.check_status();
      if (result.hasOwnProperty === "member") {
        store.commit("setStatus", "member");
      } else if (result.hasOwnProperty === "notRegistered") {
        store.commit("setStatus", "notRegistered");
      } else if (result.hasOwnProperty === "notConfirmed") {
        store.commit("setStatus", "notConfirmed");
      } else {
        throw new Error("Unknown status");
      }
    }

    return {
      status: computed(() => store.getters.getStatus),
      connected: computed(() => store.getters.getAuthenticatedActor_hub != null && store.getters.getAuthenticatedActor_hub != null),
    };
  },
  components: {
    Connect,
    Confirm,
    Member,
    Loading,
  },
  inheritAttrs: false,
});
</script>
