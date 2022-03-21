<template>
  <div class="w-screen h-screen overflow-visible">
    <VTabletCanvas />
  </div>
  <Settings />
  <BtnBox />
</template>

<script setup>
import VTabletCanvas from './components/VTabletCanvas.vue';
import Settings from './components/Settings.vue';
import BtnBox from './components/BtnBox.vue';
</script>
