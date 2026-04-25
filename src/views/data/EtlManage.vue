<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'

const loading = ref(false)
const etlTasks = ref([
  { id: 1, name: 'K8科目余额表抽取', source: '金蝶K8', target: '科目余额事实表', cron: '0 2 * * *', status: 'success', lastRun: '2026-04-24 02:00:00', nextRun: '2026-04-25 02:00:00', records: 12580, duration: '3m 25s' },
  { id: 2, name: 'K8利润表抽取', source: '金蝶K8', target: '利润表事实表', cron: '0 2 * * *', status: 'success', lastRun: '2026-04-24 02:00:00', nextRun: '2026-04-25 02:00:00', records: 3250, duration: '1m 12s' },
  { id: 3, name: 'K8现金流量表抽取', source: '金蝶K8', target: '现金流量表事实表', cron: '0 2 * * *', status: 'failed', lastRun: '2026-04-24 02:00:00', nextRun: '2026-04-25 02:00:00', records: 0, duration: '0m 45s' }
])

const connectionForm = reactive({
  url: 'jdbc:mysql://192.168.1.100:3306/k8db',
  username: 'readonly',
  password: '',
  driver: 'com.mysql.cj.jdbc.Driver'
})

const connectionDialogVisible = ref(false)
const testLoading = ref(false)

function handleTrigger(row) {
  ElMessageBox.confirm(`确认手动触发任务"${row.name}"？`, '提示', { type: 'warning' })
    .then(() => {
      ElMessage.success(`任务"${row.name}"已触发`)
    })
    .catch(() => {})
}

function handleViewLog(row) {
  ElMessage.info(`查看任务"${row.name}"的日志`)
}

function showConnectionConfig() {
  connectionDialogVisible.value = true
}

async function testConnection() {
  testLoading.value = true
  setTimeout(() => {
    testLoading.value = false
    ElMessage.success('数据库连接测试成功')
  }, 1500)
}

const statusTagType = { success: 'success', failed: 'danger', running: 'warning', pending: 'info' }
const statusLabel = { success: '成功', failed: '失败', running: '运行中', pending: '待执行' }
</script>

<template>
  <div class="page-container">
    <div class="page-header">
      <h2>ETL管理</h2>
      <el-button type="primary" @click="showConnectionConfig">
        <el-icon><Setting /></el-icon>
        数据库连接配置
      </el-button>
    </div>

    <div class="card-container">
      <el-table :data="etlTasks" v-loading="loading" stripe>
        <el-table-column prop="name" label="任务名称" min-width="180" />
        <el-table-column prop="source" label="数据源" width="120" />
        <el-table-column prop="target" label="目标表" width="160" />
        <el-table-column prop="cron" label="调度规则" width="140" />
        <el-table-column prop="status" label="最近状态" width="100">
          <template #default="{ row }">
            <el-tag :type="statusTagType[row.status]" size="small">{{ statusLabel[row.status] }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="lastRun" label="最近执行时间" width="180" />
        <el-table-column prop="records" label="抽取记录数" width="120" align="right" />
        <el-table-column prop="duration" label="耗时" width="100" />
        <el-table-column label="操作" width="180" fixed="right">
          <template #default="{ row }">
            <el-button type="primary" link size="small" @click="handleTrigger(row)">手动执行</el-button>
            <el-button type="info" link size="small" @click="handleViewLog(row)">查看日志</el-button>
          </template>
        </el-table-column>
      </el-table>
    </div>

    <el-dialog v-model="connectionDialogVisible" title="K8数据库连接配置" width="560px">
      <el-form :model="connectionForm" label-width="100px">
        <el-form-item label="JDBC URL">
          <el-input v-model="connectionForm.url" />
        </el-form-item>
        <el-form-item label="用户名">
          <el-input v-model="connectionForm.username" />
        </el-form-item>
        <el-form-item label="密码">
          <el-input v-model="connectionForm.password" type="password" show-password />
        </el-form-item>
        <el-form-item label="驱动类">
          <el-input v-model="connectionForm.driver" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="testConnection" :loading="testLoading">测试连接</el-button>
        <el-button type="primary" @click="connectionDialogVisible = false">保存</el-button>
        <el-button @click="connectionDialogVisible = false">取消</el-button>
      </template>
    </el-dialog>
  </div>
</template>
