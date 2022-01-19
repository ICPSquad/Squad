<template>
  <section>
    <div class="box">
      <div class="circle"></div>
      <div class="circle"></div>
      <div class="dot" style="--i: 0"></div>
      <div class="dot" style="--i: 1"></div>
      <div class="dot" style="--i: 2"></div>
      <div class="dot" style="--i: 3"></div>
      <div class="dot" style="--i: 4"></div>
      <div class="dot" style="--i: 5"></div>
      <div class="dot" style="--i: 6"></div>
      <div class="dot" style="--i: 7"></div>
      <div class="dot" style="--i: 8"></div>
      <div class="dot" style="--i: 9"></div>
      <div class="dot" style="--i: 10"></div>
      <div class="dot" style="--i: 11"></div>
      <div class="dot" style="--i: 12"></div>
      <div class="dot" style="--i: 13"></div>
      <div class="dot" style="--i: 14"></div>
      <div class="dot" style="--i: 15"></div>
      <div class="dot" style="--i: 16"></div>
      <div class="dot" style="--i: 17"></div>
      <div class="dot" style="--i: 18"></div>
      <div class="dot" style="--i: 19"></div>
      <div class="dot" style="--i: 20"></div>
      <div class="dot" style="--i: 21"></div>
      <div class="dot" style="--i: 22"></div>
      <div class="dot" style="--i: 23"></div>
      <div class="dot" style="--i: 24"></div>
      <div class="dot" style="--i: 25"></div>
      <div class="dot" style="--i: 26"></div>
      <div class="dot" style="--i: 27"></div>
      <div class="dot" style="--i: 28"></div>
      <div class="dot" style="--i: 29"></div>
      <div class="dot" style="--i: 30"></div>
      <div class="dot" style="--i: 31"></div>
      <div class="dot" style="--i: 32"></div>
      <div class="dot" style="--i: 33"></div>
      <div class="dot" style="--i: 34"></div>
      <div class="dot" style="--i: 35"></div>
      <div class="dot" style="--i: 36"></div>
    </div>
  </section>
</template>

<style scoped>
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

section {
  display: flex;
  justify-content: center;
  min-height: 10vh;
  align-items: center;
  margin-top: 20px;
}

.box {
  position: relative;
  width: 360px;
  height: 200px;
  display: flex;
  justify-content: center;
  align-items: center;
}

.circle {
  position: relative;
  width: 200px;
  height: 200px;
  margin: 0 -20px;
  border: 40px solid #000;
  border-radius: 50%;
}

.dot {
  position: absolute;
  width: 40px;
  height: 40px;
  border-radius: 50%;
  left: 50%;
  top: 50%;
  transform: translateY(-50%);
  animation: animatedot 4s linear calc(-0.03s * var(--i)) infinite,
    color 4s linear infinite;
}

@keyframes animatedot {
  0% {
    transform-origin: 100px 50%;
    transform: translate(-50%, -50%) rotate(0deg);
  }
  50% {
    transform-origin: 100px 50%;
    transform: translate(-50%, -50%) rotate(360deg);
  }
  50.0001% {
    transform-origin: -60px 50%;
    transform: translate(-50%, -50%) rotate(360deg);
  }
  75% {
  }
  100% {
    transform-origin: -60px 50%;
    transform: translate(-50%, -50%) rotate(0deg);
  }
}

@keyframes color {
  0% {
    background: rgb(241, 90, 36);
    box-shadow: 0 0 25px rgb(241, 90, 36);
  }
  24% {
    background: rgb(251, 177, 58);
    box-shadow: 0 0 25px rgb(251, 177, 58);
  }
  25% {
    background: rgb(41, 171, 226);
    box-shadow: 0 0 25px rgb(41, 171, 226);
  }
  66% {
    background: rgb(91, 39, 133);
    box-shadow: 0 0 25px rgb(91, 39, 133);
  }
  95% {
    background: rgb(237, 30, 121);
    box-shadow: 0 0 25px rgb(237, 30, 121);
  }
  100% {
    background: rgb(241, 90, 36);
    box-shadow: 0 0 25px rgb(241, 90, 36);
  }
}
</style>
