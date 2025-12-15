<template>
  <div class="user-management">
    <div class="page-header">
      <h2>用户管理</h2>
      <el-input
        v-model="searchQuery"
        placeholder="搜索用户名或邮箱"
        style="width: 300px"
        clearable
        @clear="handleSearch"
        @keyup.enter="handleSearch"
      >
        <template #append>
          <el-button @click="handleSearch">
            <el-icon><Search /></el-icon>
          </el-button>
        </template>
      </el-input>
    </div>

    <el-table
      v-loading="loading"
      :data="filteredUsers"
      stripe
      style="width: 100%"
    >
      <el-table-column prop="userId" label="ID" width="80" />
      <el-table-column prop="username" label="用户名" width="150" />
      <el-table-column prop="email" label="邮箱" width="220" />
      <el-table-column prop="role" label="角色" width="100">
        <template #default="{ row }">
          <el-tag :type="row.role === 'ADMIN' ? 'danger' : 'primary'">
            {{ row.role === 'ADMIN' ? '管理员' : '普通用户' }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="status" label="状态" width="100">
        <template #default="{ row }">
          <el-tag :type="row.status === 'ACTIVE' ? 'success' : 'info'">
            {{ row.status === 'ACTIVE' ? '正常' : '已禁用' }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="createdAt" label="注册时间" width="180">
        <template #default="{ row }">
          {{ formatDate(row.createdAt) }}
        </template>
      </el-table-column>
      <el-table-column label="操作" fixed="right" width="200">
        <template #default="{ row }">
          <el-button
            v-if="row.status === 'ACTIVE'"
            type="warning"
            size="small"
            @click="handleDisable(row)"
            :disabled="row.role === 'ADMIN'"
          >
            禁用
          </el-button>
          <el-button
            v-else
            type="success"
            size="small"
            @click="handleEnable(row)"
          >
            启用
          </el-button>
          <el-button
            type="danger"
            size="small"
            @click="handleDelete(row)"
            :disabled="row.role === 'ADMIN'"
          >
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
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Search } from '@element-plus/icons-vue'
import { adminAPI } from '../../api/admin'

const loading = ref(false)
const users = ref([])
const total = ref(0)
const currentPage = ref(1)
const pageSize = ref(10)
const searchQuery = ref('')

const filteredUsers = computed(() => {
  if (!searchQuery.value) return users.value
  const query = searchQuery.value.toLowerCase()
  return users.value.filter(user =>
    user.username.toLowerCase().includes(query) ||
    user.email.toLowerCase().includes(query)
  )
})

const fetchUsers = async () => {
  loading.value = true
  try {
    const response = await adminAPI.getUsers({
      page: currentPage.value - 1,
      size: pageSize.value
    })
    users.value = response.content || []
    total.value = response.totalElements || 0
  } catch (error) {
    ElMessage.error(error.message || '获取用户列表失败')
  } finally {
    loading.value = false
  }
}

const handleSearch = () => {
  currentPage.value = 1
}

const handlePageChange = (page) => {
  currentPage.value = page
  fetchUsers()
}

const handleSizeChange = (size) => {
  pageSize.value = size
  currentPage.value = 1
  fetchUsers()
}

const handleDisable = async (user) => {
  try {
    await ElMessageBox.confirm(
      `确定要禁用用户 "${user.username}" 吗？禁用后该用户将无法登录。`,
      '确认禁用',
      { type: 'warning' }
    )
    await adminAPI.disableUser(user.userId)
    ElMessage.success('用户已禁用')
    fetchUsers()
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error(error.message || '操作失败')
    }
  }
}

const handleEnable = async (user) => {
  try {
    await adminAPI.enableUser(user.userId)
    ElMessage.success('用户已启用')
    fetchUsers()
  } catch (error) {
    ElMessage.error(error.message || '操作失败')
  }
}

const handleDelete = async (user) => {
  try {
    await ElMessageBox.confirm(
      `确定要删除用户 "${user.username}" 吗？该用户的所有帖子和评论也将被删除，此操作不可恢复！`,
      '确认删除',
      { type: 'error' }
    )
    await adminAPI.deleteUser(user.userId)
    ElMessage.success('用户已删除')
    fetchUsers()
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
  fetchUsers()
})
</script>

<style scoped>
.user-management {
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
</style>
