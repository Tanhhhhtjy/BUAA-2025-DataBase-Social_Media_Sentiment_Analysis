<template>
  <div class="dashboard-view">
    <div class="dashboard-header">
      <h1>系统仪表板</h1>
      <el-button @click="refreshData" :loading="loading">
        <el-icon><Refresh /></el-icon>
        刷新数据
      </el-button>
    </div>

    <!-- 统计卡片 -->
    <div class="stats-grid">
      <el-card class="stat-card" shadow="hover">
        <div class="stat-content">
          <div class="stat-icon users">
            <el-icon size="32"><User /></el-icon>
          </div>
          <div class="stat-details">
            <div class="stat-number">{{ dashboardData.activeUsers }}</div>
            <div class="stat-label">活跃用户</div>
            <div class="stat-trend positive">+{{ dashboardData.usersGrowth }}%</div>
          </div>
        </div>
      </el-card>

      <el-card class="stat-card" shadow="hover">
        <div class="stat-content">
          <div class="stat-icon posts">
            <el-icon size="32"><Document /></el-icon>
          </div>
          <div class="stat-details">
            <div class="stat-number">{{ dashboardData.activePosts }}</div>
            <div class="stat-label">活跃帖子</div>
            <div class="stat-trend positive">+{{ dashboardData.postsGrowth }}%</div>
          </div>
        </div>
      </el-card>

      <el-card class="stat-card" shadow="hover">
        <div class="stat-content">
          <div class="stat-icon comments">
            <el-icon size="32"><ChatDotRound /></el-icon>
          </div>
          <div class="stat-details">
            <div class="stat-number">{{ dashboardData.activeComments }}</div>
            <div class="stat-label">活跃评论</div>
            <div class="stat-trend positive">+{{ dashboardData.commentsGrowth }}%</div>
          </div>
        </div>
      </el-card>

      <el-card class="stat-card" shadow="hover">
        <div class="stat-content">
          <div class="stat-icon alerts">
            <el-icon size="32"><Warning /></el-icon>
          </div>
          <div class="stat-details">
            <div class="stat-number">{{ dashboardData.alertsToday }}</div>
            <div class="stat-label">今日预警</div>
            <div class="stat-trend" :class="dashboardData.alertsTrend > 0 ? 'negative' : 'positive'">
              {{ dashboardData.alertsTrend > 0 ? '+' : '' }}{{ dashboardData.alertsTrend }}%
            </div>
          </div>
        </div>
      </el-card>
    </div>

    <!-- 图表区域 -->
    <div class="charts-grid">
      <!-- 舆情趋势图 -->
      <el-card class="chart-card" shadow="hover">
        <template #header>
          <div class="card-header">
            <span>舆情趋势分析</span>
            <el-select v-model="trendDays" @change="fetchTrendData" style="width: 120px">
              <el-option label="7天" :value="7" />
              <el-option label="30天" :value="30" />
              <el-option label="90天" :value="90" />
            </el-select>
          </div>
        </template>
        <div ref="trendChartRef" class="chart-container"></div>
      </el-card>

      <!-- 情感分布图 -->
      <el-card class="chart-card" shadow="hover">
        <template #header>
          <div class="card-header">
            <span>情感分布统计</span>
          </div>
        </template>
        <div ref="distributionChartRef" class="chart-container"></div>
      </el-card>
    </div>

    <!-- 热点话题和预警列表 -->
    <div class="bottom-grid">
      <!-- 热点话题 -->
      <el-card class="list-card" shadow="hover">
        <template #header>
          <div class="card-header">
            <span>🔥 热点话题</span>
          </div>
        </template>
        <div class="hashtag-list">
          <div
            v-for="(hashtag, index) in hotHashtags"
            :key="hashtag.hashtagId"
            class="hashtag-item"
            @click="viewHashtagPosts(hashtag)"
          >
            <div class="hashtag-rank">#{{ index + 1 }}</div>
            <div class="hashtag-info">
              <div class="hashtag-name">{{ hashtag.hashtagName }}</div>
              <div class="hashtag-stats">
                {{ hashtag.postCount }} 帖子 · 热度 {{ hashtag.heatScore }}
              </div>
            </div>
            <el-icon class="hashtag-arrow"><ArrowRight /></el-icon>
          </div>
        </div>
      </el-card>

      <!-- 最近预警 -->
      <el-card class="list-card" shadow="hover">
        <template #header>
          <div class="card-header">
            <span>⚠️ 最近预警</span>
            <el-button type="text" @click="$router.push('/admin')">查看全部</el-button>
          </div>
        </template>
        <div class="alert-list">
          <div
            v-for="alert in recentAlerts"
            :key="alert.alertId"
            class="alert-item"
            @click="viewAlertDetail(alert)"
          >
            <div class="alert-type">
              <el-tag :type="alert.contentType === 'POST' ? 'primary' : 'success'" size="small">
                {{ alert.contentType === 'POST' ? '帖子' : '评论' }}
              </el-tag>
            </div>
            <div class="alert-info">
              <div class="alert-keyword">{{ alert.keyword }}</div>
              <div class="alert-summary">{{ truncate(alert.summary, 30) }}</div>
            </div>
            <div class="alert-time">{{ formatRelativeTime(alert.createdAt) }}</div>
          </div>
        </div>
      </el-card>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, nextTick } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { Refresh, User, Document, ChatDotRound, Warning, ArrowRight } from '@element-plus/icons-vue'
import * as echarts from 'echarts'
import { analyticsAPI } from '../api/analytics'
import { adminAPI } from '../api/admin'

const router = useRouter()
const loading = ref(false)
const trendDays = ref(30)

// 数据
const dashboardData = ref({
  activeUsers: 0,
  usersGrowth: 0,
  activePosts: 0,
  postsGrowth: 0,
  activeComments: 0,
  commentsGrowth: 0,
  alertsToday: 0,
  alertsTrend: 0
})

const hotHashtags = ref([])
const recentAlerts = ref([])

// 图表引用
const trendChartRef = ref(null)
const distributionChartRef = ref(null)
let trendChart = null
let distributionChart = null

// 获取仪表板数据
const fetchDashboardData = async () => {
  loading.value = true
  try {
    const response = await adminAPI.getDashboard()
    dashboardData.value = response
  } catch (error) {
    ElMessage.error('获取仪表板数据失败')
  } finally {
    loading.value = false
  }
}

// 获取舆情趋势数据
const fetchTrendData = async () => {
  try {
    const response = await analyticsAPI.getSentimentTrend({
      days: trendDays.value
    })
    renderTrendChart(response)
  } catch (error) {
    ElMessage.error('获取趋势数据失败')
  }
}

// 渲染趋势图表
const renderTrendChart = (data) => {
  if (!trendChart) {
    trendChart = echarts.init(trendChartRef.value)
  }

  const option = {
    tooltip: {
      trigger: 'axis'
    },
    legend: {
      data: ['正面', '中立', '负面']
    },
    grid: {
      left: '3%',
      right: '4%',
      bottom: '3%',
      containLabel: true
    },
    xAxis: {
      type: 'category',
      data: data.dates
    },
    yAxis: {
      type: 'value'
    },
    series: [
      {
        name: '正面',
        type: 'line',
        data: data.positive,
        smooth: true,
        itemStyle: { color: '#67C23A' }
      },
      {
        name: '中立',
        type: 'line',
        data: data.neutral,
        smooth: true,
        itemStyle: { color: '#909399' }
      },
      {
        name: '负面',
        type: 'line',
        data: data.negative,
        smooth: true,
        itemStyle: { color: '#F56C6C' }
      }
    ]
  }

  trendChart.setOption(option)
}

// 渲染情感分布图表
const renderDistributionChart = (data) => {
  if (!distributionChart) {
    distributionChart = echarts.init(distributionChartRef.value)
  }

  const option = {
    tooltip: {
      trigger: 'item',
      formatter: '{b}: {c} ({d}%)'
    },
    legend: {
      orient: 'vertical',
      left: 'left'
    },
    series: [
      {
        type: 'pie',
        radius: ['40%', '70%'],
        avoidLabelOverlap: false,
        itemStyle: {
          borderRadius: 10,
          borderColor: '#fff',
          borderWidth: 2
        },
        label: {
          show: true,
          formatter: '{b}: {d}%'
        },
        emphasis: {
          label: {
            show: true,
            fontSize: 16,
            fontWeight: 'bold'
          }
        },
        data: [
          { value: data.positive, name: '正面', itemStyle: { color: '#67C23A' } },
          { value: data.neutral, name: '中立', itemStyle: { color: '#909399' } },
          { value: data.negative, name: '负面', itemStyle: { color: '#F56C6C' } }
        ]
      }
    ]
  }

  distributionChart.setOption(option)
}

// 获取热点话题
const fetchHotHashtags = async () => {
  try {
    const response = await analyticsAPI.getHotHashtags({ limit: 10 })
    hotHashtags.value = response
  } catch (error) {
    ElMessage.error('获取热点话题失败')
  }
}

// 获取最近预警
const fetchRecentAlerts = async () => {
  try {
    const response = await adminAPI.getAlerts({
      page: 0,
      size: 10,
      hours: 24
    })
    recentAlerts.value = response.content || []
  } catch (error) {
    ElMessage.error('获取预警信息失败')
  }
}

// 刷新所有数据
const refreshData = async () => {
  await Promise.all([
    fetchDashboardData(),
    fetchTrendData(),
    fetchHotHashtags(),
    fetchRecentAlerts()
  ])
  ElMessage.success('数据刷新成功')
}

// 查看话题帖子
const viewHashtagPosts = (hashtag) => {
  router.push(`/hashtags/${hashtag.hashtagId}/posts`)
}

// 查看预警详情
const viewAlertDetail = (alert) => {
  router.push('/admin?tab=alerts')
}

// 工具函数
const truncate = (text, length) => {
  if (!text) return ''
  return text.length > length ? text.substring(0, length) + '...' : text
}

const formatRelativeTime = (dateStr) => {
  if (!dateStr) return ''
  const date = new Date(dateStr)
  const now = new Date()
  const diff = now - date
  const minutes = Math.floor(diff / 60000)
  const hours = Math.floor(diff / 3600000)
  const days = Math.floor(diff / 86400000)

  if (minutes < 60) return `${minutes}分钟前`
  if (hours < 24) return `${hours}小时前`
  return `${days}天前`
}

onMounted(async () => {
  await refreshData()

  // 初始化情感分布图表
  await nextTick()
  renderDistributionChart({
    positive: dashboardData.value.positivePosts || 0,
    neutral: dashboardData.value.neutralPosts || 0,
    negative: dashboardData.value.negativePosts || 0
  })

  // 监听窗口大小变化
  window.addEventListener('resize', () => {
    trendChart && trendChart.resize()
    distributionChart && distributionChart.resize()
  })
})
</script>

<style scoped>
.dashboard-view {
  padding: 20px;
}

.dashboard-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.dashboard-header h1 {
  margin: 0;
  color: #303133;
}

.stats-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 20px;
  margin-bottom: 20px;
}

.stat-card {
  cursor: pointer;
  transition: transform 0.3s;
}

.stat-card:hover {
  transform: translateY(-5px);
}

.stat-content {
  display: flex;
  align-items: center;
  gap: 20px;
}

.stat-icon {
  width: 60px;
  height: 60px;
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
}

.stat-icon.users {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}

.stat-icon.posts {
  background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
}

.stat-icon.comments {
  background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);
}

.stat-icon.alerts {
  background: linear-gradient(135deg, #fa709a 0%, #fee140 100%);
}

.stat-details {
  flex: 1;
}

.stat-number {
  font-size: 28px;
  font-weight: bold;
  color: #303133;
  line-height: 1;
}

.stat-label {
  font-size: 14px;
  color: #909399;
  margin-top: 5px;
}

.stat-trend {
  font-size: 12px;
  margin-top: 5px;
  font-weight: 500;
}

.stat-trend.positive {
  color: #67C23A;
}

.stat-trend.negative {
  color: #F56C6C;
}

.charts-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(400px, 1fr));
  gap: 20px;
  margin-bottom: 20px;
}

.chart-card {
  min-height: 400px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.chart-container {
  width: 100%;
  height: 320px;
}

.bottom-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(400px, 1fr));
  gap: 20px;
}

.list-card {
  min-height: 400px;
}

.hashtag-list,
.alert-list {
  max-height: 320px;
  overflow-y: auto;
}

.hashtag-item,
.alert-item {
  display: flex;
  align-items: center;
  gap: 15px;
  padding: 15px;
  border-bottom: 1px solid #EBEEF5;
  cursor: pointer;
  transition: background-color 0.3s;
}

.hashtag-item:hover,
.alert-item:hover {
  background-color: #F5F7FA;
}

.hashtag-item:last-child,
.alert-item:last-child {
  border-bottom: none;
}

.hashtag-rank {
  font-size: 18px;
  font-weight: bold;
  color: #909399;
  min-width: 40px;
}

.hashtag-info,
.alert-info {
  flex: 1;
}

.hashtag-name,
.alert-keyword {
  font-weight: 500;
  color: #303133;
  margin-bottom: 5px;
}

.hashtag-stats,
.alert-summary {
  font-size: 12px;
  color: #909399;
}

.alert-time {
  font-size: 12px;
  color: #C0C4CC;
  white-space: nowrap;
}

.hashtag-arrow {
  color: #C0C4CC;
}

@media (max-width: 768px) {
  .stats-grid {
    grid-template-columns: 1fr;
  }

  .charts-grid,
  .bottom-grid {
    grid-template-columns: 1fr;
  }
}
</style>
