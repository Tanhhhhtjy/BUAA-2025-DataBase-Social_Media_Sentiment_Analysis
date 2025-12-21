<template>
  <div class="home-view">
    <!-- Hero Section: 极简大标题风格 -->
    <div class="hero-section">
      <div class="hero-content">
        <h1 class="main-title">
          洞察社交舆情<br>
          <span class="highlight">掌握未来趋势</span>
        </h1>
        <p class="subtitle">基于 AI 大模型的智能情感分析平台，为您提供精准、实时的舆情监控服务。</p>
        <div class="action-buttons">
          <el-button type="primary" size="large" class="hero-btn primary" @click="$router.push('/posts')">
            开始探索
          </el-button>
          <el-button size="large" class="hero-btn secondary" @click="$router.push('/hashtags')">
            热门话题
          </el-button>
        </div>
      </div>
    </div>

    <!-- Feature Section: 无边框悬浮卡片 -->
    <div class="features-section">
      <el-row :gutter="40">
        <el-col :span="8">
          <div class="feature-card">
            <div class="icon-wrapper">
              <el-icon :size="32" color="#18181b"><ChatSquare /></el-icon>
            </div>
            <h3>智能提取</h3>
            <p>自动识别帖子中的 #话题# 标签，构建实时关联网络。</p>
          </div>
        </el-col>
        <el-col :span="8">
          <div class="feature-card">
            <div class="icon-wrapper">
              <el-icon :size="32" color="#18181b"><DataAnalysis /></el-icon>
            </div>
            <h3>深度分析</h3>
            <p>利用先进的大语言模型，精准捕捉文本背后的情感倾向。</p>
          </div>
        </el-col>
        <el-col :span="8">
          <div class="feature-card">
            <div class="icon-wrapper">
              <el-icon :size="32" color="#18181b"><TrendCharts /></el-icon>
            </div>
            <h3>趋势监控</h3>
            <p>全天候监控数据波动，第一时间发现潜在的热点与危机。</p>
          </div>
        </el-col>
      </el-row>
    </div>

    <!-- Recent Posts -->
    <div class="recent-posts-section" v-if="isAuthenticated">
      <div class="section-header">
        <h2>最新动态</h2>
        <div class="view-all-btn" @click="$router.push('/posts')">
          查看全部
          <el-icon><ArrowRight /></el-icon>
        </div>
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
import { ChatSquare, DataAnalysis, TrendCharts, ArrowRight } from '@element-plus/icons-vue'
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
  padding-bottom: 60px;
}

/* Hero Section */
.hero-section {
  padding: 100px 20px 80px;
  text-align: center;
  max-width: 800px;
  margin: 0 auto;
}

.main-title {
  font-size: 56px;
  line-height: 1.1;
  font-weight: 800;
  color: #18181b;
  margin-bottom: 24px;
  letter-spacing: -1.5px;
}

.highlight {
  background: linear-gradient(120deg, #18181b 0%, #52525b 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
}

.subtitle {
  font-size: 20px;
  color: #71717a;
  margin-bottom: 48px;
  line-height: 1.6;
  max-width: 600px;
  margin-left: auto;
  margin-right: auto;
}

.action-buttons {
  display: flex;
  gap: 20px;
  justify-content: center;
}

.hero-btn {
  height: 50px;
  padding: 0 40px;
  font-size: 16px;
  border-radius: 25px;
  font-weight: 600;
  transition: transform 0.2s;
}

.hero-btn:hover {
  transform: translateY(-2px);
}

.hero-btn.secondary {
  border-color: #e4e4e7;
  color: #18181b;
}

.hero-btn.secondary:hover {
  border-color: #18181b;
  background-color: transparent;
}

/* Features Section */
.features-section {
  padding: 40px 0 80px;
}

.feature-card {
  background: #ffffff;
  padding: 40px 30px;
  border-radius: 16px;
  text-align: left;
  transition: all 0.3s ease;
  border: 1px solid transparent;
  height: 100%;
}

.feature-card:hover {
  transform: translateY(-5px);
  box-shadow: 0 20px 40px rgba(0,0,0,0.05);
  border-color: rgba(0,0,0,0.05);
}

.icon-wrapper {
  width: 56px;
  height: 56px;
  background-color: #f4f4f5;
  border-radius: 14px;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 24px;
}

.feature-card h3 {
  font-size: 20px;
  font-weight: 700;
  color: #18181b;
  margin-bottom: 12px;
}

.feature-card p {
  color: #71717a;
  line-height: 1.6;
  font-size: 15px;
}

/* Recent Posts */
.recent-posts-section {
  margin-top: 40px;
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 30px;
}

.section-header h2 {
  font-size: 24px;
  font-weight: 700;
  color: #18181b;
  margin: 0;
  position: relative;
  padding-left: 16px;
}

.section-header h2::before {
  content: '';
  position: absolute;
  left: 0;
  top: 50%;
  transform: translateY(-50%);
  width: 4px;
  height: 24px;
  background-color: #18181b;
  border-radius: 2px;
}

.view-all-btn {
  display: flex;
  align-items: center;
  gap: 4px;
  font-size: 14px;
  color: #71717a;
  cursor: pointer;
  transition: all 0.2s ease;
  font-weight: 500;
}

.view-all-btn:hover {
  color: #18181b;
  transform: translateX(2px);
}
</style>
