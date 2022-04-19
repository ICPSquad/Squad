<template>
  <div class="flex flex-col items-center justify-around flex-1">
    <div>
      <div class="flex flex-col justify-center items-center">
        <h3 class="w-2/3 mx-auto text-center lg:text-3xl md:text-2xl text-xl font-bold mt-24 text-gray-800">
          Make sure you have a stable internet connection and that you have checked the article or the video.
          <br />
          <br />
          ⚠️ Do not refresh during the process of you'll have to reconnect and start again.
        </h3>
        <div class="flex flex-row justify-around w-2/3">
          <button class="lg:text-3xl md:text-2xl text-xl shadow-2xl font-bold font-marker text-gray-800 bg-pink-600 rounded py-6 px-8 mt-16 cursor-pointer">
            <a href="" target="_blank"> Article 🗞 </a>
          </button>
          <button class="lg:text-3xl md:text-2xl text-xl shadow-2xl text-gray-800 bg-pink-600 rounded font-bold font-marker py-6 px-8 mt-16 cursor-pointer">
            <a href="" target="_blank"> Video 📽 </a>
          </button>
        </div>
      </div>
    </div>
    <router-link to="/avatar">
      <button class="lg:text-5xl md:text-2xl📽 text-xl shadow-2xl font-marker text-white bg-pink-600 rounded py-8 px-24 mt-8 cursor-pointer">Start</button>
    </router-link>
  </div>
</template>
