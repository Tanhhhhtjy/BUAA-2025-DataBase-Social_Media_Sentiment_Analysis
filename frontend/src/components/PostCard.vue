<template>
  <el-card class="post-card" shadow="hover">
    <div class="post-header">
      <div class="user-info">
        <el-avatar :size="40">{{ post.username?.[0]?.toUpperCase() }}</el-avatar>
        <div class="user-details">
          <span class="username">{{ post.username }}</span>
          <span class="timestamp">{{ formatDate(post.createdAt) }}</span>
        </div>
      </div>
      <el-dropdown v-if="canDelete" @command="handleCommand">
        <el-button type="text" :icon="MoreFilled"></el-button>
        <template #dropdown>
          <el-dropdown-menu>
            <el-dropdown-item command="delete">删除</el-dropdown-item>
          </el-dropdown-menu>
        </template>
      </el-dropdown>
    </div>

    <div class="post-content">
      <p class="content-text">{{ post.content }}</p>
    </div>

    <div class="post-footer">
      <div class="hashtags" v-if="post.hashtags && post.hashtags.length > 0">
        <el-tag
          v-for="tag in post.hashtags"
          :key="tag"
          type="info"
          size="small"
          class="hashtag-tag"
          @click="$router.push(`/hashtags/${tag}/posts`)"
        >
          #{{ tag }}
        </el-tag>
      </div>
      <div class="post-stats">
        <el-tag :type="getSentimentType(post.sentiment)" size="small">
          {{ getSentimentText(post.sentiment) }}
        </el-tag>
        <span class="comment-count">
          <el-icon><ChatDotRound /></el-icon>
          {{ post.commentCount || 0 }}
        </span>
      </div>
    </div>
  </el-card>
</template>

<script setup>
import { computed } from 'vue'
import { useAuthStore } from '../stores/auth'
import { ElMessage, ElMessageBox } from 'element-plus'
import { MoreFilled, ChatDotRound } from '@element-plus/icons-vue'

const props = defineProps({
  post: {
    type: Object,
    required: true
  }
})

const emit = defineEmits(['delete'])

const authStore = useAuthStore()

const canDelete = computed(() => {
  return props.post.userId === authStore.user?.userId || authStore.isAdmin
})

const handleCommand = (command) => {
  if (command === 'delete') {
    ElMessageBox.confirm('确定要删除这条帖子吗？', '提示', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    }).then(() => {
      emit('delete', props.post.postId)
      ElMessage.success('删除成功')
    }).catch(() => {})
  }
}

const formatDate = (date) => {
  if (!date) return ''
  return new Date(date).toLocaleString('zh-CN', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit'
  })
}

const getSentimentType = (sentiment) => {
  const types = {
    POSITIVE: 'success',
    NEUTRAL: 'info',
    NEGATIVE: 'danger',
    UNANALYZED: 'warning'
  }
  return types[sentiment] || 'info'
}

const getSentimentText = (sentiment) => {
  const texts = {
    POSITIVE: '正面',
    NEUTRAL: '中立',
    NEGATIVE: '负面',
    UNANALYZED: '未分析'
  }
  return texts[sentiment] || '未知'
}
</script>

<style scoped>
.post-card {
  margin-bottom: 16px;
  cursor: pointer;
  transition: transform 0.2s;
}

.post-card:hover {
  transform: translateY(-2px);
}

.post-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 12px;
}

.user-info {
  display: flex;
  align-items: center;
  gap: 12px;
}

.user-details {
  display: flex;
  flex-direction: column;
}

.username {
  font-weight: 600;
  color: #303133;
}

.timestamp {
  font-size: 12px;
  color: #909399;
}

.post-content {
  margin-bottom: 12px;
}

.content-text {
  line-height: 1.6;
  color: #606266;
  white-space: pre-wrap;
}

.post-footer {
  border-top: 1px solid #ebeef5;
  padding-top: 12px;
}

.hashtags {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  margin-bottom: 12px;
}

.hashtag-tag {
  cursor: pointer;
  transition: all 0.2s;
}

.hashtag-tag:hover {
  transform: scale(1.05);
}

.post-stats {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.comment-count {
  display: flex;
  align-items: center;
  gap: 4px;
  color: #909399;
  font-size: 14px;
}
</style>
