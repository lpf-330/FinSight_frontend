<script setup>
import { ref } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'

const loading = ref(false)
const etlTasks = ref([
  { id: 1, name: 'K8科目余额表抽取', startTime: '2026-04-24 02:00:00', endTime: '2026-04-24 02:03:25', status: 'success', records: 12580, errorCount: 0, errorMessage: '', duration: '3m 25s' },
  { id: 2, name: 'K8利润表抽取', startTime: '2026-04-24 02:00:00', endTime: '2026-04-24 02:01:12', status: 'success', records: 3250, errorCount: 0, errorMessage: '', duration: '1m 12s' },
  { id: 3, name: 'K8现金流量表抽取', startTime: '2026-04-24 02:00:00', endTime: '2026-04-24 02:00:45', status: 'failed', records: 0, errorCount: 1, errorMessage: 'Connection timeout: K8数据库连接超时', duration: '0m 45s' },
  { id: 4, name: 'K8科目余额表抽取', startTime: '2026-04-23 02:00:00', endTime: '2026-04-23 02:04:10', status: 'success', records: 12450, errorCount: 0, errorMessage: '', duration: '4m 10s' },
  { id: 5, name: 'K8利润表抽取', startTime: '2026-04-23 02:00:00', endTime: '2026-04-23 02:01:30', status: 'success', records: 3180, errorCount: 0, errorMessage: '', duration: '1m 30s' },
  { id: 6, name: 'K8现金流量表抽取', startTime: '2026-04-23 02:00:00', endTime: '2026-04-23 02:01:55', status: 'success', records: 2890, errorCount: 0, errorMessage: '', duration: '1m 55s' }
])

const logDialogVisible = ref(false)
const currentLog = ref('')

function handleManualTrigger() {
  ElMessageBox.confirm('确认手动触发ETL任务？同一时间只能运行一个ETL任务。', '手动执行', { type: 'warning' })
    .then(() => {
      ElMessage.success('ETL任务已手动触发')
    })
    .catch(() => {})
}

function handleStop(row) {
  ElMessageBox.confirm('确认停止该任务？', '停止任务', { type: 'warning' })
    .then(() => {
      row.status = 'stopped'
      ElMessage.success('任务已停止')
    })
    .catch(() => {})
}

function handleViewLog(row) {
  currentLog.value = row.errorMessage || `[INFO] ${row.startTime} - 任务开始执行\n[INFO] ${row.startTime} - 连接K8数据库...\n[INFO] ${row.startTime} - 开始抽取数据...\n${row.status === 'failed' ? '[ERROR] 连接超时\n[ERROR] 任务执行失败' : '[INFO] 数据抽取完成\n[INFO] 数据清洗完成\n[INFO] 数据加载完成\n[INFO] 任务执行成功'}\n[INFO] ${row.endTime} - 任务结束`
  logDialogVisible.value = true
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
          <div class="stat-value">2</div>
        </div>
      </div>
      <div class="stat-card">
        <div class="stat-icon" style="background: #fef0f0; color: #f56c6c;">
          <el-icon size="24"><CircleCloseFilled /></el-icon>
        </div>
        <div class="stat-info">
          <div class="stat-label">今日失败</div>
          <div class="stat-value">1</div>
        </div>
      </div>
      <div class="stat-card">
        <div class="stat-icon" style="background: #ecf5ff; color: #409eff;">
          <el-icon size="24"><DataLine /></el-icon>
        </div>
        <div class="stat-info">
          <div class="stat-label">今日抽取记录</div>
          <div class="stat-value">15,830</div>
        </div>
      </div>
      <div class="stat-card">
        <div class="stat-icon" style="background: #fdf6ec; color: #e6a23c;">
          <el-icon size="24"><Timer /></el-icon>
        </div>
        <div class="stat-info">
          <div class="stat-label">平均耗时</div>
          <div class="stat-value">2m 14s</div>
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
          :total="6"
          :page-sizes="[10, 20, 50]"
          :page-size="10"
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
