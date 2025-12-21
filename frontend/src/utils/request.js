import axios from 'axios'
import { useAuthStore } from '../stores/auth'

const request = axios.create({
  baseURL: import.meta.env.VITE_API_BASE_URL || '/api',
  timeout: 10000,
  headers: {
    'Content-Type': 'application/json'
  }
})

request.interceptors.request.use(
  (config) => {
    const authStore = useAuthStore()
    if (authStore.token) {
      config.headers.Authorization = `Bearer ${authStore.token}`
    }
    return config
  },
  (error) => {
    return Promise.reject(error)
  }
)

request.interceptors.response.use(
  (response) => {
    return response.data
  },
  (error) => {
    // Check if the error is 401 and it's NOT a login request
    // We don't want to redirect/refresh if the user is currently trying to login and failed
    if (error.response?.status === 401 && !error.config?.url?.includes('/auth/login')) {
      const authStore = useAuthStore()
      authStore.logout()
      window.location.href = '/login'
    }
    return Promise.reject(error.response?.data || error.message)
  }
)

export default request
