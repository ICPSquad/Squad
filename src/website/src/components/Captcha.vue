<template>
  <div class="flex flex-row justify-center">
    <div ref="captcha" class="mx-auto"></div>
  </div>
</template>

<script>
import svgCaptcha from "svg-captcha-browser";
import { onMounted, ref } from "@vue/runtime-core";

export default {
  setup(props, context) {
    const captcha = ref(null);
    let text = "err";
    function createCaptcha(context) {
      svgCaptcha
        .loadFont("others/fonts/Comismsh.ttf")
        .then(() => {
          svgCaptcha.options.width = 300;
          svgCaptcha.options.height = 160;
          svgCaptcha.options.fontSize = 150;
          let cap = svgCaptcha.create({ color: true, noise: 4 });
          // {data: '<svg.../svg>', text: 'abcd'}
          let svg = document.createElementNS(
            "http://www.w3.org/2000/svg",
            "svg"
          );
          svg.innerHTML = cap.data;
          text = cap.text;
          context.emit("newCaptcha", text);
          //@ts-ignore
          captcha.value.appendChild(svg);

          //   registerEmailField()
        })
        .catch((e) => {
          console.log(e);
        });
    }
    onMounted(() => {
      createCaptcha(context);
    });

    return { captcha };
  },
};
</script>
