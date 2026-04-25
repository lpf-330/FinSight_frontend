<script setup>
import { ref, reactive } from 'vue'
import * as echarts from 'echarts'
import { onMounted } from 'vue'
import { ElMessage } from 'element-plus'

const forecastForm = reactive({
  baseRevenue: 2458.6,
  revenueGrowthRate: 8,
  costRate: 67.5,
  expenseRate: 15,
  taxRate: 25,
  periods: 4
})

const calculated = ref(true)
const forecastResults = ref([
  { period: '2026-Q1', revenue: 2458.6, cost: 1659.6, expense: 368.8, profitBeforeTax: 430.2, tax: 107.6, netProfit: 322.7 },
  { period: '2026-Q2', revenue: 2655.3, cost: 1792.3, expense: 398.3, profitBeforeTax: 464.7, tax: 116.2, netProfit: 348.5 },
  { period: '2026-Q3', revenue: 2867.7, cost: 1935.7, expense: 430.2, profitBeforeTax: 501.9, tax: 125.5, netProfit: 376.4 },
  { period: '2026-Q4', revenue: 3097.2, cost: 2090.6, expense: 464.6, profitBeforeTax: 542.0, tax: 135.5, netProfit: 406.5 }
])

const chartRef = ref(null)

function handleCalculate() {
  calculated.value = true
  ElMessage.success('损益预测计算完成')
}

function handleSave() {
  ElMessage.success('预测方案已保存')
}

onMounted(() => {
  if (calculated.value) initChart()
})

function initChart() {
  if (!chartRef.value) return
  const chart = echarts.init(chartRef.value)
  chart.setOption({
    tooltip: { trigger: 'axis' },
    legend: { data: ['营业收入', '营业成本', '净利润'], top: 10 },
    grid: { left: '3%', right: '4%', bottom: '3%', containLabel: true },
    xAxis: {
      type: 'category',
      data: forecastResults.value.map(r => r.period),
      axisLabel: { color: '#666' }
    },
    yAxis: { type: 'value', name: '万元', axisLabel: { color: '#666' } },
    series: [
      { name: '营业收入', type: 'bar', data: forecastResults.value.map(r => r.revenue), itemStyle: { color: '#409eff', borderRadius: [4, 4, 0, 0] } },
      { name: '营业成本', type: 'bar', data: forecastResults.value.map(r => r.cost), itemStyle: { color: '#e6e8eb', borderRadius: [4, 4, 0, 0] } },
      { name: '净利润', type: 'line', data: forecastResults.value.map(r => r.netProfit), smooth: true, itemStyle: { color: '#67c23a' }, lineStyle: { width: 2 } }
    ]
  })
  window.addEventListener('resize', () => chart.resize())
}
</script>

<template>
  <div class="page-container">
    <div class="page-header">
      <h2>损益预测</h2>
    </div>

    <el-row :gutter="20">
      <el-col :span="8">
        <div class="card-container">
          <h3 class="section-title">预测参数</h3>
          <el-form :model="forecastForm" label-width="120px" style="margin-top: 16px;">
            <el-form-item label="基准营业收入">
              <el-input-number v-model="forecastForm.baseRevenue" :precision="1" style="width: 100%;" />
              <div class="form-tip">单位：万元</div>
            </el-form-item>
            <el-form-item label="收入增长率(%)">
              <el-input-number v-model="forecastForm.revenueGrowthRate" :precision="1" style="width: 100%;" />
            </el-form-item>
            <el-form-item label="营业成本率(%)">
              <el-input-number v-model="forecastForm.costRate" :precision="1" :min="0" :max="100" style="width: 100%;" />
            </el-form-item>
            <el-form-item label="期间费用率(%)">
              <el-input-number v-model="forecastForm.expenseRate" :precision="1" :min="0" :max="100" style="width: 100%;" />
            </el-form-item>
            <el-form-item label="所得税率(%)">
              <el-input-number v-model="forecastForm.taxRate" :precision="0" :min="0" :max="100" style="width: 100%;" />
            </el-form-item>
            <el-form-item label="预测期数">
              <el-input-number v-model="forecastForm.periods" :min="1" :max="20" style="width: 100%;" />
            </el-form-item>
            <el-form-item>
              <el-button type="primary" @click="handleCalculate">计算预测</el-button>
              <el-button @click="handleSave">保存方案</el-button>
            </el-form-item>
          </el-form>
        </div>
      </el-col>

      <el-col :span="16">
        <div v-if="calculated" class="card-container">
          <h3 class="section-title">预测结果</h3>
          <div ref="chartRef" style="height: 320px;"></div>

          <h3 class="section-title" style="margin-top: 20px;">预测明细表</h3>
          <el-table :data="forecastResults" stripe size="small" style="margin-top: 12px;">
            <el-table-column prop="period" label="期间" width="120" />
            <el-table-column prop="revenue" label="营业收入" width="110" align="right" />
            <el-table-column prop="cost" label="营业成本" width="110" align="right" />
            <el-table-column prop="expense" label="期间费用" width="110" align="right" />
            <el-table-column prop="profitBeforeTax" label="税前利润" width="110" align="right" />
            <el-table-column prop="tax" label="所得税" width="100" align="right" />
            <el-table-column prop="netProfit" label="净利润" min-width="100" align="right" />
          </el-table>
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
}

.form-tip {
  font-size: 12px;
  color: #909399;
  margin-top: 4px;
}
</style>
