<template>
  <div class="my-comments-view">
    <div class="page-header">
      <h2>我的评论</h2>
      <p class="subtitle">共 {{ totalComments }} 条评论</p>
    </div>

    <div v-loading="loading" class="comments-container">
      <template v-if="comments.length > 0">
        <div class="comment-list">
          <div v-for="comment in comments" :key="comment.commentId" class="comment-card">
            <div class="comment-header">
              <span class="comment-time">{{ formatDate(comment.createdAt) }}</span>
              <el-button type="danger" size="small" text bg round @click="handleDelete(comment.commentId)">
                删除
              </el-button>
            </div>
            <div class="comment-content">{{ comment.content }}</div>
            <div class="comment-post" @click="goToPost(comment.postId)">
              <div class="post-icon">
                <el-icon><Document /></el-icon>
              </div>
              <div class="post-text">
                <span class="label">原帖</span>
                <span class="content">{{ comment.postContent || '帖子已删除' }}</span>
              </div>
            </div>
          </div>
        </div>
        <div class="pagination-container">
          <el-pagination
            v-model:current-page="currentPage"
            v-model:page-size="pageSize"
            :page-sizes="[10, 20, 50]"
            :total="totalComments"
            layout="total, sizes, prev, pager, next"
            @size-change="handleSizeChange"
            @current-change="handleCurrentChange"
          />
        </div>
      </template>
      <el-empty v-else description="暂无评论" />
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '../stores/auth'
import { postsAPI } from '../api/posts'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Document } from '@element-plus/icons-vue'

const router = useRouter()
const authStore = useAuthStore()
const userId = computed(() => authStore.user?.userId)

const loading = ref(false)
const comments = ref([])
const currentPage = ref(1)
const pageSize = ref(10)
const totalComments = ref(0)

const fetchComments = async () => {
  if (!userId.value) return

  loading.value = true
  try {
    const response = await postsAPI.getUserComments(userId.value, {
      page: currentPage.value - 1,
      size: pageSize.value
    })
    comments.value = response.content || []
    totalComments.value = response.totalElements || 0
  } catch (error) {
    ElMessage.error('获取评论失败')
  } finally {
    loading.value = false
  }
}

const handleDelete = (commentId) => {
  ElMessageBox.confirm(
    '此操作将永久删除该评论，是否继续？',
    '删除确认',
    {
      confirmButtonText: '确认删除',
      cancelButtonText: '取消',
      confirmButtonClass: 'el-button--danger',
      center: true,
      draggable: true
    }
  ).then(async () => {
    try {
      await postsAPI.deleteComment(commentId)
      ElMessage.success('删除成功')
      await fetchComments()
    } catch (error) {
      ElMessage.error(error.message || '删除失败')
    }
  }).catch(() => {})
}

const goToPost = (postId) => {
  router.push(`/posts/${postId}`)
}

const handleSizeChange = () => {
  currentPage.value = 1
  fetchComments()
}

const handleCurrentChange = () => {
  fetchComments()
}

const formatDate = (date) => {
  if (!date) return '-'
  return new Date(date).toLocaleString('zh-CN', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit'
  })
}

onMounted(() => {
  fetchComments()
})
</script>

<style scoped>
.my-comments-view {
  padding: 20px 0;
  max-width: 800px; /* 评论列表保持单列居中，稍窄一点便于阅读 */
  margin: 0 auto;
}

.page-header {
  text-align: center;
  margin-bottom: 40px;
}

.page-header h2 {
  font-size: 32px;
  font-weight: 800;
  color: #18181b;
  margin: 0 0 8px 0;
  letter-spacing: -1px;
}

.subtitle {
  color: #71717a;
  font-size: 16px;
  margin: 0;
}

.comments-container {
  min-height: 400px;
}

.comment-list {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.comment-card {
  background: #ffffff;
  border-radius: 16px;
  padding: 24px;
  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.02);
  transition: transform 0.2s;
  border: none;
}

.comment-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.05);
}

.comment-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 12px;
}

.comment-time {
  color: #a1a1aa;
  font-size: 13px;
  font-weight: 500;
}

.comment-content {
  color: #3f3f46;
  line-height: 1.6;
  font-size: 15px;
  margin-bottom: 20px;
}

.comment-post {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 12px 16px;
  background-color: #f8fafc;
  border-radius: 12px;
  cursor: pointer;
  transition: all 0.2s;
  border: 1px solid transparent;
}

.comment-post:hover {
  background-color: #ffffff;
  border-color: #e4e4e7;
  box-shadow: 0 2px 8px rgba(0,0,0,0.04);
}

.post-icon {
  width: 32px;
  height: 32px;
  background-color: #eef2ff;
  color: #4f46e5;
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.post-text {
  display: flex;
  flex-direction: column;
  gap: 2px;
  overflow: hidden;
}

.post-text .label {
  font-size: 11px;
  color: #94a3b8;
  font-weight: 600;
  text-transform: uppercase;
}

.post-text .content {
  font-size: 13px;
  color: #334155;
  font-weight: 500;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.pagination-container {
  display: flex;
  justify-content: center;
  margin-top: 40px;
}
</style>
