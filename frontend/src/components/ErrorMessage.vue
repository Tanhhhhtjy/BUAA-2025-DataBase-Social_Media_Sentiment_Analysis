<template>
  <div class="error-message">
    <el-icon class="error-icon" :size="iconSize">
      <CircleClose />
    </el-icon>
    <div class="error-content">
      <div class="error-title">{{ title }}</div>
      <div class="error-description">{{ description }}</div>
      <el-button v-if="showRetry" type="primary" @click="$emit('retry')" size="small">
        重试
      </el-button>
    </div>
  </div>
</template>

<script setup>
import { CircleClose } from '@element-plus/icons-vue'

defineProps({
  title: {
    type: String,
    default: '出现错误'
  },
  description: {
    type: String,
    default: '操作失败，请稍后重试'
  },
  iconSize: {
    type: Number,
    default: 48
  },
  showRetry: {
    type: Boolean,
    default: false
  }
})

defineEmits(['retry'])
</script>

<style scoped>
.error-message {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 40px 20px;
  text-align: center;
}

.error-icon {
  color: #F56C6C;
  margin-bottom: 16px;
}

.error-content {
  max-width: 400px;
}

.error-title {
  font-size: 18px;
  font-weight: 500;
  color: #303133;
  margin-bottom: 8px;
}

.error-description {
  font-size: 14px;
  color: #909399;
  margin-bottom: 16px;
  line-height: 1.5;
}
</style>
