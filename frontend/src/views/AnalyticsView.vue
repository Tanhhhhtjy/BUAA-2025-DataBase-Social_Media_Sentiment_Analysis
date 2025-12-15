<template>
  <div class="analytics-view">
    <div class="page-header">
      <h2>数据分析</h2>
      <div class="date-range-picker">
        <el-date-picker
          v-model="dateRange"
          type="daterange"
          range-separator="至"
          start-placeholder="开始日期"
          end-placeholder="结束日期"
          format="YYYY-MM-DD"
          value-format="YYYY-MM-DD"
          @change="handleDateRangeChange"
        />
        <el-button type="primary" @click="refreshData" :loading="loading">
          刷新数据
        </el-button>
      </div>
    </div>

    <el-row :gutter="20">
      <el-col :span="12">
        <el-card v-loading="loading">
          <template #header>
            <span>情感分布统计</span>
          </template>
          <SentimentPieChart :data="pieChartData" :height="300" />
        </el-card>
      </el-col>
      <el-col :span="12">
        <el-card v-loading="loading">
          <template #header>
            <span>热点话题排行</span>
          </template>
          <HotTopicsChart :data="hotTopics" :height="300" />
        </el-card>
      </el-col>
    </el-row>

    <el-card class="trend-chart-card" v-loading="loading">
      <template #header>
        <span>舆情趋势分析</span>
      </template>
      <SentimentTrendChart :data="trendChartData" :height="400" />
    </el-card>

    <el-row :gutter="20" class="stats-row">
      <el-col :span="6">
        <el-statistic title="总帖子数" :value="stats.totalPosts">
          <template #prefix><el-icon><Document /></el-icon></template>
        </el-statistic>
      </el-col>
      <el-col :span="6">
        <el-statistic title="正面情感" :value="stats.positivePosts" :value-style="{ color: '#67c23a' }">
          <template #prefix><el-icon><SuccessFilled /></el-icon></template>
        </el-statistic>
      </el-col>
      <el-col :span="6">
        <el-statistic title="中立情感" :value="stats.neutralPosts" :value-style="{ color: '#909399' }">
          <template #prefix><el-icon><Minus /></el-icon></template>
        </el-statistic>
      </el-col>
      <el-col :span="6">
        <el-statistic title="负面情感" :value="stats.negativePosts" :value-style="{ color: '#f56c6c' }">
          <template #prefix><el-icon><CircleCloseFilled /></el-icon></template>
        </el-statistic>
      </el-col>
    </el-row>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue'
import { useAnalyticsStore } from '../stores/analytics'
import { ElMessage } from 'element-plus'
import { Document, SuccessFilled, Minus, CircleCloseFilled } from '@element-plus/icons-vue'
import SentimentPieChart from '../components/SentimentPieChart.vue'
import HotTopicsChart from '../components/HotTopicsChart.vue'
import SentimentTrendChart from '../components/SentimentTrendChart.vue'

const analyticsStore = useAnalyticsStore()

const loading = computed(() => analyticsStore.loading)
const dateRange = ref([])

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

const handleDateRangeChange = (dates) => {
  if (dates && dates.length === 2) {
    analyticsStore.setDateRange(dates[0], dates[1])
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

const getSentimentColor = (sentiment) => {
  const colors = {
    POSITIVE: '#67c23a',
    NEUTRAL: '#909399',
    NEGATIVE: '#f56c6c',
    UNANALYZED: '#e6a23c'
  }
  return colors[sentiment] || '#909399'
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
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.page-header h2 {
  margin: 0;
  color: #303133;
}

.date-range-picker {
  display: flex;
  gap: 12px;
  align-items: center;
}

.chart-container {
  height: 300px;
}

.chart-container-large {
  height: 400px;
}

.trend-chart-card {
  margin: 20px 0;
}

.stats-row {
  margin-top: 20px;
}
</style>
