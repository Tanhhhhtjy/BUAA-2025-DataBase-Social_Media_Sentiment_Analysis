<template>
  <el-switch
    v-model="isDark"
    :active-icon="Moon"
    :inactive-icon="Sunny"
    @change="toggleTheme"
    style="--el-switch-on-color: #409EFF;"
  />
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { Moon, Sunny } from '@element-plus/icons-vue'

const isDark = ref(false)

const toggleTheme = (value) => {
  if (value) {
    document.documentElement.classList.add('dark')
    localStorage.setItem('theme', 'dark')
  } else {
    document.documentElement.classList.remove('dark')
    localStorage.setItem('theme', 'light')
  }
}

onMounted(() => {
  // 从本地存储读取主题设置
  const savedTheme = localStorage.getItem('theme')
  const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches

  if (savedTheme) {
    isDark.value = savedTheme === 'dark'
  } else {
    isDark.value = prefersDark
  }

  // 应用主题
  toggleTheme(isDark.value)

  // 监听系统主题变化
  window.matchMedia('(prefers-color-scheme: dark)').addEventListener('change', (e) => {
    if (!localStorage.getItem('theme')) {
      isDark.value = e.matches
      toggleTheme(isDark.value)
    }
  })
})
</script>

<style>
/* Dark mode styles */
.dark {
  color-scheme: dark;
}

.dark body {
  background-color: #1a1a1a;
  color: #e0e0e0;
}

.dark .el-card {
  background-color: #2d2d2d;
  border-color: #3d3d3d;
}

.dark .el-table {
  background-color: #2d2d2d;
  color: #e0e0e0;
}

.dark .el-table th.el-table__cell {
  background-color: #262626;
}

.dark .el-pagination {
  color: #e0e0e0;
}

.dark .el-dialog {
  background-color: #2d2d2d;
}

.dark .el-form-item__label {
  color: #e0e0e0;
}

.dark .el-input__wrapper {
  background-color: #3d3d3d;
}

.dark .el-textarea__inner {
  background-color: #3d3d3d;
  color: #e0e0e0;
}
</style>
