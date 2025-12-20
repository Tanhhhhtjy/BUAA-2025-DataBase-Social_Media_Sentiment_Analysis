<template>
  <div id="app">
    <el-container>
      <el-header>
        <div class="header-content">
          <h1>社交媒体舆情分析系统</h1>
          <el-menu
            mode="horizontal"
            :router="true"
            :default-active="activeMenu"
            class="main-menu"
          >
            <el-menu-item index="/">首页</el-menu-item>
            <el-menu-item index="/posts">帖子列表</el-menu-item>
            <el-menu-item index="/hashtags">话题列表</el-menu-item>
            <el-menu-item index="/analytics">数据分析</el-menu-item>
            <el-menu-item index="/admin" v-if="isAdmin">管理后台</el-menu-item>
          </el-menu>
          <div class="auth-buttons">
            <template v-if="!isAuthenticated">
              <el-button type="primary" @click="$router.push('/login')">登录</el-button>
              <el-button @click="$router.push('/register')">注册</el-button>
            </template>
            <template v-else>
              <span class="username">欢迎, {{ username }}</span>
              <el-button @click="logout">退出</el-button>
            </template>
          </div>
        </div>
      </el-header>
      <el-main>
        <router-view />
      </el-main>
    </el-container>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { useRoute } from 'vue-router'
import { useAuthStore } from './stores/auth'

const route = useRoute()
const authStore = useAuthStore()

const activeMenu = computed(() => {
  const path = route.path
  // 处理子路由，如 /posts/123 应该高亮 /posts
  if (path.startsWith('/posts')) return '/posts'
  if (path.startsWith('/hashtags')) return '/hashtags'
  if (path.startsWith('/analytics')) return '/analytics'
  if (path.startsWith('/admin')) return '/admin'
  return path
})

const isAuthenticated = computed(() => authStore.isAuthenticated)
const username = computed(() => authStore.user?.username)
const isAdmin = computed(() => authStore.user?.role === 'ADMIN')

const logout = () => {
  authStore.logout()
}
</script>

<style>
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

#app {
  font-family: 'Helvetica Neue', Helvetica, 'PingFang SC', 'Hiragino Sans GB', 'Microsoft YaHei', '微软雅黑', Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  color: #2c3e50;
}

.el-container {
  min-height: 100vh;
}

.el-header {
  background-color: #409eff;
  color: white;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.header-content {
  display: flex;
  align-items: center;
  justify-content: space-between;
  max-width: 1200px;
  margin: 0 auto;
  height: 100%;
}

.header-content h1 {
  font-size: 20px;
  margin-right: 30px;
}

.main-menu {
  flex: 1;
  background-color: transparent !important;
  border-bottom: none;
}

.el-menu-item {
  color: white !important;
  background-color: transparent !important;
}

.el-menu-item:hover {
  background-color: rgba(255, 255, 255, 0.2) !important;
}

/* 激活状态 - 保持白底蓝字，不受 focus/blur 影响 */
.el-menu-item.is-active {
  background-color: white !important;
  color: #409eff !important;
  border-bottom-color: transparent !important;
}

.el-menu-item.is-active:focus,
.el-menu-item.is-active:active,
.el-menu-item.is-active:hover {
  background-color: white !important;
  color: #409eff !important;
}

.auth-buttons {
  display: flex;
  align-items: center;
  gap: 10px;
}

.username {
  margin-right: 10px;
}

.el-main {
  max-width: 1200px;
  margin: 0 auto;
  padding: 20px;
}
</style>
