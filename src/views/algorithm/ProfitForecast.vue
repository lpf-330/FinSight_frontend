<script setup>
import { ref, reactive, onMounted, nextTick } from 'vue'
import * as echarts from 'echarts'
import { ElMessage } from 'element-plus'
import { calcProfitForecast } from '../../api/algorithm'

const forecastForm = reactive({
  baseRevenue: 2458.6,
  revenueGrowthRate: 8,
  costRate: 67.5,
  expenseRate: 15,
  taxRate: 25,
  periods: 4
})

const calculated = ref(false)
const calculating = ref(false)
const forecastResults = ref([])

const chartRef = ref(null)
let chartInstance = null

async function handleCalculate() {
  calculating.value = true
  try {
    const res = await calcProfitForecast({
      baseRevenue: forecastForm.baseRevenue,
      revenueGrowthRate: forecastForm.revenueGrowthRate,
      costRate: forecastForm.costRate,
      expenseRate: forecastForm.expenseRate,
      taxRate: forecastForm.taxRate,
      periods: forecastForm.periods
    })
    forecastResults.value = res.data || []
    calculated.value = true
    ElMessage.success('损益预测计算完成')
    await nextTick()
    updateChart()
  } catch (err) {
    ElMessage.error('损益预测计算失败: ' + (err.message || '未知错误'))
  } finally {
    calculating.value = false
  }
}

function handleSave() {
  ElMessage.success('预测方案已保存')
}

function initChart() {
  if (!chartRef.value) return
  chartInstance = echarts.init(chartRef.value)
  if (calculated.value) updateChart()
  window.addEventListener('resize', () => chartInstance && chartInstance.resize())
}

function updateChart() {
  if (!chartInstance || !forecastResults.value.length) return
  chartInstance.setOption({
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
}

onMounted(() => {
  initChart()
})
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
              <el-button type="primary" @click="handleCalculate" :loading="calculating">计算预测</el-button>
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
