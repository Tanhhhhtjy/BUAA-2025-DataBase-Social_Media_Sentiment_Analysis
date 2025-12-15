import { defineStore } from 'pinia'
import { analyticsAPI } from '../api/analytics'

export const useAnalyticsStore = defineStore('analytics', {
  state: () => ({
    hotTopics: [],
    sentimentTrend: [],
    sentimentDistribution: [],
    stats: {
      totalPosts: 0,
      positivePosts: 0,
      neutralPosts: 0,
      negativePosts: 0,
      unanalyzedPosts: 0
    },
    dateRange: {
      startDate: null,
      endDate: null
    },
    loading: false,
    error: null
  }),

  actions: {
    async fetchHotTopics(params = {}) {
      this.loading = true
      this.error = null
      try {
        const response = await analyticsAPI.getHotTopics(params)
        this.hotTopics = response
        return response
      } catch (error) {
        this.error = error.message || '获取热点话题失败'
        throw error
      } finally {
        this.loading = false
      }
    },

    async fetchSentimentTrend(params = {}) {
      this.loading = true
      this.error = null
      try {
        const response = await analyticsAPI.getSentimentTrend(params)
        this.sentimentTrend = response
        return response
      } catch (error) {
        this.error = error.message || '获取舆情趋势失败'
        throw error
      } finally {
        this.loading = false
      }
    },

    async fetchSentimentDistribution(params = {}) {
      this.loading = true
      this.error = null
      try {
        const response = await analyticsAPI.getSentimentDistribution(params)
        this.sentimentDistribution = response
        return response
      } catch (error) {
        this.error = error.message || '获取情感分布失败'
        throw error
      } finally {
        this.loading = false
      }
    },

    async fetchStats(params = {}) {
      this.loading = true
      this.error = null
      try {
        const response = await analyticsAPI.getStats(params)
        this.stats = response
        return response
      } catch (error) {
        this.error = error.message || '获取统计数据失败'
        throw error
      } finally {
        this.loading = false
      }
    },

    async fetchAllAnalytics(params = {}) {
      this.loading = true
      this.error = null
      try {
        await Promise.all([
          this.fetchHotTopics(params),
          this.fetchSentimentTrend(params),
          this.fetchSentimentDistribution(params),
          this.fetchStats(params)
        ])
      } catch (error) {
        this.error = error.message || '获取分析数据失败'
        throw error
      } finally {
        this.loading = false
      }
    },

    setDateRange(startDate, endDate) {
      this.dateRange.startDate = startDate
      this.dateRange.endDate = endDate
    },

    getParams() {
      const params = {}
      if (this.dateRange.startDate) {
        params.startDate = this.dateRange.startDate
      }
      if (this.dateRange.endDate) {
        params.endDate = this.dateRange.endDate
      }
      return params
    }
  }
})
