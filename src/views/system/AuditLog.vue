<script setup>
import { ref, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { getAuditLogs, exportAuditLogs } from '../../api/system'

const loading = ref(false)
const dateRange = ref([])
const filterUser = ref('')
const filterType = ref('')
const total = ref(0)
const pageSize = ref(10)
const currentPage = ref(1)

const auditLogs = ref([])

const operationTypes = ['数据导入', '配置修改', '用户管理', '权限变更', '报告生成', '公式修改', 'ETL操作']

onMounted(() => {
  fetchAuditLogs()
})

async function fetchAuditLogs() {
  loading.value = true
  try {
    const params = {
      page: currentPage.value,
      pageSize: pageSize.value,
      startDate: dateRange.value?.[0] || '',
      endDate: dateRange.value?.[1] || '',
      user: filterUser.value,
      type: filterType.value
    }
    const res = await getAuditLogs(params)
    const data = res.data || res
    auditLogs.value = data.list || data.records || data || []
    total.value = data.total || 0
  } catch (error) {
    ElMessage.error('获取审计日志失败')
    console.error(error)
  } finally {
    loading.value = false
  }
}

async function handleSearch() {
  currentPage.value = 1
  await fetchAuditLogs()
}

async function handleExport() {
  try {
    const params = {
      startDate: dateRange.value?.[0] || '',
      endDate: dateRange.value?.[1] || '',
      user: filterUser.value,
      type: filterType.value
    }
    const res = await exportAuditLogs(params)
    const blob = new Blob([res.data || res], { type: 'text/csv' })
    const url = window.URL.createObjectURL(blob)
    const link = document.createElement('a')
    link.href = url
    link.download = '审计日志.csv'
    link.click()
    window.URL.revokeObjectURL(url)
    ElMessage.success('审计日志导出成功')
  } catch (error) {
    ElMessage.error('导出审计日志失败')
    console.error(error)
  }
}

function handleReset() {
  dateRange.value = []
  filterUser.value = ''
  filterType.value = ''
  currentPage.value = 1
  fetchAuditLogs()
}

function handleSizeChange(val) {
  pageSize.value = val
  fetchAuditLogs()
}

function handlePageChange(val) {
  currentPage.value = val
  fetchAuditLogs()
}
</script>

<template>
  <div class="page-container">
    <div class="page-header">
      <h2>审计日志</h2>
      <el-button @click="handleExport"><el-icon><Download /></el-icon>导出CSV</el-button>
    </div>

    <div class="card-container">
      <div class="search-bar">
        <el-date-picker
          v-model="dateRange"
          type="daterange"
          range-separator="至"
          start-placeholder="开始日期"
          end-placeholder="结束日期"
          style="width: 280px;"
        />
        <el-input v-model="filterUser" placeholder="操作人" style="width: 140px;" clearable />
        <el-select v-model="filterType" placeholder="操作类型" clearable style="width: 160px;">
          <el-option v-for="opt in operationTypes" :key="opt" :label="opt" :value="opt" />
        </el-select>
        <el-button type="primary" @click="handleSearch"><el-icon><Search /></el-icon>搜索</el-button>
        <el-button @click="handleReset">重置</el-button>
      </div>

      <el-table :data="auditLogs" v-loading="loading" stripe>
        <el-table-column prop="time" label="操作时间" width="170" sortable />
        <el-table-column prop="user" label="操作人" width="100" />
        <el-table-column prop="operation" label="操作类型" width="120">
          <template #default="{ row }">
            <el-tag size="small">{{ row.operation }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="module" label="功能模块" width="120" />
        <el-table-column prop="detail" label="操作详情" min-width="260" show-overflow-tooltip />
        <el-table-column prop="ip" label="IP地址" width="140" />
      </el-table>

      <div class="pagination-wrapper">
        <el-pagination
          background
          layout="total, sizes, prev, pager, next, jumper"
          :total="total"
          :page-sizes="[10, 20, 50]"
          :page-size="pageSize"
          :current-page="currentPage"
          @size-change="handleSizeChange"
          @current-change="handlePageChange"
        />
      </div>
    </div>
  </div>
</template>
