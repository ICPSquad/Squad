<template>
  <div class="sliderContainer">
    <input
      type="range"
      min="1"
      max="100"
      ref="slider"
      value="100"
      class="slider"
      @input="onInput"
    />
  </div>
  <p class="text-gray-800 font-bold text-center text-base md:text-2xl">
    Value :
    <span ref="output"></span>
  </p>
</template>

<script>
import { ref } from "@vue/reactivity";
import { onMounted } from "@vue/runtime-core";
import { useStore } from "vuex";
import { changeCSSOpacity } from "../../types/color";
export default {
  setup() {
    const slider = ref();
    const output = ref();

    const store = useStore();

    const onInput = () => {
      output.value.innerHTML = slider.value.value;
      let x = slider.value.value;
      var color =
        "linear-gradient(90deg, #d51d81 " +
        x +
        "%, rgb(214,214,214) " +
        x +
        "%)";
      slider.value.style.background = color;

      // For this app
      store.commit("setBackgroundOpacity", x);
      changeCSSOpacity(x / 100);
    };

    onMounted(() => {
      output.value.innerHTML = slider.value.value;
    });
    return {
      slider,
      output,
      onInput,
    };
  },
};
</script>

<style scoped>
.sliderContainer {
  width: 50%;
  margin-top: 30px;
}

.slider {
  -webkit-appearance: none;
  width: 100%;
  height: 30px;
  background: #d51d81;
  outline: none;
  opacity: 0.7;
  -webkit-transition: 0.2s;
  transition: opacity 0.2s;
  border-radius: 12px;
  box-shadow: 0px 1px 10px 1px black;
}

.slider:hover {
  opacity: 1;
}
.slider::-webkit-slider-thumb {
  -webkit-appearance: none;
  appearance: none;
  width: 40px;
  height: 40px;
  background: white;
  cursor: pointer;
  border-radius: 50%;
}

p {
  margin-top: 10px;
  opacity: 0.7;
}
</style>
