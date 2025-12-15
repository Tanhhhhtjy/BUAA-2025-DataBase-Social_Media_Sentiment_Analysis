<template>
  <div class="loading-spinner" :style="{ size: size + 'px' }">
    <div class="spinner" :style="{ borderTopColor: color }"></div>
    <div v-if="text" class="loading-text">{{ text }}</div>
  </div>
</template>

<script setup>
defineProps({
  size: {
    type: Number,
    default: 50
  },
  color: {
    type: String,
    default: '#409EFF'
  },
  text: {
    type: String,
    default: ''
  }
})
</script>

<style scoped>
.loading-spinner {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 20px;
}

.spinner {
  width: 100%;
  height: 100%;
  border: 4px solid #f3f3f3;
  border-radius: 50%;
  border-top: 4px solid transparent;
  animation: spin 1s linear infinite;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

.loading-text {
  margin-top: 10px;
  font-size: 14px;
  color: #909399;
}
</style>
