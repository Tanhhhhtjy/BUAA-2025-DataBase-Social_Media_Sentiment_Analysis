<template>
  <div class="hashtag-list-view">
    <div class="page-header">
      <h2>话题广场</h2>
      <p class="subtitle">发现热门讨论与趋势</p>
    </div>

    <HashtagFilter
      :hashtags="hashtags"
      @change="handleHashtagSelectionChange"
      @filter="handleFilter"
      class="custom-filter"
    />

    <div class="hashtag-stats" v-if="selectedHashtags.length > 0">
      <div class="stats-panel">
        <div class="stats-header">已选话题概览</div>
        <div class="stats-content">
          <div class="stat-pill" v-for="hashtag in selectedHashtags" :key="hashtag.hashtagId">
            <span class="pill-label">#{{ hashtag.tagName }}</span>
            <span class="pill-value">{{ hashtag.postCount }} 篇</span>
          </div>
        </div>
      </div>
    </div>

    <div class="hashtags-container" v-loading="loading">
      <template v-if="filteredHashtags.length > 0">
        <div class="hashtag-grid">
          <div
            v-for="hashtag in filteredHashtags"
            :key="hashtag.hashtagId"
            class="hashtag-card"
            @click="navigateToHashtagPosts(hashtag)"
          >
            <div class="card-body">
              <h3 class="tag-name">#{{ hashtag.tagName }}</h3>
              <div class="meta-row">
                <div class="meta-item">
                  <el-icon><Collection /></el-icon>
                  <span>{{ hashtag.postCount }} 篇帖子</span>
                </div>
                <div class="meta-item">
                  <el-icon><Calendar /></el-icon>
                  <span>{{ formatDate(hashtag.createdAt) }}</span>
                </div>
              </div>
            </div>
            <div class="card-footer">
              <span class="view-link">查看详情 →</span>
            </div>
          </div>
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
  max-width: 1200px;
  margin: 0 auto;
}

.page-header {
  margin-bottom: 32px;
  text-align: center;
}

.page-header h2 {
  font-size: 32px;
  font-weight: 800;
  color: #18181b;
  margin-bottom: 8px;
  letter-spacing: -0.5px;
}

.subtitle {
  color: #71717a;
  font-size: 16px;
}

/* 覆盖 Filter 组件样式 */
:deep(.custom-filter) {
  background: transparent;
  padding: 0;
  margin-bottom: 40px;
  display: flex;
  justify-content: center;
}

:deep(.custom-filter .el-input__wrapper) {
  box-shadow: 0 4px 12px rgba(0,0,0,0.05);
  border-radius: 100px;
  padding-left: 16px;
}

.hashtag-stats {
  margin-bottom: 32px;
}

.stats-panel {
  background: #ffffff;
  border-radius: 16px;
  padding: 20px;
  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.02);
}

.stats-header {
  font-size: 14px;
  font-weight: 600;
  color: #71717a;
  margin-bottom: 12px;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.stats-content {
  display: flex;
  flex-wrap: wrap;
  gap: 12px;
}

.stat-pill {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  background: #f4f4f5;
  padding: 6px 12px;
  border-radius: 8px;
  font-size: 14px;
}

.pill-label {
  color: #18181b;
  font-weight: 600;
}

.pill-value {
  color: #71717a;
}

.hashtags-container {
  min-height: 400px;
}

.hashtag-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
  gap: 24px;
  margin-bottom: 40px;
}

/* 现代卡片样式 */
.hashtag-card {
  background: #ffffff;
  border-radius: 16px;
  padding: 24px;
  cursor: pointer;
  transition: all 0.3s ease;
  border: 1px solid rgba(0,0,0,0.04);
  display: flex;
  flex-direction: column;
  justify-content: space-between;
  height: 180px;
  position: relative;
  overflow: hidden;
}

.hashtag-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 12px 30px rgba(0,0,0,0.06);
  border-color: rgba(0,0,0,0);
}

/* 装饰性背景圆 */
.hashtag-card::after {
  content: '';
  position: absolute;
  top: -20px;
  right: -20px;
  width: 80px;
  height: 80px;
  background: linear-gradient(135deg, rgba(64, 158, 255, 0.1), rgba(64, 158, 255, 0.02));
  border-radius: 50%;
  transition: transform 0.3s;
}

.hashtag-card:hover::after {
  transform: scale(1.5);
}

.tag-name {
  margin: 0 0 16px 0;
  color: #18181b; /* 深色标题 */
  font-size: 20px;
  font-weight: 700;
  line-height: 1.4;
  word-break: break-all;
}

.meta-row {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.meta-item {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 14px;
  color: #71717a; /* 灰色元数据 */
}

.meta-item .el-icon {
  color: #a1a1aa;
}

.card-footer {
  margin-top: auto;
  padding-top: 16px;
  display: flex;
  justify-content: flex-end;
}

.view-link {
  font-size: 13px;
  color: #18181b;
  font-weight: 600;
  opacity: 0;
  transform: translateX(-10px);
  transition: all 0.3s;
}

.hashtag-card:hover .view-link {
  opacity: 1;
  transform: translateX(0);
}
</style>
