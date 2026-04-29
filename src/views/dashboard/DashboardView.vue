<script setup>
import { ref, onMounted, shallowRef } from 'vue'
import * as echarts from 'echarts'
import { getDashboardData } from '../../api/report'

const loading = ref(false)
const indicatorCards = ref([])
const warningList = ref([])
const revenueChartData = ref({ months: [], revenue: [], profit: [] })
const ratioChartData = ref({ months: [], currentRatio: [], quickRatio: [], cashRatio: [] })

const revenueChartRef = ref(null)
const ratioChartRef = ref(null)

const levelTagType = { yellow: 'warning', orange: 'danger', red: 'danger' }
const levelLabel = { yellow: '黄色预警', orange: '橙色预警', red: '红色预警' }

onMounted(async () => {
  await fetchDashboardData()
  initRevenueChart()
  initRatioChart()
})

async function fetchDashboardData() {
  loading.value = true
  try {
    const res = await getDashboardData()
    console.log('仪表盘 API 返回:', res)
    const data = res.data || res
    console.log('解析后的数据:', data)
    
    // 转换字段名：change_pct -> change
    if (data.indicatorCards) {
      indicatorCards.value = data.indicatorCards.map(card => ({
        ...card,
        change: card.change_pct != null ? card.change_pct : card.change
      }))
    } else {
      indicatorCards.value = []
    }
    
    // 转换预警信息的字段名
    if (data.warningList) {
      console.log('原始 warningList:', data.warningList)
      warningList.value = data.warningList.map(item => ({
        ...item,
        threshold: item.threshold || item.yellow_threshold || item.threshold_value,
        suggestion: item.suggestion || item.advice || item.suggestion_text,
        time: item.time || item.created_at || item.triggered_at
      }))
    } else {
      warningList.value = []
    }
    
    revenueChartData.value = data.revenueChart || { months: [], revenue: [], profit: [] }
    ratioChartData.value = data.ratioChart || { months: [], currentRatio: [], quickRatio: [], cashRatio: [] }
    console.log('处理后的 indicatorCards:', indicatorCards.value)
    console.log('处理后的 warningList:', warningList.value)
  } catch (e) {
    console.error('获取仪表盘数据失败:', e)
  } finally {
    loading.value = false
  }
}

function initRevenueChart() {
  if (!revenueChartRef.value) return
  const chart = echarts.init(revenueChartRef.value)
  const d = revenueChartData.value
  chart.setOption({
    tooltip: { trigger: 'axis' },
    legend: { data: ['营业收入', '净利润'], top: 10 },
    grid: { left: '3%', right: '4%', bottom: '3%', containLabel: true },
    xAxis: {
      type: 'category',
      data: d.months,
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
        data: d.revenue,
        itemStyle: { color: '#409eff', borderRadius: [4, 4, 0, 0] }
      },
      {
        name: '净利润',
        type: 'line',
        data: d.profit,
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
  if (!ratioChartRef.value) return
  const chart = echarts.init(ratioChartRef.value)
  const d = ratioChartData.value
  chart.setOption({
    tooltip: { trigger: 'axis' },
    legend: { data: ['流动比率', '速动比率', '现金比率'], top: 10 },
    grid: { left: '3%', right: '4%', bottom: '3%', containLabel: true },
    xAxis: {
      type: 'category',
      data: d.months,
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
        data: d.currentRatio,
        smooth: true,
        itemStyle: { color: '#409eff' }
      },
      {
        name: '速动比率',
        type: 'line',
        data: d.quickRatio,
        smooth: true,
        itemStyle: { color: '#e6a23c' }
      },
      {
        name: '现金比率',
        type: 'line',
        data: d.cashRatio,
        smooth: true,
        itemStyle: { color: '#f56c6c' }
      }
    ]
  })
  window.addEventListener('resize', () => chart.resize())
}

function getChangeClass(change) {
  if (change == null) return ''
  return change >= 0 ? 'up' : 'down'
}

function getChangeIcon(change) {
  if (change == null) return 'Minus'
  return change >= 0 ? 'Top' : 'Bottom'
}

function formatChange(change) {
  if (change == null) return '-'
  return Math.abs(change).toFixed(1)
}
</script>

<template>
  <div class="dashboard-page" v-loading="loading">
    <div class="stat-cards">
      <div v-for="card in indicatorCards" :key="card.label" class="stat-card">
        <div class="stat-icon" :style="{ background: card.bgColor, color: card.color }">
          <el-icon size="24"><component :is="card.icon" /></el-icon>
        </div>
        <div class="stat-info">
          <div class="stat-label">{{ card.label }}</div>
          <div class="stat-value">{{ card.value }}<span class="stat-unit" v-if="card.unit">{{ card.unit }}</span></div>
          <div class="stat-change" :class="getChangeClass(card.change)">
            <el-icon size="12"><component :is="getChangeIcon(card.change)" /></el-icon>
            {{ formatChange(card.change) }}%
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
