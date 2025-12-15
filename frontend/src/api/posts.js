import request from '../utils/request'

export const postsAPI = {
  // 获取帖子列表
  getPosts(params) {
    return request({
      url: '/posts',
      method: 'get',
      params
    })
  },

  // 获取帖子详情
  getPost(id) {
    return request({
      url: `/posts/${id}`,
      method: 'get'
    })
  },

  // 创建帖子
  createPost(data) {
    return request({
      url: '/posts',
      method: 'post',
      data
    })
  },

  // 删除帖子
  deletePost(id) {
    return request({
      url: `/posts/${id}`,
      method: 'delete'
    })
  },

  // 获取用户的帖子
  getUserPosts(userId, params) {
    return request({
      url: `/posts/user/${userId}`,
      method: 'get',
      params
    })
  },

  // 获取话题下的帖子
  getHashtagPosts(hashtagId, params) {
    return request({
      url: `/posts/hashtag/${hashtagId}`,
      method: 'get',
      params
    })
  },

  // 发表评论
  addComment(postId, data) {
    return request({
      url: `/comments/post/${postId}`,
      method: 'post',
      data
    })
  },

  // 获取帖子评论
  getComments(postId, params) {
    return request({
      url: `/comments/post/${postId}`,
      method: 'get',
      params
    })
  }
}
