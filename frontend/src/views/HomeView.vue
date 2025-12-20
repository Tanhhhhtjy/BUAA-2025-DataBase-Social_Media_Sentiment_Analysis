<template>
  <div class="home-view">
    <div class="hero-section">
      <h1>欢迎使用社交媒体舆情分析系统</h1>
      <p>基于大模型的智能情感分析平台</p>
      <div class="action-buttons">
        <el-button type="primary" size="large" @click="$router.push('/posts')">
          浏览帖子
        </el-button>
        <el-button size="large" @click="$router.push('/hashtags')">
          查看话题
        </el-button>
      </div>
    </div>

    <div class="features-section">
      <el-row :gutter="20">
        <el-col :span="8">
          <el-card shadow="hover" class="feature-card">
            <el-icon size="48" color="#409eff"><ChatSquare /></el-icon>
            <h3>智能话题提取</h3>
            <p>自动识别帖子中的 #话题# 标签，快速构建话题网络</p>
          </el-card>
        </el-col>
        <el-col :span="8">
          <el-card shadow="hover" class="feature-card">
            <el-icon size="48" color="#67c23a"><DataAnalysis /></el-icon>
            <h3>情感分析</h3>
            <p>基于大模型技术，准确分析帖子情感倾向</p>
          </el-card>
        </el-col>
        <el-col :span="8">
          <el-card shadow="hover" class="feature-card">
            <el-icon size="48" color="#e6a23c"><TrendCharts /></el-icon>
            <h3>舆情趋势</h3>
            <p>实时监控舆情动态，掌握热点话题走向</p>
          </el-card>
        </el-col>
      </el-row>
    </div>

    <div class="stats-section" v-if="isAuthenticated">
      <h2>系统概览</h2>
      <el-row :gutter="20">
        <el-col :span="6">
          <el-statistic title="总用户数" :value="1234">
            <template #prefix><el-icon><User /></el-icon></template>
          </el-statistic>
        </el-col>
        <el-col :span="6">
          <el-statistic title="总帖子数" :value="5678">
            <template #prefix><el-icon><Document /></el-icon></template>
          </el-statistic>
        </el-col>
        <el-col :span="6">
          <el-statistic title="总话题数" :value="89">
            <template #prefix><el-icon><Collection /></el-icon></template>
          </el-statistic>
        </el-col>
        <el-col :span="6">
          <el-statistic title="今日分析" :value="234">
            <template #prefix><el-icon><DataAnalysis /></el-icon></template>
          </el-statistic>
        </el-col>
      </el-row>
    </div>

    <div class="recent-posts-section" v-if="isAuthenticated">
      <div class="section-header">
        <h2>最新帖子</h2>
        <el-button text @click="$router.push('/posts')">查看更多 →</el-button>
      </div>
      <div v-loading="loading">
        <PostCard
          v-for="post in recentPosts"
          :key="post.postId"
          :post="post"
          @delete="handleDeletePost"
          @update="handleUpdatePost"
        />
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue'
import { useAuthStore } from '../stores/auth'
import { usePostsStore } from '../stores/posts'
import { ChatSquare, DataAnalysis, TrendCharts, User, Document, Collection } from '@element-plus/icons-vue'
import PostCard from '../components/PostCard.vue'

const authStore = useAuthStore()
const postsStore = usePostsStore()

const loading = ref(false)
const recentPosts = ref([])

const isAuthenticated = computed(() => authStore.isAuthenticated)

const fetchRecentPosts = async () => {
  if (!isAuthenticated.value) return

  loading.value = true
  try {
    const response = await postsStore.fetchPosts(0, 5)
    recentPosts.value = response.content
  } catch (error) {
    console.error('获取最新帖子失败:', error)
  } finally {
    loading.value = false
  }
}

const handleDeletePost = async (postId) => {
  try {
    await postsStore.deletePost(postId)
    fetchRecentPosts()
  } catch (error) {
    console.error('删除帖子失败:', error)
  }
}

const handleUpdatePost = () => {
  fetchRecentPosts()
}

onMounted(() => {
  fetchRecentPosts()
})
</script>

<style scoped>
.home-view {
  padding: 20px 0;
}

.hero-section {
  text-align: center;
  padding: 60px 20px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border-radius: 12px;
  margin-bottom: 40px;
}

.hero-section h1 {
  font-size: 42px;
  margin-bottom: 16px;
}

.hero-section p {
  font-size: 18px;
  margin-bottom: 32px;
  opacity: 0.9;
}

.action-buttons {
  display: flex;
  gap: 16px;
  justify-content: center;
}

.features-section {
  margin-bottom: 40px;
}

.feature-card {
  text-align: center;
  padding: 20px;
  height: 100%;
}

.feature-card h3 {
  margin: 16px 0 12px;
  color: #303133;
}

.feature-card p {
  color: #606266;
  line-height: 1.6;
}

.stats-section {
  margin-bottom: 40px;
  padding: 30px;
  background: #f5f7fa;
  border-radius: 12px;
}

.stats-section h2 {
  margin-bottom: 24px;
  color: #303133;
}

.recent-posts-section {
  margin-bottom: 40px;
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.section-header h2 {
  margin: 0;
  color: #303133;
}
</style>
