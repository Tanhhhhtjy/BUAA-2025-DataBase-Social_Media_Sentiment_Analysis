<template>
  <div class="user-management">
    <el-table :data="users" v-loading="loading" stripe>
      <el-table-column prop="userId" label="用户ID" width="100" />
      <el-table-column prop="username" label="用户名" />
      <el-table-column prop="email" label="邮箱" />
      <el-table-column prop="role" label="角色" width="100">
        <template #default="{ row }">
          <el-tag :type="row.role === 'ADMIN' ? 'danger' : 'info'">
            {{ row.role }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="status" label="状态" width="100">
        <template #default="{ row }">
          <el-tag :type="row.status === 'ACTIVE' ? 'success' : 'warning'">
            {{ row.status === 'ACTIVE' ? '活跃' : '禁用' }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="createdAt" label="创建时间" />
      <el-table-column label="操作" width="200">
        <template #default="{ row }">
          <el-button
            v-if="row.status === 'ACTIVE'"
            size="small"
            @click="handleToggleStatus(row)"
          >
            禁用
          </el-button>
          <el-button
            v-else
            size="small"
            type="success"
            @click="handleToggleStatus(row)"
          >
            启用
          </el-button>
          <el-button
            size="small"
            type="danger"
            @click="handleDeleteUser(row)"
          >
            删除
          </el-button>
        </template>
      </el-table-column>
    </el-table>

    <Pagination
      v-if="totalElements > 0"
      :current-page="currentPage"
      :page-size="pageSize"
      :total="totalElements"
      @change="handlePageChange"
    />
  </div>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import Pagination from '../../components/Pagination.vue'

const loading = ref(false)
const users = ref([])
const currentPage = ref(0)
const pageSize = ref(20)
const totalElements = ref(0)

const fetchUsers = async (page = 0, size = 20) => {
  loading.value = true
  try {
    // 这里需要调用用户管理 API
    console.log('获取用户列表:', page, size)
  } catch (error) {
    ElMessage.error('获取用户列表失败')
  } finally {
    loading.value = false
  }
}

const handlePageChange = ({ page, size }) => {
  fetchUsers(page, size)
}

const handleToggleStatus = async (user) => {
  try {
    await ElMessageBox.confirm(
      `确定要${user.status === 'ACTIVE' ? '禁用' : '启用'}用户 ${user.username} 吗？`,
      '提示',
      {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }
    )
    // 这里需要调用切换状态的 API
    ElMessage.success('操作成功')
    fetchUsers(currentPage.value, pageSize.value)
  } catch (error) {
    // 用户取消
  }
}

const handleDeleteUser = async (user) => {
  try {
    await ElMessageBox.confirm(
      `确定要删除用户 ${user.username} 吗？此操作不可恢复！`,
      '警告',
      {
        confirmButtonText: '确定删除',
        cancelButtonText: '取消',
        type: 'error'
      }
    )
    // 这里需要调用删除用户的 API
    ElMessage.success('删除成功')
    fetchUsers(currentPage.value, pageSize.value)
  } catch (error) {
    // 用户取消
  }
}

onMounted(() => {
  fetchUsers()
})
</script>

<style scoped>
.user-management {
  padding: 20px 0;
}
</style>
