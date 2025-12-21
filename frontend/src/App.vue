<template>
  <div id="app">
    <el-container>
      <el-header>
        <div class="header-content">
          <h1>社交媒体舆情分析系统</h1>
          <el-menu mode="horizontal" :router="true" :default-active="activeMenu" class="main-menu">
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
              <span class="welcome-text">欢迎, {{ username }}</span>
              <el-dropdown trigger="hover" @command="handleCommand">
                <el-avatar class="user-avatar" :size="36">
                  {{ username?.[0]?.toUpperCase() }}
                </el-avatar>
                <template #dropdown>
                  <el-dropdown-menu>
                    <el-dropdown-item command="profile">
                      <el-icon><User /></el-icon>
                      个人中心
                    </el-dropdown-item>
                    <el-dropdown-item command="my-posts">
                      <el-icon><Document /></el-icon>
                      我的帖子
                    </el-dropdown-item>
                    <el-dropdown-item command="my-comments">
                      <el-icon><ChatDotRound /></el-icon>
                      我的评论
                    </el-dropdown-item>
                    <el-dropdown-item divided command="settings">
                      <el-icon><Setting /></el-icon>
                      账户设置
                    </el-dropdown-item>
                    <el-dropdown-item command="logout">
                      <el-icon><SwitchButton /></el-icon>
                      退出登录
                    </el-dropdown-item>
                  </el-dropdown-menu>
                </template>
              </el-dropdown>
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
import { useRoute, useRouter } from 'vue-router'
import { useAuthStore } from './stores/auth'
import { User, Document, ChatDotRound, Setting, SwitchButton } from '@element-plus/icons-vue'

const route = useRoute()
const router = useRouter()
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

const handleCommand = command => {
  switch (command) {
    case 'profile':
      router.push('/profile')
      break
    case 'my-posts':
      router.push('/my-posts')
      break
    case 'my-comments':
      router.push('/my-comments')
      break
    case 'settings':
      router.push('/settings')
      break
    case 'logout':
      authStore.logout()
      router.push('/')
      break
  }
}
</script>

<style>
:root {
  /* 覆盖 Element Plus 主题色 - 采用高级黑/深灰作为主视觉，靛蓝作为强调 */
  --el-color-primary: #18181b; /* Zinc-900 */
  --el-color-primary-light-3: #3f3f46;
  --el-color-primary-light-5: #71717a;
  --el-color-primary-light-7: #a1a1aa;
  --el-color-primary-light-8: #d4d4d8;
  --el-color-primary-light-9: #f4f4f5;
  --el-color-primary-dark-2: #09090b;

  --app-bg-color: #f8fafc; /* 极淡的灰蓝色背景 */
  --app-text-primary: #1e293b;
  --app-text-secondary: #64748b;
  --app-accent-color: #4f46e5; /* 靛蓝强调色 */
}

* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

#app {
  font-family:
    'Inter',
    -apple-system,
    BlinkMacSystemFont,
    'Segoe UI',
    Roboto,
    'Helvetica Neue',
    Arial,
    sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  color: var(--app-text-primary);
  background-color: var(--app-bg-color);
}

.el-container {
  min-height: 100vh;
}

/* 现代简约导航栏 */
.el-header {
  background-color: rgba(255, 255, 255, 0.9) !important;
  backdrop-filter: blur(10px);
  color: var(--app-text-primary);
  box-shadow: none !important;
  border-bottom: 1px solid rgba(0, 0, 0, 0.05);
  position: sticky;
  top: 0;
  z-index: 100;
}

.header-content {
  display: flex;
  align-items: center;
  justify-content: space-between;
  max-width: 1600px;
  margin: 0 auto;
  height: 100%;
}

.header-content h1 {
  font-size: 18px;
  font-weight: 600;
  letter-spacing: -0.5px;
  margin-right: 40px;
  color: #0f172a;
}

.main-menu {
  flex: 1;
  background-color: transparent !important;
  border-bottom: none !important;
}

/* 菜单项样式重置 */
.el-menu-item {
  color: var(--app-text-secondary) !important;
  background-color: transparent !important;
  font-weight: 500;
  font-size: 14px;
  transition: all 0.2s ease;
}

.el-menu-item:hover {
  color: var(--app-accent-color) !important;
  background-color: transparent !important;
}

/* 激活状态 */
.el-menu-item.is-active {
  color: var(--app-accent-color) !important;
  background-color: transparent !important;
  font-weight: 600;
}

.auth-buttons {
  display: flex;
  align-items: center;
  gap: 16px;
}

.welcome-text {
  color: var(--app-text-secondary);
  font-size: 14px;
  font-weight: 500;
}

.user-avatar {
  cursor: pointer;
  background-color: var(--el-color-primary);
  color: white;
  font-weight: 600;
  transition: all 0.2s;
  border: 2px solid white;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.user-avatar:hover {
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
}

.el-dropdown-menu .el-dropdown-item {
  display: flex;
  align-items: center;
  gap: 8px;
}

.el-main {
  width: 100%;
  margin: 0 auto;
  padding: 40px 20px;
}

/* 全局按钮微调：更圆润 */
.el-button {
  border-radius: 8px;
  font-weight: 500;
}

.el-button--primary {
  box-shadow: 0 2px 6px rgba(24, 24, 27, 0.2);
}

/* 强制 Message Box 居中显示 - 增强版 */
.el-overlay.is-message-box .el-overlay-message-box {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 100%;
  height: 100%;
  padding: 0;
  text-align: center;
}

/* 统一的卡片式弹窗风格 */
.el-message-box {
  display: flex !important;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  background-color: #ffffff;
  width: 400px;
  max-width: 90vw;
  padding: 32px !important;
  border-radius: 20px;
  box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.25);
  border: none;
  margin: 0 !important;
  vertical-align: unset;
}

/* 头部样式 */
.el-message-box__header {
  width: 100%;
  padding: 0 !important;
  margin-bottom: 12px;
  display: flex;
  justify-content: center;
}

.el-message-box__title {
  font-size: 20px;
  font-weight: 700;
  color: #18181b;
  line-height: 1.4;
}

/* 隐藏默认图标和关闭按钮，保持极简 */
.el-message-box__status {
  display: none !important;
}

.el-message-box__headerbtn {
  display: none !important;
}

/* 内容样式 */
.el-message-box__content {
  padding: 0 !important;
  margin-bottom: 24px;
  color: #71717a;
  font-size: 15px;
  text-align: center;
}

.el-message-box__container {
  display: flex;
  flex-direction: column;
  align-items: center;
}

/* 按钮区域样式 */
.el-message-box__btns {
  width: 100%;
  padding: 0 !important;
  display: flex;
  justify-content: center;
  gap: 12px;
  flex-direction: row-reverse; /* 让"确认"在右边，或者根据习惯调整 */
}

.el-message-box__btns .el-button {
  margin: 0 !important;
  min-width: 100px;
  height: 40px;
  border-radius: 10px;
  font-weight: 600;
}
</style>
