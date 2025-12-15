<template>
  <div class="pagination-container">
    <el-pagination
      v-model:current-page="currentPageLocal"
      v-model:page-size="pageSizeLocal"
      :page-sizes="[10, 20, 50, 100]"
      :small="small"
      :disabled="disabled"
      :background="background"
      layout="total, sizes, prev, pager, next, jumper"
      :total="total"
      @size-change="handleSizeChange"
      @current-change="handleCurrentChange"
    />
  </div>
</template>

<script setup>
import { ref, watch } from 'vue'

const props = defineProps({
  currentPage: {
    type: Number,
    default: 1
  },
  pageSize: {
    type: Number,
    default: 20
  },
  total: {
    type: Number,
    required: true
  },
  small: {
    type: Boolean,
    default: false
  },
  disabled: {
    type: Boolean,
    default: false
  },
  background: {
    type: Boolean,
    default: true
  }
})

const emit = defineEmits(['update:currentPage', 'update:pageSize', 'change'])

const currentPageLocal = ref(props.currentPage)
const pageSizeLocal = ref(props.pageSize)

watch(() => props.currentPage, (newVal) => {
  currentPageLocal.value = newVal
})

watch(() => props.pageSize, (newVal) => {
  pageSizeLocal.value = newVal
})

const handleSizeChange = (val) => {
  pageSizeLocal.value = val
  emit('update:pageSize', val)
  emit('change', { page: currentPageLocal.value, size: val })
}

const handleCurrentChange = (val) => {
  currentPageLocal.value = val
  emit('update:currentPage', val)
  emit('change', { page: val, size: pageSizeLocal.value })
}
</script>

<style scoped>
.pagination-container {
  display: flex;
  justify-content: center;
  margin-top: 20px;
  padding: 20px 0;
}
</style>
