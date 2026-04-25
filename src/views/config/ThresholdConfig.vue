<script setup>
import { ref, reactive } from 'vue'
import { ElMessage } from 'element-plus'

const loading = ref(false)
const thresholds = ref([
  { id: 1, indicator: '流动比率', indicatorCode: 'R001', direction: 'lower', yellowValue: '< 2.0', orangeValue: '< 1.5', redValue: '< 1.0', dynamicBase: false, updateTime: '2026-04-10' },
  { id: 2, indicator: '速动比率', indicatorCode: 'R002', direction: 'lower', yellowValue: '< 1.2', orangeValue: '< 1.0', redValue: '< 0.8', dynamicBase: false, updateTime: '2026-04-10' },
  { id: 3, indicator: '现金比率', indicatorCode: 'R003', direction: 'lower', yellowValue: '< 0.3', orangeValue: '< 0.25', redValue: '< 0.2', dynamicBase: true, updateTime: '2026-04-12' },
  { id: 4, indicator: '资产负债率', indicatorCode: 'R004', direction: 'upper', yellowValue: '> 50%', orangeValue: '> 60%', redValue: '> 70%', dynamicBase: false, updateTime: '2026-04-10' }
])

const dialogVisible = ref(false)
const dialogTitle = ref('配置阈值')
const thresholdForm = reactive({
  id: null,
  indicator: '',
  indicatorCode: '',
  direction: 'lower',
  yellowValue: '',
  orangeValue: '',
  redValue: '',
  dynamicBase: false
})

function handleEdit(row) {
  dialogTitle.value = '配置阈值 - ' + row.indicator
  Object.assign(thresholdForm, { ...row })
  dialogVisible.value = true
}

function handleSave() {
  if (!thresholdForm.yellowValue || !thresholdForm.orangeValue || !thresholdForm.redValue) {
    ElMessage.warning('请填写完整的阈值配置')
    return
  }
  ElMessage.success('阈值配置保存成功')
  dialogVisible.value = false
}

function handleDynamicSuggestion() {
  ElMessage.info('正在计算动态基准建议值...')
  setTimeout(() => {
    ElMessage.success('动态基准建议值已生成，请查看并确认')
  }, 1000)
}

const directionLabel = { lower: '越低越差', upper: '越高越差' }
</script>

<template>
  <div class="page-container">
    <div class="page-header">
      <h2>预警阈值配置</h2>
    </div>

    <div class="card-container">
      <el-table :data="thresholds" v-loading="loading" stripe>
        <el-table-column prop="indicator" label="预警指标" width="140" />
        <el-table-column prop="indicatorCode" label="指标编码" width="100" />
        <el-table-column prop="direction" label="判断方向" width="100">
          <template #default="{ row }">
            <el-tag size="small" :type="row.direction === 'lower' ? 'danger' : 'warning'">{{ directionLabel[row.direction] }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="yellowValue" label="黄色阈值" width="120">
          <template #default="{ row }">
            <span class="warning-level-yellow">{{ row.yellowValue }}</span>
          </template>
        </el-table-column>
        <el-table-column prop="orangeValue" label="橙色阈值" width="120">
          <template #default="{ row }">
            <span class="warning-level-orange">{{ row.orangeValue }}</span>
          </template>
        </el-table-column>
        <el-table-column prop="redValue" label="红色阈值" width="120">
          <template #default="{ row }">
            <span class="warning-level-red">{{ row.redValue }}</span>
          </template>
        </el-table-column>
        <el-table-column prop="dynamicBase" label="动态基准" width="100">
          <template #default="{ row }">
            <el-tag v-if="row.dynamicBase" type="success" size="small">已启用</el-tag>
            <el-tag v-else type="info" size="small">未启用</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="updateTime" label="更新时间" width="120" />
        <el-table-column label="操作" width="100" fixed="right">
          <template #default="{ row }">
            <el-button type="primary" link size="small" @click="handleEdit(row)">配置</el-button>
          </template>
        </el-table-column>
      </el-table>
    </div>

    <el-dialog v-model="dialogVisible" :title="dialogTitle" width="560px">
      <el-form :model="thresholdForm" label-width="110px">
        <el-form-item label="预警指标">
          <el-input v-model="thresholdForm.indicator" disabled />
        </el-form-item>
        <el-form-item label="判断方向">
          <el-radio-group v-model="thresholdForm.direction">
            <el-radio value="lower">越低越差</el-radio>
            <el-radio value="upper">越高越差</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="黄色阈值" required>
          <el-input v-model="thresholdForm.yellowValue" placeholder="如: < 2.0 或 > 50%" />
        </el-form-item>
        <el-form-item label="橙色阈值" required>
          <el-input v-model="thresholdForm.orangeValue" placeholder="如: < 1.5 或 > 60%" />
        </el-form-item>
        <el-form-item label="红色阈值" required>
          <el-input v-model="thresholdForm.redValue" placeholder="如: < 1.0 或 > 70%" />
        </el-form-item>
        <el-form-item label="动态基准">
          <el-switch v-model="thresholdForm.dynamicBase" />
          <span style="margin-left: 8px; font-size: 12px; color: #909399;">基于历史数据分位数自动建议阈值</span>
        </el-form-item>
        <el-form-item v-if="thresholdForm.dynamicBase">
          <el-button @click="handleDynamicSuggestion">获取动态基准建议</el-button>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleSave">保存</el-button>
      </template>
    </el-dialog>
  </div>
</template>
