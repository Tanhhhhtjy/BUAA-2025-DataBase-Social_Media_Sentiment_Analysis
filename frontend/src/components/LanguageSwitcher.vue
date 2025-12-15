<template>
  <el-dropdown @command="handleCommand">
    <span class="language-switcher">
      <el-icon><Connection /></el-icon>
      <span class="current-lang">{{ currentLangText }}</span>
      <el-icon class="el-icon--right"><arrow-down /></el-icon>
    </span>
    <template #dropdown>
      <el-dropdown-menu>
        <el-dropdown-item command="zh-CN">
          <span class="lang-option">🇨🇳 中文</span>
        </el-dropdown-item>
        <el-dropdown-item command="en-US">
          <span class="lang-option">🇺🇸 English</span>
        </el-dropdown-item>
      </el-dropdown-menu>
    </template>
  </el-dropdown>
</template>

<script setup>
import { ref, computed } from 'vue'
import { ArrowDown, Connection } from '@element-plus/icons-vue'
import { switchLanguage, getCurrentLanguage } from '../i18n'

const currentLang = ref(getCurrentLanguage())

const currentLangText = computed(() => {
  return currentLang.value === 'zh-CN' ? '中文' : 'English'
})

const handleCommand = (lang) => {
  switchLanguage(lang)
  currentLang.value = lang
}
</script>

<style scoped>
.language-switcher {
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 8px 12px;
  border-radius: 4px;
  transition: background-color 0.3s;
}

.language-switcher:hover {
  background-color: var(--el-fill-color-light);
}

.current-lang {
  font-size: 14px;
  color: var(--el-text-color-primary);
}

.lang-option {
  display: flex;
  align-items: center;
  gap: 8px;
}
</style>
