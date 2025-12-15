<template>
  <div class="admin-view">
    <div class="page-header">
      <h2>管理后台</h2>
    </div>

    <el-tabs v-model="activeTab">
      <el-tab-pane label="用户管理" name="users">
        <UserManagementView />
      </el-tab-pane>
      <el-tab-pane label="关键词管理" name="keywords">
        <KeywordManagementView />
      </el-tab-pane>
      <el-tab-pane label="预警监控" name="alerts">
        <AlertListView />
      </el-tab-pane>
    </el-tabs>
  </div>
</template>

<script setup>
import { ref } from 'vue'

const activeTab = ref('users')

// 导入子组件
import UserManagementView from './UserManagementView.vue'
import KeywordManagementView from './KeywordManagementView.vue'
import AlertListView from './AlertListView.vue'
</script>

<style scoped>
.admin-view {
  padding: 20px 0;
}

.page-header {
  margin-bottom: 20px;
}

.page-header h2 {
  margin: 0;
  color: #303133;
}
</style>
