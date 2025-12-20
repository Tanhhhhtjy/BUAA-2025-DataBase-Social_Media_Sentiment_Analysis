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
      <el-dropdown v-if="canModify" @command="handleCommand">
        <el-button type="text" :icon="MoreFilled"></el-button>
        <template #dropdown>
          <el-dropdown-menu>
            <el-dropdown-item command="edit">编辑</el-dropdown-item>
            <el-dropdown-item command="delete" divided>删除</el-dropdown-item>
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
        <span class="comment-count" @click.stop="goToDetail" title="查看评论">
          <el-icon><ChatDotRound /></el-icon>
          {{ post.commentCount || 0 }}
        </span>
      </div>
    </div>

    <!-- 编辑对话框 -->
    <el-dialog
      v-model="editDialogVisible"
      title="编辑帖子"
      width="500px"
      :close-on-click-modal="false"
      @close="resetEditForm"
    >
      <el-form :model="editForm" label-width="0">
        <el-form-item>
          <el-input
            v-model="editForm.content"
            type="textarea"
            :rows="5"
            placeholder="请输入帖子内容，使用 #话题# 添加话题标签"
            maxlength="500"
            show-word-limit
          />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="editDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="submitEdit" :loading="editLoading">
          保存
        </el-button>
      </template>
    </el-dialog>
  </el-card>
</template>

<script setup>
import { computed, ref, reactive } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '../stores/auth'
import { postsAPI } from '../api/posts'
import { ElMessage, ElMessageBox } from 'element-plus'
import { MoreFilled, ChatDotRound } from '@element-plus/icons-vue'

const props = defineProps({
  post: {
    type: Object,
    required: true
  }
})

const emit = defineEmits(['delete', 'update'])

const router = useRouter()
const authStore = useAuthStore()

// 编辑相关状态
const editDialogVisible = ref(false)
const editLoading = ref(false)
const editForm = reactive({
  content: ''
})

const goToDetail = () => {
  router.push(`/posts/${props.post.postId}`)
}

const canModify = computed(() => {
  return props.post.userId === authStore.user?.userId || authStore.isAdmin
})

const handleCommand = (command) => {
  if (command === 'edit') {
    openEditDialog()
  } else if (command === 'delete') {
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

const openEditDialog = () => {
  editForm.content = props.post.content
  editDialogVisible.value = true
}

const resetEditForm = () => {
  editForm.content = ''
}

const submitEdit = async () => {
  if (!editForm.content.trim()) {
    ElMessage.warning('帖子内容不能为空')
    return
  }

  editLoading.value = true
  try {
    const updatedPost = await postsAPI.updatePost(props.post.postId, {
      content: editForm.content
    })
    ElMessage.success('编辑成功')
    editDialogVisible.value = false
    emit('update', updatedPost)
  } catch (error) {
    ElMessage.error(error.message || '编辑失败')
  } finally {
    editLoading.value = false
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
  cursor: pointer;
  padding: 4px 8px;
  border-radius: 4px;
  transition: all 0.2s;
}

.comment-count:hover {
  color: #409eff;
  background-color: #ecf5ff;
}
</style>
