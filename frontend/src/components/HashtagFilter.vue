<template>
  <div class="hashtag-filter">
    <el-input
      v-model="filterKeyword"
      placeholder="搜索话题..."
      clearable
      :prefix-icon="Search"
      @input="handleFilter"
      style="width: 100%; max-width: 400px"
    />

    <div class="hashtag-list" v-if="filteredHashtags.length > 0">
      <el-tag
        v-for="hashtag in filteredHashtags"
        :key="hashtag.hashtagId"
        class="hashtag-item"
        :type="isSelected(hashtag.hashtagId) ? 'primary' : 'info'"
        @click="toggleSelection(hashtag)"
      >
        #{{ hashtag.tagName }}
        <span class="post-count">({{ hashtag.postCount }})</span>
      </el-tag>
    </div>

    <div class="selected-hashtags" v-if="selectedHashtags.length > 0">
      <span class="label">已选择话题:</span>
      <el-tag
        v-for="hashtag in selectedHashtags"
        :key="hashtag.hashtagId"
        type="primary"
        closable
        @close="removeSelection(hashtag.hashtagId)"
      >
        #{{ hashtag.tagName }}
      </el-tag>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, watch } from 'vue'
import { Search } from '@element-plus/icons-vue'

const props = defineProps({
  hashtags: {
    type: Array,
    default: () => []
  }
})

const emit = defineEmits(['change'])

const filterKeyword = ref('')
const selectedHashtags = ref([])

const filteredHashtags = computed(() => {
  if (!filterKeyword.value) {
    return props.hashtags
  }
  const keyword = filterKeyword.value.toLowerCase()
  return props.hashtags.filter(h =>
    h.tagName.toLowerCase().includes(keyword)
  )
})

const isSelected = (hashtagId) => {
  return selectedHashtags.value.some(h => h.hashtagId === hashtagId)
}

const toggleSelection = (hashtag) => {
  if (isSelected(hashtag.hashtagId)) {
    removeSelection(hashtag.hashtagId)
  } else {
    selectedHashtags.value.push(hashtag)
    emit('change', selectedHashtags.value)
  }
}

const removeSelection = (hashtagId) => {
  selectedHashtags.value = selectedHashtags.value.filter(h => h.hashtagId !== hashtagId)
  emit('change', selectedHashtags.value)
}

const handleFilter = () => {
  // 过滤逻辑在 computed 中处理
}

watch(selectedHashtags, (newVal) => {
  emit('change', newVal)
}, { deep: true })
</script>

<style scoped>
.hashtag-filter {
  padding: 16px;
  background: #f5f7fa;
  border-radius: 8px;
  margin-bottom: 20px;
}

.hashtag-list {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  margin-top: 16px;
  max-height: 200px;
  overflow-y: auto;
}

.hashtag-item {
  cursor: pointer;
  transition: all 0.2s;
  margin: 0;
}

.hashtag-item:hover {
  transform: translateY(-2px);
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.post-count {
  font-size: 12px;
  margin-left: 4px;
  opacity: 0.7;
}

.selected-hashtags {
  display: flex;
  align-items: center;
  flex-wrap: wrap;
  gap: 8px;
  margin-top: 16px;
  padding-top: 16px;
  border-top: 1px solid #e4e7ed;
}

.label {
  font-size: 14px;
  color: #606266;
  margin-right: 8px;
}
</style>
