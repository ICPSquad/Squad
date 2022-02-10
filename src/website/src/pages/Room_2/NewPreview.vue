<template>
  <!-- Not connected -->
  <div class="flex flex-col" v-if="!connected">
    <room-connexion></room-connexion>
  </div>
  <!-- Not loaded -->
  <div class="flex flex-col" v-else-if="!loaded">
    <loading-avatar></loading-avatar>
  </div>
  <!-- Room -->
  <div class="flex lg:flex-row flex-col min-h-screen justify-around" v-else>
    <div class="flex flex-col lg:w-1/2 lg:border-r-4 border-b-4 lg:border-b-0 border-gray-500">
      <avatar :body_name="body_name" :layers="layers" :style="style"></avatar>
      <!-- <slot-component></slot-component> -->
    </div>
  </div>
</template>

<script lang="ts">
import { defineComponent, computed } from "vue";
import { useStore } from "vuex";
import RoomConnexion from "../../components/Connexion/RoomConnexion.vue";
import LoadingAvatar from "./LoadingAvatar.vue";
import Avatar from "./Avatar.vue";
import SlotComponent from "./Slots.vue";

export default defineComponent({
  setup() {
    const store = useStore();

    //  Not reactive
    // const { token_identifier, layers, slots, body_name, style } = store.state.auth.avatarPreview;
    // const inventory = store.state.auth.inventory;

    return {
      connected: computed(() => store.getters.isRoomConnected),
      loaded: computed(() => store.state.auth.avatarPreview),
      token_identifier: computed(() => store.state.auth.avatarPreview.token_identifier),
      layers: computed(() => store.state.auth.avatarPreview.layers),
      slots: computed(() => store.state.auth.avatarPreview.slots),
      body_name: computed(() => store.state.auth.avatarPreview.body_name),
      style: computed(() => store.state.auth.avatarPreview.style),
      inventory: computed(() => store.state.auth.inventory),
    };
  },
  components: {
    RoomConnexion,
    LoadingAvatar,
    Avatar,
    SlotComponent,
  },
});
</script>
