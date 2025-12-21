<template>
  <div ref="chartContainer" class="sentiment-pie-chart" :style="{ height: height + 'px' }"></div>
</template>

<script setup>
import { ref, onMounted, watch } from 'vue'
import * as echarts from 'echarts/core'
import { PieChart } from 'echarts/charts'
import { TooltipComponent, LegendComponent } from 'echarts/components'
import { CanvasRenderer } from 'echarts/renderers'

echarts.use([PieChart, TooltipComponent, LegendComponent, CanvasRenderer])

const props = defineProps({
  data: {
    type: Array,
    default: () => []
  },
  height: {
    type: Number,
    default: 300
  }
})

const chartContainer = ref(null)
let chart = null

const initChart = () => {
  if (!chartContainer.value) return

  chart = echarts.init(chartContainer.value)

  const option = {
    tooltip: {
      trigger: 'item',
      formatter: '{a} <br/>{b}: {c} ({d}%)'
    },
    legend: {
      orient: 'vertical',
      left: 'left'
    },
    series: [
      {
        name: '情感分布',
        type: 'pie',
        radius: ['40%', '70%'],
        avoidLabelOverlap: false,
        itemStyle: {
          borderRadius: 10,
          borderColor: '#fff',
          borderWidth: 2
        },
        label: {
          show: false,
          position: 'center'
        },
        emphasis: {
          label: {
            show: true,
            fontSize: 20,
            fontWeight: 'bold'
          },
          itemStyle: {
            shadowBlur: 10,
            shadowOffsetX: 0,
            shadowColor: 'rgba(0, 0, 0, 0.5)'
          }
        },
        labelLine: {
          show: false
        },
        data: props.data
      }
    ]
  }

  chart.setOption(option)
}

const updateChart = () => {
  if (!chart) return

  chart.setOption({
    series: [{
      data: props.data
    }]
  })
}

onMounted(() => {
  initChart()
  window.addEventListener('resize', () => {
    if (chart) {
      chart.resize()
    }
  })
})

watch(() => props.data, () => {
  updateChart()
}, { deep: true })
</script>

<style scoped>
.sentiment-pie-chart {
  width: 100%;
  height: 100%;
}
</style>
