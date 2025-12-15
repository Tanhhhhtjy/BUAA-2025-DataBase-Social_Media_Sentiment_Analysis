import { defineStore } from 'pinia'
import { authAPI } from '../api/auth'

export const useAuthStore = defineStore('auth', {
  state: () => ({
    token: localStorage.getItem('token') || '',
    user: JSON.parse(localStorage.getItem('user') || 'null')
  }),

  getters: {
    isAuthenticated: (state) => !!state.token,
    username: (state) => state.user?.username,
    isAdmin: (state) => state.user?.role === 'ADMIN'
  },

  actions: {
    async register(userData) {
      try {
        const response = await authAPI.register(userData)
        this.token = response.token
        this.user = {
          userId: response.userId,
          username: response.username,
          email: response.email,
          role: response.role
        }
        localStorage.setItem('token', this.token)
        localStorage.setItem('user', JSON.stringify(this.user))
        return { success: true }
      } catch (error) {
        return { success: false, message: error.message || '注册失败' }
      }
    },

    async login(credentials) {
      try {
        const response = await authAPI.login(credentials)
        this.token = response.token
        this.user = {
          userId: response.userId,
          username: response.username,
          email: response.email,
          role: response.role
        }
        localStorage.setItem('token', this.token)
        localStorage.setItem('user', JSON.stringify(this.user))
        return { success: true }
      } catch (error) {
        return { success: false, message: error.message || '登录失败' }
      }
    },

    logout() {
      this.token = ''
      this.user = null
      localStorage.removeItem('token')
      localStorage.removeItem('user')
    }
  }
})
