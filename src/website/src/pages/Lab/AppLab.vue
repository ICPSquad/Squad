<template>
  <div>
    <div class="flex flex-col items-center py-8">
      <h2 class="text-center 2xl:text-5xl lg:text-4xl md:text-3xl text-2xl font-bold text-gray-800 font-marker mt-8">Welcome to the Lab 🧑‍🔬 !</h2>
      <h3 class="w-2/3 md:w-1/2 mx-auto text-center lg:text-3xl md:text-2xl text-xl font-bold mt-16 text-gray-800">
        Here you can create new fancy accessories directly from your materials.
        <br />
      </h3>
    </div>
    <div class="grid grid-cols-1 md:grid-cols-3">
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

<style scoped>
.fuck {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
}
</style>
