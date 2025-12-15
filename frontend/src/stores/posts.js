import { defineStore } from 'pinia'
import { postsAPI } from '../api/posts'

export const usePostsStore = defineStore('posts', {
  state: () => ({
    posts: [],
    currentPost: null,
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
    async fetchPosts(page = 0, size = 20) {
      this.loading = true
      this.error = null
      try {
        const response = await postsAPI.getPosts({ page, size })
        this.posts = response.content
        this.pagination = {
          page: response.page,
          size: response.size,
          totalElements: response.totalElements,
          totalPages: response.totalPages
        }
        return response
      } catch (error) {
        this.error = error.message || '获取帖子列表失败'
        throw error
      } finally {
        this.loading = false
      }
    },

    async fetchPost(id) {
      this.loading = true
      this.error = null
      try {
        this.currentPost = await postsAPI.getPost(id)
        return this.currentPost
      } catch (error) {
        this.error = error.message || '获取帖子详情失败'
        throw error
      } finally {
        this.loading = false
      }
    },

    async createPost(content) {
      this.loading = true
      this.error = null
      try {
        const post = await postsAPI.createPost({ content })
        this.posts.unshift(post)
        return post
      } catch (error) {
        this.error = error.message || '发布帖子失败'
        throw error
      } finally {
        this.loading = false
      }
    },

    async deletePost(id) {
      this.loading = true
      this.error = null
      try {
        await postsAPI.deletePost(id)
        this.posts = this.posts.filter(p => p.postId !== id)
      } catch (error) {
        this.error = error.message || '删除帖子失败'
        throw error
      } finally {
        this.loading = false
      }
    },

    setPage(page) {
      this.pagination.page = page
    }
  }
})
