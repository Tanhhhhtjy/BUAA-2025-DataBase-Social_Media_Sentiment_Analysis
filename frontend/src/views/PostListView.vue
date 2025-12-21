<template>
  <div class="post-list-view">
    <div class="page-header">
      <div class="header-content">
        <h2>{{ pageTitle }}</h2>
        <p class="subtitle" v-if="!hashtagId">探索最新的观点与讨论</p>
      </div>
      <el-button type="primary" size="large" round class="create-btn" @click="showCreateDialog = true">
        <el-icon><Plus /></el-icon>
        发布帖子
      </el-button>
    </div>

    <div class="posts-container" v-loading="loading">
      <template v-if="posts.length > 0">
        <div class="post-grid">
          <PostCard
            v-for="post in posts"
            :key="post.postId"
            :post="post"
            @delete="handleDeletePost"
            @update="handleUpdatePost"
          />
        </div>
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
      title="发布新帖子"
      width="600px"
      :close-on-click-modal="false"
      class="custom-dialog"
    >
      <el-form :model="newPost" label-width="0">
        <el-form-item required>
          <el-input
            v-model="newPost.content"
            type="textarea"
            :rows="6"
            placeholder="分享你的想法... (使用 #话题# 添加标签)"
            maxlength="5000"
            show-word-limit
            class="custom-textarea"
          />
        </el-form-item>
        <div class="hashtag-tips">
          <el-icon><InfoFilled /></el-icon>
          <span>提示：在内容中输入 #话题名称# 即可自动生成话题标签</span>
        </div>
      </el-form>
      <template #footer>
        <div class="dialog-footer">
          <el-button @click="showCreateDialog = false" round>取消</el-button>
          <el-button type="primary" @click="handleCreatePost" :loading="creating" round>
            发布
          </el-button>
        </div>
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
import { Plus, InfoFilled } from '@element-plus/icons-vue'
import PostCard from '../components/PostCard.vue'
import Pagination from '../components/Pagination.vue'

const route = useRoute()
const postsStore = usePostsStore()

const hashtagId = computed(() => route.params.id)
const hashtagName = ref('')

const loading = ref(false)
const creating = ref(false)
const showCreateDialog = ref(false)
const newPost = ref({
  content: ''
})

const posts = computed(() => postsStore.posts)
const currentPage = computed(() => postsStore.pagination.page + 1)
const pageSize = computed(() => postsStore.pagination.size)
const totalElements = computed(() => postsStore.pagination.totalElements)

const pageTitle = computed(() => {
  if (hashtagId.value && hashtagName.value) {
    return `#${hashtagName.value}`
  }
  return '社区动态'
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

const handleUpdatePost = (updatedPost) => {
  // 刷新帖子列表以显示更新后的内容
  fetchPosts(currentPage.value - 1, pageSize.value)
}

// 监听路由参数变化，当 hashtagId 改变时重新获取数据
watch(hashtagId, async (newId, oldId) => {
  if (newId !== oldId) {
    hashtagName.value = ''
    await fetchHashtagInfo()
    fetchPosts()
  }
})

onMounted(async () => {
  await fetchHashtagInfo()
  fetchPosts()
})
</script>

<style scoped>
.post-list-view {
  padding: 20px 0;
  max-width: 1200px;
  margin: 0 auto;
}

.page-header {
  position: relative;
  display: flex;
  justify-content: center;
  align-items: center;
  margin-bottom: 40px;
  padding: 0 20px;
}

.header-content {
  display: flex;
  flex-direction: column;
  align-items: center;
  text-align: center;
}

.header-content h2 {
  font-size: 32px;
  font-weight: 800;
  color: #18181b;
  margin: 0 0 8px 0;
  letter-spacing: -1px;
}

.subtitle {
  color: #71717a;
  font-size: 16px;
  margin: 0;
}

.create-btn {
  position: absolute;
  right: 0;
  top: 50%;
  transform: translateY(-50%);
  box-shadow: 0 4px 12px rgba(24, 24, 27, 0.2);
}

@media (max-width: 768px) {
  .page-header {
    flex-direction: column;
    gap: 20px;
  }
  
  .create-btn {
    position: static;
    transform: none;
  }
}

.posts-container {
  min-height: 400px;
}

.post-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 24px;
  margin-bottom: 32px;
}

@media (max-width: 900px) {
  .post-grid {
    grid-template-columns: 1fr;
  }
}

/* 弹窗样式 */
.hashtag-tips {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-top: 12px;
  color: #71717a;
  font-size: 13px;
  background-color: #f4f4f5;
  padding: 10px 16px;
  border-radius: 8px;
}

.dialog-footer {
  display: flex;
  justify-content: flex-end;
  gap: 12px;
}

:deep(.custom-textarea .el-textarea__inner) {
  padding: 16px;
  border-radius: 12px;
  background-color: #f8fafc;
  border-color: transparent;
  font-size: 16px;
  box-shadow: none;
}

:deep(.custom-textarea .el-textarea__inner:focus) {
  background-color: #ffffff;
  border-color: #18181b;
  box-shadow: 0 0 0 1px #18181b;
}
</style>