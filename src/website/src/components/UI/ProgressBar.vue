<template>
  <div class="flex flex-col items-center justify-center w-full">
    <div class="container my-4 md:my-20 w-full mx-auto">
      <ul class="progressbar">
        <li class="active">🕵️</li>
        <li class="active">💰</li>
        <li class="active">⛏</li>
      </ul>
    </div>
  </div>
</template>

<script>
export default {
  data() {
    return {};
  },
};
</script>

<style scoped>
.container {
  position: absolute;
  z-index: 1;
}
.progressbar {
  counter-reset: step;
}
.progressbar li {
  float: left;
  width: 20%;
  text-align: center;
  margin: 0 auto;
}
.progressbar li:before {
  content: counter(step);
  counter-increment: step;
  width: 30px;
  height: 30px;
  border: 2px solid #bebebe;
  display: block;
  margin: 0 auto 10px auto;
  border-radius: 50%;
  line-height: 27px;
  background: white;
  color: #bebebe;
  text-align: center;
  font-weight: bold;
}
.progressbar li:after {
  content: "";
  position: absolute;
  width: 100%;
  height: 3px;
  background: #979797;
  top: 15px;
  left: -50%;
  z-index: -1;
}
.progressbar li.active:before {
  border-color: #d51d81;
  background: #d51d81;
  color: white;
}
.progressbar li.active:after {
  background: #d51d81;
}
.progressbar li.active + li:after {
  background: #d51d81;
}
.progressbar li.active + li:before {
  border-color: #d51d81;
  background: #d51d81;
  color: white;
}
.progressbar li:first-child:after {
  content: none;
}
</style>
