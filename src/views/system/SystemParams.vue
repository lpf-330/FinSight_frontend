<script setup>
import { ref, reactive } from 'vue'
import { ElMessage } from 'element-plus'

const loading = ref(false)
const activeTab = ref('general')

const generalParams = ref([
  { id: 1, key: 'system.name', value: 'FinSight财务智能分析系统', description: '系统名称', editable: true },
  { id: 2, key: 'system.version', value: '1.0.0', description: '系统版本', editable: false },
  { id: 3, key: 'etl.cron', value: '0 0 2 * * ?', description: 'ETL定时执行Cron表达式', editable: true },
  { id: 4, key: 'etl.timeout', value: '3600', description: 'ETL任务超时时间(秒)', editable: true },
  { id: 5, key: 'warning.auto_notify', value: 'true', description: '预警自动通知', editable: true },
  { id: 6, key: 'warning.notify_email', value: 'finance@company.com', description: '预警通知邮箱', editable: true },
  { id: 7, key: 'report.max_history', value: '100', description: '报告最大保留数量', editable: true },
  { id: 8, key: 'data.retention_days', value: '365', description: '数据保留天数', editable: true }
])

const emailParams = reactive({
  smtpHost: 'smtp.company.com',
  smtpPort: '465',
  sender: 'finsight@company.com',
  username: 'finsight@company.com',
  password: '********',
  sslEnabled: true
})

const emailTestResult = ref(null)

function handleSaveGeneral() {
  ElMessage.success('系统参数保存成功')
}

function handleSaveEmail() {
  ElMessage.success('邮件配置保存成功')
}

function handleTestEmail() {
  emailTestResult.value = null
  setTimeout(() => {
    emailTestResult.value = { success: true, message: '测试邮件发送成功，请检查收件箱' }
    ElMessage.success('测试邮件发送成功')
  }, 1500)
}

function handleClearCache() {
  ElMessage.success('缓存清理成功')
}

function handleExportConfig() {
  ElMessage.success('配置导出成功')
}
</script>

<template>
  <div class="page-container">
    <div class="page-header">
      <h2>系统参数</h2>
      <div>
        <el-button @click="handleExportConfig"><el-icon><Download /></el-icon>导出配置</el-button>
        <el-button @click="handleClearCache"><el-icon><Delete /></el-icon>清理缓存</el-button>
      </div>
    </div>

    <el-tabs v-model="activeTab">
      <el-tab-pane label="通用参数" name="general" />
      <el-tab-pane label="邮件配置" name="email" />
    </el-tabs>

    <div v-if="activeTab === 'general'" class="card-container">
      <el-table :data="generalParams" v-loading="loading" stripe>
        <el-table-column prop="key" label="参数键" width="220">
          <template #default="{ row }">
            <code style="font-size: 13px; color: #303133;">{{ row.key }}</code>
          </template>
        </el-table-column>
        <el-table-column prop="value" label="参数值" min-width="240">
          <template #default="{ row }">
            <el-input v-if="row.editable" v-model="row.value" size="small" />
            <span v-else>{{ row.value }}</span>
          </template>
        </el-table-column>
        <el-table-column prop="description" label="说明" width="220" />
        <el-table-column prop="editable" label="可编辑" width="80">
          <template #default="{ row }">
            <el-tag :type="row.editable ? 'success' : 'info'" size="small">{{ row.editable ? '是' : '否' }}</el-tag>
          </template>
        </el-table-column>
      </el-table>

      <div style="margin-top: 20px; text-align: right;">
        <el-button type="primary" @click="handleSaveGeneral">保存参数</el-button>
      </div>
    </div>

    <div v-if="activeTab === 'email'" class="card-container">
      <el-form :model="emailParams" label-width="120px" style="max-width: 600px;">
        <el-form-item label="SMTP服务器">
          <el-input v-model="emailParams.smtpHost" />
        </el-form-item>
        <el-form-item label="SMTP端口">
          <el-input v-model="emailParams.smtpPort" style="width: 200px;" />
        </el-form-item>
        <el-form-item label="发件人地址">
          <el-input v-model="emailParams.sender" />
        </el-form-item>
        <el-form-item label="认证用户名">
          <el-input v-model="emailParams.username" />
        </el-form-item>
        <el-form-item label="认证密码">
          <el-input v-model="emailParams.password" type="password" show-password />
        </el-form-item>
        <el-form-item label="启用SSL">
          <el-switch v-model="emailParams.sslEnabled" />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSaveEmail">保存配置</el-button>
          <el-button @click="handleTestEmail">发送测试邮件</el-button>
        </el-form-item>
      </el-form>

      <el-alert
        v-if="emailTestResult"
        :title="emailTestResult.message"
        :type="emailTestResult.success ? 'success' : 'error'"
        show-icon
        style="max-width: 600px; margin-top: 16px;"
      />
    </div>
  </div>
</template>
