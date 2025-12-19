<template>
  <div class="post-list-view">
    <div class="page-header">
      <h2>{{ pageTitle }}</h2>
      <el-button type="primary" @click="showCreateDialog = true">
        <el-icon><Plus /></el-icon>
        发布帖子
      </el-button>
    </div>

    <div class="filters">
      <el-input
        v-model="searchKeyword"
        placeholder="搜索帖子内容..."
        style="width: 300px"
        clearable
        @clear="handleSearch"
      >
        <template #append>
          <el-button :icon="Search" @click="handleSearch" />
        </template>
      </el-input>
    </div>

    <div class="posts-container" v-loading="loading">
      <template v-if="posts.length > 0">
        <PostCard
          v-for="post in posts"
          :key="post.postId"
          :post="post"
          @delete="handleDeletePost"
        />
      </template>
      <el-empty v-else description="暂无帖子数据" />

      <Pagination
        v-if="totalElements > 0"
        :current-page="currentPage"
        :page-size="pageSize"
        :total="totalElements"
        @change="handlePageChange"
      />
    </div>

    <el-dialog
      v-model="showCreateDialog"
      title="发布帖子"
      width="600px"
      :close-on-click-modal="false"
    >
      <el-form :model="newPost" label-width="80px">
        <el-form-item label="内容" required>
          <el-input
            v-model="newPost.content"
            type="textarea"
            :rows="6"
            placeholder="请输入帖子内容，支持 #话题# 格式"
            maxlength="5000"
            show-word-limit
          />
        </el-form-item>
        <div class="hashtag-tips">
          <el-alert
            title="使用话题标签"
            type="info"
            :closable="false"
            show-icon
          >
            在帖子中使用 #话题名称# 的格式自动提取话题
          </el-alert>
        </div>
      </el-form>
      <template #footer>
        <el-button @click="showCreateDialog = false">取消</el-button>
        <el-button type="primary" @click="handleCreatePost" :loading="creating">
          发布
        </el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, onMounted, computed, watch } from 'vue'
import { useRoute } from 'vue-router'
import { usePostsStore } from '../stores/posts'
import { hashtagsAPI } from '../api/hashtags'
import { ElMessage } from 'element-plus'
import { Plus, Search } from '@element-plus/icons-vue'
import PostCard from '../components/PostCard.vue'
import Pagination from '../components/Pagination.vue'

const route = useRoute()
const postsStore = usePostsStore()

const hashtagId = computed(() => route.params.id)
const hashtagName = ref('')

const loading = ref(false)
const creating = ref(false)
const showCreateDialog = ref(false)
const searchKeyword = ref('')
const newPost = ref({
  content: ''
})

const posts = computed(() => postsStore.posts)
const currentPage = computed(() => postsStore.pagination.page + 1)
const pageSize = computed(() => postsStore.pagination.size)
const totalElements = computed(() => postsStore.pagination.totalElements)

const pageTitle = computed(() => {
  if (hashtagId.value && hashtagName.value) {
    return `帖子列表(#${hashtagName.value})`
  }
  return '帖子列表'
})

const fetchHashtagInfo = async () => {
  if (hashtagId.value) {
    try {
      const hashtag = await hashtagsAPI.getHashtag(hashtagId.value)
      hashtagName.value = hashtag.tagName
    } catch (error) {
      console.error('获取话题信息失败', error)
    }
  }
}

const fetchPosts = async (page = 0, size = 20) => {
  loading.value = true
  try {
    if (hashtagId.value) {
      const response = await hashtagsAPI.getPostsByHashtag(hashtagId.value, { page, size })
      postsStore.posts = response.content
      postsStore.pagination = {
        page: response.page,
        size: response.size,
        totalElements: response.totalElements,
        totalPages: response.totalPages
      }
    } else {
      await postsStore.fetchPosts(page, size)
    }
  } catch (error) {
    ElMessage.error(error.message || '获取帖子列表失败')
  } finally {
    loading.value = false
  }
}

const handlePageChange = ({ page, size }) => {
  fetchPosts(page - 1, size)
}

const handleSearch = () => {
  fetchPosts(0, pageSize.value)
}

const handleCreatePost = async () => {
  if (!newPost.value.content.trim()) {
    ElMessage.warning('请输入帖子内容')
    return
  }

  creating.value = true
  try {
    await postsStore.createPost(newPost.value.content)
    newPost.value.content = ''
    showCreateDialog.value = false
    ElMessage.success('发布成功')
    fetchPosts(currentPage.value - 1, pageSize.value)
  } catch (error) {
    ElMessage.error(error.message || '发布失败')
  } finally {
    creating.value = false
  }
}

const handleDeletePost = async (postId) => {
  try {
    await postsStore.deletePost(postId)
    ElMessage.success('删除成功')
  } catch (error) {
    ElMessage.error(error.message || '删除失败')
  }
}

onMounted(async () => {
  await fetchHashtagInfo()
  fetchPosts()
})
</script>

<style scoped>
.post-list-view {
  padding: 20px 0;
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.page-header h2 {
  margin: 0;
  color: #303133;
}

.filters {
  margin-bottom: 20px;
}

.posts-container {
  min-height: 400px;
}

.hashtag-tips {
  margin-top: 12px;
}
</style>
