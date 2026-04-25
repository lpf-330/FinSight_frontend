<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { getSystemParams, updateSystemParams } from '../../api/system'

const loading = ref(false)
const activeTab = ref('general')

const generalParams = ref([])

const emailParams = reactive({
  smtpHost: '',
  smtpPort: '',
  sender: '',
  username: '',
  password: '',
  sslEnabled: true
})

const emailTestResult = ref(null)

onMounted(() => {
  fetchSystemParams()
})

async function fetchSystemParams() {
  loading.value = true
  try {
    const res = await getSystemParams()
    const data = res.data || res
    if (data.general) {
      generalParams.value = data.general
    }
    if (data.email) {
      Object.assign(emailParams, data.email)
    }
  } catch (error) {
    ElMessage.error('获取系统参数失败')
    console.error(error)
  } finally {
    loading.value = false
  }
}

async function handleSaveGeneral() {
  try {
    await updateSystemParams({ general: generalParams.value })
    ElMessage.success('系统参数保存成功')
  } catch (error) {
    ElMessage.error('系统参数保存失败')
    console.error(error)
  }
}

async function handleSaveEmail() {
  try {
    await updateSystemParams({ email: { ...emailParams } })
    ElMessage.success('邮件配置保存成功')
  } catch (error) {
    ElMessage.error('邮件配置保存失败')
    console.error(error)
  }
}

async function handleTestEmail() {
  emailTestResult.value = null
  try {
    await updateSystemParams({ email: { ...emailParams }, testEmail: true })
    emailTestResult.value = { success: true, message: '测试邮件发送成功，请检查收件箱' }
    ElMessage.success('测试邮件发送成功')
  } catch (error) {
    emailTestResult.value = { success: false, message: '测试邮件发送失败，请检查配置' }
    ElMessage.error('测试邮件发送失败')
    console.error(error)
  }
}

async function handleClearCache() {
  try {
    await updateSystemParams({ action: 'clearCache' })
    ElMessage.success('缓存清理成功')
  } catch (error) {
    ElMessage.error('缓存清理失败')
    console.error(error)
  }
}

async function handleExportConfig() {
  try {
    await updateSystemParams({ action: 'exportConfig' })
    ElMessage.success('配置导出成功')
  } catch (error) {
    ElMessage.error('配置导出失败')
    console.error(error)
  }
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
