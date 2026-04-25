<script setup>
import { ref } from 'vue'
import { ElMessage } from 'element-plus'

const loading = ref(false)
const warningRecords = ref([
  { id: 1, indicator: '现金比率', indicatorCode: 'R003', level: 'red', currentValue: 0.15, yellowThreshold: '< 0.3', orangeThreshold: '< 0.25', redThreshold: '< 0.2', trend: '持续下降(3期)', suggestion: '现金比率严重不足，需立即加强现金管理，考虑短期融资方案', time: '2026-04-24 09:30', status: 'active' },
  { id: 2, indicator: '速动比率', indicatorCode: 'R002', level: 'orange', currentValue: 0.92, yellowThreshold: '< 1.2', orangeThreshold: '< 1.0', redThreshold: '< 0.8', trend: '持续下降(2期)', suggestion: '速动比率偏低，建议减少存货占比或增加速动资产', time: '2026-04-24 09:30', status: 'active' },
  { id: 3, indicator: '流动比率', indicatorCode: 'R001', level: 'yellow', currentValue: 1.85, yellowThreshold: '< 2.0', orangeThreshold: '< 1.5', redThreshold: '< 1.0', trend: '轻微下降', suggestion: '建议优化短期偿债能力，适当增加流动资产或减少短期负债', time: '2026-04-24 09:30', status: 'active' },
  { id: 4, indicator: '资产负债率', indicatorCode: 'R004', level: 'yellow', currentValue: 45.3, yellowThreshold: '> 50%', orangeThreshold: '> 60%', redThreshold: '> 70%', trend: '缓慢上升', suggestion: '资产负债率接近警戒线，建议控制新增负债', time: '2026-04-23 09:30', status: 'ignored' }
])

const filterLevel = ref('')
const filterStatus = ref('')

const levelTagType = { yellow: 'warning', orange: 'danger', red: 'danger' }
const levelLabel = { yellow: '黄色', orange: '橙色', red: '红色' }
const statusLabel = { active: '生效', ignored: '已忽略' }
const statusTagType = { active: 'danger', ignored: 'info' }

function handleIgnore(row) {
  row.status = 'ignored'
  ElMessage.success('已忽略该预警')
}

function handleViewDetail(row) {
  ElMessage.info(`查看预警详情: ${row.indicator}`)
}

const filteredRecords = ref(warningRecords)

function handleFilter() {
  let result = [...warningRecords.value]
  if (filterLevel.value) {
    result = result.filter(r => r.level === filterLevel.value)
  }
  if (filterStatus.value) {
    result = result.filter(r => r.status === filterStatus.value)
  }
  filteredRecords.value = result
}

const summary = ref({
  red: warningRecords.value.filter(r => r.level === 'red' && r.status === 'active').length,
  orange: warningRecords.value.filter(r => r.level === 'orange' && r.status === 'active').length,
  yellow: warningRecords.value.filter(r => r.level === 'yellow' && r.status === 'active').length
})
</script>

<template>
  <div class="page-container">
    <div class="page-header">
      <h2>预警模型</h2>
    </div>

    <div class="stat-cards">
      <div class="stat-card">
        <div class="stat-icon" style="background: #fef0f0; color: #f56c6c;">
          <el-icon size="24"><Warning /></el-icon>
        </div>
        <div class="stat-info">
          <div class="stat-label">红色预警</div>
          <div class="stat-value" style="color: #f56c6c;">{{ summary.red }}</div>
        </div>
      </div>
      <div class="stat-card">
        <div class="stat-icon" style="background: #fdf6ec; color: #ff8c00;">
          <el-icon size="24"><Warning /></el-icon>
        </div>
        <div class="stat-info">
          <div class="stat-label">橙色预警</div>
          <div class="stat-value" style="color: #ff8c00;">{{ summary.orange }}</div>
        </div>
      </div>
      <div class="stat-card">
        <div class="stat-icon" style="background: #fdf6ec; color: #e6a23c;">
          <el-icon size="24"><Warning /></el-icon>
        </div>
        <div class="stat-info">
          <div class="stat-label">黄色预警</div>
          <div class="stat-value" style="color: #e6a23c;">{{ summary.yellow }}</div>
        </div>
      </div>
    </div>

    <div class="card-container">
      <div class="search-bar">
        <el-select v-model="filterLevel" placeholder="预警级别" clearable style="width: 140px;">
          <el-option label="红色" value="red" />
          <el-option label="橙色" value="orange" />
          <el-option label="黄色" value="yellow" />
        </el-select>
        <el-select v-model="filterStatus" placeholder="状态" clearable style="width: 140px;">
          <el-option label="生效" value="active" />
          <el-option label="已忽略" value="ignored" />
        </el-select>
        <el-button type="primary" @click="handleFilter"><el-icon><Search /></el-icon>筛选</el-button>
      </div>

      <el-table :data="filteredRecords" v-loading="loading" stripe>
        <el-table-column prop="indicator" label="预警指标" width="120" />
        <el-table-column prop="level" label="预警级别" width="100">
          <template #default="{ row }">
            <el-tag :type="levelTagType[row.level]" size="small" effect="dark">{{ levelLabel[row.level] }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="currentValue" label="当前值" width="100" align="right">
          <template #default="{ row }">
            <span :class="'warning-level-' + row.level">{{ row.currentValue }}</span>
          </template>
        </el-table-column>
        <el-table-column prop="yellowThreshold" label="黄色阈值" width="100" />
        <el-table-column prop="orangeThreshold" label="橙色阈值" width="100" />
        <el-table-column prop="redThreshold" label="红色阈值" width="100" />
        <el-table-column prop="trend" label="趋势" width="140" />
        <el-table-column prop="suggestion" label="调整建议" min-width="240" show-overflow-tooltip />
        <el-table-column prop="time" label="触发时间" width="170" />
        <el-table-column prop="status" label="状态" width="80">
          <template #default="{ row }">
            <el-tag :type="statusTagType[row.status]" size="small">{{ statusLabel[row.status] }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="140" fixed="right">
          <template #default="{ row }">
            <el-button v-if="row.status === 'active'" type="warning" link size="small" @click="handleIgnore(row)">忽略</el-button>
            <el-button type="primary" link size="small" @click="handleViewDetail(row)">详情</el-button>
          </template>
        </el-table-column>
      </el-table>
    </div>
  </div>
</template>
