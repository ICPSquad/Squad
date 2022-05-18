<script lang="ts">
  export let message: string;
</script>

<div>
  <svg class="spinner" viewBox="0 0 50 50">
    <circle class="path" cx="25" cy="25" r="20" fill="none" stroke-width="5" />
  </svg>
  <p>{message}</p>
</div>

<style lang="scss">
  @use "./src/website/src/styles" as *;

  div {
    position: absolute;
    top: 0;
    left: 0;
    z-index: 99;
    background-color: $black;
    display: flex;
    flex-direction: column;
    justify-content: center;
    align-items: center;
    text-align: center;
    width: 100%;
    height: 100vh;
  }

  p {
    margin-top: 20px;
  }

  .spinner {
    animation: rotate 2s linear infinite;
    z-index: 2;
    margin: 0;
    width: 50px;
    height: 50px;
    & .path {
      stroke: #d51d81;
      stroke-linecap: round;
      animation: dash 1.5s ease-in-out infinite;
    }
  }

  @keyframes rotate {
    100% {
      transform: rotate(360deg);
    }
  }

  @keyframes dash {
    0% {
      stroke-dasharray: 1, 150;
      stroke-dashoffset: 0;
    }
    50% {
      stroke-dasharray: 90, 150;
      stroke-dashoffset: -35;
    }
    100% {
      stroke-dasharray: 90, 150;
      stroke-dashoffset: -124;
    }
  }
</style>
