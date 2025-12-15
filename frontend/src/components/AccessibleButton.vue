<template>
  <el-button
    :type="type"
    :size="size"
    :disabled="disabled"
    :aria-label="ariaLabel"
    :aria-describedby="ariaDescribedby"
    :role="role"
    :tabindex="tabindex"
    @click="handleClick"
    @keydown="handleKeydown"
    v-focus="autoFocus"
  >
    <slot></slot>
  </el-button>
</template>

<script setup>
const props = defineProps({
  type: {
    type: String,
    default: 'primary'
  },
  size: {
    type: String,
    default: 'default'
  },
  disabled: {
    type: Boolean,
    default: false
  },
  ariaLabel: {
    type: String,
    default: ''
  },
  ariaDescribedby: {
    type: String,
    default: ''
  },
  role: {
    type: String,
    default: 'button'
  },
  tabindex: {
    type: Number,
    default: 0
  },
  autoFocus: {
    type: Boolean,
    default: false
  },
  keyboardShortcut: {
    type: String,
    default: ''
  }
})

const emit = defineEmits(['click', 'keydown'])

// 自动聚焦指令
const vFocus = {
  mounted(el, binding) {
    if (binding.value) {
      el.focus()
    }
  }
}

const handleClick = (event) => {
  if (!props.disabled) {
    emit('click', event)
  }
}

const handleKeydown = (event) => {
  // 支持 Enter 和 Space 键
  if (event.key === 'Enter' || event.key === ' ') {
    event.preventDefault()
    handleClick(event)
  }

  // 键盘快捷键支持
  if (props.keyboardShortcut && event.ctrlKey && event.key === props.keyboardShortcut) {
    event.preventDefault()
    handleClick(event)
  }

  emit('keydown', event)
}
</script>

<style scoped>
/* 聚焦样式 */
.el-button:focus {
  outline: 2px solid #409EFF;
  outline-offset: 2px;
}

/* 键盘导航样式 */
.el-button:focus-visible {
  outline: 2px solid #409EFF;
  outline-offset: 2px;
}

/* 高对比度模式支持 */
@media (prefers-contrast: high) {
  .el-button {
    border-width: 2px;
  }
}
</style>
