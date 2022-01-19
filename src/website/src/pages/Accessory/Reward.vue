<template>
  <div
    class="
      flex
      md:flex-row
      flex-col
      justify-around
      items-center
      w-full
      gap-x-20 gap-y-8
      px-25
      md:px-8
    "
  >
    <div class="w-1/2 md:w-2/3">
      <img
        :src="`cards/materials/${airdrop.material}.svg`"
        alt="material_reward"
      />
    </div>
    <div v-if="airdrop.accessory1.length > 0" class="w-1/2 md:w-2/3">
      <img
        :src="`cards/accessories/${airdrop.accessory1[0]}.svg`"
        alt="accessory1_reward"
      />
    </div>
    <div v-if="airdrop.accessory2.length > 0" class="w-1/2 md:w-2/3">
      <img
        :src="`cards/accessories/${airdrop.accessory2[0]}.svg`"
        alt="accessory2_reward"
      />
    </div>
  </div>
</template>

<script>
export default {
  props: ["airdrop_object"],
  setup(props) {
    const airdrop = props.airdrop_object;
    return { airdrop };
  },
};
</script>
