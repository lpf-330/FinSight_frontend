<script setup>
import { ref, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { getPdfReportHistory, generatePdfReport } from '../../api/report'

const loading = ref(false)
const reportHistory = ref([])

const generating = ref(false)
const reportForm = ref({
  name: '',
  type: 'comprehensive',
  period: '2026-Q1',
  includeWarning: true,
  includeRatio: true,
  includeTrend: true,
  includeInvestment: false
})

const typeOptions = [
  { label: '综合分析报告', value: 'comprehensive' },
  { label: '预警报告', value: 'warning' },
  { label: '投资评估报告', value: 'investment' }
]

onMounted(() => {
  fetchReportHistory()
})

async function fetchReportHistory() {
  loading.value = true
  try {
    const res = await getPdfReportHistory()
    reportHistory.value = res.data || res || []
  } catch (error) {
    ElMessage.error('获取报告历史失败')
    console.error(error)
  } finally {
    loading.value = false
  }
}

async function handleGenerate() {
  if (!reportForm.value.name) {
    ElMessage.warning('请输入报告名称')
    return
  }
  generating.value = true
  try {
    const res = await generatePdfReport(reportForm.value)
    const blob = new Blob([res.data || res], { type: 'application/pdf' })
    const url = window.URL.createObjectURL(blob)
    const link = document.createElement('a')
    link.href = url
    link.download = `${reportForm.value.name}.pdf`
    link.click()
    window.URL.revokeObjectURL(url)
    ElMessage.success('PDF报告生成成功，正在下载...')
    fetchReportHistory()
  } catch (error) {
    ElMessage.error('PDF报告生成失败')
    console.error(error)
  } finally {
    generating.value = false
  }
}

function handleDownload(row) {
  if (row.status !== 'completed') {
    ElMessage.warning('报告尚未生成完成，无法下载')
    return
  }
  try {
    generatePdfReport({ id: row.id, download: true }).then(res => {
      const blob = new Blob([res.data || res], { type: 'application/pdf' })
      const url = window.URL.createObjectURL(blob)
      const link = document.createElement('a')
      link.href = url
      link.download = `${row.name}.pdf`
      link.click()
      window.URL.revokeObjectURL(url)
      ElMessage.success(`正在下载: ${row.name}`)
    })
  } catch (error) {
    ElMessage.error('下载报告失败')
    console.error(error)
  }
}

function handleDelete(row) {
  ElMessageBox.confirm(`确认删除报告"${row.name}"？`, '提示', { type: 'warning' })
    .then(() => {
      reportHistory.value = reportHistory.value.filter(r => r.id !== row.id)
      ElMessage.success('删除成功')
    })
    .catch(() => {})
}

const statusLabel = { completed: '已完成', generating: '生成中', failed: '生成失败' }
const statusTagType = { completed: 'success', generating: 'warning', failed: 'danger' }
</script>

<template>
  <div class="page-container">
    <div class="page-header">
      <h2>PDF报告</h2>
    </div>

    <el-row :gutter="20">
      <el-col :span="8">
        <div class="card-container">
          <h3 class="section-title">生成报告</h3>
          <el-form :model="reportForm" label-width="110px" style="margin-top: 16px;">
            <el-form-item label="报告名称" required>
              <el-input v-model="reportForm.name" placeholder="请输入报告名称" />
            </el-form-item>
            <el-form-item label="报告类型">
              <el-select v-model="reportForm.type" style="width: 100%;">
                <el-option v-for="opt in typeOptions" :key="opt.value" :label="opt.label" :value="opt.value" />
              </el-select>
            </el-form-item>
            <el-form-item label="分析期间">
              <el-input v-model="reportForm.period" placeholder="如: 2026-Q1" />
            </el-form-item>
            <el-form-item label="包含内容">
              <el-checkbox v-model="reportForm.includeWarning">预警信息</el-checkbox>
              <el-checkbox v-model="reportForm.includeRatio">比率分析</el-checkbox>
              <el-checkbox v-model="reportForm.includeTrend">趋势图表</el-checkbox>
              <el-checkbox v-model="reportForm.includeInvestment">投资评估</el-checkbox>
            </el-form-item>
            <el-form-item>
              <el-button type="primary" :loading="generating" @click="handleGenerate">
                <el-icon><Document /></el-icon>
                生成PDF报告
              </el-button>
            </el-form-item>
          </el-form>
        </div>
      </el-col>

      <el-col :span="16">
        <div class="card-container">
          <h3 class="section-title">报告历史</h3>
          <el-table :data="reportHistory" v-loading="loading" stripe style="margin-top: 16px;">
            <el-table-column prop="name" label="报告名称" min-width="200" />
            <el-table-column prop="type" label="类型" width="120" />
            <el-table-column prop="period" label="期间" width="100" />
            <el-table-column prop="fileSize" label="大小" width="80" />
            <el-table-column prop="status" label="状态" width="100">
              <template #default="{ row }">
                <el-tag :type="statusTagType[row.status]" size="small">{{ statusLabel[row.status] }}</el-tag>
              </template>
            </el-table-column>
            <el-table-column prop="creator" label="生成人" width="80" />
            <el-table-column prop="createTime" label="生成时间" width="160" />
            <el-table-column label="操作" width="140" fixed="right">
              <template #default="{ row }">
                <el-button type="primary" link size="small" @click="handleDownload(row)">下载</el-button>
                <el-button type="danger" link size="small" @click="handleDelete(row)">删除</el-button>
              </template>
            </el-table-column>
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
</style>
