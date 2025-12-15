<template>
  <div class="empty-state">
    <el-icon class="empty-icon" :size="iconSize">
      <component :is="iconComponent" />
    </el-icon>
    <div class="empty-content">
      <div class="empty-title">{{ title }}</div>
      <div class="empty-description">{{ description }}</div>
      <el-button v-if="actionText" type="primary" @click="$emit('action')" size="small">
        {{ actionText }}
      </el-button>
    </div>
  </div>
</template>

<script setup>
import {
  Document,
  User,
  ChatDotRound,
  Warning,
  Search
} from '@element-plus/icons-vue'

const props = defineProps({
  icon: {
    type: String,
    default: 'Document'
  },
  iconSize: {
    type: Number,
    default: 64
  },
  title: {
    type: String,
    default: '暂无数据'
  },
  description: {
    type: String,
    default: '这里还没有任何内容'
  },
  actionText: {
    type: String,
    default: ''
  }
})

defineEmits(['action'])

const iconMap = {
  Document,
  User,
  ChatDotRound,
  Warning,
  Search
}

const iconComponent = iconMap[props.icon] || Document
</script>

<style scoped>
.empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 60px 20px;
  text-align: center;
}

.empty-icon {
  color: #C0C4CC;
  margin-bottom: 20px;
}

.empty-content {
  max-width: 400px;
}

.empty-title {
  font-size: 16px;
  font-weight: 500;
  color: #303133;
  margin-bottom: 8px;
}

.empty-description {
  font-size: 14px;
  color: #909399;
  margin-bottom: 16px;
  line-height: 1.5;
}
</style>
