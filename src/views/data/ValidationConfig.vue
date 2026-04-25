<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { getValidationRules, createValidationRule, updateValidationRule, deleteValidationRule } from '../../api/data'

const loading = ref(false)
const rules = ref([])

const dialogVisible = ref(false)
const dialogTitle = ref('新增校验规则')
const ruleForm = reactive({
  id: null,
  name: '',
  expression: '',
  level: 'warning',
  message: '',
  enabled: true
})

const levelOptions = [
  { label: '警告', value: 'warning' },
  { label: '错误', value: 'error' }
]

onMounted(() => {
  fetchRules()
})

async function fetchRules() {
  loading.value = true
  try {
    const res = await getValidationRules()
    rules.value = res.data || res || []
  } catch (e) {
    console.error('获取校验规则失败:', e)
  } finally {
    loading.value = false
  }
}

function handleAdd() {
  dialogTitle.value = '新增校验规则'
  Object.assign(ruleForm, { id: null, name: '', expression: '', level: 'warning', message: '', enabled: true })
  dialogVisible.value = true
}

function handleEdit(row) {
  dialogTitle.value = '编辑校验规则'
  Object.assign(ruleForm, { ...row })
  dialogVisible.value = true
}

async function handleDelete(row) {
  try {
    await ElMessageBox.confirm(`确认删除规则"${row.name}"？`, '提示', { type: 'warning' })
    await deleteValidationRule(row.id)
    ElMessage.success('删除成功')
    fetchRules()
  } catch (e) {
    if (e !== 'cancel') ElMessage.error(e.message || '删除失败')
  }
}

async function handleSave() {
  if (!ruleForm.name || !ruleForm.expression) {
    ElMessage.warning('请填写规则名称和表达式')
    return
  }
  try {
    if (ruleForm.id) {
      await updateValidationRule(ruleForm.id, { ...ruleForm })
    } else {
      await createValidationRule({ ...ruleForm })
    }
    ElMessage.success('保存成功')
    dialogVisible.value = false
    fetchRules()
  } catch (e) {
    ElMessage.error(e.message || '保存失败')
  }
}

async function handleToggleEnabled(row) {
  try {
    await updateValidationRule(row.id, { enabled: row.enabled })
    ElMessage.success(`规则"${row.name}"已${row.enabled ? '启用' : '禁用'}`)
  } catch (e) {
    row.enabled = !row.enabled
    ElMessage.error('操作失败')
  }
}

const levelTagType = { warning: 'warning', error: 'danger' }
</script>

<template>
  <div class="page-container">
    <div class="page-header">
      <h2>数据校验配置</h2>
      <el-button type="primary" @click="handleAdd">
        <el-icon><Plus /></el-icon>
        新增规则
      </el-button>
    </div>

    <div class="card-container">
      <el-table :data="rules" v-loading="loading" stripe>
        <el-table-column prop="name" label="规则名称" min-width="160" />
        <el-table-column prop="expression" label="校验表达式" min-width="280">
          <template #default="{ row }">
            <code class="expression-code">{{ row.expression }}</code>
          </template>
        </el-table-column>
        <el-table-column prop="level" label="校验级别" width="100">
          <template #default="{ row }">
            <el-tag :type="levelTagType[row.level]" size="small">{{ row.level === 'error' ? '错误' : '警告' }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="message" label="失败提示" min-width="200" />
        <el-table-column prop="enabled" label="状态" width="80">
          <template #default="{ row }">
            <el-switch v-model="row.enabled" @change="handleToggleEnabled(row)" />
          </template>
        </el-table-column>
        <el-table-column prop="createdAt" label="创建时间" width="180" />
        <el-table-column label="操作" width="150" fixed="right">
          <template #default="{ row }">
            <el-button type="primary" link size="small" @click="handleEdit(row)">编辑</el-button>
            <el-button type="danger" link size="small" @click="handleDelete(row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>
    </div>

    <el-dialog v-model="dialogVisible" :title="dialogTitle" width="600px">
      <el-form :model="ruleForm" label-width="100px">
        <el-form-item label="规则名称" required>
          <el-input v-model="ruleForm.name" placeholder="请输入规则名称" />
        </el-form-item>
        <el-form-item label="校验表达式" required>
          <el-input v-model="ruleForm.expression" type="textarea" :rows="3" placeholder="如: ABS(asset - liability - equity) < 0.01" />
        </el-form-item>
        <el-form-item label="校验级别">
          <el-select v-model="ruleForm.level">
            <el-option v-for="opt in levelOptions" :key="opt.value" :label="opt.label" :value="opt.value" />
          </el-select>
        </el-form-item>
        <el-form-item label="失败提示">
          <el-input v-model="ruleForm.message" type="textarea" :rows="2" placeholder="校验失败时显示的提示信息" />
        </el-form-item>
        <el-form-item label="是否启用">
          <el-switch v-model="ruleForm.enabled" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleSave">保存</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<style scoped>
.expression-code {
  background: #f5f7fa;
  padding: 4px 8px;
  border-radius: 4px;
  font-family: 'Courier New', monospace;
  font-size: 13px;
  color: #303133;
}
</style>
