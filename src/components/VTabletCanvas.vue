<template>
  <div class="h-screen w-screen overflow-visible select-none touch-none bg-black">
    <div id="box" :style="boxCSS">
      <div id="aria" :style="ariaCSS">
        {{boxCSS}}
      </div>
    </div>
  </div>
</template>

<script setup>
import { computed, onMounted, ref } from "@vue/runtime-core"
const settings = {
  data: {
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
      hideAria: false
    },
  }
}
const screen = ref({
  height: 1,
  width: 1
})
let scale = (16 / 9)

const maxAriaWidth = computed(() => {
  return Math.min(screen.value.width, screen.value.height * scale)
})
const maxAriaHeight = computed(() => {
  return maxAriaWidth.value / scale
})
const ariaWidth = computed(() => {
  return maxAriaWidth.value * settings.data.aria.size
})
const ariaHeight = computed(() => {
  return ariaWidth.value / scale
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
    background: settings.data.theme.ariaBackground
  }
})

onMounted(() => {
  resize()
  window.addEventListener('resize', () => resize)
  window.onresize = resize

  let box = document.getElementById('box')
  box.addEventListener('pointermove', e => pointerEventHandle(e))
  box.addEventListener('pointerdown', e => pointerEventHandle(e))
  box.addEventListener('pointerup', e => pointerEventHandle(e))
})
function pointerEventHandle(event) {
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
  console.log(x, y)
}
function resize() {
  screen.value.height = window.innerHeight
  screen.value.width = window.innerWidth
}
</script>
