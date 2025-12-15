<template>
  <div class="post-detail-view" v-loading="loading">
    <el-card v-if="post">
      <div class="post-header">
        <div class="user-info">
          <el-avatar :size="50">{{ post.username?.[0]?.toUpperCase() }}</el-avatar>
          <div class="user-details">
            <h3>{{ post.username }}</h3>
            <span class="timestamp">{{ formatDate(post.createdAt) }}</span>
          </div>
        </div>
      </div>

      <div class="post-content">
        <p>{{ post.content }}</p>
      </div>

      <div class="post-footer">
        <div class="hashtags" v-if="post.hashtags && post.hashtags.length > 0">
          <el-tag
            v-for="tag in post.hashtags"
            :key="tag"
            type="info"
            size="small"
            class="hashtag-tag"
          >
            #{{ tag }}
          </el-tag>
        </div>
        <div class="post-stats">
          <el-tag :type="getSentimentType(post.sentiment)" size="large">
            {{ getSentimentText(post.sentiment) }}
            <span v-if="post.confidence"> ({{ (post.confidence * 100).toFixed(1) }}%)</span>
          </el-tag>
        </div>
      </div>
    </el-card>

    <el-card class="comments-section" v-if="post">
      <template #header>
        <h3>评论 ({{ commentCount }})</h3>
      </template>

      <div class="comment-form">
        <el-input
          v-model="newComment"
          type="textarea"
          :rows="3"
          placeholder="写下你的评论..."
          maxlength="500"
          show-word-limit
        />
        <div class="comment-actions">
          <el-button type="primary" @click="handleAddComment" :loading="commentLoading">
            发表评论
          </el-button>
        </div>
      </div>

      <div class="comments-list" v-loading="commentLoading">
        <div v-if="comments.length > 0">
          <div
            v-for="comment in comments"
            :key="comment.commentId"
            class="comment-item"
          >
            <div class="comment-header">
              <el-avatar :size="32">{{ comment.username?.[0]?.toUpperCase() }}</el-avatar>
              <span class="comment-username">{{ comment.username }}</span>
              <span class="comment-time">{{ formatDate(comment.createdAt) }}</span>
            </div>
            <div class="comment-content">
              {{ comment.content }}
            </div>
          </div>
        </div>
        <el-empty v-else description="暂无评论，来发表第一条评论吧！" />
      </div>
    </el-card>
  </div>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue'
import { useRoute } from 'vue-router'
import { postsAPI } from '../api/posts'
import { ElMessage } from 'element-plus'

const route = useRoute()

const loading = ref(false)
const commentLoading = ref(false)
const post = ref(null)
const comments = ref([])
const newComment = ref('')

const commentCount = computed(() => comments.value.length)

const fetchPost = async () => {
  loading.value = true
  try {
    post.value = await postsAPI.getPost(route.params.id)
  } catch (error) {
    ElMessage.error(error.message || '获取帖子详情失败')
  } finally {
    loading.value = false
  }
}

const fetchComments = async () => {
  commentLoading.value = true
  try {
    const response = await postsAPI.getComments(route.params.id, { page: 0, size: 50 })
    comments.value = response.content
  } catch (error) {
    ElMessage.error(error.message || '获取评论失败')
  } finally {
    commentLoading.value = false
  }
}

const handleAddComment = async () => {
  if (!newComment.value.trim()) {
    ElMessage.warning('请输入评论内容')
    return
  }

  commentLoading.value = true
  try {
    await postsAPI.addComment(route.params.id, { content: newComment.value })
    newComment.value = ''
    ElMessage.success('评论成功')
    fetchComments()
  } catch (error) {
    ElMessage.error(error.message || '评论失败')
  } finally {
    commentLoading.value = false
  }
}

const formatDate = (date) => {
  if (!date) return ''
  return new Date(date).toLocaleString('zh-CN')
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

onMounted(() => {
  fetchPost()
  fetchComments()
})
</script>

<style scoped>
.post-detail-view {
  max-width: 800px;
  margin: 0 auto;
}

.post-header {
  margin-bottom: 20px;
}

.user-info {
  display: flex;
  align-items: center;
  gap: 12px;
}

.user-details h3 {
  margin: 0;
  color: #303133;
}

.timestamp {
  font-size: 14px;
  color: #909399;
}

.post-content {
  margin: 20px 0;
  font-size: 16px;
  line-height: 1.8;
  color: #303133;
}

.post-footer {
  border-top: 1px solid #ebeef5;
  padding-top: 16px;
}

.hashtags {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  margin-bottom: 16px;
}

.hashtag-tag {
  cursor: pointer;
}

.comments-section {
  margin-top: 20px;
}

.comment-form {
  margin-bottom: 24px;
}

.comment-actions {
  margin-top: 12px;
  text-align: right;
}

.comments-list {
  min-height: 200px;
}

.comment-item {
  padding: 16px 0;
  border-bottom: 1px solid #ebeef5;
}

.comment-item:last-child {
  border-bottom: none;
}

.comment-header {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 8px;
}

.comment-username {
  font-weight: 600;
  color: #303133;
}

.comment-time {
  font-size: 12px;
  color: #909399;
  margin-left: auto;
}

.comment-content {
  padding-left: 40px;
  color: #606266;
  line-height: 1.6;
}
</style>
