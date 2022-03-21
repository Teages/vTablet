<template>
  <div :style="{ opacity: isOpacity ? 0.4 : 1 }" v-show="settings.dialog">
    <div class="w-screen h-screen fixed top-0 left-0 bottom-0 right-0 z-10 bg-white flex flex-col	">
      <div class="navbar bg-base-100">
        <div class="flex-none">
          <button class="btn btn-square btn-ghost" @click="settings.dialog = !settings.dialog">
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
        <div class="flex-none">
          <button class="btn gap-2 btn-ghost" @click="isOpacity = !isOpacity">Preview</button>
        </div>
      </div>
      <div class="max-h-full overflow-y-auto">
        <div class="m-auto max-w-md ">
          <SettingBlock title="控制区域">
            大小
            <input
              v-model="settings.data.aria.size"
              type="range" class="range"
              min="0.01" max="1" step="0.01"
            />
            x 偏移
            <input
              v-model="settings.data.aria.offset.x"
              type="range" class="range"
              min="-1" max="1" step="0.01"
            />
            y 偏移
            <input
              v-model="settings.data.aria.offset.y"
              type="range" class="range"
              min="-1" max="1" step="0.01"
            />
            旋转
            <input
              v-model="settings.data.aria.rotate"
              type="range" class="range"
              min="-90" max="90" step="1"
            />
          </SettingBlock>
          <SettingBlock title="同步设置">
            <div class="card-actions min-w-full flex">
              <button class="btn btn-success flex-1" @click="loadSetting">下载</button>
              <button class="btn btn-warning flex-1" @click="saveSetting">上传</button>
              <button class="btn btn-error flex-1" @click="settings.reset">重置</button>
            </div>
          </SettingBlock>
          <SettingBlock title="UI 设置">
            <SettingSwitch title="显示设置按钮" v-model="settings.data.settingBtn" />
            <SettingSwitch title="显示全屏按钮" v-model="settings.data.fullScreenBtn" />
            <SettingSwitch title="显示退出全屏按钮" v-model="settings.data.exitFullScreenBtn" />
            <SettingSwitch title="隐藏控制区域" v-model="settings.data.hideCAria" />
          </SettingBlock>
          <SettingBlock title="其他设置">
            <SettingSwitch title="屏蔽点击输入" v-model="settings.data.blockClick" />
            <SettingSwitch title="处理压力" v-model="settings.data.pressure" />
          </SettingBlock>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { useSettingStore } from '@/stores/settings'
import { onMounted } from "vue-demi";

import SettingBlock from './Settings/SettingBlock.vue'
import SettingSwitch from './Settings/SettingSwitch.vue'

const settings = useSettingStore()


var ws = null

// onMounted(()=>{

//   console.log("connecting:", `ws://${window.location.host}/ws`)
//   ws = new WebSocket(`ws://${window.location.host}/ws`)

//   ws.addEventListener('open', ()=>{
//     loadSetting(ws)
//   })
//   ws.addEventListener('message', (e)=>{
//     let cloudData = JSON.parse(e.data)
//     console.log(e.data)
//     try {
//       let cloudSetting = JSON.parse(cloudData.setting)
//       console.log(cloudSetting)
//       if (!cloudSetting) throw "no cloud setting";
//       settings.loadSetting(cloudSetting)
//       console.log("loaded from server")
//     } catch (error) {
//       saveSetting(ws)
//       console.error(error)
//     }
//   })
// })

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