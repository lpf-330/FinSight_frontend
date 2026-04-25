<script setup>
import { ref, onMounted } from 'vue'
import * as echarts from 'echarts'
import { ElMessage } from 'element-plus'

const radarChartRef = ref(null)
const benchmarkData = ref([
  { indicator: '流动比率', enterprise: 1.85, industryAvg: 2.1, industryBest: 3.2, deviation: 88.1 },
  { indicator: '速动比率', enterprise: 0.92, industryAvg: 1.15, industryBest: 2.0, deviation: 80.0 },
  { indicator: '资产负债率(%)', enterprise: 45.3, industryAvg: 42.0, industryBest: 30.0, deviation: 107.9 },
  { indicator: '销售净利率(%)', enterprise: 15.7, industryAvg: 12.5, industryBest: 22.0, deviation: 125.6 },
  { indicator: '总资产周转率', enterprise: 0.85, industryAvg: 0.9, industryBest: 1.5, deviation: 94.4 },
  { indicator: 'ROE(%)', enterprise: 15.6, industryAvg: 14.0, industryBest: 25.0, deviation: 111.4 }
])

const uploadDialogVisible = ref(false)

onMounted(() => {
  initRadarChart()
})

function initRadarChart() {
  if (!radarChartRef.value) return
  const chart = echarts.init(radarChartRef.value)
  const indicators = benchmarkData.value.map(d => ({
    name: d.indicator,
    max: Math.max(d.enterprise, d.industryAvg, d.industryBest) * 1.3
  }))

  chart.setOption({
    tooltip: {},
    legend: { data: ['企业值', '行业平均', '行业优秀'], top: 10 },
    radar: {
      indicator: indicators,
      shape: 'polygon',
      splitNumber: 5,
      axisName: { color: '#606266', fontSize: 12 },
      splitArea: { areaStyle: { color: ['rgba(64,158,255,0.02)', 'rgba(64,158,255,0.05)'] } }
    },
    series: [{
      type: 'radar',
      data: [
        { value: benchmarkData.value.map(d => d.enterprise), name: '企业值', itemStyle: { color: '#409eff' }, areaStyle: { color: 'rgba(64,158,255,0.2)' } },
        { value: benchmarkData.value.map(d => d.industryAvg), name: '行业平均', itemStyle: { color: '#e6a23c' }, areaStyle: { color: 'rgba(230,162,60,0.1)' } },
        { value: benchmarkData.value.map(d => d.industryBest), name: '行业优秀', itemStyle: { color: '#67c23a' }, areaStyle: { color: 'rgba(103,194,58,0.1)' } }
      ]
    }]
  })
  window.addEventListener('resize', () => chart.resize())
}

function handleUpload() {
  uploadDialogVisible.value = true
}

function handleDownloadTemplate() {
  ElMessage.success('行业数据模板下载成功')
}

function handleUploadSubmit() {
  ElMessage.success('行业数据上传成功')
  uploadDialogVisible.value = false
}
</script>

<template>
  <div class="page-container">
    <div class="page-header">
      <h2>行业对标</h2>
      <div>
        <el-button @click="handleDownloadTemplate"><el-icon><Download /></el-icon>下载模板</el-button>
        <el-button type="primary" @click="handleUpload"><el-icon><Upload /></el-icon>上传行业数据</el-button>
      </div>
    </div>

    <el-row :gutter="20">
      <el-col :span="12">
        <div class="card-container">
          <h3 class="section-title">雷达图对比</h3>
          <div ref="radarChartRef" style="height: 420px;"></div>
        </div>
      </el-col>
      <el-col :span="12">
        <div class="card-container">
          <h3 class="section-title">对标明细</h3>
          <el-table :data="benchmarkData" stripe size="small" style="margin-top: 12px;">
            <el-table-column prop="indicator" label="指标" width="130" />
            <el-table-column prop="enterprise" label="企业值" width="90" align="right">
              <template #default="{ row }">
                <span style="font-weight: 600;">{{ row.enterprise }}</span>
              </template>
            </el-table-column>
            <el-table-column prop="industryAvg" label="行业平均" width="90" align="right" />
            <el-table-column prop="industryBest" label="行业优秀" width="90" align="right" />
            <el-table-column prop="deviation" label="偏离度(%)" min-width="100" align="right">
              <template #default="{ row }">
                <span :style="{ color: row.deviation >= 100 ? '#67c23a' : '#f56c6c' }">
                  {{ row.deviation }}%
                </span>
              </template>
            </el-table-column>
          </el-table>

          <div style="margin-top: 16px; padding: 12px; background: #f5f7fa; border-radius: 6px;">
            <h4 style="font-size: 14px; color: #303133; margin-bottom: 8px;">对标分析总结</h4>
            <ul style="font-size: 13px; color: #606266; line-height: 1.8; padding-left: 16px;">
              <li>销售净利率和ROE高于行业平均水平，盈利能力表现较好</li>
              <li>流动比率和速动比率低于行业平均，短期偿债能力需加强</li>
              <li>资产负债率略高于行业平均，需关注负债结构</li>
              <li>总资产周转率接近行业平均，资产运营效率中等</li>
            </ul>
          </div>
        </div>
      </el-col>
    </el-row>

    <el-dialog v-model="uploadDialogVisible" title="上传行业基准数据" width="480px">
      <el-upload drag action="/api/report/benchmark/upload" accept=".xlsx,.xls" :limit="1">
        <div style="text-align: center; padding: 20px;">
          <el-icon size="40" color="#c0c4cc"><UploadFilled /></el-icon>
          <p>将文件拖到此处，或<em style="color: #409eff;">点击上传</em></p>
          <p style="font-size: 12px; color: #909399;">请使用标准模板填写行业数据后上传</p>
        </div>
      </el-upload>
      <template #footer>
        <el-button @click="uploadDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleUploadSubmit">确认上传</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<style scoped>
.section-title {
  font-size: 16px;
  font-weight: 600;
  color: #303133;
  margin-bottom: 12px;
}
</style>
