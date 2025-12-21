<template>
  <div class="post-card">
    <div class="post-header">
      <div class="user-info">
        <el-avatar :size="40" class="custom-avatar">{{ post.username?.[0]?.toUpperCase() }}</el-avatar>
        <div class="user-details">
          <span class="username">{{ post.username }}</span>
          <span class="timestamp">{{ formatDate(post.createdAt) }}</span>
        </div>
      </div>
      <el-dropdown v-if="canModify" @command="handleCommand">
        <el-button type="text" :icon="MoreFilled" class="more-btn"></el-button>
        <template #dropdown>
          <el-dropdown-menu>
            <el-dropdown-item command="edit">编辑</el-dropdown-item>
            <el-dropdown-item command="delete" divided>删除</el-dropdown-item>
          </el-dropdown-menu>
        </template>
      </el-dropdown>
    </div>

    <div class="post-content">
      <p class="content-text" v-html="parsedContent" @click="handleContentClick"></p>
    </div>

    <div class="post-footer">
      <div class="hashtags" v-if="post.hashtags && post.hashtags.length > 0">
        <span
          v-for="tag in post.hashtags"
          :key="tag"
          class="hashtag-pill"
        >
          #{{ tag }}
        </span>
      </div>
      <div class="post-stats">
        <div class="sentiment-area">
          <span :class="['sentiment-badge', getSentimentClass(post.sentiment)]">
            <span class="dot"></span>
            {{ getSentimentText(post.sentiment) }}
          </span>
          <el-button
            v-if="post.sentiment === 'UNANALYZED'"
            type="primary"
            link
            size="small"
            :loading="analyzing"
            @click.stop="handleAnalyze"
            class="analyze-btn"
          >
            立即分析
          </el-button>
        </div>
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
      width="600px"
      :close-on-click-modal="false"
      @close="resetEditForm"
      class="custom-dialog"
      append-to-body
    >
      <el-form :model="editForm" label-width="0">
        <el-form-item>
          <el-input
            v-model="editForm.content"
            type="textarea"
            :rows="6"
            placeholder="请输入帖子内容..."
            maxlength="5000"
            show-word-limit
            class="custom-textarea"
          />
        </el-form-item>
        <div class="hashtag-tips">
          <el-icon><InfoFilled /></el-icon>
          <span>提示：修改内容时，#话题# 依然会被自动识别</span>
        </div>
      </el-form>
      <template #footer>
        <div class="dialog-footer">
          <el-button @click="editDialogVisible = false" round>取消</el-button>
          <el-button type="primary" @click="submitEdit" :loading="editLoading" round>
            保存修改
          </el-button>
        </div>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { computed, ref, reactive } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '../stores/auth'
import { postsAPI } from '../api/posts'
import { hashtagsAPI } from '../api/hashtags'
import { ElMessage, ElMessageBox } from 'element-plus'
import { MoreFilled, ChatDotRound, InfoFilled } from '@element-plus/icons-vue'

const props = defineProps({
  post: {
    type: Object,
    required: true
  }
})

const emit = defineEmits(['delete', 'update', 'analyze'])

const router = useRouter()
const authStore = useAuthStore()

// 编辑相关状态
const editDialogVisible = ref(false)
const editLoading = ref(false)
const editForm = reactive({
  content: ''
})

// 情感分析状态
const analyzing = ref(false)

const goToDetail = () => {
  router.push(`/posts/${props.post.postId}`)
}

const canModify = computed(() => {
  return props.post.userId === authStore.user?.userId || authStore.isAdmin
})

// 解析内容中的话题标签，转换为可点击的蓝色链接
const parsedContent = computed(() => {
  if (!props.post.content) return ''
  const escaped = props.post.content
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
  // 匹配 #话题名 格式
  return escaped.replace(/#([^\s#]{2,})/g, '<span class="hashtag-link" data-tag="$1">#$1</span>')
})

const handleContentClick = async (event) => {
  const target = event.target
  if (target.classList.contains('hashtag-link')) {
    event.stopPropagation()
    const tagName = target.dataset.tag.toLowerCase()
    try {
      const hashtag = await hashtagsAPI.getHashtagByName(tagName)
      if (hashtag && hashtag.hashtagId) {
        router.push(`/hashtags/${hashtag.hashtagId}/posts`)
      }
    } catch (error) {
      ElMessage.warning('该话题不存在')
    }
  }
}

const handleCommand = (command) => {
  if (command === 'edit') {
    openEditDialog()
  } else if (command === 'delete') {
    ElMessageBox.confirm(
      '此操作将永久删除该帖子，是否继续？',
      '删除确认',
      {
        confirmButtonText: '确认删除',
        cancelButtonText: '取消',
        type: 'warning',
        center: true,
        confirmButtonClass: 'el-button--danger',
        draggable: true
      }
    ).then(() => {
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

const getSentimentClass = (sentiment) => {
  const classes = {
    POSITIVE: 'positive',
    NEUTRAL: 'neutral',
    NEGATIVE: 'negative',
    UNANALYZED: 'unanalyzed'
  }
  return classes[sentiment] || 'neutral'
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

const handleAnalyze = async () => {
  analyzing.value = true
  try {
    await postsAPI.analyzePost(props.post.postId)
    ElMessage.info('正在分析中...')
    await pollForResult()
  } catch (error) {
    ElMessage.error(error.message || '触发分析失败')
    analyzing.value = false
  }
}

const pollForResult = async () => {
  const maxAttempts = 15
  const interval = 2000
  for (let i = 0; i < maxAttempts; i++) {
    await new Promise(resolve => setTimeout(resolve, interval))
    try {
      const updatedPost = await postsAPI.getPost(props.post.postId)
      if (updatedPost.sentiment && updatedPost.sentiment !== 'UNANALYZED') {
        ElMessage.success('情感分析完成')
        emit('update', updatedPost)
        analyzing.value = false
        return
      }
    } catch (error) {
      console.error('轮询失败:', error)
    }
  }
  ElMessage.warning('分析超时，请稍后刷新查看结果')
  analyzing.value = false
}
</script>

<style scoped>
.post-card {
  background: #ffffff;
  border-radius: 12px;
  padding: 24px;
  margin-bottom: 20px;
  transition: all 0.3s ease;
  border: 1px solid rgba(0,0,0,0.04);
}

.post-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 12px 24px rgba(0,0,0,0.04);
  border-color: rgba(0,0,0,0);
}

.post-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
}

.user-info {
  display: flex;
  align-items: center;
  gap: 14px;
}

.custom-avatar {
  background-color: #f4f4f5;
  color: #18181b;
  font-weight: 700;
  border: 1px solid #e4e4e7;
}

.user-details {
  display: flex;
  flex-direction: column;
}

.username {
  font-weight: 700;
  color: #18181b;
  font-size: 15px;
}

.timestamp {
  font-size: 13px;
  color: #a1a1aa;
  margin-top: 2px;
}

.more-btn {
  color: #a1a1aa;
}

.more-btn:hover {
  color: #18181b;
}

.post-content {
  margin-bottom: 20px;
}

.content-text {
  line-height: 1.7;
  color: #3f3f46;
  white-space: pre-wrap;
  font-size: 15px;
}

.content-text :deep(.hashtag-link) {
  color: #409eff;
  background-color: #f4f4f5;
  padding: 2px 8px;
  border-radius: 6px;
  font-size: 0.9em;
  font-weight: 600;
  margin: 0 2px;
  cursor: pointer;
  transition: all 0.2s ease;
  text-decoration: none;
  border: 1px solid transparent;
}

.content-text :deep(.hashtag-link:hover) {
  background-color: #ecf5ff;
  color: #409eff;
  border-color: #d9ecff;
}

.post-footer {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.hashtags {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}

.hashtag-pill {
  font-size: 13px;
  color: #71717a;
  background-color: #f4f4f5;
  padding: 4px 10px;
  border-radius: 100px;
  cursor: default;
  font-weight: 500;
}

.post-stats {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding-top: 16px;
  border-top: 1px solid #f4f4f5;
}

/* 情感标签样式 */
.sentiment-area {
  display: flex;
  align-items: center;
  gap: 12px;
}

.sentiment-badge {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  padding: 4px 12px;
  border-radius: 100px;
  font-size: 13px;
  font-weight: 600;
  transition: all 0.2s;
}

.sentiment-badge .dot {
  width: 6px;
  height: 6px;
  border-radius: 50%;
}

/* 正面 - Emerald */
.sentiment-badge.positive {
  background-color: #ecfdf5;
  color: #059669;
}
.sentiment-badge.positive .dot {
  background-color: #059669;
}

/* 中立 - Slate */
.sentiment-badge.neutral {
  background-color: #f1f5f9;
  color: #475569;
}
.sentiment-badge.neutral .dot {
  background-color: #64748b;
}

/* 负面 - Rose */
.sentiment-badge.negative {
  background-color: #fff1f2;
  color: #e11d48;
}
.sentiment-badge.negative .dot {
  background-color: #e11d48;
}

/* 未分析 - Amber */
.sentiment-badge.unanalyzed {
  background-color: #fffbeb;
  color: #d97706;
}
.sentiment-badge.unanalyzed .dot {
  background-color: #d97706;
}

.analyze-btn {
  font-weight: 500;
  color: #4f46e5;
}

.comment-count {
  display: flex;
  align-items: center;
  gap: 6px;
  color: #a1a1aa;
  font-size: 14px;
  cursor: pointer;
  transition: color 0.2s;
}

.comment-count:hover {
  color: #18181b;
}

/* Edit Dialog Styles */
.hashtag-tips {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-top: 12px;
  color: #71717a;
  font-size: 13px;
  background-color: #f4f4f5;
  padding: 10px 16px;
  border-radius: 8px;
}

.dialog-footer {
  display: flex;
  justify-content: flex-end;
  gap: 12px;
}

:deep(.custom-textarea .el-textarea__inner) {
  padding: 16px;
  border-radius: 12px;
  background-color: #f8fafc;
  border-color: transparent;
  font-size: 16px;
  box-shadow: none;
}

:deep(.custom-textarea .el-textarea__inner:focus) {
  background-color: #ffffff;
  border-color: #18181b;
  box-shadow: 0 0 0 1px #18181b;
}
</style>
