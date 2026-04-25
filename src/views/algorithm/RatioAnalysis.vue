<script setup>
import { ref, onMounted } from 'vue'
import * as echarts from 'echarts'
import { ElMessage } from 'element-plus'

const activeCategory = ref('solvency')
const categories = [
  { key: 'solvency', label: '偿债能力' },
  { key: 'operating', label: '营运能力' },
  { key: 'profitability', label: '盈利能力' },
  { key: 'growth', label: '发展能力' }
]

const ratioData = ref({
  solvency: [
    { code: 'R001', name: '流动比率', formula: '流动资产 / 流动负债', value: 1.85, prevValue: 1.92, change: -3.65, standard: '2.0' },
    { code: 'R002', name: '速动比率', formula: '(流动资产 - 存货) / 流动负债', value: 0.92, prevValue: 1.02, change: -9.80, standard: '1.0' },
    { code: 'R003', name: '现金比率', formula: '现金及等价物 / 流动负债', value: 0.15, prevValue: 0.22, change: -31.82, standard: '0.2' },
    { code: 'R004', name: '资产负债率', formula: '负债总额 / 资产总额 × 100%', value: 45.3, prevValue: 43.2, change: 4.86, standard: '≤60%' }
  ],
  operating: [
    { code: 'R005', name: '应收账款周转率', formula: '营业收入 / 应收账款平均余额', value: 8.5, prevValue: 7.8, change: 8.97, standard: '≥6' },
    { code: 'R006', name: '存货周转率', formula: '营业成本 / 存货平均余额', value: 5.2, prevValue: 4.8, change: 8.33, standard: '≥5' },
    { code: 'R007', name: '总资产周转率', formula: '营业收入 / 总资产平均余额', value: 0.85, prevValue: 0.78, change: 8.97, standard: '≥0.8' }
  ],
  profitability: [
    { code: 'R008', name: '销售净利率', formula: '净利润 / 营业收入 × 100%', value: 15.7, prevValue: 16.2, change: -3.09, standard: '≥10%' },
    { code: 'R009', name: '净资产收益率(ROE)', formula: '净利润 / 净资产平均余额 × 100%', value: 15.6, prevValue: 16.8, change: -7.14, standard: '≥15%' },
    { code: 'R010', name: '毛利率', formula: '(营业收入 - 营业成本) / 营业收入 × 100%', value: 32.5, prevValue: 30.8, change: 5.52, standard: '≥25%' }
  ],
  growth: [
    { code: 'R011', name: '营业收入增长率', formula: '(本期收入 - 上期收入) / 上期收入 × 100%', value: 12.5, prevValue: 10.3, change: 21.36, standard: '≥10%' },
    { code: 'R012', name: '净利润增长率', formula: '(本期净利润 - 上期净利润) / 上期净利润 × 100%', value: -3.2, prevValue: 5.6, change: -157.14, standard: '≥5%' }
  ]
})

const period = ref('2026-Q1')
const chartRef = ref(null)

function handleCalculate() {
  ElMessage.success('比率计算任务已触发')
}

function getChangeClass(change) {
  return change >= 0 ? 'change-up' : 'change-down'
}

onMounted(() => {
  initChart()
})

function initChart() {
  if (!chartRef.value) return
  const chart = echarts.init(chartRef.value)
  const data = ratioData.value[activeCategory.value]
  chart.setOption({
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
  window.addEventListener('resize', () => chart.resize())
}
</script>

<template>
  <div class="page-container">
    <div class="page-header">
      <h2>比率分析</h2>
      <div>
        <el-date-picker v-model="period" type="quarter" placeholder="选择期间" style="width: 200px; margin-right: 12px;" />
        <el-button type="primary" @click="handleCalculate">
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
          <el-table :data="ratioData[activeCategory]" stripe>
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
