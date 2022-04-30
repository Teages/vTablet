<template>
  <div class="w-screen h-screen overflow-visible">
    <VTabletCanvas />
  </div>
  <Settings />
  <BtnBox />
</template>

<script setup>
import VTabletCanvas from "./components/VTabletCanvas.vue";
import Settings from "./components/Settings.vue";
import BtnBox from "./components/BtnBox.vue";

import { useSettingStore } from '@/stores/settings'
const settings = useSettingStore()

let serverLink = getQuery('server')
if (serverLink) {
  settings.wsLink = serverLink
}
function getQuery(v) {
  var q = window.location.search.substring(1);
  var vars = q.split("&");
  for (var i = 0; i < vars.length; i++) {
    var pair = vars[i].split("=");
    if (pair[0] == v) {
      return pair[1];
    }
  }
  return null;
}
</script>
