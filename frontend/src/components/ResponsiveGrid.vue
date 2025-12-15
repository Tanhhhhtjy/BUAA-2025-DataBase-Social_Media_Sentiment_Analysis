<template>
  <div class="responsive-grid" :style="gridStyle">
    <slot></slot>
  </div>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  columns: {
    type: Number,
    default: 4
  },
  gap: {
    type: String,
    default: '20px'
  },
  minItemWidth: {
    type: String,
    default: '250px'
  }
})

const gridStyle = computed(() => {
  return {
    display: 'grid',
    gridTemplateColumns: `repeat(auto-fit, minmax(${props.minItemWidth}, 1fr))`,
    gap: props.gap
  }
})
</script>

<style scoped>
.responsive-grid {
  width: 100%;
}

/* 响应式断点 */
@media (max-width: 1200px) {
  .responsive-grid {
    grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  }
}

@media (max-width: 768px) {
  .responsive-grid {
    grid-template-columns: 1fr;
  }
}

@media (min-width: 1200px) {
  .responsive-grid {
    grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  }
}
</style>
