<template>
  <div class="flex flex-col flex-1 min-h-screen">
    <the-header></the-header>
    <router-view class="flex-1"></router-view>
    <the-footer></the-footer>
  </div>
</template>

<script lang="ts">
import { defineComponent } from "vue";
import TheHeader from "./components/Header.vue";
import Sidebar from "./components/Sidebar.vue";
import TheFooter from "./components/Footer.vue";

export default defineComponent({
  components: {
    TheHeader,
    TheFooter,
    Sidebar,
  },
});
</script>

<style>
button:hover {
  transform: scale(0.95);
}

* {
  box-sizing: border-box;
  margin: 0;
  padding: 0;
}
</style>
