<script setup>
import { ref, onMounted, shallowRef } from 'vue'
import * as echarts from 'echarts'

const indicatorCards = ref([
  { label: '营业收入', value: '2,458.6', unit: '万元', change: 12.5, icon: 'TrendCharts', color: '#409eff', bgColor: '#ecf5ff' },
  { label: '净利润', value: '386.2', unit: '万元', change: -3.2, icon: 'Money', color: '#67c23a', bgColor: '#f0f9eb' },
  { label: '经营现金流', value: '521.8', unit: '万元', change: 8.7, icon: 'Coin', color: '#e6a23c', bgColor: '#fdf6ec' },
  { label: '流动比率', value: '1.85', unit: '', change: -5.1, icon: 'DataAnalysis', color: '#f56c6c', bgColor: '#fef0f0' },
  { label: '资产负债率', value: '45.3', unit: '%', change: 2.1, icon: 'PieChart', color: '#909399', bgColor: '#f4f4f5' },
  { label: '净资产收益率', value: '15.6', unit: '%', change: -1.8, icon: 'Odometer', color: '#409eff', bgColor: '#ecf5ff' }
])

const warningList = ref([
  { id: 1, indicator: '流动比率', level: 'yellow', value: '1.85', threshold: '< 2.0', suggestion: '建议优化短期偿债能力，适当增加流动资产或减少短期负债', time: '2026-04-24 09:30' },
  { id: 2, indicator: '速动比率', level: 'orange', value: '0.92', threshold: '< 1.0', suggestion: '速动比率偏低，建议减少存货占比或增加速动资产', time: '2026-04-24 09:30' },
  { id: 3, indicator: '现金比率', level: 'red', value: '0.15', threshold: '< 0.2', suggestion: '现金比率严重不足，需立即加强现金管理，考虑短期融资', time: '2026-04-24 09:30' }
])

const revenueChartRef = ref(null)
const ratioChartRef = ref(null)

const levelTagType = { yellow: 'warning', orange: 'danger', red: 'danger' }
const levelLabel = { yellow: '黄色预警', orange: '橙色预警', red: '红色预警' }

onMounted(() => {
  initRevenueChart()
  initRatioChart()
})

function initRevenueChart() {
  const chart = echarts.init(revenueChartRef.value)
  chart.setOption({
    tooltip: { trigger: 'axis' },
    legend: { data: ['营业收入', '净利润'], top: 10 },
    grid: { left: '3%', right: '4%', bottom: '3%', containLabel: true },
    xAxis: {
      type: 'category',
      data: ['1月', '2月', '3月', '4月', '5月', '6月', '7月', '8月', '9月', '10月', '11月', '12月'],
      axisLine: { lineStyle: { color: '#ddd' } },
      axisLabel: { color: '#666' }
    },
    yAxis: {
      type: 'value',
      name: '万元',
      axisLine: { show: false },
      splitLine: { lineStyle: { color: '#f0f0f0' } },
      axisLabel: { color: '#666' }
    },
    series: [
      {
        name: '营业收入',
        type: 'bar',
        data: [180, 165, 195, 210, 198, 220, 205, 230, 215, 240, 225, 245],
        itemStyle: { color: '#409eff', borderRadius: [4, 4, 0, 0] }
      },
      {
        name: '净利润',
        type: 'line',
        data: [28, 25, 32, 35, 30, 38, 33, 40, 36, 42, 38, 45],
        smooth: true,
        itemStyle: { color: '#67c23a' },
        lineStyle: { width: 2 },
        areaStyle: { color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [
          { offset: 0, color: 'rgba(103,194,58,0.3)' },
          { offset: 1, color: 'rgba(103,194,58,0.05)' }
        ])}
      }
    ]
  })
  window.addEventListener('resize', () => chart.resize())
}

function initRatioChart() {
  const chart = echarts.init(ratioChartRef.value)
  chart.setOption({
    tooltip: { trigger: 'axis' },
    legend: { data: ['流动比率', '速动比率', '现金比率'], top: 10 },
    grid: { left: '3%', right: '4%', bottom: '3%', containLabel: true },
    xAxis: {
      type: 'category',
      data: ['1月', '2月', '3月', '4月', '5月', '6月', '7月', '8月', '9月', '10月', '11月', '12月'],
      axisLine: { lineStyle: { color: '#ddd' } },
      axisLabel: { color: '#666' }
    },
    yAxis: {
      type: 'value',
      axisLine: { show: false },
      splitLine: { lineStyle: { color: '#f0f0f0' } },
      axisLabel: { color: '#666' }
    },
    series: [
      {
        name: '流动比率',
        type: 'line',
        data: [2.1, 2.0, 1.95, 1.9, 1.92, 1.88, 1.85, 1.82, 1.86, 1.83, 1.80, 1.85],
        smooth: true,
        itemStyle: { color: '#409eff' }
      },
      {
        name: '速动比率',
        type: 'line',
        data: [1.2, 1.15, 1.1, 1.05, 1.08, 1.02, 0.98, 0.95, 0.92, 0.90, 0.88, 0.92],
        smooth: true,
        itemStyle: { color: '#e6a23c' }
      },
      {
        name: '现金比率',
        type: 'line',
        data: [0.35, 0.32, 0.28, 0.25, 0.23, 0.22, 0.20, 0.18, 0.17, 0.16, 0.15, 0.15],
        smooth: true,
        itemStyle: { color: '#f56c6c' }
      }
    ]
  })
  window.addEventListener('resize', () => chart.resize())
}
</script>

<template>
  <div class="dashboard-page">
    <div class="stat-cards">
      <div v-for="card in indicatorCards" :key="card.label" class="stat-card">
        <div class="stat-icon" :style="{ background: card.bgColor, color: card.color }">
          <el-icon size="24"><component :is="card.icon" /></el-icon>
        </div>
        <div class="stat-info">
          <div class="stat-label">{{ card.label }}</div>
          <div class="stat-value">{{ card.value }}<span class="stat-unit" v-if="card.unit">{{ card.unit }}</span></div>
          <div class="stat-change" :class="card.change >= 0 ? 'up' : 'down'">
            <el-icon size="12"><component :is="card.change >= 0 ? 'Top' : 'Bottom'" /></el-icon>
            {{ Math.abs(card.change) }}%
          </div>
        </div>
      </div>
    </div>

    <el-row :gutter="20">
      <el-col :span="16">
        <div class="card-container">
          <div class="chart-header">
            <h3>营收与利润趋势</h3>
          </div>
          <div ref="revenueChartRef" class="chart-container" style="height: 360px;"></div>
        </div>
      </el-col>
      <el-col :span="8">
        <div class="card-container warning-panel">
          <div class="chart-header">
            <h3>预警信息</h3>
            <el-tag type="danger" size="small">{{ warningList.length }} 条</el-tag>
          </div>
          <div class="warning-list">
            <div v-for="item in warningList" :key="item.id" class="warning-item">
              <div class="warning-header">
                <el-tag :type="levelTagType[item.level]" size="small">{{ levelLabel[item.level] }}</el-tag>
                <span class="warning-indicator">{{ item.indicator }}</span>
                <span class="warning-value">{{ item.value }}</span>
              </div>
              <div class="warning-threshold">阈值: {{ item.threshold }}</div>
              <div class="warning-suggestion">{{ item.suggestion }}</div>
              <div class="warning-time">{{ item.time }}</div>
            </div>
          </div>
        </div>
      </el-col>
    </el-row>

    <div class="card-container" style="margin-top: 20px;">
      <div class="chart-header">
        <h3>偿债能力指标趋势</h3>
      </div>
      <div ref="ratioChartRef" class="chart-container" style="height: 360px;"></div>
    </div>
  </div>
</template>

<style scoped>
.dashboard-page {
  padding: 0;
}

.chart-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
}

.chart-header h3 {
  font-size: 16px;
  font-weight: 600;
  color: #303133;
}

.stat-unit {
  font-size: 13px;
  font-weight: 400;
  color: #909399;
  margin-left: 2px;
}

.warning-panel {
  height: 100%;
}

.warning-list {
  max-height: 340px;
  overflow-y: auto;
}

.warning-item {
  padding: 12px;
  border-bottom: 1px solid #f0f0f0;
}

.warning-item:last-child {
  border-bottom: none;
}

.warning-header {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 6px;
}

.warning-indicator {
  font-weight: 600;
  font-size: 14px;
  color: #303133;
}

.warning-value {
  font-size: 14px;
  color: #f56c6c;
  font-weight: 600;
}

.warning-threshold {
  font-size: 12px;
  color: #909399;
  margin-bottom: 4px;
}

.warning-suggestion {
  font-size: 13px;
  color: #606266;
  line-height: 1.6;
  margin-bottom: 4px;
}

.warning-time {
  font-size: 12px;
  color: #c0c4cc;
}
</style>
