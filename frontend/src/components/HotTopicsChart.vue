<template>
  <div ref="chartContainer" class="hot-topics-chart" :style="{ height: height + 'px' }"></div>
</template>

<script setup>
import { ref, onMounted, watch } from 'vue'
import * as echarts from 'echarts/core'
import { BarChart } from 'echarts/charts'
import { GridComponent, TooltipComponent, LegendComponent } from 'echarts/components'
import { CanvasRenderer } from 'echarts/renderers'

echarts.use([BarChart, GridComponent, TooltipComponent, LegendComponent, CanvasRenderer])

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
      trigger: 'axis',
      axisPointer: {
        type: 'shadow'
      },
      formatter: function(params) {
        const param = params[0]
        const data = props.data[param.dataIndex]
        return `#${param.name}<br/>` +
               `帖子数: ${data.postCount}<br/>` +
               `评论数: ${data.commentCount}<br/>` +
               `热度: ${param.value}`
      }
    },
    grid: {
      left: '3%',
      right: '4%',
      bottom: '3%',
      containLabel: true
    },
    xAxis: {
      type: 'category',
      data: props.data.map(item => item.tagName),
      axisLabel: {
        interval: 0,
        rotate: 45
      }
    },
    yAxis: {
      type: 'value',
      name: '热度'
    },
    series: [
      {
        name: '热度',
        type: 'bar',
        data: props.data.map(item => ({
          value: item.heatScore,
          itemStyle: {
            color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [
              { offset: 0, color: '#83bff6' },
              { offset: 1, color: '#188df0' }
            ])
          }
        })),
        emphasis: {
          itemStyle: {
            shadowBlur: 10,
            shadowOffsetX: 0,
            shadowColor: 'rgba(0, 0, 0, 0.5)'
          }
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
      data: props.data.map(item => item.tagName)
    },
    series: [{
      data: props.data.map(item => ({
        value: item.heatScore,
        itemStyle: {
          color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [
            { offset: 0, color: '#83bff6' },
            { offset: 1, color: '#188df0' }
          ])
        }
      }))
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
.hot-topics-chart {
  width: 100%;
  height: 100%;
}
</style>
