<template>
  <div ref="chartContainer" class="sentiment-trend-chart" :style="{ height: height + 'px' }"></div>
</template>

<script setup>
import { ref, onMounted, watch } from 'vue'
import * as echarts from 'echarts/core'
import { LineChart } from 'echarts/charts'
import { GridComponent, TooltipComponent, LegendComponent } from 'echarts/components'
import { CanvasRenderer } from 'echarts/renderers'

echarts.use([LineChart, GridComponent, TooltipComponent, LegendComponent, CanvasRenderer])

const props = defineProps({
  data: {
    type: Array,
    default: () => []
  },
  height: {
    type: Number,
    default: 350
  }
})

const chartContainer = ref(null)
let chart = null

const initChart = () => {
  if (!chartContainer.value) return

  chart = echarts.init(chartContainer.value)

  const option = {
    tooltip: {
      trigger: 'axis',
      axisPointer: {
        type: 'cross'
      }
    },
    legend: {
      data: ['正面', '中立', '负面']
    },
    grid: {
      left: '3%',
      right: '4%',
      bottom: '3%',
      containLabel: true
    },
    xAxis: {
      type: 'category',
      boundaryGap: false,
      data: props.data.map(item => item.date)
    },
    yAxis: {
      type: 'value',
      name: '帖子数量'
    },
    series: [
      {
        name: '正面',
        type: 'line',
        data: props.data.map(item => item.positive),
        smooth: true,
        itemStyle: { color: '#67c23a' },
        areaStyle: {
          color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [
            { offset: 0, color: 'rgba(103, 194, 58, 0.3)' },
            { offset: 1, color: 'rgba(103, 194, 58, 0.05)' }
          ])
        }
      },
      {
        name: '中立',
        type: 'line',
        data: props.data.map(item => item.neutral),
        smooth: true,
        itemStyle: { color: '#909399' },
        areaStyle: {
          color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [
            { offset: 0, color: 'rgba(144, 147, 153, 0.3)' },
            { offset: 1, color: 'rgba(144, 147, 153, 0.05)' }
          ])
        }
      },
      {
        name: '负面',
        type: 'line',
        data: props.data.map(item => item.negative),
        smooth: true,
        itemStyle: { color: '#f56c6c' },
        areaStyle: {
          color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [
            { offset: 0, color: 'rgba(245, 108, 108, 0.3)' },
            { offset: 1, color: 'rgba(245, 108, 108, 0.05)' }
          ])
        }
      }
    ]
  }

  chart.setOption(option)
}

const updateChart = () => {
  if (!chart) return

  chart.setOption({
    xAxis: {
      data: props.data.map(item => item.date)
    },
    series: [
      {
        name: '正面',
        data: props.data.map(item => item.positive)
      },
      {
        name: '中立',
        data: props.data.map(item => item.neutral)
      },
      {
        name: '负面',
        data: props.data.map(item => item.negative)
      }
    ]
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
.sentiment-trend-chart {
  width: 100%;
  height: 100%;
}
</style>
