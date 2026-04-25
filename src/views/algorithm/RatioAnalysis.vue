<script setup>
import { ref, onMounted, watch, nextTick } from 'vue'
import * as echarts from 'echarts'
import { ElMessage } from 'element-plus'
import { getRatioResults, triggerRatioCalc } from '../../api/algorithm'

const activeCategory = ref('solvency')
const categories = [
  { key: 'solvency', label: '偿债能力' },
  { key: 'operating', label: '营运能力' },
  { key: 'profitability', label: '盈利能力' },
  { key: 'growth', label: '发展能力' }
]

const ratioData = ref({
  solvency: [],
  operating: [],
  profitability: [],
  growth: []
})

const period = ref('2026-Q1')
const chartRef = ref(null)
const loading = ref(false)
let chartInstance = null

async function fetchRatioData() {
  loading.value = true
  try {
    const res = await getRatioResults({ period: period.value })
    ratioData.value = res.data || {
      solvency: [],
      operating: [],
      profitability: [],
      growth: []
    }
    await nextTick()
    updateChart()
  } catch (err) {
    ElMessage.error('获取比率数据失败: ' + (err.message || '未知错误'))
  } finally {
    loading.value = false
  }
}

async function handleCalculate() {
  loading.value = true
  try {
    await triggerRatioCalc({ period: period.value })
    ElMessage.success('比率计算任务已触发')
    await fetchRatioData()
  } catch (err) {
    ElMessage.error('触发计算失败: ' + (err.message || '未知错误'))
  } finally {
    loading.value = false
  }
}

function getChangeClass(change) {
  return change >= 0 ? 'change-up' : 'change-down'
}

function initChart() {
  if (!chartRef.value) return
  chartInstance = echarts.init(chartRef.value)
  updateChart()
  window.addEventListener('resize', () => chartInstance && chartInstance.resize())
}

function updateChart() {
  if (!chartInstance) return
  const data = ratioData.value[activeCategory.value] || []
  chartInstance.setOption({
    tooltip: { trigger: 'axis' },
    legend: { data: ['本期', '上期'], top: 10 },
    grid: { left: '3%', right: '4%', bottom: '3%', containLabel: true },
    xAxis: {
      type: 'category',
      data: data.map(d => d.name),
      axisLabel: { rotate: 15, color: '#666' }
    },
    yAxis: { type: 'value', axisLabel: { color: '#666' } },
    series: [
      { name: '本期', type: 'bar', data: data.map(d => d.value), itemStyle: { color: '#409eff', borderRadius: [4, 4, 0, 0] } },
      { name: '上期', type: 'bar', data: data.map(d => d.prevValue), itemStyle: { color: '#e6e8eb', borderRadius: [4, 4, 0, 0] } }
    ]
  })
}

watch(activeCategory, () => {
  updateChart()
})

onMounted(() => {
  initChart()
  fetchRatioData()
})
</script>

<template>
  <div class="page-container">
    <div class="page-header">
      <h2>比率分析</h2>
      <div>
        <el-date-picker v-model="period" type="quarter" placeholder="选择期间" style="width: 200px; margin-right: 12px;" />
        <el-button type="primary" @click="handleCalculate" :loading="loading">
          <el-icon><Cpu /></el-icon>
          重新计算
        </el-button>
      </div>
    </div>

    <el-tabs v-model="activeCategory">
      <el-tab-pane v-for="cat in categories" :key="cat.key" :label="cat.label" :name="cat.key" />
    </el-tabs>

    <el-row :gutter="20">
      <el-col :span="14">
        <div class="card-container">
          <el-table :data="ratioData[activeCategory]" stripe v-loading="loading">
            <el-table-column prop="code" label="编码" width="80" />
            <el-table-column prop="name" label="指标名称" width="140" />
            <el-table-column prop="formula" label="计算公式" min-width="200">
              <template #default="{ row }">
                <code class="formula-code">{{ row.formula }}</code>
              </template>
            </el-table-column>
            <el-table-column prop="value" label="本期值" width="100" align="right">
              <template #default="{ row }">
                <span class="value-text">{{ row.value }}</span>
              </template>
            </el-table-column>
            <el-table-column prop="prevValue" label="上期值" width="100" align="right" />
            <el-table-column prop="change" label="环比变化" width="120" align="right">
              <template #default="{ row }">
                <span :class="getChangeClass(row.change)">
                  {{ row.change >= 0 ? '+' : '' }}{{ row.change.toFixed(2) }}%
                </span>
              </template>
            </el-table-column>
            <el-table-column prop="standard" label="参考标准" width="100" />
          </el-table>
        </div>
      </el-col>
      <el-col :span="10">
        <div class="card-container">
          <h3 class="section-title">指标对比图</h3>
          <div ref="chartRef" style="height: 400px;"></div>
        </div>
      </el-col>
    </el-row>
  </div>
</template>

<style scoped>
.section-title {
  font-size: 16px;
  font-weight: 600;
  color: #303133;
  margin-bottom: 12px;
}

.formula-code {
  background: #f5f7fa;
  padding: 2px 6px;
  border-radius: 3px;
  font-family: 'Courier New', monospace;
  font-size: 12px;
  color: #606266;
}

.value-text {
  font-weight: 600;
  color: #303133;
}

.change-up {
  color: #67c23a;
  font-weight: 500;
}

.change-down {
  color: #f56c6c;
  font-weight: 500;
}
</style>
