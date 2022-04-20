<template>
  <div class="flex flex-col relative">
    <nav class="flex flex-row w-full py-2 px-4 bg-black md:py-4 md:px-12 justify-between items-center">
      <h1 class="text-left font-marker text-xl md:text-xl lg:text-3xl 2lg:text-5xl font-bold cursor-pointer text-white">
        <router-link to="/"> ICP Squad </router-link>
      </h1>
      <div class="flex-row gap-x-3 xl:gap-x-6 hidden lg:flex">
        <router-link to="/"><button-cypher class="h-12 xl:w-44 xl:h-12 px-4" text="Avatar 👤"></button-cypher></router-link>
        <router-link to="/"> <button-cypher class="h-12 xl:w-44 xl:h-12 px-4" text="Accessory 🧢"></button-cypher></router-link>
        <router-link to="/"> <button-cypher class="h-12 xl:w-44 xl:h-12 px-4" text="Mission 🎲"></button-cypher></router-link>
        <router-link to="/">
          <button-cypher class="block h-12 xl:w-44 xl:h-12 px-4" text="Education 💡"></button-cypher>
        </router-link>
      </div>

      <!-- Hamburger menu goes here -->
      <div class="lg:hidden block">
        <div class="menu-btn" @click="toggleMenu" :class="{ open: menuMobile }">
          <div class="menu-btn__burger"></div>
        </div>
      </div>
      <!-- Mobile menu goes here  -->
    </nav>
    <sidebar v-if="menuMobile" />
  </div>
</template>

<script>
import Sidebar from "./Sidebar.vue";
import ButtonCypher from "./Button/ButtonCypher.vue";
import RoundedButton from "./Button/RoundedButton.vue";
import { ref } from "vue";
export default {
  components: {
    Sidebar,
    ButtonCypher,
    RoundedButton,
  },
  setup() {
    const menuMobile = ref(false);
    const menuLearn = ref(false);
    const toggleMenu = () => {
      menuMobile.value = !menuMobile.value;
    };

    // Take care of when user click on something or click away
    return {
      menuMobile,
      menuLearn,
      toggleMenu,
    };
  },
};
</script>

<style scoped>
.menu-btn {
  position: relative;
  display: flex;
  justify-content: center;
  align-items: center;
  width: 60px;
  height: 60px;
  cursor: pointer;
  transition: all 0.3s ease-in-out;
}
.menu-btn__burger {
  width: 45px;
  height: 6px;
  background: #fff;
  border-radius: 5px;
  box-shadow: 0 2px 5px rgba(255, 101, 47, 0.2);
  transition: all 0.3s ease-in-out;
}
.menu-btn__burger::before,
.menu-btn__burger::after {
  content: "";
  position: absolute;
  width: 45px;
  height: 6px;
  background: #fff;
  border-radius: 5px;
  box-shadow: 0 2px 5px rgba(255, 101, 47, 0.2);
  transition: all 0.3s ease-in-out;
}
.menu-btn__burger::before {
  transform: translateY(-16px);
}
.menu-btn__burger::after {
  transform: translateY(16px);
}
/* ANIMATION */
.menu-btn.open .menu-btn__burger {
  transform: translateX(-45px);
  background: transparent;
  box-shadow: none;
}
.menu-btn.open .menu-btn__burger::before {
  transform: rotate(45deg) translate(35px, -35px);
}
.menu-btn.open .menu-btn__burger::after {
  transform: rotate(-45deg) translate(35px, 35px);
}
</style>
