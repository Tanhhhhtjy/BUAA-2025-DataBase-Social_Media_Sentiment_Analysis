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
        let msg = '注册失败'
        if (typeof error === 'string') {
          msg = error
        } else if (error?.message) {
          msg = error.message
        } else if (error?.msg) {
          msg = error.msg
        }
        return { success: false, message: msg }
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
        let msg = '登录失败'
        if (typeof error === 'string') {
          msg = error
        } else if (error?.message) {
          msg = error.message
        } else if (error?.msg) {
          msg = error.msg
        }
        return { success: false, message: msg }
      }
    },

    logout() {
      this.token = ''
      this.user = null
      localStorage.removeItem('token')
      localStorage.removeItem('user')
    },

    checkToken() {
      if (!this.token) return false
      
      try {
        // Decode JWT payload (middle part)
        const base64Url = this.token.split('.')[1]
        const base64 = base64Url.replace(/-/g, '+').replace(/_/g, '/')
        const jsonPayload = decodeURIComponent(window.atob(base64).split('').map(function(c) {
            return '%' + ('00' + c.charCodeAt(0).toString(16)).slice(-2)
        }).join(''))
        
        const payload = JSON.parse(jsonPayload)
        const expirationTime = payload.exp * 1000 // convert to ms
        
        // Check if token is expired
        if (Date.now() >= expirationTime) {
          this.logout()
          return false
        }
        return true
      } catch (e) {
        console.error('Token validation failed:', e)
        this.logout()
        return false
      }
    }
  }
})
