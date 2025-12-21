<template>
  <div class="profile-view">
    <div class="profile-panel">
      <div class="profile-header">
        <div class="avatar-wrapper">
          <span class="avatar-text">{{ user?.username?.[0]?.toUpperCase() }}</span>
        </div>
        <div class="header-info">
          <h2 class="username">{{ user?.username }}</h2>
          <span class="role-badge" :class="{ 'admin': user?.role === 'ADMIN' }">
            {{ user?.role === 'ADMIN' ? '管理员' : '社区成员' }}
          </span>
        </div>
      </div>
      
      <div class="divider"></div>

      <div class="info-list">
        <div class="info-item">
          <span class="label">邮箱地址</span>
          <span class="value">{{ user?.email }}</span>
        </div>
        <div class="info-item">
          <span class="label">注册时间</span>
          <span class="value">{{ formatDate(user?.createdAt) }}</span>
        </div>
        <div class="info-item">
          <span class="label">账户状态</span>
          <span class="status-badge" :class="{ 'active': user?.active !== false }">
            <span class="dot"></span>
            {{ user?.active !== false ? '活跃' : '已禁用' }}
          </span>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { useAuthStore } from '../stores/auth'

const authStore = useAuthStore()
const user = computed(() => authStore.user)

const formatDate = (date) => {
  if (!date) return '-'
  return new Date(date).toLocaleDateString('zh-CN', {
    year: 'numeric',
    month: 'long',
    day: 'numeric'
  })
}
</script>

<style scoped>
.profile-view {
  min-height: 60vh;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 40px 20px;
}

.profile-panel {
  background: #ffffff;
  width: 100%;
  max-width: 480px;
  border-radius: 24px;
  padding: 40px;
  box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04);
  border: none;
}

.profile-header {
  display: flex;
  flex-direction: column;
  align-items: center;
  text-align: center;
  margin-bottom: 32px;
}

.avatar-wrapper {
  width: 96px;
  height: 96px;
  background: linear-gradient(135deg, #18181b 0%, #3f3f46 100%);
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 20px;
  box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1);
  border: 4px solid #fff;
  outline: 2px solid #f4f4f5;
}

.avatar-text {
  font-size: 36px;
  font-weight: 700;
  color: white;
}

.username {
  font-size: 24px;
  font-weight: 800;
  color: #18181b;
  margin: 0 0 8px 0;
}

.role-badge {
  display: inline-block;
  padding: 4px 12px;
  background-color: #f4f4f5;
  color: #71717a;
  border-radius: 100px;
  font-size: 13px;
  font-weight: 600;
}

.role-badge.admin {
  background-color: #fff1f2;
  color: #e11d48;
}

.divider {
  height: 1px;
  background-color: #f4f4f5;
  margin: 0 0 32px 0;
}

.info-list {
  display: flex;
  flex-direction: column;
  gap: 24px;
}

.info-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.label {
  color: #71717a;
  font-size: 14px;
  font-weight: 500;
}

.value {
  color: #18181b;
  font-size: 15px;
  font-weight: 600;
}

.status-badge {
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 14px;
  font-weight: 600;
  color: #ef4444; /* Default inactive */
}

.status-badge.active {
  color: #10b981;
}

.dot {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  background-color: currentColor;
}
</style>
