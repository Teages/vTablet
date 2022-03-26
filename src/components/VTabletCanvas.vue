<template>
  <div class="h-screen w-screen overflow-visible select-none touch-none bg-black">
    <div id="box" :style="boxCSS">
      <div id="aria" :style="ariaCSS">
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
let scale = ref(16 / 9)

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
    background: settings.data.theme.ariaBackground,
    opacity: (settings.data.theme.hideCAria && !settings.dialog) ? '0' : '1'
  }
})

onMounted(() => {
  resize()
  window.addEventListener('resize', () => resize)
  window.onresize = resize

  console.log("connecting:", `ws://${import.meta.env.PROD ? window.location.host : 'localhost:8888'}/ws`)
  let ws = new WebSocket(`ws://${import.meta.env.PROD ? window.location.host : 'localhost:8888'}/ws`)
  ws.addEventListener('close', (e) => {
    if (settings.data.autoReload) {
      alert("连接丢失, 需要刷新.")
      console.error("连接丢失, 需要刷新.")
      location.reload();
    }
  })


  let box = document.getElementById('box')
  let aria = document.getElementById('aria')
  box.addEventListener('pointermove', e => pointerEventHandle(e, ws))
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
</script>
