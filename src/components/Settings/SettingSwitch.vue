<template>
  <div class="form-control">
    <label class="label cursor-pointer">
      <span class="label-text">{{ title }}</span> 
      <input type="checkbox" class="toggle" :checked="modelValue" @input="updateValue($event)">
    </label>
  </div>
</template>

<script>
export default {
  model: {
    prop: "modelValue",
    event: "update"
  },
  props: {
    modelValue: Boolean,
    title: String,
  },
  methods: {
    updateValue(e) {
      this.$emit('update:modelValue', e.target.checked)
    } 
  }
}
</script>

<style>

</style>