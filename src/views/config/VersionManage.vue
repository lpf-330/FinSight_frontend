<script setup>
import { ref } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'

const loading = ref(false)
const modelType = ref('ratio')
const versions = ref([
  { id: 1, modelType: 'ratio', version: 'v1.3', description: '新增现金比率公式，修正速动比率计算逻辑', creator: '张三', createTime: '2026-04-10 14:30', isActive: true },
  { id: 2, modelType: 'ratio', version: 'v1.2', description: '优化存货周转率公式，支持平均余额计算', creator: '张三', createTime: '2026-03-15 10:00', isActive: false },
  { id: 3, modelType: 'ratio', version: 'v1.1', description: '修正资产负债率公式', creator: '李四', createTime: '2026-02-20 16:45', isActive: false },
  { id: 4, modelType: 'ratio', version: 'v1.0', description: '初始版本，包含基础比率公式', creator: '李四', createTime: '2026-01-15 09:00', isActive: false },
  { id: 5, modelType: 'warning', version: 'v2.0', description: '调整流动比率阈值，新增现金比率预警', creator: '张三', createTime: '2026-04-12 11:20', isActive: true },
  { id: 6, modelType: 'warning', version: 'v1.0', description: '初始预警阈值配置', creator: '李四', createTime: '2026-01-15 09:00', isActive: false }
])

const filteredVersions = ref(versions.value.filter(v => v.modelType === 'ratio'))
const simulateDialogVisible = ref(false)
const simulateResult = ref(null)

function handleModelTypeChange() {
  filteredVersions.value = versions.value.filter(v => v.modelType === modelType.value)
}

function handleSimulate(row) {
  simulateDialogVisible.value = true
  simulateResult.value = {
    version: row.version,
    differences: [
      { indicator: '流动比率', currentResult: 1.85, simulatedResult: 1.82, diff: -0.03 },
      { indicator: '速动比率', currentResult: 0.92, simulatedResult: 0.95, diff: 0.03 },
      { indicator: '资产负债率', currentResult: 45.3, simulatedResult: 45.3, diff: 0 }
    ]
  }
}

function handleSwitchVersion(row) {
  ElMessageBox.confirm(`确认将版本"${row.version}"切换为当前版本？切换后需要重新触发全量计算。`, '切换版本', { type: 'warning' })
    .then(() => {
      versions.value.forEach(v => {
        if (v.modelType === row.modelType) v.isActive = v.id === row.id
      })
      handleModelTypeChange()
      ElMessage.success('版本切换成功')
    })
    .catch(() => {})
}

const modelTypeOptions = [
  { label: '比率模型', value: 'ratio' },
  { label: '预警模型', value: 'warning' }
]
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
