<template>
  <div class="analytics-view">
    <div class="page-header">
      <div class="header-left">
        <h2>数据洞察</h2>
        <p class="subtitle">实时监控舆情趋势与情感分布</p>
      </div>
    </div>

    <div class="controls-bar">
      <div class="date-controls">
        <el-date-picker
          v-model="startDate"
          type="date"
          placeholder="开始日期"
          format="YYYY-MM-DD"
          value-format="YYYY-MM-DD"
          @change="handleDateChange"
          class="custom-date-picker"
        />
        <span class="date-separator">-</span>
        <el-date-picker
          v-model="endDate"
          type="date"
          placeholder="结束日期"
          format="YYYY-MM-DD"
          value-format="YYYY-MM-DD"
          @change="handleDateChange"
          class="custom-date-picker"
        />
        <el-button type="primary" @click="refreshData" :loading="loading" round>
          刷新
        </el-button>
      </div>
    </div>

    <!-- 核心指标卡片 -->
    <div class="stats-overview">
      <div class="stat-card">
        <div class="stat-icon bg-blue">
          <el-icon><Document /></el-icon>
        </div>
        <div class="stat-info">
          <div class="stat-label">总帖子数</div>
          <div class="stat-value">{{ stats.totalPosts }}</div>
        </div>
      </div>
      <div class="stat-card">
        <div class="stat-icon bg-green">
          <el-icon><SuccessFilled /></el-icon>
        </div>
        <div class="stat-info">
          <div class="stat-label">正面情感</div>
          <div class="stat-value positive">{{ stats.positivePosts }}</div>
        </div>
      </div>
      <div class="stat-card">
        <div class="stat-icon bg-gray">
          <el-icon><Minus /></el-icon>
        </div>
        <div class="stat-info">
          <div class="stat-label">中立情感</div>
          <div class="stat-value neutral">{{ stats.neutralPosts }}</div>
        </div>
      </div>
      <div class="stat-card">
        <div class="stat-icon bg-red">
          <el-icon><CircleCloseFilled /></el-icon>
        </div>
        <div class="stat-info">
          <div class="stat-label">负面情感</div>
          <div class="stat-value negative">{{ stats.negativePosts }}</div>
        </div>
      </div>
    </div>

    <el-row :gutter="24">
      <el-col :span="12">
        <div class="chart-panel" v-loading="loading">
          <div class="panel-header">
            <h3>情感分布</h3>
          </div>
          <SentimentPieChart :data="pieChartData" :height="320" />
        </div>
      </el-col>
      <el-col :span="12">
        <div class="chart-panel" v-loading="loading">
          <div class="panel-header">
            <h3>热点话题排行</h3>
          </div>
          <HotTopicsChart :data="hotTopics" :height="320" />
        </div>
      </el-col>
    </el-row>

    <div class="chart-panel trend-panel" v-loading="loading">
      <div class="panel-header">
        <h3>舆情趋势分析</h3>
      </div>
      <SentimentTrendChart :data="trendChartData" :height="420" />
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useAnalyticsStore } from '../stores/analytics'
import { ElMessage } from 'element-plus'
import { Document, SuccessFilled, Minus, CircleCloseFilled } from '@element-plus/icons-vue'
import SentimentPieChart from '../components/SentimentPieChart.vue'
import HotTopicsChart from '../components/HotTopicsChart.vue'
import SentimentTrendChart from '../components/SentimentTrendChart.vue'

const analyticsStore = useAnalyticsStore()

const loading = computed(() => analyticsStore.loading)
const startDate = ref(null)
const endDate = ref(null)

const hotTopics = computed(() => analyticsStore.hotTopics)
const stats = computed(() => analyticsStore.stats)

const pieChartData = computed(() => {
  return analyticsStore.sentimentDistribution.map(item => ({
    name: getSentimentText(item.sentiment),
    value: item.count,
    itemStyle: {
      color: getSentimentColor(item.sentiment)
    }
  }))
})

const trendChartData = computed(() => {
  return analyticsStore.sentimentTrend.map(item => ({
    date: formatDate(item.trend_date || item.date),
    positive: parseInt(item.positive || item.positive_count || 0),
    neutral: parseInt(item.neutral || item.neutral_count || 0),
    negative: parseInt(item.negative || item.negative_count || 0)
  }))
})

const handleDateChange = () => {
  if (startDate.value && endDate.value) {
    analyticsStore.setDateRange(startDate.value, endDate.value)
    refreshData()
  }
}

const refreshData = async () => {
  try {
    await analyticsStore.fetchAllAnalytics(analyticsStore.getParams())
  } catch (error) {
    ElMessage.error(error.message || '获取数据失败')
  }
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

// 使用新主题色：Emerald, Slate, Rose
const getSentimentColor = (sentiment) => {
  const colors = {
    POSITIVE: '#10b981', // Emerald-500
    NEUTRAL: '#64748b',  // Slate-500
    NEGATIVE: '#f43f5e', // Rose-500
    UNANALYZED: '#f59e0b' // Amber-500
  }
  return colors[sentiment] || '#94a3b8'
}

const formatDate = (dateStr) => {
  if (!dateStr) return ''
  return new Date(dateStr).toLocaleDateString('zh-CN', {
    month: '2-digit',
    day: '2-digit'
  })
}

onMounted(() => {
  refreshData()
})
</script>

<style scoped>
.analytics-view {
  padding: 20px 0;
  max-width: 1200px;
  margin: 0 auto;
}

.page-header {
  margin-bottom: 24px;
  text-align: center;
}

.controls-bar {
  display: flex;
  justify-content: center;
  margin-bottom: 32px;
}

.header-left h2 {
  font-size: 32px;
  font-weight: 800;
  color: #18181b;
  margin-bottom: 8px;
  letter-spacing: -0.5px;
}

.subtitle {
  color: #71717a;
  font-size: 16px;
}

.date-controls {
  display: flex;
  align-items: center;
  gap: 12px;
  background: #ffffff;
  padding: 8px;
  border-radius: 12px;
  box-shadow: 0 1px 2px rgba(0,0,0,0.05);
}

.date-separator {
  color: #a1a1aa;
  font-weight: 500;
}

/* Stats Cards Overview */
.stats-overview {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 24px;
  margin-bottom: 32px;
}

.stat-card {
  background: #ffffff;
  border-radius: 16px;
  padding: 24px;
  display: flex;
  align-items: center;
  gap: 16px;
  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.02);
  transition: transform 0.2s;
}

.stat-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.05);
}

.stat-icon {
  width: 48px;
  height: 48px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 24px;
}

.bg-blue { background-color: #eff6ff; color: #3b82f6; }
.bg-green { background-color: #ecfdf5; color: #10b981; }
.bg-gray { background-color: #f8fafc; color: #64748b; }
.bg-red { background-color: #fff1f2; color: #f43f5e; }

.stat-info {
  display: flex;
  flex-direction: column;
}

.stat-label {
  font-size: 13px;
  color: #71717a;
  font-weight: 500;
  margin-bottom: 4px;
}

.stat-value {
  font-size: 24px;
  font-weight: 700;
  color: #18181b;
  line-height: 1;
}

.stat-value.positive { color: #10b981; }
.stat-value.neutral { color: #64748b; }
.stat-value.negative { color: #f43f5e; }

/* Charts */
.chart-panel {
  background: #ffffff;
  border-radius: 20px;
  padding: 24px;
  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.02);
  margin-bottom: 24px;
  border: 1px solid rgba(0,0,0,0.02);
}

.trend-panel {
  margin-bottom: 40px;
}

.panel-header {
  margin-bottom: 24px;
  padding-left: 8px;
  border-left: 4px solid #18181b;
}

.panel-header h3 {
  font-size: 18px;
  font-weight: 700;
  color: #18181b;
  margin: 0;
}

:deep(.el-input__wrapper) {
  box-shadow: none !important;
  background-color: #f4f4f5;
}
</style>
