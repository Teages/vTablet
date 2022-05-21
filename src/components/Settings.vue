<template>
  <transition name="fade">
    <div v-show="settings.dialog">
      <div :style="{ opacity: isOpacity ? 0.4 : 1 }" class="transition-opacity">
        <div class="w-screen h-screen fixed top-0 left-0 bottom-0 right-0 z-10 bg-white flex flex-col	">
          <div class="navbar bg-base-100">
            <div class="flex-none">
              <button class="btn btn-circle btn-ghost" @click="closeDialog">
                <svg
                  xmlns="http://www.w3.org/2000/svg"
                  class="h-6 w-6"
                  fill="none"
                  viewBox="0 0 24 24"
                  stroke="currentColor"
                >
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M6 18L18 6M6 6l12 12"
                  />
                </svg>
              </button>
            </div>
            <div class="flex-1">
              <a class="btn btn-ghost normal-case text-xl">vTablet</a>
            </div>
            <div class="flex-none select-none mx-5" style="opacity: 0.8">
              <div :class="'badge gap-2 ' + getDelayColor()">
                <svg style="width:12px;height:12px" viewBox="0 0 24 24">
                  <path fill="currentColor" d="M1,21H21V1" />
                </svg>
                {{ wsDelay }} ms
              </div>
            </div>
          </div>
          <div class="max-h-full overflow-y-auto bg-base-100">
            <div class="m-auto max-w-md my-4">
              <SettingBlock :title="$t(lang, 'controlSizetitle')">
                {{$t(lang, 'size')}} {{settings.data.aria.size * 100}}%
                <input
                  v-model="settings.data.aria.size"
                  type="range" class="range"
                  min="0.01" max="1" step="0.01"
                />
                {{$t(lang, 'offsetxX')}} {{settings.data.aria.offset.x * 100}}%
                <input
                  v-model="settings.data.aria.offset.x"
                  type="range" class="range"
                  min="-1" max="1" step="0.01"
                />
                {{$t(lang, 'offsetxY')}} {{settings.data.aria.offset.y * 100}}%
                <input
                  v-model="settings.data.aria.offset.y"
                  type="range" class="range"
                  min="-1" max="1" step="0.01"
                />
                {{$t(lang, 'rotate')}} {{settings.data.aria.rotate}}°
                <input
                  v-model="settings.data.aria.rotate"
                  type="range" class="range"
                  min="-90" max="90" step="1"
                />
                  <button class="btn flex-1 mt-4" @click="isOpacity = !isOpacity">{{$t(lang, 'preview')}}</button>
              </SettingBlock>
              
              <SettingBlock :title="$t(lang, 'syncSettingsTitle')">
                <div class="card-actions min-w-full flex">
                  <button class="btn btn-success flex-1" @click="loadSetting">{{$t(lang, 'download')}}</button>
                  <button class="btn btn-warning flex-1" @click="saveSetting">{{$t(lang, 'upload')}}</button>
                  <button class="btn btn-error flex-1" @click="settings.reset">{{$t(lang, 'reset')}}</button>
                </div>
              </SettingBlock>

              <SettingBlock :title="$t(lang, 'uiSettingsTitle')">
                <SettingSwitch :title="$t(lang, 'showSettingBtn')" v-model="settings.data.settingBtn" />
                <div v-show="!settings.data.settingBtn" class="alert alert-warning shadow-lg">
                  <div>
                    <svg xmlns="http://www.w3.org/2000/svg" class="stroke-current flex-shrink-0 h-6 w-6" fill="none" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" /></svg>
                    <span>{{$t(lang, 'showSettingHit')}}</span>
                  </div>
                </div>
                <SettingSwitch :title="$t(lang, 'showFullScreenBtn')" v-model="settings.data.fullScreenBtn" />
                <SettingSwitch :title="$t(lang, 'showExitFullScreenBtn')" v-model="settings.data.exitFullScreenBtn" />
                <SettingSwitch :title="$t(lang, 'hideControllAria')" v-model="settings.data.theme.hideCAria" />
              </SettingBlock>

              <SettingBlock :title="$t(lang, 'disableInputTitle')">
                <SettingSwitch :title="$t(lang, 'disableMouseInput')" v-model="settings.data.disableMouseInput" />
                <SettingSwitch :title="$t(lang, 'disablePenInput')" v-model="settings.data.disablePenInput" />
                <SettingSwitch :title="$t(lang, 'disableTouchInput')" v-model="settings.data.disableTouchInput" />
              </SettingBlock>
              
              <SettingBlock :title="$t(lang, 'otherSettingsTitle')">
                <SettingSwitch :title="$t(lang, 'autoReload')" v-model="settings.data.autoReload" />
                <SettingSwitch :title="$t(lang, 'alwaysPing')" v-model="settings.data.alwaysPing" />
                <SettingSwitch :title="$t(lang, 'doNotSleep')" v-model="settings.data.doNotSleep" />
                <SettingSwitch :title="$t(lang, 'blockClick')" v-model="settings.data.blockClick" />
                <SettingSwitch :title="$t(lang, 'handlePressure')" v-model="settings.data.pressure" />
                <div class="alert alert-info shadow-lg">
                  <div>
                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" class="stroke-current flex-shrink-0 w-6 h-6"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path></svg>
                    <span>{{$t(lang, 'vMultiHit')}}</span>
                  </div>
                </div>
                <div v-show="settings.data.pressure">
                  
                  <SettingSwitch :title="$t(lang, 'rawInput')" v-model="settings.data.rawInput" />
                  <SettingSwitch :title="$t(lang, 'handlePressureFirefox')" v-model="settings.data.pressureFireFox" />
                  <div v-show="settings.data.pressureFireFox" class="alert alert-warning shadow-lg mt-2">
                    <div>
                      <svg xmlns="http://www.w3.org/2000/svg" class="stroke-current flex-shrink-0 h-6 w-6" fill="none" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" /></svg>
                      <span>{{$t(lang, 'handlePressureFirefoxHit')}}</span>
                    </div>
                  </div>
                </div>
              </SettingBlock>
              
              <SettingBlock :title="$t(lang, 'infoTitle')">
                {{$t(lang, 'selectLang')}}
                <select v-model="settings.data.language" class="select select-info w-full">
                  <option value="auto"> Auto </option>
                  <option value="en"> English </option>
                  <option value="zh"> 中文 </option>
                </select>

                <div class="flex content-center	justify-between items-center">
                  Version 1.1.9 by @Teages
                  <button class="btn gap-2" @click="toGitHub">
                    <svg class="h-6 w-6" viewBox="0 0 24 24"><path fill="currentColor" d="M12,2A10,10 0 0,0 2,12C2,16.42 4.87,20.17 8.84,21.5C9.34,21.58 9.5,21.27 9.5,21C9.5,20.77 9.5,20.14 9.5,19.31C6.73,19.91 6.14,17.97 6.14,17.97C5.68,16.81 5.03,16.5 5.03,16.5C4.12,15.88 5.1,15.9 5.1,15.9C6.1,15.97 6.63,16.93 6.63,16.93C7.5,18.45 8.97,18 9.54,17.76C9.63,17.11 9.89,16.67 10.17,16.42C7.95,16.17 5.62,15.31 5.62,11.5C5.62,10.39 6,9.5 6.65,8.79C6.55,8.54 6.2,7.5 6.75,6.15C6.75,6.15 7.59,5.88 9.5,7.17C10.29,6.95 11.15,6.84 12,6.84C12.85,6.84 13.71,6.95 14.5,7.17C16.41,5.88 17.25,6.15 17.25,6.15C17.8,7.5 17.45,8.54 17.35,8.79C18,9.5 18.38,10.39 18.38,11.5C18.38,15.32 16.04,16.16 13.81,16.41C14.17,16.72 14.5,17.33 14.5,18.26C14.5,19.6 14.5,20.68 14.5,21C14.5,21.27 14.66,21.59 15.17,21.5C19.14,20.16 22,16.42 22,12A10,10 0 0,0 12,2Z" /></svg>
                    GitHub
                  </button>
                </div>
              </SettingBlock>
            </div>
            <div class="min-h-16 h-24" />
          </div>
        </div>
      </div>
    </div>
  </transition>
</template>

<script setup>
import { useSettingStore } from '@/stores/settings'
import { computed, onMounted, ref } from "vue";
import { $t, autoLang } from '@/locates/main'
import NoSleep from 'nosleep.js';

import SettingBlock from './Settings/SettingBlock.vue'
import SettingSwitch from './Settings/SettingSwitch.vue'

const settings = useSettingStore()

const wsDelay = ref(-1)

var ws = null

var userLanguages = ['en']

var noSleep = new NoSleep()
var isNoSleeping = false

onMounted(()=>{
  settings.loadSetting({})

  userLanguages = navigator.languages
  console.log(userLanguages, lang.value)

  console.log("connecting:", `ws://${settings.wsLink}/ws`)
  ws = new WebSocket(`ws://${settings.wsLink}/ws`)

  const pingPerSecond = () => {
    if (settings.dialog || settings.data.alwaysPing) {
      ping()
    }
    setTimeout(pingPerSecond, 1000);
  }
  
  ws.addEventListener('open', ()=>{
    loadSetting()
    pingPerSecond()
  })
  ws.addEventListener('message', (e)=>{
    let cloudData = JSON.parse(e.data)
    if (cloudData.setting) {
      console.log(cloudData)
      try {
        let cloudSetting = JSON.parse(cloudData.setting)
        console.log(cloudSetting)
        if (!cloudSetting) throw "no cloud setting";
        settings.loadSetting(cloudSetting)
        console.log("loaded from server")
      } catch (error) {
        // saveSetting()
        console.error(error)
      }
    } else if (cloudData.pong) {
      pong(cloudData.pong.time)
    }
  })
})

function loadSetting() {
  return ws.send(JSON.stringify({
    type: "load_setting"
  }))
}
function saveSetting() {
  return ws.send(JSON.stringify({
    type: "save_setting",
    setting: JSON.stringify(settings.data)
  }))
}
function toGitHub() {
  window.open('https://github.com/Teages/vTablet', '__blank')
}

const lang = computed(() => {
  if (settings.data.language && settings.data.language != 'auto') {
    return settings.data.language
  }
  return autoLang(userLanguages)
})

function closeDialog() {
  settings.dialog = false
  if (settings.data.doNotSleep && (!isNoSleeping)) {
    noSleep.enable()
    isNoSleeping = true
  } else if ((!settings.data.doNotSleep) && isNoSleeping) {
    noSleep.disable()
  }
}

function ping() {
  // console.log("ping")
  return ws.send(JSON.stringify({
    type: "ping",
    time: (new Date()).getTime() % 2147483647
  }))
}
function pong(time) {
  wsDelay.value = Math.round(((new Date()).getTime() % 2147483647 - time) / 2)
  settings.ping = wsDelay.value
}
function getDelayColor() {
  let delay = wsDelay.value
  if (delay > 200 || delay < 0) {
    return 'badge-error'
  }
  if (delay > 30) {
    return 'badge-warning'
  }
  return 'badge-success'

}
</script>

<script>
export default {
  data: () => {
    return {
      isOpacity: false
    }
  }
}
</script>

<style scoped>
.fade-enter-active,
.fade-leave-active {
  @apply transition-opacity;
}

.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}

</style>