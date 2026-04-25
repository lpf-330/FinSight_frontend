<script setup>
import { ref, onMounted, watch, nextTick } from 'vue'
import * as echarts from 'echarts'
import { ElMessage } from 'element-plus'
import { getTrendData, getDuPontAnalysis } from '../../api/algorithm'

const activeTab = ref('trend')
const selectedIndicator = ref('ROE')
const indicatorOptions = ['ROE', '毛利率', '总资产周转率', '销售净利率', '权益乘数']

const trendChartRef = ref(null)
const dupontChartRef = ref(null)

const trendData = ref([])

const dupontData = ref({
  roe: null,
  roeChange: null,
  factors: []
})

let trendChartInstance = null
let dupontChartInstance = null
const loading = ref(false)

async function fetchTrendData() {
  loading.value = true
  try {
    const res = await getTrendData({ indicator: selectedIndicator.value })
    trendData.value = res.data || []
    await nextTick()
    updateTrendChart()
  } catch (err) {
    ElMessage.error('获取趋势数据失败: ' + (err.message || '未知错误'))
  } finally {
    loading.value = false
  }
}

async function fetchDuPontData() {
  loading.value = true
  try {
    const res = await getDuPontAnalysis()
    dupontData.value = res.data || { roe: null, roeChange: null, factors: [] }
    await nextTick()
    updateDupontChart()
  } catch (err) {
    ElMessage.error('获取杜邦分析数据失败: ' + (err.message || '未知错误'))
  } finally {
    loading.value = false
  }
}

function initTrendChart() {
  if (!trendChartRef.value) return
  trendChartInstance = echarts.init(trendChartRef.value)
  updateTrendChart()
  window.addEventListener('resize', () => trendChartInstance && trendChartInstance.resize())
}

function initDupontChart() {
  if (!dupontChartRef.value) return
  dupontChartInstance = echarts.init(dupontChartRef.value)
  updateDupontChart()
  window.addEventListener('resize', () => dupontChartInstance && dupontChartInstance.resize())
}

function updateTrendChart() {
  if (!trendChartInstance || !trendData.value.length) return
  trendChartInstance.setOption({
    tooltip: { trigger: 'axis' },
    grid: { left: '3%', right: '4%', bottom: '3%', containLabel: true },
    xAxis: {
      type: 'category',
      data: trendData.value.map(d => d.month),
      axisLabel: { color: '#666', rotate: 30 }
    },
    yAxis: {
      type: 'value',
      name: '%',
      axisLabel: { color: '#666' },
      splitLine: { lineStyle: { color: '#f0f0f0' } }
    },
    series: [{
      type: 'line',
      data: trendData.value.map(d => d.value),
      smooth: true,
      itemStyle: { color: '#409eff' },
      lineStyle: { width: 2 },
      areaStyle: {
        color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [
          { offset: 0, color: 'rgba(64,158,255,0.3)' },
          { offset: 1, color: 'rgba(64,158,255,0.05)' }
        ])
      },
      markPoint: {
        data: [
          { type: 'max', name: '最大值' },
          { type: 'min', name: '最小值' }
        ]
      }
    }]
  })
}

function updateDupontChart() {
  if (!dupontChartInstance) return
  const factors = dupontData.value.factors || []
  if (!factors.length) return
  dupontChartInstance.setOption({
    tooltip: { trigger: 'axis' },
    grid: { left: '3%', right: '4%', bottom: '3%', containLabel: true },
    xAxis: {
      type: 'category',
      data: factors.map(f => f.name),
      axisLabel: { color: '#666' }
    },
    yAxis: {
      type: 'value',
      name: '贡献度(%)',
      axisLabel: { color: '#666' },
      splitLine: { lineStyle: { color: '#f0f0f0' } }
    },
    series: [{
      type: 'bar',
      data: factors.map(f => ({
        value: f.contribution,
        itemStyle: { color: f.contribution >= 0 ? '#67c23a' : '#f56c6c', borderRadius: f.contribution >= 0 ? [4, 4, 0, 0] : [0, 0, 4, 4] }
      })),
      label: {
        show: true,
        position: 'outside',
        formatter: '{c}%'
      }
    }]
  })
}

watch(selectedIndicator, () => {
  if (activeTab.value === 'trend') {
    fetchTrendData()
  }
})

watch(activeTab, (val) => {
  if (val === 'trend') {
    fetchTrendData()
  } else if (val === 'dupont') {
    fetchDuPontData()
  }
})

onMounted(() => {
  initTrendChart()
  initDupontChart()
  fetchTrendData()
  fetchDuPontData()
})
</script>

<template>
  <div class="page-container">
    <div class="page-header">
      <h2>趋势与杜邦分析</h2>
      <el-select v-model="selectedIndicator" style="width: 180px;">
        <el-option v-for="opt in indicatorOptions" :key="opt" :label="opt" :value="opt" />
      </el-select>
    </div>

    <el-tabs v-model="activeTab">
      <el-tab-pane label="趋势分析" name="trend" />
      <el-tab-pane label="杜邦分析" name="dupont" />
    </el-tabs>

    <div v-if="activeTab === 'trend'" class="card-container">
      <h3 class="section-title">{{ selectedIndicator }} 趋势（近12个月）</h3>
      <div ref="trendChartRef" style="height: 400px;"></div>
    </div>

    <div v-if="activeTab === 'dupont'" class="card-container">
      <h3 class="section-title">杜邦分析分解</h3>

      <div class="dupont-summary">
        <div class="dupont-roe">
          <div class="roe-label">净资产收益率 (ROE)</div>
          <div class="roe-value">{{ dupontData.roe }}%</div>
          <div class="roe-change" :class="dupontData.roeChange >= 0 ? 'up' : 'down'">
            {{ dupontData.roeChange >= 0 ? '+' : '' }}{{ dupontData.roeChange }}%
          </div>
        </div>
      </div>

      <div class="dupont-formula">
        <span class="formula-text">ROE = 销售净利率 × 总资产周转率 × 权益乘数</span>
      </div>

      <el-row :gutter="16" style="margin-top: 20px;">
        <el-col :span="8" v-for="factor in dupontData.factors" :key="factor.name">
          <div class="factor-card">
            <div class="factor-name">{{ factor.name }}</div>
            <div class="factor-value">{{ factor.value }}</div>
            <div class="factor-detail">
              <span>上期: {{ factor.prevValue }}</span>
              <span :class="factor.change >= 0 ? 'up' : 'down'">
                {{ factor.change >= 0 ? '+' : '' }}{{ factor.change }}%
              </span>
            </div>
            <div class="factor-contribution">
              贡献度: <span :class="factor.contribution >= 0 ? 'up' : 'down'">{{ factor.contribution }}%</span>
            </div>
          </div>
        </el-col>
      </el-row>

      <h3 class="section-title" style="margin-top: 24px;">各因子贡献度</h3>
      <div ref="dupontChartRef" style="height: 300px;"></div>
    </div>
  </div>
</template>

<style scoped>
.section-title {
  font-size: 16px;
  font-weight: 600;
  color: #303133;
  margin-bottom: 16px;
}

.dupont-summary {
  display: flex;
  justify-content: center;
  margin: 20px 0;
}

.dupont-roe {
  text-align: center;
  padding: 24px 48px;
  background: linear-gradient(135deg, #409eff, #1d6fce);
  border-radius: 12px;
  color: #fff;
}

.roe-label {
  font-size: 14px;
  opacity: 0.9;
  margin-bottom: 8px;
}

.roe-value {
  font-size: 36px;
  font-weight: 700;
}

.roe-change {
  font-size: 14px;
  margin-top: 4px;
}

.dupont-formula {
  text-align: center;
  margin: 16px 0;
}

.formula-text {
  font-size: 16px;
  color: #606266;
  font-family: 'Courier New', monospace;
  background: #f5f7fa;
  padding: 8px 20px;
  border-radius: 6px;
}

.factor-card {
  background: #f5f7fa;
  border-radius: 8px;
  padding: 20px;
  text-align: center;
}

.factor-name {
  font-size: 14px;
  color: #909399;
  margin-bottom: 8px;
}

.factor-value {
  font-size: 28px;
  font-weight: 700;
  color: #303133;
}

.factor-detail {
  font-size: 13px;
  color: #909399;
  margin-top: 8px;
  display: flex;
  justify-content: center;
  gap: 12px;
}

.factor-contribution {
  font-size: 13px;
  color: #606266;
  margin-top: 8px;
}

.up {
  color: #67c23a;
}

.down {
  color: #f56c6c;
}
</style>
