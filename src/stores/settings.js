// stores/counter.js
import { useLocalStorage } from '@vueuse/core'
import { defineStore } from 'pinia'

export const useSettingStore = defineStore('settings', {
  state: () => {
    return { 
      data: useLocalStorage('settings', getDefaultSetting()),
      dialog: true,
      ping: -1,
      wsLink: import.meta.env.PROD ? window.location.host : 'localhost:8888'
    }
  },
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
    },
    theme: {
      fullScreenBackground: "#000000",
      ariaBackground: "#606060",
      hideCAria: false
    },
    // Disable Input
    disablePenInput: false,
    disableMouseInput: true,
    disableTouchInput: true,

    language: 'auto',

    fullScreenBtn: true,
    exitFullScreenBtn: true,
    settingBtn: true,
    blockClick: false,
    pressure: true,
    pressureFireFox: false,
    rawInput: true,
    autoReload: true,
    doNotSleep: false,
    alwaysPing: false,
  }
}