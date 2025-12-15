import request from '../utils/request'

export const adminAPI = {
  // 获取用户列表
  getUsers(params) {
    return request({
      url: '/admin/users',
      method: 'get',
      params
    })
  },

  // 获取单个用户
  getUser(userId) {
    return request({
      url: `/admin/users/${userId}`,
      method: 'get'
    })
  },

  // 启用用户
  enableUser(userId) {
    return request({
      url: `/admin/users/${userId}/enable`,
      method: 'put'
    })
  },

  // 禁用用户
  disableUser(userId) {
    return request({
      url: `/admin/users/${userId}/disable`,
      method: 'put'
    })
  },

  // 删除用户
  deleteUser(userId) {
    return request({
      url: `/admin/users/${userId}`,
      method: 'delete'
    })
  },

  // 获取关键词列表
  getKeywords(params) {
    return request({
      url: '/admin/keywords',
      method: 'get',
      params
    })
  },

  // 添加关键词
  addKeyword(data) {
    return request({
      url: '/admin/keywords',
      method: 'post',
      data
    })
  },

  // 更新关键词
  updateKeyword(keywordId, data) {
    return request({
      url: `/admin/keywords/${keywordId}`,
      method: 'put',
      data
    })
  },

  // 删除关键词
  deleteKeyword(keywordId) {
    return request({
      url: `/admin/keywords/${keywordId}`,
      method: 'delete'
    })
  },

  // 获取预警列表
  getAlerts(params) {
    return request({
      url: '/admin/alerts',
      method: 'get',
      params
    })
  },

  // 标记预警为已处理
  markAlertHandled(alertId) {
    return request({
      url: `/admin/alerts/${alertId}/handle`,
      method: 'put'
    })
  }
}
