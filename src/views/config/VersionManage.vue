<script setup>
import { ref, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { getVersions, simulateVersion, switchVersion } from '../../api/config'

const loading = ref(false)
const modelType = ref('ratio')
const versions = ref([])
const filteredVersions = ref([])
const simulateDialogVisible = ref(false)
const simulateResult = ref(null)

async function fetchVersions() {
  loading.value = true
  try {
    const res = await getVersions()
    versions.value = res.data || res || []
    filteredVersions.value = versions.value.filter(v => v.modelType === modelType.value)
  } catch (error) {
    ElMessage.error('获取版本列表失败')
  } finally {
    loading.value = false
  }
}

function handleModelTypeChange() {
  filteredVersions.value = versions.value.filter(v => v.modelType === modelType.value)
}

async function handleSimulate(row) {
  try {
    loading.value = true
    const res = await simulateVersion({ versionId: row.id, modelType: row.modelType })
    const data = res.data || res
    simulateResult.value = {
      version: row.version,
      differences: data.differences || []
    }
    simulateDialogVisible.value = true
  } catch (error) {
    ElMessage.error('模拟计算失败')
  } finally {
    loading.value = false
  }
}

async function handleSwitchVersion(row) {
  try {
    await ElMessageBox.confirm(`确认将版本"${row.version}"切换为当前版本？切换后需要重新触发全量计算。`, '切换版本', { type: 'warning' })
    loading.value = true
    await switchVersion({ versionId: row.id, modelType: row.modelType })
    ElMessage.success('版本切换成功')
    await fetchVersions()
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error('版本切换失败')
    }
  } finally {
    loading.value = false
  }
}

const modelTypeOptions = [
  { label: '比率模型', value: 'ratio' },
  { label: '预警模型', value: 'warning' }
]

onMounted(() => {
  fetchVersions()
})
</script>

<template>
  <div class="page-container">
    <div class="page-header">
      <h2>模型版本管理</h2>
    </div>

    <div class="search-bar">
      <el-radio-group v-model="modelType" @change="handleModelTypeChange">
        <el-radio-button v-for="opt in modelTypeOptions" :key="opt.value" :value="opt.value">{{ opt.label }}</el-radio-button>
      </el-radio-group>
    </div>

    <div class="card-container">
      <el-table :data="filteredVersions" v-loading="loading" stripe>
        <el-table-column prop="version" label="版本号" width="100" />
        <el-table-column prop="description" label="变更说明" min-width="280" />
        <el-table-column prop="creator" label="创建人" width="100" />
        <el-table-column prop="createTime" label="创建时间" width="170" />
        <el-table-column prop="isActive" label="状态" width="100">
          <template #default="{ row }">
            <el-tag v-if="row.isActive" type="success" size="small" effect="dark">当前版本</el-tag>
            <el-tag v-else type="info" size="small">历史版本</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="200" fixed="right">
          <template #default="{ row }">
            <el-button type="primary" link size="small" @click="handleSimulate(row)">模拟计算</el-button>
            <el-button v-if="!row.isActive" type="warning" link size="small" @click="handleSwitchVersion(row)">切换版本</el-button>
          </template>
        </el-table-column>
      </el-table>
    </div>

    <el-dialog v-model="simulateDialogVisible" title="模拟计算结果" width="680px">
      <div v-if="simulateResult">
        <el-alert
          :title="`使用版本 ${simulateResult.version} 的配置重新计算`"
          type="info"
          :closable="false"
          style="margin-bottom: 16px;"
        />
        <el-table :data="simulateResult.differences" stripe>
          <el-table-column prop="indicator" label="指标" width="140" />
          <el-table-column prop="currentResult" label="当前版本结果" width="140" align="right" />
          <el-table-column prop="simulatedResult" label="模拟版本结果" width="140" align="right" />
          <el-table-column prop="diff" label="差异" width="120" align="right">
            <template #default="{ row }">
              <span :style="{ color: row.diff > 0 ? '#67c23a' : row.diff < 0 ? '#f56c6c' : '#909399' }">
                {{ row.diff > 0 ? '+' : '' }}{{ row.diff }}
              </span>
            </template>
          </el-table-column>
        </el-table>
      </div>
      <template #footer>
        <el-button @click="simulateDialogVisible = false">关闭</el-button>
      </template>
    </el-dialog>
  </div>
</template>
