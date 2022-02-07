<template>
  <div class="flex flex-col">
    <!-- Slot picker -->
    <div class="flex md:flex-row flex-col justify-around gap-x-8">
      <button class="lg:text-3xl md:text-2xl text-xl shadow-2xl font-marker bg-pink rounded py-6 px-8 mt-8 cursor-pointer" :class="picker === 'Hat' ? 'text-black' : 'text-white'" @click="changePicker('Hat')">Hat 🎩</button>
      <button class="lg:text-3xl md:text-2xl text-xl shadow-2xl font-marker bg-pink rounded py-6 px-8 mt-8 cursor-pointer" :class="picker === 'Face' ? 'text-black' : 'text-white'" @click="changePicker('Face')">Face 👦</button>
      <button class="lg:text-3xl md:text-2xl text-xl shadow-2xl font-marker bg-pink rounded py-6 px-8 mt-8 cursor-pointer" :class="picker === 'Eyes' ? 'text-black' : 'text-white'" @click="changePicker('Eyes')">Eyes 👀</button>
      <button class="lg:text-3xl md:text-2xl text-xl shadow-2xl font-marker bg-pink rounded py-6 px-8 mt-8 cursor-pointer" :class="picker === 'Body' ? 'text-black' : 'text-white'" @click="changePicker('Body')">Body 👕</button>
      <button class="lg:text-3xl md:text-2xl text-xl shadow-2xl font-marker bg-pink rounded py-6 px-8 mt-8 cursor-pointer" :class="picker === 'Special' ? 'text-black' : 'text-white'" @click="changePicker('Special')">Special ✨</button>
    </div>
    <div class="flex flex-col items-center justify-around gap-16">
      <accessory-lab v-for="accessory in accessoriesFiltered" :key="accessory.name" :description="accessory.description" :name="accessory.name" :recipe="accessory.blueprint"></accessory-lab>
    </div>
  </div>
</template>

<script lang="ts">
import { defineComponent, ref, computed } from "vue";
import AccessoryLab from "../../components/Lab/AccessoryLab.vue";
import { accessories } from "../../utils/list";

export default defineComponent({
  setup() {
    const picker = ref<string>("Hat");
    const changePicker = (new_picker: string) => {
      picker.value = new_picker;
    };

    const accessoriesFiltered = computed(() => {
      return accessories.filter((accessory) => {
        return accessory.slot === picker.value;
      });
    });
    return { picker, changePicker, accessoriesFiltered };
  },
  components: {
    AccessoryLab,
  },
});
</script>
