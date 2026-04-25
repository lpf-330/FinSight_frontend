<script setup>
import { ref, onMounted, nextTick } from 'vue'
import * as echarts from 'echarts'
import { getChartData } from '../../api/report'
import { ElMessage } from 'element-plus'

const chartType = ref('line')
const selectedPeriod = ref('2026')
const chartRef1 = ref(null)
const chartRef2 = ref(null)
const loading = ref(false)

const profitChartData = ref({
  months: [],
  series: []
})
const structureChartData = ref([])
const comparisonData = ref([])
const balanceSheetData = ref([])
const incomeStatementData = ref([])
const cashFlowData = ref([])

onMounted(() => {
  fetchChartData()
})

async function fetchChartData() {
  loading.value = true
  try {
    const res = await getChartData({ period: selectedPeriod.value })
    const data = res.data || res
    profitChartData.value = data.profitChart || { months: [], series: [] }
    structureChartData.value = data.structureChart || []
    comparisonData.value = data.comparison || []
    balanceSheetData.value = data.balanceSheet || []
    incomeStatementData.value = data.incomeStatement || []
    cashFlowData.value = data.cashFlow || []
    await nextTick()
    initProfitChart()
    initStructureChart()
  } catch (error) {
    ElMessage.error('获取图表数据失败')
    console.error(error)
  } finally {
    loading.value = false
  }
}

function initProfitChart() {
  if (!chartRef1.value) return
  const chart = echarts.init(chartRef1.value)
  const months = profitChartData.value.months.length
    ? profitChartData.value.months
    : ['1月', '2月', '3月', '4月', '5月', '6月', '7月', '8月', '9月', '10月', '11月', '12月']
  const series = profitChartData.value.series.length
    ? profitChartData.value.series.map(s => ({
        ...s,
        type: s.type === 'line' ? s.type : chartType.value,
        smooth: true
      }))
    : []
  chart.setOption({
    tooltip: { trigger: 'axis' },
    legend: { data: series.map(s => s.name), top: 10 },
    grid: { left: '3%', right: '4%', bottom: '3%', containLabel: true },
    toolbox: {
      feature: {
        magicType: { type: ['line', 'bar'] },
        saveAsImage: {}
      }
    },
    xAxis: { type: 'category', data: months, axisLabel: { color: '#666' } },
    yAxis: { type: 'value', name: '万元', axisLabel: { color: '#666' } },
    series: series
  })
  window.addEventListener('resize', () => chart.resize())
}

function initStructureChart() {
  if (!chartRef2.value) return
  const chart = echarts.init(chartRef2.value)
  chart.setOption({
    tooltip: { trigger: 'item' },
    legend: { orient: 'vertical', left: 'left', top: 20 },
    series: [{
      type: 'pie',
      radius: ['40%', '70%'],
      center: ['55%', '55%'],
      avoidLabelOverlap: false,
      itemStyle: { borderRadius: 8, borderColor: '#fff', borderWidth: 2 },
      label: { show: true, formatter: '{b}: {d}%' },
      data: structureChartData.value
    }]
  })
  window.addEventListener('resize', () => chart.resize())
}
</script>

<template>
  <div class="page-container">
    <div class="page-header">
      <h2>图表展示</h2>
      <div>
        <el-date-picker v-model="selectedPeriod" type="year" placeholder="选择年份" style="width: 140px; margin-right: 12px;" />
        <el-button-group>
          <el-button :type="chartType === 'line' ? 'primary' : ''" @click="chartType = 'line'">折线图</el-button>
          <el-button :type="chartType === 'bar' ? 'primary' : ''" @click="chartType = 'bar'">柱状图</el-button>
        </el-button-group>
      </div>
    </div>

    <el-row :gutter="20">
      <el-col :span="16">
        <div class="card-container">
          <h3 class="section-title">损益趋势分析</h3>
          <div ref="chartRef1" style="height: 400px;"></div>
        </div>
      </el-col>
      <el-col :span="8">
        <div class="card-container">
          <h3 class="section-title">收入结构分析</h3>
          <div ref="chartRef2" style="height: 400px;"></div>
        </div>
      </el-col>
    </el-row>

    <el-row :gutter="20" style="margin-top: 20px;">
      <el-col :span="12">
        <div class="card-container">
          <h3 class="section-title">同比环比对比</h3>
          <el-table :data="comparisonData" stripe size="small">
            <el-table-column prop="indicator" label="指标" width="120" />
            <el-table-column prop="current" label="本期(万元)" width="120" align="right" />
            <el-table-column prop="lastYear" label="去年同期(万元)" width="140" align="right" />
            <el-table-column prop="yoy" label="同比(%)" width="100" align="right">
              <template #default="{ row }">
                <span :style="{ color: row.yoy >= 0 ? '#67c23a' : '#f56c6c' }">
                  {{ row.yoy >= 0 ? '+' : '' }}{{ row.yoy }}%
                </span>
              </template>
            </el-table-column>
            <el-table-column prop="mom" label="环比(%)" min-width="100" align="right">
              <template #default="{ row }">
                <span :style="{ color: row.mom >= 0 ? '#67c23a' : '#f56c6c' }">
                  {{ row.mom >= 0 ? '+' : '' }}{{ row.mom }}%
                </span>
              </template>
            </el-table-column>
          </el-table>
        </div>
      </el-col>
      <el-col :span="12">
        <div class="card-container">
          <h3 class="section-title">三大报表摘要</h3>
          <el-tabs>
            <el-tab-pane label="资产负债表">
              <el-descriptions :column="2" border size="small">
                <el-descriptions-item v-for="item in balanceSheetData" :key="item.label" :label="item.label">{{ item.value }}</el-descriptions-item>
              </el-descriptions>
            </el-tab-pane>
            <el-tab-pane label="利润表">
              <el-descriptions :column="2" border size="small">
                <el-descriptions-item v-for="item in incomeStatementData" :key="item.label" :label="item.label">{{ item.value }}</el-descriptions-item>
              </el-descriptions>
            </el-tab-pane>
            <el-tab-pane label="现金流量表">
              <el-descriptions :column="2" border size="small">
                <el-descriptions-item v-for="item in cashFlowData" :key="item.label" :label="item.label">{{ item.value }}</el-descriptions-item>
              </el-descriptions>
            </el-tab-pane>
          </el-tabs>
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
  margin-bottom: 16px;
}
</style>
