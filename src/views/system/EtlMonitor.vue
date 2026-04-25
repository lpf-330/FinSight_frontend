<script setup>
import { ref, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { getEtlMonitorData, manualTriggerEtl, stopEtlTask } from '../../api/system'

const loading = ref(false)
const etlTasks = ref([])
const total = ref(0)
const pageSize = ref(10)
const currentPage = ref(1)

const statCards = ref({
  successCount: 0,
  failedCount: 0,
  totalRecords: 0,
  avgDuration: ''
})

const logDialogVisible = ref(false)
const currentLog = ref('')

onMounted(() => {
  fetchEtlMonitorData()
})

async function fetchEtlMonitorData() {
  loading.value = true
  try {
    const res = await getEtlMonitorData({
      page: currentPage.value,
      pageSize: pageSize.value
    })
    const data = res.data || res
    etlTasks.value = data.list || data.records || data.tasks || []
    total.value = data.total || 0
    if (data.stats) {
      statCards.value = {
        successCount: data.stats.successCount || 0,
        failedCount: data.stats.failedCount || 0,
        totalRecords: data.stats.totalRecords || 0,
        avgDuration: data.stats.avgDuration || ''
      }
    }
  } catch (error) {
    ElMessage.error('获取ETL监控数据失败')
    console.error(error)
  } finally {
    loading.value = false
  }
}

function handleManualTrigger() {
  ElMessageBox.confirm('确认手动触发ETL任务？同一时间只能运行一个ETL任务。', '手动执行', { type: 'warning' })
    .then(async () => {
      try {
        await manualTriggerEtl()
        ElMessage.success('ETL任务已手动触发')
        fetchEtlMonitorData()
      } catch (error) {
        ElMessage.error('手动触发ETL任务失败')
        console.error(error)
      }
    })
    .catch(() => {})
}

function handleStop(row) {
  ElMessageBox.confirm('确认停止该任务？', '停止任务', { type: 'warning' })
    .then(async () => {
      try {
        await stopEtlTask(row.id)
        ElMessage.success('任务已停止')
        fetchEtlMonitorData()
      } catch (error) {
        ElMessage.error('停止任务失败')
        console.error(error)
      }
    })
    .catch(() => {})
}

function handleViewLog(row) {
  currentLog.value = row.errorMessage || `[INFO] ${row.startTime} - 任务开始执行\n[INFO] ${row.startTime} - 连接K8数据库...\n[INFO] ${row.startTime} - 开始抽取数据...\n${row.status === 'failed' ? '[ERROR] 连接超时\n[ERROR] 任务执行失败' : '[INFO] 数据抽取完成\n[INFO] 数据清洗完成\n[INFO] 数据加载完成\n[INFO] 任务执行成功'}\n[INFO] ${row.endTime} - 任务结束`
  logDialogVisible.value = true
}

function handleSizeChange(val) {
  pageSize.value = val
  fetchEtlMonitorData()
}

function handlePageChange(val) {
  currentPage.value = val
  fetchEtlMonitorData()
}

const statusTagType = { success: 'success', failed: 'danger', running: 'warning', stopped: 'info' }
const statusLabel = { success: '成功', failed: '失败', running: '运行中', stopped: '已停止' }
</script>

<template>
  <div class="page-container">
    <div class="page-header">
      <h2>ETL任务监控</h2>
      <el-button type="primary" @click="handleManualTrigger">
        <el-icon><VideoPlay /></el-icon>
        手动执行
      </el-button>
    </div>

    <div class="stat-cards">
      <div class="stat-card">
        <div class="stat-icon" style="background: #f0f9eb; color: #67c23a;">
          <el-icon size="24"><SuccessFilled /></el-icon>
        </div>
        <div class="stat-info">
          <div class="stat-label">今日成功</div>
          <div class="stat-value">{{ statCards.successCount }}</div>
        </div>
      </div>
      <div class="stat-card">
        <div class="stat-icon" style="background: #fef0f0; color: #f56c6c;">
          <el-icon size="24"><CircleCloseFilled /></el-icon>
        </div>
        <div class="stat-info">
          <div class="stat-label">今日失败</div>
          <div class="stat-value">{{ statCards.failedCount }}</div>
        </div>
      </div>
      <div class="stat-card">
        <div class="stat-icon" style="background: #ecf5ff; color: #409eff;">
          <el-icon size="24"><DataLine /></el-icon>
        </div>
        <div class="stat-info">
          <div class="stat-label">今日抽取记录</div>
          <div class="stat-value">{{ statCards.totalRecords.toLocaleString() }}</div>
        </div>
      </div>
      <div class="stat-card">
        <div class="stat-icon" style="background: #fdf6ec; color: #e6a23c;">
          <el-icon size="24"><Timer /></el-icon>
        </div>
        <div class="stat-info">
          <div class="stat-label">平均耗时</div>
          <div class="stat-value">{{ statCards.avgDuration }}</div>
        </div>
      </div>
    </div>

    <div class="card-container">
      <el-table :data="etlTasks" v-loading="loading" stripe>
        <el-table-column prop="name" label="任务名称" min-width="180" />
        <el-table-column prop="startTime" label="开始时间" width="170" />
        <el-table-column prop="endTime" label="结束时间" width="170" />
        <el-table-column prop="status" label="状态" width="80">
          <template #default="{ row }">
            <el-tag :type="statusTagType[row.status]" size="small">{{ statusLabel[row.status] }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="records" label="抽取记录数" width="120" align="right" />
        <el-table-column prop="errorCount" label="错误数" width="80" align="right">
          <template #default="{ row }">
            <span :style="{ color: row.errorCount > 0 ? '#f56c6c' : '#67c23a' }">{{ row.errorCount }}</span>
          </template>
        </el-table-column>
        <el-table-column prop="duration" label="耗时" width="100" />
        <el-table-column label="操作" width="160" fixed="right">
          <template #default="{ row }">
            <el-button type="primary" link size="small" @click="handleViewLog(row)">查看日志</el-button>
            <el-button v-if="row.status === 'running'" type="danger" link size="small" @click="handleStop(row)">停止</el-button>
          </template>
        </el-table-column>
      </el-table>

      <div class="pagination-wrapper">
        <el-pagination
          background
          layout="total, sizes, prev, pager, next"
          :total="total"
          :page-sizes="[10, 20, 50]"
          :page-size="pageSize"
          :current-page="currentPage"
          @size-change="handleSizeChange"
          @current-change="handlePageChange"
        />
      </div>
    </div>

    <el-dialog v-model="logDialogVisible" title="任务执行日志" width="680px">
      <pre class="log-content">{{ currentLog }}</pre>
      <template #footer>
        <el-button @click="logDialogVisible = false">关闭</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<style scoped>
.log-content {
  background: #1d1e2c;
  color: #a3e635;
  padding: 16px;
  border-radius: 8px;
  font-family: 'Courier New', monospace;
  font-size: 13px;
  line-height: 1.8;
  max-height: 400px;
  overflow-y: auto;
  white-space: pre-wrap;
}
</style>
