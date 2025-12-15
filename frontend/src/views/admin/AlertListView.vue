<template>
  <div class="alert-list">
    <div class="page-header">
      <h2>预警列表</h2>
      <div class="filter-controls">
        <el-select v-model="hoursFilter" @change="fetchAlerts" style="width: 150px">
          <el-option label="最近24小时" :value="24" />
          <el-option label="最近48小时" :value="48" />
          <el-option label="最近72小时" :value="72" />
          <el-option label="最近7天" :value="168" />
        </el-select>
        <el-button @click="fetchAlerts" :loading="loading">
          <el-icon><Refresh /></el-icon>
          刷新
        </el-button>
      </div>
    </div>

    <el-alert
      v-if="total > 0"
      :title="`发现 ${total} 条预警`"
      type="warning"
      :closable="false"
      show-icon
      style="margin-bottom: 20px"
    />

    <el-table
      v-loading="loading"
      :data="alerts"
      stripe
      style="width: 100%"
    >
      <el-table-column prop="alertId" label="ID" width="80" />
      <el-table-column prop="contentType" label="类型" width="100">
        <template #default="{ row }">
          <el-tag :type="row.contentType === 'POST' ? 'primary' : 'success'">
            {{ row.contentType === 'POST' ? '帖子' : '评论' }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="keyword" label="命中关键词" width="120">
        <template #default="{ row }">
          <el-tag type="danger">{{ row.keyword }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="summary" label="内容摘要" min-width="200">
        <template #default="{ row }">
          <el-tooltip :content="row.summary" placement="top" :show-after="500">
            <span class="content-excerpt">{{ truncate(row.summary, 50) }}</span>
          </el-tooltip>
        </template>
      </el-table-column>
      <el-table-column prop="username" label="发布者" width="120" />
      <el-table-column prop="createdAt" label="预警时间" width="180">
        <template #default="{ row }">
          {{ formatDate(row.createdAt) }}
        </template>
      </el-table-column>
      <el-table-column label="操作" fixed="right" width="180">
        <template #default="{ row }">
          <el-button type="primary" size="small" @click="viewContent(row)">
            查看
          </el-button>
          <el-button type="success" size="small" @click="handleMark(row)">
            已处理
          </el-button>
          <el-button type="danger" size="small" @click="handleDelete(row)">
            删除
          </el-button>
        </template>
      </el-table-column>
    </el-table>

    <el-empty v-if="!loading && alerts.length === 0" description="暂无预警信息" />

    <div class="pagination-container" v-if="total > 0">
      <el-pagination
        v-model:current-page="currentPage"
        v-model:page-size="pageSize"
        :page-sizes="[10, 20, 50]"
        :total="total"
        layout="total, sizes, prev, pager, next, jumper"
        @size-change="handleSizeChange"
        @current-change="handlePageChange"
      />
    </div>

    <!-- 内容详情对话框 -->
    <el-dialog
      v-model="detailDialogVisible"
      title="内容详情"
      width="500px"
    >
      <div v-if="selectedAlert" class="alert-detail">
        <el-descriptions :column="1" border>
          <el-descriptions-item label="类型">
            {{ selectedAlert.contentType === 'POST' ? '帖子' : '评论' }}
          </el-descriptions-item>
          <el-descriptions-item label="命中关键词">
            <el-tag type="danger">{{ selectedAlert.keyword }}</el-tag>
          </el-descriptions-item>
          <el-descriptions-item label="发布者">
            {{ selectedAlert.username }}
          </el-descriptions-item>
          <el-descriptions-item label="预警时间">
            {{ formatDate(selectedAlert.createdAt) }}
          </el-descriptions-item>
          <el-descriptions-item label="内容">
            {{ selectedAlert.summary }}
          </el-descriptions-item>
        </el-descriptions>
      </div>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Refresh } from '@element-plus/icons-vue'
import { adminAPI } from '../../api/admin'

const loading = ref(false)
const alerts = ref([])
const total = ref(0)
const currentPage = ref(1)
const pageSize = ref(10)
const hoursFilter = ref(24)

const detailDialogVisible = ref(false)
const selectedAlert = ref(null)

const fetchAlerts = async () => {
  loading.value = true
  try {
    const response = await adminAPI.getAlerts({
      page: currentPage.value - 1,
      size: pageSize.value,
      hours: hoursFilter.value
    })
    alerts.value = response.content || []
    total.value = response.totalElements || 0
  } catch (error) {
    ElMessage.error(error.message || '获取预警列表失败')
  } finally {
    loading.value = false
  }
}

const handlePageChange = (page) => {
  currentPage.value = page
  fetchAlerts()
}

const handleSizeChange = (size) => {
  pageSize.value = size
  currentPage.value = 1
  fetchAlerts()
}

const viewContent = (alert) => {
  selectedAlert.value = alert
  detailDialogVisible.value = true
}

const handleMark = async (alert) => {
  try {
    await adminAPI.markAlertHandled(alert.alertId)
    ElMessage.success('已标记为已处理')
    fetchAlerts()
  } catch (error) {
    ElMessage.error(error.message || '操作失败')
  }
}

const handleDelete = async (alert) => {
  try {
    await ElMessageBox.confirm(
      '确定要删除这条预警吗？',
      '确认删除',
      { type: 'warning' }
    )
    await adminAPI.deleteAlert(alert.alertId)
    ElMessage.success('预警已删除')
    fetchAlerts()
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error(error.message || '删除失败')
    }
  }
}

const truncate = (text, length) => {
  if (!text) return ''
  return text.length > length ? text.substring(0, length) + '...' : text
}

const formatDate = (dateStr) => {
  if (!dateStr) return ''
  return new Date(dateStr).toLocaleString('zh-CN')
}

onMounted(() => {
  fetchAlerts()
})
</script>

<style scoped>
.alert-list {
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

.filter-controls {
  display: flex;
  gap: 12px;
  align-items: center;
}

.pagination-container {
  display: flex;
  justify-content: flex-end;
  margin-top: 20px;
}

.content-excerpt {
  display: inline-block;
  max-width: 300px;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.alert-detail {
  padding: 10px 0;
}
</style>
