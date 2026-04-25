<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { getKnowledgeList, createKnowledge, updateKnowledge, deleteKnowledge, exportKnowledge, importKnowledge } from '../../api/config'

const loading = ref(false)
const knowledgeList = ref([])

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

async function fetchKnowledgeList() {
  loading.value = true
  try {
    const res = await getKnowledgeList()
    knowledgeList.value = res.data || res || []
  } catch (error) {
    ElMessage.error('获取知识库列表失败')
  } finally {
    loading.value = false
  }
}

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

async function handleDelete(row) {
  try {
    await ElMessageBox.confirm('确认删除该建议？', '提示', { type: 'warning' })
    loading.value = true
    await deleteKnowledge(row.id)
    ElMessage.success('删除成功')
    await fetchKnowledgeList()
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error('删除失败')
    }
  } finally {
    loading.value = false
  }
}

async function handleSave() {
  if (!knowledgeForm.indicator || !knowledgeForm.content) {
    ElMessage.warning('请填写预警指标和建议内容')
    return
  }
  try {
    if (knowledgeForm.id) {
      await updateKnowledge(knowledgeForm.id, { ...knowledgeForm })
    } else {
      await createKnowledge({ ...knowledgeForm })
    }
    ElMessage.success('保存成功')
    dialogVisible.value = false
    await fetchKnowledgeList()
  } catch (error) {
    ElMessage.error('保存失败')
  }
}

async function handleExport() {
  try {
    const res = await exportKnowledge()
    const blob = new Blob([res], { type: 'application/octet-stream' })
    const url = window.URL.createObjectURL(blob)
    const link = document.createElement('a')
    link.href = url
    link.download = 'knowledge_export.xlsx'
    link.click()
    window.URL.revokeObjectURL(url)
    ElMessage.success('知识库导出成功')
  } catch (error) {
    ElMessage.error('导出失败')
  }
}

async function handleImport() {
  const input = document.createElement('input')
  input.type = 'file'
  input.accept = '.xlsx,.xls,.csv'
  input.onchange = async (e) => {
    const file = e.target.files[0]
    if (!file) return
    const formData = new FormData()
    formData.append('file', file)
    try {
      await importKnowledge(formData)
      ElMessage.success('导入成功')
      await fetchKnowledgeList()
    } catch (error) {
      ElMessage.error('导入失败')
    }
  }
  input.click()
}

const levelTagType = { yellow: 'warning', orange: 'danger', red: 'danger' }
const levelLabel = { yellow: '黄色', orange: '橙色', red: '红色' }

onMounted(() => {
  fetchKnowledgeList()
})
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
