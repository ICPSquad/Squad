<template>
  <div class="flex flex-col flex-1 w-full bg-gradient-to-l from-gray-600 via-gray-900 to-black text-white justify-around">
    <!-- Invoice -->
    <div class="flex flex-col w-full items-center gap-y-4">
      <h2 class="text-5xl font-bold mb-8">Invoice 💸</h2>
    </div>
    <div class="flex flex-col w-full items-center gap-y-4">
      <h2 class="text-3xl">Id : {{ id }}</h2>
      <h2 class="text-3xl">Account : {{ account }}</h2>
      <h2 class="text-3xl">Amount : {{ amount }} ICP</h2>
      <h2 class="text-3xl">Expiration date : {{ amount }}</h2>
    </div>

    <!--  Pay -->
    <div class="flex flex-col items-center justify-center">
      <button class="lg:text-3xl md:text-2xl text-xl shadow-2xl font-marker text-white bg-pink-600 rounded py-6 px-14 mt-8 cursor-pointer" @click="pay">Pay</button>
    </div>
    <!--  Help  -->
  </div>
</template>

<script lang="ts">
import { defineComponent } from "vue";

export default defineComponent({
  props: {
    id: {
      type: Number,
      required: false,
      default: 0,
    },
    account: {
      type: String,
      required: true,
    },
    amount: {
      type: Number,
      required: false,
      default: 0,
    },
    date: {
      type: String,
      required: false,
      default: "",
    },
  },
  setup() {},
});
</script>
