<template>
  <div class="h-screen w-screen overflow-visible select-none touch-none bg-black">
    <div id="box" :style="boxCSS">
      <div id="aria" :style="ariaCSS" class=" hover:opacity-80">
      </div>
    </div>
  </div>
  <div v-if="settings.data.alwaysPing" class="fixed bottom-8 left-4">
    <div class="flex-none select-none mx-5" style="opacity: 0.3">
      <div :class="'badge gap-2 ' + getDelayColor()">
        <svg style="width:12px;height:12px" viewBox="0 0 24 24">
          <path fill="currentColor" d="M1,21H21V1" />
        </svg>
        {{ settings.ping }} ms
      </div>
    </div>
  </div>
</template>

<script setup>
import { computed, onMounted, ref } from "vue"
import { useSettingStore } from '@/stores/settings'
const settings = useSettingStore()

const screen = ref({
  height: 1,
  width: 1
})
let serverScale = ref(16 / 9)

const scale = computed(() => {
  return serverScale.value * (settings.data.aria.scaleResize || 1)
})

const maxAriaWidth = computed(() => {
  return Math.min(screen.value.width, screen.value.height * scale.value)
})
const maxAriaHeight = computed(() => {
  return maxAriaWidth.value / scale.value
})
const ariaWidth = computed(() => {
  return maxAriaWidth.value * settings.data.aria.size
})
const ariaHeight = computed(() => {
  return ariaWidth.value / scale.value
})
const boxWidth = computed(() => {
  return screen.value.width * 2 - ariaWidth.value
})
const boxHeight = computed(() => {
  return screen.value.height * 2 - ariaHeight.value
})

const boxCSS = computed(() => {
  let offsetX = (screen.value.width - boxWidth.value) * (1 - settings.data.aria.offset.x) / 2
  let offsetY = (screen.value.height - boxHeight.value) * (1 - settings.data.aria.offset.y) / 2
  return {
    width: `${boxWidth.value}px`,
    height: `${boxHeight.value}px`,
    background: settings.data.theme.fullScreenBackground,
    display: "flex",
    "justify-content": "center",
    "align-items": "center",
    "align-content": "center",
    position: "fixed",
    transform: `translate(${offsetX}px, ${offsetY}px) rotate(${settings.data.aria.rotate}deg)`,
    "transform-origin": "center",
  }
})
const ariaCSS = computed(() => {
  return {
    width: `${ariaWidth.value}px`,
    height: `${ariaHeight.value}px`,
    background: (settings.data.theme.hideCAria && !settings.dialog) ? '#00000000' : settings.data.theme.ariaBackground,
    // background: settings.data.theme.ariaBackground,
    // opacity: (settings.data.theme.hideCAria && !settings.dialog) ? '0' : '1'
  }
})

let firefoxPenLastTime = 0
const firefoxPenLimit = 1000/30

onMounted(() => {
  syncServerData()
  resize()
  window.addEventListener('resize', () => resize)
  window.onresize = resize

  console.log("connecting:", `ws://${settings.wsLink}/ws`)
  let ws = new WebSocket(`ws://${settings.wsLink}/ws`)
  ws.addEventListener('close', (e) => {
    if (settings.data.autoReload) {
      // alert("连接丢失, 需要刷新.")
      location.reload();
    }
  })


  let box = document.getElementById('box')
  let aria = document.getElementById('aria')
  box.addEventListener('pointermove', e => {
    if (!settings.data.rawInput) {
      pointerEventHandle(e, ws)
    }
  })
  box.addEventListener('pointerrawupdate', e => {
    if (settings.data.rawInput) {
      pointerEventHandle(e, ws)
    }
  })
  aria.addEventListener('pointerdown', e => pointerDown(e, ws))
  box.addEventListener('pointerup', e => pointerUp(e, ws))
})
function pointerEventHandle(event, ws) {
  if (!preCheck(event)) {
    return
  }
  let box = document.getElementById('box')
  let aria = document.getElementById('aria')
  let ox = event.offsetX
  let oy = event.offsetY
  if (event.target != aria) {
    ox = event.offsetX - (boxWidth.value - ariaWidth.value) / 2
    oy = event.offsetY - (boxHeight.value - ariaHeight.value) / 2
  }
  let x = ox / aria.offsetWidth
  let y = oy / aria.offsetHeight
  // Limit x & y
  if (x < 0 || x > 1) {
    // Move Coordinate System
    x -= 0.5
    y -= 0.5

    let newX = 0.5 * (x / Math.abs(x))
    let newY = y / x * newX

    // Fix Coordinate System
    x = newX + 0.5
    y = newY + 0.5
  }
  if (y < 0 || y > 1) {
    // Move Coordinate System
    x -= 0.5
    y -= 0.5

    let newY = 0.5 * (y / Math.abs(y))
    let newX = x / y * newY

    // Fix Coordinate System
    x = newX + 0.5
    y = newY + 0.5
  }
  // console.log(x, y)
  if (settings.data.pressureFireFox == true && settings.data.pressure == true) {
    // console.log(event)
    let type = event.pointerType.toLowerCase()
    if (type == 'mouse') {
      firefoxPenLastTime = Date.now()
      sendMsg({
        type: 'digi',
        x: Math.round(x * 32767),
        y: Math.round(y * 32767),
        pressure: event.pressure,
        bottom: event.pressure > 0 ? 0x21 : 0x20
      }, ws)
    } else if (type == 'touch') {
      console.log(firefoxPenLastTime, firefoxPenLimit, firefoxPenLastTime + firefoxPenLimit - Date.now(), (firefoxPenLastTime + firefoxPenLimit) > Date.now())
      if ((firefoxPenLastTime + firefoxPenLimit) > Date.now()) {
        firefoxPenLastTime = Date.now()
        sendMsg({
          type: 'digi',
          x: Math.round(x * 32767),
          y: Math.round(y * 32767),
          pressure: event.pressure,
          bottom: event.pressure > 0 ? 0x21 : 0x20
        }, ws)
      }
    }
    return
  }
  if (event.pointerType.toLowerCase() == 'pen' && settings.data.pressure == true) {
    sendMsg({
      type: 'digi',
      x: Math.round(x * 32767),
      y: Math.round(y * 32767),
      pressure: event.pressure,
      bottom: event.pressure > 0 ? 0x21 : 0x20
    }, ws)
  } else {
    sendMsg({
      type: 'move',
      x: x,
      y: y
    }, ws)
  }

}
function pointerDown(event, ws) {
  if (!preCheck(event)) {
    return
  }
  if ((settings.data.pressureFireFox == true && settings.data.pressure == true)) {
    return
  }
  if (event.pointerType.toLowerCase() == 'pen' && settings.data.pressure == true) {
    return
  }
  if (settings.data.blockClick) {
    return 
  }
  sendMsg({
    type: 'click',
    action: 'down'
  }, ws)
}
function pointerUp(event, ws) {
  if (!preCheck(event)) {
    return
  }
  if ((settings.data.pressureFireFox == true && settings.data.pressure == true)) {
    return
  }
  if (event.pointerType.toLowerCase() == 'pen' && settings.data.pressure == true) {
  return
  }
  sendMsg({
    type: 'click',
    action: 'up'
  }, ws)
}
function sendMsg(msgObj, ws) {
  try {
    ws.send(JSON.stringify(msgObj))
  } catch (error) {
    console.error(error)
  }
}
function preCheck(event) {
  let type = event.pointerType.toLowerCase()
  if (settings.data.pressureFireFox == true && settings.data.pressure == true) {
    return true
  } 
  if (type == 'pen' && settings.data.disablePenInput) {
    return false
  }
  if (type == 'mouse' && settings.data.disableMouseInput) {
    return false
  }
  if (type == 'touch' && settings.data.disableTouchInput) {
    return false
  }
  return true
}
function resize() {
  screen.value.height = window.innerHeight
  screen.value.width = window.innerWidth
}
function syncServerData(times = 5) {
  let serverUrl = settings.wsLink
  let xhr = new XMLHttpRequest();
  xhr.open('GET', `http://${serverUrl}/server-data`, false)
  xhr.onload = function() {
    if (xhr.status != 200) {
      syncServerData(times - 1)
    } else {
      let serverData = JSON.parse(xhr.response)
      console.log(serverData)
      serverScale.value = serverData.screen.width / serverData.screen.height
    }
  }
  xhr.onerror = function() {
    if (times > 0) {
      syncServerData(times - 1)
    }
  }
  xhr.send()
}

function getDelayColor() {
  let delay = settings.ping
  if (delay > 200 || delay < 0) {
    return 'badge-error'
  }
  if (delay > 30) {
    return 'badge-warning'
  }
  return 'badge-success'

}
</script>
