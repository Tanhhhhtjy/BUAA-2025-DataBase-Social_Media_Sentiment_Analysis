<template>
  <div class="keyword-management">
    <div class="actions">
      <el-button type="primary" @click="showAddDialog = true">
        <el-icon><Plus /></el-icon>
        添加关键词
      </el-button>
    </div>

    <el-table :data="keywords" v-loading="loading" stripe>
      <el-table-column prop="keywordId" label="ID" width="80" />
      <el-table-column prop="keyword" label="关键词" />
      <el-table-column prop="category" label="类别" width="150" />
      <el-table-column prop="createdAt" label="创建时间" width="180" />
      <el-table-column label="操作" width="150">
        <template #default="{ row }">
          <el-button size="small" @click="handleEditKeyword(row)">编辑</el-button>
          <el-button size="small" type="danger" @click="handleDeleteKeyword(row)">
            删除
          </el-button>
        </template>
      </el-table-column>
    </el-table>

    <el-dialog
      v-model="showAddDialog"
      :title="editingKeyword ? '编辑关键词' : '添加关键词'"
      width="500px"
    >
      <el-form :model="keywordForm" label-width="100px">
        <el-form-item label="关键词" required>
          <el-input v-model="keywordForm.keyword" placeholder="请输入关键词" />
        </el-form-item>
        <el-form-item label="类别" required>
          <el-input v-model="keywordForm.category" placeholder="请输入类别" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="showAddDialog = false">取消</el-button>
        <el-button type="primary" @click="handleSaveKeyword">保存</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Plus } from '@element-plus/icons-vue'

const loading = ref(false)
const keywords = ref([])
const showAddDialog = ref(false)
const editingKeyword = ref(null)

const keywordForm = reactive({
  keyword: '',
  category: ''
})

const fetchKeywords = async () => {
  loading.value = true
  try {
    // 这里需要调用关键词管理 API
    console.log('获取关键词列表')
  } catch (error) {
    ElMessage.error('获取关键词列表失败')
  } finally {
    loading.value = false
  }
}

const handleEditKeyword = (keyword) => {
  editingKeyword.value = keyword
  keywordForm.keyword = keyword.keyword
  keywordForm.category = keyword.category
  showAddDialog.value = true
}

const handleDeleteKeyword = async (keyword) => {
  try {
    await ElMessageBox.confirm(
      `确定要删除关键词 "${keyword.keyword}" 吗？`,
      '提示',
      {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }
    )
    // 这里需要调用删除关键词的 API
    ElMessage.success('删除成功')
    fetchKeywords()
  } catch (error) {
    // 用户取消
  }
}

const handleSaveKeyword = async () => {
  if (!keywordForm.keyword || !keywordForm.category) {
    ElMessage.warning('请填写完整信息')
    return
  }

  try {
    // 这里需要调用保存关键词的 API
    ElMessage.success(editingKeyword.value ? '更新成功' : '添加成功')
    showAddDialog.value = false
    editingKeyword.value = null
    keywordForm.keyword = ''
    keywordForm.category = ''
    fetchKeywords()
  } catch (error) {
    ElMessage.error('保存失败')
  }
}

fetchKeywords()
</script>

<style scoped>
.keyword-management {
  padding: 20px 0;
}

.actions {
  margin-bottom: 20px;
}
</style>
