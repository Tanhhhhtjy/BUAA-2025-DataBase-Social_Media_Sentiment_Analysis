import request from '../utils/request'

export const authAPI = {
  // 用户注册
  register(data) {
    return request({
      url: '/auth/register',
      method: 'post',
      data
    })
  },

  // 用户登录
  login(data) {
    return request({
      url: '/auth/login',
      method: 'post',
      data
    })
  },

  // 验证令牌
  validateToken(token) {
    return request({
      url: '/auth/validate',
      method: 'get',
      headers: {
        Authorization: `Bearer ${token}`
      }
    })
  }
}
