<script setup>
import { ref, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { UploadFilled } from '@element-plus/icons-vue'
import { uploadExcel, downloadTemplate, getImportHistory } from '../../api/data'

const uploadRef = ref(null)
const uploadProgress = ref(0)
const uploading = ref(false)
const importType = ref('balance')
const importMode = ref('append')
const importHistory = ref([])

const typeOptions = [
  { label: '资产负债表', value: 'balance' },
  { label: '利润表', value: 'income' },
  { label: '现金流量表', value: 'cashflow' }
]

const modeOptions = [
  { label: '追加', value: 'append' },
  { label: '覆盖指定期间', value: 'overwrite' }
]

onMounted(() => {
  fetchImportHistory()
})

async function fetchImportHistory() {
  try {
    const res = await getImportHistory()
    importHistory.value = res.data || res || []
  } catch (e) {
    console.error('获取导入历史失败:', e)
  }
}

async function handleDownloadTemplate(type) {
  try {
    const res = await downloadTemplate(type)
    const blob = new Blob([res], { type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' })
    const url = window.URL.createObjectURL(blob)
    const link = document.createElement('a')
    link.href = url
    link.download = `${typeOptions.find(t => t.value === type)?.label || ''}模板.xlsx`
    link.click()
    window.URL.revokeObjectURL(url)
    ElMessage.success('模板下载成功')
  } catch (e) {
    ElMessage.error('模板下载失败')
  }
}

function beforeUpload(file) {
  const isExcel = file.name.endsWith('.xlsx') || file.name.endsWith('.xls')
  const isLt10M = file.size / 1024 / 1024 < 10
  if (!isExcel) {
    ElMessage.error('仅支持上传 .xlsx 或 .xls 格式文件')
    return false
  }
  if (!isLt10M) {
    ElMessage.error('文件大小不能超过 10MB')
    return false
  }
  return true
}

async function handleCustomUpload(options) {
  uploading.value = true
  uploadProgress.value = 0
  const formData = new FormData()
  formData.append('file', options.file)
  formData.append('type', importType.value)
  formData.append('mode', importMode.value)
  try {
    await uploadExcel(formData, (event) => {
      uploadProgress.value = Math.round((event.loaded / event.total) * 100)
    })
    ElMessage.success('文件导入成功')
    fetchImportHistory()
  } catch (e) {
    ElMessage.error('文件导入失败，请检查文件格式')
  } finally {
    uploading.value = false
    uploadProgress.value = 0
  }
}

const statusTagType = { success: 'success', failed: 'danger' }
const statusLabel = { success: '成功', failed: '失败' }
</script>

<template>
  <div class="page-container">
    <div class="page-header">
      <h2>Excel导入</h2>
    </div>

    <el-row :gutter="20">
      <el-col :span="12">
        <div class="card-container">
          <h3 class="section-title">模板下载</h3>
          <p class="section-desc">请先下载标准模板，按模板格式填写数据后上传</p>
          <div class="template-list">
            <div v-for="opt in typeOptions" :key="opt.value" class="template-item">
              <div class="template-info">
                <el-icon size="20"><Document /></el-icon>
                <span>{{ opt.label }}模板</span>
              </div>
              <el-button type="primary" link @click="handleDownloadTemplate(opt.value)">
                <el-icon><Download /></el-icon>
                下载
              </el-button>
            </div>
          </div>
        </div>
      </el-col>

      <el-col :span="12">
        <div class="card-container">
          <h3 class="section-title">文件上传</h3>
          <el-form label-width="100px" style="margin-top: 16px;">
            <el-form-item label="报表类型">
              <el-select v-model="importType" style="width: 100%;">
                <el-option v-for="opt in typeOptions" :key="opt.value" :label="opt.label" :value="opt.value" />
              </el-select>
            </el-form-item>
            <el-form-item label="导入模式">
              <el-radio-group v-model="importMode">
                <el-radio v-for="opt in modeOptions" :key="opt.value" :value="opt.value">{{ opt.label }}</el-radio>
              </el-radio-group>
            </el-form-item>
            <el-form-item label="选择文件">
              <el-upload
                ref="uploadRef"
                :http-request="handleCustomUpload"
                :before-upload="beforeUpload"
                :show-file-list="false"
                accept=".xlsx,.xls"
                drag
              >
                <div class="upload-area">
                  <el-icon size="40" color="#c0c4cc"><UploadFilled /></el-icon>
                  <p>将文件拖到此处，或<em>点击上传</em></p>
                  <p class="upload-tip">仅支持 .xlsx 格式，文件大小不超过 10MB</p>
                </div>
              </el-upload>
              <el-progress v-if="uploading" :percentage="uploadProgress" style="margin-top: 10px;" />
            </el-form-item>
          </el-form>
        </div>
      </el-col>
    </el-row>

    <div class="card-container" style="margin-top: 20px;">
      <h3 class="section-title">导入历史</h3>
      <el-table :data="importHistory" stripe style="margin-top: 16px;">
        <el-table-column prop="fileName" label="文件名" min-width="200" />
        <el-table-column prop="type" label="报表类型" width="120" />
        <el-table-column prop="mode" label="导入模式" width="120" />
        <el-table-column prop="records" label="导入记录数" width="120" align="right" />
        <el-table-column prop="status" label="状态" width="80">
          <template #default="{ row }">
            <el-tag :type="statusTagType[row.status]" size="small">{{ statusLabel[row.status] }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="operatorName" label="操作人" width="100" />
        <el-table-column prop="createdAt" label="操作时间" width="180" />
      </el-table>
    </div>
  </div>
</template>

<style scoped>
.section-title {
  font-size: 16px;
  font-weight: 600;
  color: #303133;
}

.section-desc {
  font-size: 13px;
  color: #909399;
  margin-top: 8px;
}

.template-list {
  margin-top: 16px;
}

.template-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 12px 16px;
  border: 1px solid #ebeef5;
  border-radius: 8px;
  margin-bottom: 8px;
}

.template-info {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 14px;
  color: #303133;
}

.upload-area {
  text-align: center;
  padding: 20px;
}

.upload-area p {
  font-size: 14px;
  color: #606266;
  margin-top: 8px;
}

.upload-area em {
  color: #409eff;
  font-style: normal;
}

.upload-tip {
  font-size: 12px !important;
  color: #909399 !important;
}
</style>
