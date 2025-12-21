<template>
  <div class="my-posts-view">
    <div class="page-header">
      <h2>我的帖子</h2>
      <p class="subtitle">共 {{ totalPosts }} 条动态</p>
    </div>

    <div v-loading="loading" class="posts-container">
      <template v-if="posts.length > 0">
        <div class="post-grid">
          <PostCard
            v-for="post in posts"
            :key="post.postId"
            :post="post"
            @delete="handleDeletePost"
            @update="handleUpdatePost"
          />
        </div>
        <div class="pagination-container">
          <el-pagination
            v-model:current-page="currentPage"
            v-model:page-size="pageSize"
            :page-sizes="[10, 20, 50]"
            :total="totalPosts"
            layout="total, sizes, prev, pager, next"
            @size-change="handleSizeChange"
            @current-change="handleCurrentChange"
          />
        </div>
      </template>
      <el-empty v-else description="暂无帖子" />
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useAuthStore } from '../stores/auth'
import { postsAPI } from '../api/posts'
import { ElMessage } from 'element-plus'
import PostCard from '../components/PostCard.vue'

const authStore = useAuthStore()
const userId = computed(() => authStore.user?.userId)

const loading = ref(false)
const posts = ref([])
const currentPage = ref(1)
const pageSize = ref(10)
const totalPosts = ref(0)

const fetchPosts = async () => {
  if (!userId.value) return

  loading.value = true
  try {
    const response = await postsAPI.getUserPosts(userId.value, {
      page: currentPage.value - 1,
      size: pageSize.value
    })
    posts.value = response.content || []
    totalPosts.value = response.totalElements || 0
  } catch (error) {
    ElMessage.error('获取帖子失败')
  } finally {
    loading.value = false
  }
}

const handleDeletePost = async (postId) => {
  try {
    await postsAPI.deletePost(postId)
    ElMessage.success('删除成功')
    await fetchPosts()
  } catch (error) {
    ElMessage.error(error.message || '删除失败')
  }
}

const handleUpdatePost = () => {
  fetchPosts()
}

const handleSizeChange = () => {
  currentPage.value = 1
  fetchPosts()
}

const handleCurrentChange = () => {
  fetchPosts()
}

onMounted(() => {
  fetchPosts()
})
</script>

<style scoped>
.my-posts-view {
  padding: 20px 0;
  max-width: 1200px;
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

.posts-container {
  min-height: 400px;
}

.post-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 24px;
  margin-bottom: 32px;
}

@media (max-width: 900px) {
  .post-grid {
    grid-template-columns: 1fr;
  }
}

.pagination-container {
  display: flex;
  justify-content: center;
  margin-top: 40px;
}
</style>
