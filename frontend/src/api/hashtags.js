import request from '../utils/request'

export const hashtagsAPI = {
  // 获取话题列表
  getHashtags(params) {
    return request({
      url: '/hashtags',
      method: 'get',
      params
    })
  },

  // 获取话题详情
  getHashtag(id) {
    return request({
      url: `/hashtags/${id}`,
      method: 'get'
    })
  },

  // 通过名称获取话题
  getHashtagByName(tagName) {
    return request({
      url: `/hashtags/name/${tagName}`,
      method: 'get'
    })
  },

  // 获取话题下的帖子
  getPostsByHashtag(id, params) {
    return request({
      url: `/hashtags/${id}/posts`,
      method: 'get',
      params
    })
  }
}
