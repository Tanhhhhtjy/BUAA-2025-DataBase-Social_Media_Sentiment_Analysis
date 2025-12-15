<template>
  <div class="alert-list">
    <div class="filters">
      <el-select v-model="selectedCategory" placeholder="选择类别" clearable style="width: 200px">
        <el-option label="类别A" value="categoryA" />
        <el-option label="类别B" value="categoryB" />
      </el-select>
      <el-select v-model="selectedContentType" placeholder="内容类型" clearable style="width: 150px; margin-left: 12px">
        <el-option label="帖子" value="POST" />
        <el-option label="评论" value="COMMENT" />
      </el-select>
      <el-button style="margin-left: 12px" @click="fetchAlerts">查询</el-button>
    </div>

    <el-table :data="alerts" v-loading="loading" stripe>
      <el-table-column prop="alertId" label="预警ID" width="100" />
      <el-table-column prop="contentType" label="类型" width="100">
        <template #default="{ row }">
          <el-tag :type="row.contentType === 'POST' ? 'primary' : 'info'">
            {{ row.contentType === 'POST' ? '帖子' : '评论' }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="summary" label="内容摘要" show-overflow-tooltip />
      <el-table-column prop="keyword" label="关键词" width="150" />
      <el-table-column prop="category" label="类别" width="120" />
      <el-table-column prop="authorUsername" label="作者" width="120" />
      <el-table-column prop="createdAt" label="预警时间" width="180" />
      <el-table-column label="操作" width="100">
        <template #default="{ row }">
          <el-button size="small" @click="handleViewContent(row)">
            查看
          </el-button>
        </template>
      </el-table-column>
    </el-table>

    <el-dialog v-model="showContentDialog" title="内容详情" width="600px">
      <div v-if="selectedAlert">
        <p><strong>类型:</strong> {{ selectedAlert.contentType === 'POST' ? '帖子' : '评论' }}</p>
        <p><strong>关键词:</strong> {{ selectedAlert.keyword }}</p>
        <p><strong>类别:</strong> {{ selectedAlert.category }}</p>
        <p><strong>作者:</strong> {{ selectedAlert.authorUsername }}</p>
        <p><strong>内容:</strong></p>
        <div class="content-box">{{ selectedAlert.summary }}</div>
      </div>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive } from 'vue'
import { ElMessage } from 'element-plus'

const loading = ref(false)
const alerts = ref([])
const showContentDialog = ref(false)
const selectedAlert = ref(null)
const selectedCategory = ref('')
const selectedContentType = ref('')

const fetchAlerts = async () => {
  loading.value = true
  try {
    // 这里需要调用预警列表 API
    console.log('获取预警列表', selectedCategory.value, selectedContentType.value)
  } catch (error) {
    ElMessage.error('获取预警列表失败')
  } finally {
    loading.value = false
  }
}

const handleViewContent = (alert) => {
  selectedAlert.value = alert
  showContentDialog.value = true
}

fetchAlerts()
</script>

<style scoped>
.alert-list {
  padding: 20px 0;
}

.filters {
  margin-bottom: 20px;
  display: flex;
  align-items: center;
}

.content-box {
  margin-top: 12px;
  padding: 16px;
  background: #f5f7fa;
  border-radius: 4px;
  line-height: 1.6;
}
</style>
