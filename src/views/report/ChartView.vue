<script setup>
import { ref, onMounted } from 'vue'
import * as echarts from 'echarts'

const chartType = ref('line')
const selectedPeriod = ref('2026')
const chartRef1 = ref(null)
const chartRef2 = ref(null)

onMounted(() => {
  initProfitChart()
  initStructureChart()
})

function initProfitChart() {
  if (!chartRef1.value) return
  const chart = echarts.init(chartRef1.value)
  const months = ['1月', '2月', '3月', '4月', '5月', '6月', '7月', '8月', '9月', '10月', '11月', '12月']
  chart.setOption({
    tooltip: { trigger: 'axis' },
    legend: { data: ['营业收入', '营业成本', '毛利润', '净利润'], top: 10 },
    grid: { left: '3%', right: '4%', bottom: '3%', containLabel: true },
    toolbox: {
      feature: {
        magicType: { type: ['line', 'bar'] },
        saveAsImage: {}
      }
    },
    xAxis: { type: 'category', data: months, axisLabel: { color: '#666' } },
    yAxis: { type: 'value', name: '万元', axisLabel: { color: '#666' } },
    series: [
      { name: '营业收入', type: chartType.value, data: [180, 165, 195, 210, 198, 220, 205, 230, 215, 240, 225, 245], itemStyle: { color: '#409eff' }, smooth: true },
      { name: '营业成本', type: chartType.value, data: [120, 110, 130, 140, 132, 148, 138, 155, 145, 162, 152, 165], itemStyle: { color: '#e6e8eb' }, smooth: true },
      { name: '毛利润', type: chartType.value, data: [60, 55, 65, 70, 66, 72, 67, 75, 70, 78, 73, 80], itemStyle: { color: '#e6a23c' }, smooth: true },
      { name: '净利润', type: 'line', data: [28, 25, 32, 35, 30, 38, 33, 40, 36, 42, 38, 45], itemStyle: { color: '#67c23a' }, smooth: true, lineStyle: { width: 2 } }
    ]
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
      data: [
        { value: 1659.6, name: '营业成本', itemStyle: { color: '#5470c6' } },
        { value: 368.8, name: '期间费用', itemStyle: { color: '#91cc75' } },
        { value: 107.6, name: '所得税', itemStyle: { color: '#fac858' } },
        { value: 322.7, name: '净利润', itemStyle: { color: '#ee6666' } }
      ]
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
          <el-table :data="[
            { indicator: '营业收入', current: 2458.6, lastYear: 2185.2, yoy: 12.5, mom: 8.7 },
            { indicator: '净利润', current: 386.2, lastYear: 399.1, yoy: -3.2, mom: 5.3 },
            { indicator: '毛利率', current: 32.5, lastYear: 30.8, yoy: 5.5, mom: 1.2 },
            { indicator: '净利率', current: 15.7, lastYear: 18.3, yoy: -14.2, mom: 2.1 }
          ]" stripe size="small">
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
                <el-descriptions-item label="资产总额">5,426.8 万元</el-descriptions-item>
                <el-descriptions-item label="负债总额">2,458.3 万元</el-descriptions-item>
                <el-descriptions-item label="流动资产">2,856.2 万元</el-descriptions-item>
                <el-descriptions-item label="流动负债">1,543.6 万元</el-descriptions-item>
                <el-descriptions-item label="所有者权益">2,968.5 万元</el-descriptions-item>
                <el-descriptions-item label="存货">856.3 万元</el-descriptions-item>
              </el-descriptions>
            </el-tab-pane>
            <el-tab-pane label="利润表">
              <el-descriptions :column="2" border size="small">
                <el-descriptions-item label="营业收入">2,458.6 万元</el-descriptions-item>
                <el-descriptions-item label="营业成本">1,659.6 万元</el-descriptions-item>
                <el-descriptions-item label="期间费用">368.8 万元</el-descriptions-item>
                <el-descriptions-item label="税前利润">430.2 万元</el-descriptions-item>
                <el-descriptions-item label="所得税">107.6 万元</el-descriptions-item>
                <el-descriptions-item label="净利润">322.7 万元</el-descriptions-item>
              </el-descriptions>
            </el-tab-pane>
            <el-tab-pane label="现金流量表">
              <el-descriptions :column="2" border size="small">
                <el-descriptions-item label="经营活动">521.8 万元</el-descriptions-item>
                <el-descriptions-item label="投资活动">-186.5 万元</el-descriptions-item>
                <el-descriptions-item label="筹资活动">-235.6 万元</el-descriptions-item>
                <el-descriptions-item label="净现金流">99.7 万元</el-descriptions-item>
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
