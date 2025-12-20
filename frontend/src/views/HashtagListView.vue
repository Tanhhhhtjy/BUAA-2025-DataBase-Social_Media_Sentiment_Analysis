<template>
  <div class="hashtag-list-view">
    <div class="page-header">
      <h2>话题列表</h2>
    </div>

    <HashtagFilter
      :hashtags="hashtags"
      @change="handleHashtagSelectionChange"
      @filter="handleFilter"
    />

    <div class="hashtag-stats" v-if="selectedHashtags.length > 0">
      <el-card>
        <template #header>
          <span>已选择话题统计</span>
        </template>
        <div class="stats-content">
          <div class="stat-item" v-for="hashtag in selectedHashtags" :key="hashtag.hashtagId">
            <div class="stat-label">#{{ hashtag.tagName }}</div>
            <div class="stat-value">{{ hashtag.postCount }} 篇帖子</div>
          </div>
        </div>
      </el-card>
    </div>

    <div class="hashtags-container" v-loading="loading">
      <template v-if="filteredHashtags.length > 0">
        <div class="hashtag-grid">
          <el-card
            v-for="hashtag in filteredHashtags"
            :key="hashtag.hashtagId"
            class="hashtag-card"
            shadow="hover"
            @click="navigateToHashtagPosts(hashtag)"
          >
            <div class="hashtag-content">
              <h3>#{{ hashtag.tagName }}</h3>
              <div class="hashtag-meta">
                <el-icon><Collection /></el-icon>
                <span>{{ hashtag.postCount }} 篇帖子</span>
              </div>
              <div class="hashtag-meta">
                <el-icon><Calendar /></el-icon>
                <span>{{ formatDate(hashtag.createdAt) }}</span>
              </div>
            </div>
          </el-card>
        </div>
      </template>
      <el-empty v-else description="暂无话题数据" />

      <Pagination
        v-if="totalElements > 0"
        :current-page="currentPage"
        :page-size="pageSize"
        :total="totalElements"
        @change="handlePageChange"
      />
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue'
import { useRouter } from 'vue-router'
import { useHashtagsStore } from '../stores/hashtags'
import { ElMessage } from 'element-plus'
import { Collection, Calendar } from '@element-plus/icons-vue'
import HashtagFilter from '../components/HashtagFilter.vue'
import Pagination from '../components/Pagination.vue'

const router = useRouter()
const hashtagsStore = useHashtagsStore()

const loading = ref(false)
const selectedHashtags = ref([])
const filterKeyword = ref('')

const hashtags = computed(() => hashtagsStore.hashtags)
const filteredHashtags = computed(() => {
  if (!filterKeyword.value) {
    return hashtags.value
  }
  const keyword = filterKeyword.value.toLowerCase()
  return hashtags.value.filter(h =>
    h.tagName.toLowerCase().includes(keyword)
  )
})
const currentPage = computed(() => hashtagsStore.pagination.page + 1)
const pageSize = computed(() => hashtagsStore.pagination.size)
const totalElements = computed(() => hashtagsStore.pagination.totalElements)

const fetchHashtags = async (page = 0, size = 20) => {
  loading.value = true
  try {
    await hashtagsStore.fetchHashtags(page, size)
  } catch (error) {
    ElMessage.error(error.message || '获取话题列表失败')
  } finally {
    loading.value = false
  }
}

const handlePageChange = ({ page, size }) => {
  fetchHashtags(page - 1, size)
}

const handleHashtagSelectionChange = (selected) => {
  selectedHashtags.value = selected
}

const handleFilter = (keyword) => {
  filterKeyword.value = keyword
}

const navigateToHashtagPosts = (hashtag) => {
  router.push(`/hashtags/${hashtag.hashtagId}/posts`)
}

const formatDate = (date) => {
  if (!date) return ''
  return new Date(date).toLocaleDateString('zh-CN')
}

onMounted(() => {
  fetchHashtags()
})
</script>

<style scoped>
.hashtag-list-view {
  padding: 20px 0;
}

.page-header {
  margin-bottom: 20px;
}

.page-header h2 {
  margin: 0;
  color: #303133;
}

.hashtag-stats {
  margin-bottom: 20px;
}

.stats-content {
  display: flex;
  flex-wrap: wrap;
  gap: 16px;
}

.stat-item {
  flex: 1;
  min-width: 200px;
}

.stat-label {
  font-size: 16px;
  font-weight: 600;
  color: #409eff;
  margin-bottom: 4px;
}

.stat-value {
  font-size: 14px;
  color: #606266;
}

.hashtags-container {
  min-height: 400px;
}

.hashtag-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
  gap: 16px;
  margin-bottom: 20px;
}

.hashtag-card {
  cursor: pointer;
  transition: transform 0.2s;
}

.hashtag-card:hover {
  transform: translateY(-4px);
}

.hashtag-content h3 {
  margin: 0 0 12px 0;
  color: #409eff;
  font-size: 18px;
}

.hashtag-meta {
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 14px;
  color: #909399;
  margin-bottom: 6px;
}
</style>
