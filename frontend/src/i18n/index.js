import { createI18n } from 'vue-i18n'
import zhCN from './locales/zh-CN.json'
import enUS from './locales/en-US.json'

const messages = {
  'zh-CN': zhCN,
  'en-US': enUS
}

const i18n = createI18n({
  legacy: false,
  locale: 'zh-CN',
  fallbackLocale: 'zh-CN',
  messages,
  globalInjection: true,
  missingWarn: false,
  fallbackWarn: false
})

export default i18n

// 导出语言切换工具函数
export const switchLanguage = (lang) => {
  i18n.global.locale.value = lang
  localStorage.setItem('language', lang)
  document.documentElement.lang = lang
}

// 导出获取当前语言函数
export const getCurrentLanguage = () => {
  return i18n.global.locale.value
}

// 导出格式化函数
export const t = (key, params = {}) => {
  return i18n.global.t(key, params)
}
