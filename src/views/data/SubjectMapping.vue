<script setup>
import { ref, reactive } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'

const loading = ref(false)
const mappings = ref([
  { id: 1, k8Code: '1001', k8Name: '库存现金', targetCode: 'A001', targetName: '货币资金-现金', category: '资产类', enabled: true },
  { id: 2, k8Code: '1002', k8Name: '银行存款', targetCode: 'A002', targetName: '货币资金-银行存款', category: '资产类', enabled: true },
  { id: 3, k8Code: '1122', k8Name: '应收账款', targetCode: 'A010', targetName: '应收账款', category: '资产类', enabled: true },
  { id: 4, k8Code: '2202', k8Name: '应付账款', targetCode: 'L005', targetName: '应付账款', category: '负债类', enabled: true },
  { id: 5, k8Code: '6001', k8Name: '主营业务收入', targetCode: 'R001', targetName: '营业收入', category: '损益类', enabled: true }
])

const dialogVisible = ref(false)
const dialogTitle = ref('新增映射')
const mappingForm = reactive({
  id: null,
  k8Code: '',
  k8Name: '',
  targetCode: '',
  targetName: '',
  category: '资产类',
  enabled: true
})

const categoryOptions = ['资产类', '负债类', '所有者权益类', '损益类', '成本类']

function handleAdd() {
  dialogTitle.value = '新增映射'
  Object.assign(mappingForm, { id: null, k8Code: '', k8Name: '', targetCode: '', targetName: '', category: '资产类', enabled: true })
  dialogVisible.value = true
}

function handleEdit(row) {
  dialogTitle.value = '编辑映射'
  Object.assign(mappingForm, { ...row })
  dialogVisible.value = true
}

function handleDelete(row) {
  ElMessageBox.confirm(`确认删除映射"${row.k8Name}"？`, '提示', { type: 'warning' })
    .then(() => {
      mappings.value = mappings.value.filter(m => m.id !== row.id)
      ElMessage.success('删除成功')
    })
    .catch(() => {})
}

function handleSave() {
  if (!mappingForm.k8Code || !mappingForm.targetCode) {
    ElMessage.warning('请填写K8科目编码和目标科目编码')
    return
  }
  ElMessage.success('保存成功')
  dialogVisible.value = false
}

function handleBatchImport() {
  ElMessage.info('批量导入功能')
}
</script>

<template>
  <div class="page-container">
    <div class="page-header">
      <h2>科目映射</h2>
      <div>
        <el-button @click="handleBatchImport">
          <el-icon><Upload /></el-icon>
          批量导入
        </el-button>
        <el-button type="primary" @click="handleAdd">
          <el-icon><Plus /></el-icon>
          新增映射
        </el-button>
      </div>
    </div>

    <div class="search-bar">
      <el-input placeholder="搜索K8科目编码/名称" style="width: 240px;" clearable />
      <el-select placeholder="科目类别" clearable style="width: 160px;">
        <el-option v-for="opt in categoryOptions" :key="opt" :label="opt" :value="opt" />
      </el-select>
      <el-button type="primary"><el-icon><Search /></el-icon>搜索</el-button>
    </div>

    <div class="card-container">
      <el-table :data="mappings" v-loading="loading" stripe>
        <el-table-column prop="k8Code" label="K8科目编码" width="140" />
        <el-table-column prop="k8Name" label="K8科目名称" min-width="160" />
        <el-table-column prop="targetCode" label="目标科目编码" width="140" />
        <el-table-column prop="targetName" label="目标科目名称" min-width="160" />
        <el-table-column prop="category" label="科目类别" width="140" />
        <el-table-column prop="enabled" label="状态" width="80">
          <template #default="{ row }">
            <el-switch v-model="row.enabled" />
          </template>
        </el-table-column>
        <el-table-column label="操作" width="150" fixed="right">
          <template #default="{ row }">
            <el-button type="primary" link size="small" @click="handleEdit(row)">编辑</el-button>
            <el-button type="danger" link size="small" @click="handleDelete(row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>
    </div>

    <el-dialog v-model="dialogVisible" :title="dialogTitle" width="560px">
      <el-form :model="mappingForm" label-width="120px">
        <el-form-item label="K8科目编码" required>
          <el-input v-model="mappingForm.k8Code" placeholder="请输入K8科目编码" />
        </el-form-item>
        <el-form-item label="K8科目名称" required>
          <el-input v-model="mappingForm.k8Name" placeholder="请输入K8科目名称" />
        </el-form-item>
        <el-form-item label="目标科目编码" required>
          <el-input v-model="mappingForm.targetCode" placeholder="请输入目标科目编码" />
        </el-form-item>
        <el-form-item label="目标科目名称" required>
          <el-input v-model="mappingForm.targetName" placeholder="请输入目标科目名称" />
        </el-form-item>
        <el-form-item label="科目类别">
          <el-select v-model="mappingForm.category" style="width: 100%;">
            <el-option v-for="opt in categoryOptions" :key="opt" :label="opt" :value="opt" />
          </el-select>
        </el-form-item>
        <el-form-item label="是否启用">
          <el-switch v-model="mappingForm.enabled" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleSave">保存</el-button>
      </template>
    </el-dialog>
  </div>
</template>
