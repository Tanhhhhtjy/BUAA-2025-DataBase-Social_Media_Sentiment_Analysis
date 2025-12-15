import { defineStore } from 'pinia'
import { hashtagsAPI } from '../api/hashtags'

export const useHashtagsStore = defineStore('hashtags', {
  state: () => ({
    hashtags: [],
    currentHashtag: null,
    loading: false,
    error: null,
    pagination: {
      page: 0,
      size: 20,
      totalElements: 0,
      totalPages: 0
    }
  }),

  actions: {
    async fetchHashtags(page = 0, size = 20) {
      this.loading = true
      this.error = null
      try {
        const response = await hashtagsAPI.getHashtags({ page, size })
        this.hashtags = response.content
        this.pagination = {
          page: response.page,
          size: response.size,
          totalElements: response.totalElements,
          totalPages: response.totalPages
        }
        return response
      } catch (error) {
        this.error = error.message || '获取话题列表失败'
        throw error
      } finally {
        this.loading = false
      }
    },

    async fetchHashtag(id) {
      this.loading = true
      this.error = null
      try {
        this.currentHashtag = await hashtagsAPI.getHashtag(id)
        return this.currentHashtag
      } catch (error) {
        this.error = error.message || '获取话题详情失败'
        throw error
      } finally {
        this.loading = false
      }
    }
  }
})
