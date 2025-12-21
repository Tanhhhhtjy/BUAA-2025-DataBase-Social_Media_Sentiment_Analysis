<template>
  <div class="post-detail-view" v-loading="loading">
    <div v-if="post" class="post-wrapper">
      <PostCard
        :post="post"
        @delete="handleDeletePost"
        @update="handleUpdatePost"
      />
    </div>

    <div class="comments-section" v-if="post">
      <div class="section-header">
        <h3>全部评论 ({{ commentCount }})</h3>
      </div>

      <div class="comment-form-wrapper">
        <el-input
          v-model="newComment"
          type="textarea"
          :rows="3"
          placeholder="发表你的看法..."
          maxlength="500"
          show-word-limit
          class="custom-textarea"
        />
        <div class="comment-actions">
          <el-button type="primary" @click="handleAddComment" :loading="commentLoading" round>
            发布评论
          </el-button>
        </div>
      </div>

      <div class="comments-list" v-loading="commentLoading">
        <template v-if="comments.length > 0">
          <div
            v-for="comment in comments"
            :key="comment.commentId"
            class="comment-item"
          >
            <div class="comment-avatar">
              <el-avatar :size="40" class="custom-avatar">{{ comment.username?.[0]?.toUpperCase() }}</el-avatar>
            </div>
            <div class="comment-body">
              <div class="comment-meta">
                <span class="comment-username">{{ comment.username }}</span>
                <span class="comment-time">{{ formatDate(comment.createdAt) }}</span>
              </div>
              <div class="comment-content">
                {{ comment.content }}
              </div>
            </div>
          </div>
        </template>
        <el-empty v-else description="暂无评论，快来抢沙发！" />
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { postsAPI } from '../api/posts'
import { ElMessage } from 'element-plus'
import PostCard from '../components/PostCard.vue'

const route = useRoute()
const router = useRouter()

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
    // 也可以选择重新获取帖子以更新评论数，虽然 PostCard 可能不会自动刷新数字
    // fetchPost() 
  } catch (error) {
    ElMessage.error(error.message || '评论失败')
  } finally {
    commentLoading.value = false
  }
}

const handleDeletePost = async () => {
  // 如果在详情页删除了帖子，应该跳回列表页
  try {
    await postsAPI.deletePost(post.value.postId)
    ElMessage.success('删除成功')
    router.push('/posts')
  } catch (error) {
    ElMessage.error(error.message || '删除失败')
  }
}

const handleUpdatePost = (updatedPost) => {
  post.value = updatedPost
}

const formatDate = (date) => {
  if (!date) return ''
  return new Date(date).toLocaleString('zh-CN', {
    month: '2-digit',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit'
  })
}

onMounted(() => {
  fetchPost()
  fetchComments()
})
</script>

<style scoped>
.post-detail-view {
  max-width: 1000px;
  margin: 0 auto;
  padding: 20px 0;
}

.post-wrapper {
  margin-bottom: 32px;
}

/* Comments Section */
.comments-section {
  background: #ffffff;
  border-radius: 16px;
  padding: 32px;
  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.02);
}

.section-header {
  margin-bottom: 24px;
  padding-left: 8px;
  border-left: 4px solid #18181b;
}

.section-header h3 {
  margin: 0;
  font-size: 20px;
  font-weight: 700;
  color: #18181b;
}

.comment-form-wrapper {
  margin-bottom: 40px;
}

:deep(.custom-textarea .el-textarea__inner) {
  padding: 16px;
  border-radius: 12px;
  background-color: #f8fafc;
  border-color: transparent;
  font-size: 15px;
  transition: all 0.2s;
  box-shadow: none;
}

:deep(.custom-textarea .el-textarea__inner:focus) {
  background-color: #ffffff;
  border-color: #18181b;
  box-shadow: 0 0 0 1px #18181b;
}

.comment-actions {
  margin-top: 12px;
  display: flex;
  justify-content: flex-end;
}

/* Comment List */
.comment-item {
  display: flex;
  gap: 16px;
  padding: 24px 0;
  border-bottom: 1px solid #f4f4f5;
}

.comment-item:last-child {
  border-bottom: none;
}

.custom-avatar {
  background-color: #f4f4f5;
  color: #18181b;
  font-weight: 700;
}

.comment-body {
  flex: 1;
}

.comment-meta {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 8px;
}

.comment-username {
  font-weight: 700;
  color: #18181b;
  font-size: 15px;
}

.comment-time {
  font-size: 13px;
  color: #a1a1aa;
}

.comment-content {
  color: #3f3f46;
  line-height: 1.6;
  font-size: 15px;
}
</style>
