<template>
  <div class="keyword-management">
    <div class="page-header">
      <h2>关键词管理</h2>
      <el-button type="primary" @click="showAddDialog">
        <el-icon><Plus /></el-icon>
        添加关键词
      </el-button>
    </div>

    <el-table
      v-loading="loading"
      :data="keywords"
      stripe
      style="width: 100%"
    >
      <el-table-column prop="keywordId" label="ID" width="80" />
      <el-table-column prop="keyword" label="关键词" width="200" />
      <el-table-column prop="category" label="类别" width="150">
        <template #default="{ row }">
          <el-tag v-if="row.category">{{ row.category }}</el-tag>
          <span v-else class="text-muted">未分类</span>
        </template>
      </el-table-column>
      <el-table-column prop="createdAt" label="创建时间" width="180">
        <template #default="{ row }">
          {{ formatDate(row.createdAt) }}
        </template>
      </el-table-column>
      <el-table-column label="操作" fixed="right" width="150">
        <template #default="{ row }">
          <el-button type="primary" size="small" @click="showEditDialog(row)">
            编辑
          </el-button>
          <el-button type="danger" size="small" @click="handleDelete(row)">
            删除
          </el-button>
        </template>
      </el-table-column>
    </el-table>

    <div class="pagination-container">
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

    <!-- 添加/编辑对话框 -->
    <el-dialog
      v-model="dialogVisible"
      :title="editingKeyword ? '编辑关键词' : '添加关键词'"
      width="400px"
    >
      <el-form :model="form" label-width="80px">
        <el-form-item label="关键词" required>
          <el-input v-model="form.keyword" placeholder="请输入敏感关键词" />
        </el-form-item>
        <el-form-item label="类别">
          <el-select v-model="form.category" placeholder="选择类别" clearable style="width: 100%">
            <el-option label="政治敏感" value="政治敏感" />
            <el-option label="色情低俗" value="色情低俗" />
            <el-option label="暴力恐怖" value="暴力恐怖" />
            <el-option label="违法犯罪" value="违法犯罪" />
            <el-option label="其他" value="其他" />
          </el-select>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleSubmit" :loading="submitting">
          确定
        </el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Plus } from '@element-plus/icons-vue'
import { adminAPI } from '../../api/admin'

const loading = ref(false)
const submitting = ref(false)
const keywords = ref([])
const total = ref(0)
const currentPage = ref(1)
const pageSize = ref(10)

const dialogVisible = ref(false)
const editingKeyword = ref(null)
const form = ref({
  keyword: '',
  category: ''
})

const fetchKeywords = async () => {
  loading.value = true
  try {
    const response = await adminAPI.getKeywords({
      page: currentPage.value - 1,
      size: pageSize.value
    })
    keywords.value = response.content || []
    total.value = response.totalElements || 0
  } catch (error) {
    ElMessage.error(error.message || '获取关键词列表失败')
  } finally {
    loading.value = false
  }
}

const handlePageChange = (page) => {
  currentPage.value = page
  fetchKeywords()
}

const handleSizeChange = (size) => {
  pageSize.value = size
  currentPage.value = 1
  fetchKeywords()
}

const showAddDialog = () => {
  editingKeyword.value = null
  form.value = { keyword: '', category: '' }
  dialogVisible.value = true
}

const showEditDialog = (keyword) => {
  editingKeyword.value = keyword
  form.value = {
    keyword: keyword.keyword,
    category: keyword.category || ''
  }
  dialogVisible.value = true
}

const handleSubmit = async () => {
  if (!form.value.keyword.trim()) {
    ElMessage.warning('请输入关键词')
    return
  }

  submitting.value = true
  try {
    if (editingKeyword.value) {
      await adminAPI.updateKeyword(editingKeyword.value.keywordId, form.value)
      ElMessage.success('关键词已更新')
    } else {
      await adminAPI.addKeyword(form.value)
      ElMessage.success('关键词已添加')
    }
    dialogVisible.value = false
    fetchKeywords()
  } catch (error) {
    ElMessage.error(error.message || '操作失败')
  } finally {
    submitting.value = false
  }
}

const handleDelete = async (keyword) => {
  try {
    await ElMessageBox.confirm(
      `确定要删除关键词 "${keyword.keyword}" 吗？`,
      '确认删除',
      { type: 'warning' }
    )
    await adminAPI.deleteKeyword(keyword.keywordId)
    ElMessage.success('关键词已删除')
    fetchKeywords()
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error(error.message || '删除失败')
    }
  }
}

const formatDate = (dateStr) => {
  if (!dateStr) return ''
  return new Date(dateStr).toLocaleString('zh-CN')
}

onMounted(() => {
  fetchKeywords()
})
</script>

<style scoped>
.keyword-management {
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

.pagination-container {
  display: flex;
  justify-content: flex-end;
  margin-top: 20px;
}

.text-muted {
  color: #909399;
}
</style>
