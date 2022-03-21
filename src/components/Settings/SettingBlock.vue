<template>
  <h2 class="card-title">{{ title }}</h2>
  <div class="card bg-base-100 shadow-xl mb-8">
    <div class="card-body">
      <slot></slot>
    </div>
  </div>
</template>

<script setup>

const props = defineProps({
  title: String
})
</script>