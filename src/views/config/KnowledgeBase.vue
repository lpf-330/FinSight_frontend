<script setup>
import { ref, reactive } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'

const loading = ref(false)
const knowledgeList = ref([
  { id: 1, indicator: '流动比率', level: 'yellow', content: '建议优化短期偿债能力：1) 加快应收账款回收；2) 合理安排短期负债到期结构；3) 适当增加流动资产储备。', version: 'v2.1', usefulCount: 15, uselessCount: 2, updateTime: '2026-04-15' },
  { id: 2, indicator: '流动比率', level: 'orange', content: '流动比率偏低，需重点关注：1) 审查短期借款用途和必要性；2) 加速存货周转；3) 考虑长期融资替代短期负债。', version: 'v2.0', usefulCount: 8, uselessCount: 1, updateTime: '2026-04-15' },
  { id: 3, indicator: '流动比率', level: 'red', content: '流动比率严重不足，需立即行动：1) 启动紧急融资方案；2) 出售非核心资产；3) 与银行协商展期；4) 暂停非必要支出。', version: 'v2.0', usefulCount: 5, uselessCount: 0, updateTime: '2026-04-15' },
  { id: 4, indicator: '现金比率', level: 'red', content: '现金比率严重不足，需立即加强现金管理：1) 加速应收款催收；2) 延长应付款账期；3) 考虑短期融资；4) 建立最低现金储备制度。', version: 'v1.3', usefulCount: 12, uselessCount: 1, updateTime: '2026-04-12' }
])

const dialogVisible = ref(false)
const dialogTitle = ref('新增建议')
const knowledgeForm = reactive({
  id: null,
  indicator: '',
  level: 'yellow',
  content: ''
})

const indicatorOptions = ['流动比率', '速动比率', '现金比率', '资产负债率']
const levelOptions = [
  { label: '黄色预警', value: 'yellow' },
  { label: '橙色预警', value: 'orange' },
  { label: '红色预警', value: 'red' }
]

function handleAdd() {
  dialogTitle.value = '新增建议'
  Object.assign(knowledgeForm, { id: null, indicator: '', level: 'yellow', content: '' })
  dialogVisible.value = true
}

function handleEdit(row) {
  dialogTitle.value = '编辑建议'
  Object.assign(knowledgeForm, { ...row })
  dialogVisible.value = true
}

function handleDelete(row) {
  ElMessageBox.confirm('确认删除该建议？', '提示', { type: 'warning' })
    .then(() => {
      knowledgeList.value = knowledgeList.value.filter(k => k.id !== row.id)
      ElMessage.success('删除成功')
    })
    .catch(() => {})
}

function handleSave() {
  if (!knowledgeForm.indicator || !knowledgeForm.content) {
    ElMessage.warning('请填写预警指标和建议内容')
    return
  }
  ElMessage.success('保存成功')
  dialogVisible.value = false
}

function handleExport() {
  ElMessage.success('知识库导出成功')
}

function handleImport() {
  ElMessage.info('请选择导入文件')
}

const levelTagType = { yellow: 'warning', orange: 'danger', red: 'danger' }
const levelLabel = { yellow: '黄色', orange: '橙色', red: '红色' }
</script>

<template>
  <div class="page-container">
    <div class="page-header">
      <h2>知识库配置</h2>
      <div>
        <el-button @click="handleImport"><el-icon><Upload /></el-icon>导入</el-button>
        <el-button @click="handleExport"><el-icon><Download /></el-icon>导出</el-button>
        <el-button type="primary" @click="handleAdd"><el-icon><Plus /></el-icon>新增建议</el-button>
      </div>
    </div>

    <div class="search-bar">
      <el-select placeholder="预警指标" clearable style="width: 160px;">
        <el-option v-for="opt in indicatorOptions" :key="opt" :label="opt" :value="opt" />
      </el-select>
      <el-select placeholder="预警级别" clearable style="width: 140px;">
        <el-option v-for="opt in levelOptions" :key="opt.value" :label="opt.label" :value="opt.value" />
      </el-select>
      <el-button type="primary"><el-icon><Search /></el-icon>搜索</el-button>
    </div>

    <div class="card-container">
      <el-table :data="knowledgeList" v-loading="loading" stripe>
        <el-table-column prop="indicator" label="预警指标" width="120" />
        <el-table-column prop="level" label="预警级别" width="100">
          <template #default="{ row }">
            <el-tag :type="levelTagType[row.level]" size="small" effect="dark">{{ levelLabel[row.level] }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="content" label="建议内容" min-width="300" show-overflow-tooltip />
        <el-table-column prop="version" label="版本" width="80" />
        <el-table-column label="反馈统计" width="120">
          <template #default="{ row }">
            <span style="color: #67c23a;">👍 {{ row.usefulCount }}</span>
            <span style="color: #f56c6c; margin-left: 8px;">👎 {{ row.uselessCount }}</span>
          </template>
        </el-table-column>
        <el-table-column prop="updateTime" label="更新时间" width="120" />
        <el-table-column label="操作" width="150" fixed="right">
          <template #default="{ row }">
            <el-button type="primary" link size="small" @click="handleEdit(row)">编辑</el-button>
            <el-button type="danger" link size="small" @click="handleDelete(row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>
    </div>

    <el-dialog v-model="dialogVisible" :title="dialogTitle" width="600px">
      <el-form :model="knowledgeForm" label-width="100px">
        <el-form-item label="预警指标" required>
          <el-select v-model="knowledgeForm.indicator" style="width: 100%;">
            <el-option v-for="opt in indicatorOptions" :key="opt" :label="opt" :value="opt" />
          </el-select>
        </el-form-item>
        <el-form-item label="预警级别" required>
          <el-select v-model="knowledgeForm.level" style="width: 100%;">
            <el-option v-for="opt in levelOptions" :key="opt.value" :label="opt.label" :value="opt.value" />
          </el-select>
        </el-form-item>
        <el-form-item label="建议内容" required>
          <el-input v-model="knowledgeForm.content" type="textarea" :rows="5" placeholder="请输入调整建议，支持分项列表" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleSave">保存</el-button>
      </template>
    </el-dialog>
  </div>
</template>
