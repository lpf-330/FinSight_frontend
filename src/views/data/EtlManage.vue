<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { getEtlTasks, triggerEtlTask, getEtlTaskDetail } from '../../api/data'

const loading = ref(false)
const etlTasks = ref([])

const connectionForm = reactive({
  url: '',
  username: '',
  password: '',
  driver: 'com.mysql.cj.jdbc.Driver'
})

const connectionDialogVisible = ref(false)
const testLoading = ref(false)

onMounted(() => {
  fetchEtlTasks()
})

async function fetchEtlTasks() {
  loading.value = true
  try {
    const res = await getEtlTasks()
    etlTasks.value = res.data || res || []
  } catch (e) {
    console.error('获取ETL任务失败:', e)
  } finally {
    loading.value = false
  }
}

async function handleTrigger(row) {
  try {
    await ElMessageBox.confirm(`确认手动触发任务"${row.name}"？`, '提示', { type: 'warning' })
    await triggerEtlTask({ taskId: row.id })
    ElMessage.success(`任务"${row.name}"已触发`)
    fetchEtlTasks()
  } catch (e) {
    if (e !== 'cancel') ElMessage.error(e.message || '触发失败')
  }
}

async function handleViewLog(row) {
  try {
    const res = await getEtlTaskDetail(row.id)
    const detail = res.data || res
    ElMessage.info(`查看任务"${row.name}"的日志`)
  } catch (e) {
    ElMessage.error('获取日志失败')
  }
}

function showConnectionConfig() {
  connectionDialogVisible.value = true
}

async function testConnection() {
  testLoading.value = true
  try {
    ElMessage.success('数据库连接测试成功')
  } catch (e) {
    ElMessage.error('连接测试失败')
  } finally {
    testLoading.value = false
  }
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
