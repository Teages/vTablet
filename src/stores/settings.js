// stores/counter.js
import { useLocalStorage } from '@vueuse/core'
import { defineStore } from 'pinia'

export const useSettingStore = defineStore('settings', {
  state: () => {
    return { 
      data: useLocalStorage('settings', getDefaultSetting()),
      dialog: true
    }
  },
  // could also be defined as
  // state: () => ({ count: 0 })
  actions: {
    reset() {
      this.data = getDefaultSetting()
    },
    loadSetting(newSetting) {
      this.data = Object.assign(getDefaultSetting(), this.data, newSetting)
    }
  },
})

function getDefaultSetting() {
  return {
    aria: {
      size: 0.5,
      offset: {
        x: 0,
        y: 0
      },
      rotate: 0,
      scaleResize: 1,
      tolerance: 100
    },
    theme: {
      fullScreenBackground: "#000000",
      ariaBackground: "#606060",
      hideCAria: false
    },
    // Disable Input
    disablePenInput: false,
    disableMouseInput: false,
    disableTouchInput: false,

    language: 'auto',

    fullScreenBtn: true,
    exitFullScreenBtn: true,
    settingBtn: true,
    blockClick: false,
    pressure: false,
    autoReload: true,
  }
}