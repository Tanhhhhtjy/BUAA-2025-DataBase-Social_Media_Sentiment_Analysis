import request from '../utils/request'

export const analyticsAPI = {
  // 获取热点话题排行
  getHotTopics(params) {
    return request({
      url: '/analytics/hot-topics',
      method: 'get',
      params
    })
  },

  // 获取舆情趋势
  getSentimentTrend(params) {
    return request({
      url: '/analytics/sentiment-trend',
      method: 'get',
      params
    })
  },

  // 获取情感分布
  getSentimentDistribution(params) {
    return request({
      url: '/analytics/sentiment-distribution',
      method: 'get',
      params
    })
  },

  // 获取总体统计
  getStats(params) {
    return request({
      url: '/analytics/stats',
      method: 'get',
      params
    })
  }
}
