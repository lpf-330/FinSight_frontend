<script setup>
import { ref } from 'vue'
import { ElMessage } from 'element-plus'

const loading = ref(false)
const reportHistory = ref([
  { id: 1, name: '2026年Q1财务分析报告', type: '综合分析', period: '2026-Q1', status: 'completed', createTime: '2026-04-20 15:30', fileSize: '2.8MB', creator: '张三' },
  { id: 2, name: '2026年3月预警报告', type: '预警报告', period: '2026-03', status: 'completed', createTime: '2026-04-15 10:20', fileSize: '1.2MB', creator: '张三' },
  { id: 3, name: '投资测算方案-新产线', type: '投资评估', period: '-', status: 'completed', createTime: '2026-04-12 16:45', fileSize: '0.8MB', creator: '李四' }
])

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

function handleGenerate() {
  if (!reportForm.value.name) {
    ElMessage.warning('请输入报告名称')
    return
  }
  generating.value = true
  setTimeout(() => {
    generating.value = false
    ElMessage.success('PDF报告生成成功，正在下载...')
  }, 2000)
}

function handleDownload(row) {
  ElMessage.success(`正在下载: ${row.name}`)
}

function handleDelete(row) {
  reportHistory.value = reportHistory.value.filter(r => r.id !== row.id)
  ElMessage.success('删除成功')
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
