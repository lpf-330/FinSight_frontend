<script setup>
import { ref, reactive } from 'vue'
import { ElMessage } from 'element-plus'

const loading = ref(false)
const formulas = ref([
  { id: 1, name: '流动比率', expression: '流动资产 / 流动负债', category: '偿债能力', enabled: true, version: 'v1.3', updateTime: '2026-04-10' },
  { id: 2, name: '速动比率', expression: '(流动资产 - 存货) / 流动负债', category: '偿债能力', enabled: true, version: 'v1.2', updateTime: '2026-04-10' },
  { id: 3, name: '资产负债率', expression: '负债总额 / 资产总额 * 100', category: '偿债能力', enabled: true, version: 'v1.1', updateTime: '2026-03-15' },
  { id: 4, name: '应收账款周转率', expression: '营业收入 / (应收账款期初 + 应收账款期末) / 2', category: '营运能力', enabled: true, version: 'v1.0', updateTime: '2026-01-20' },
  { id: 5, name: '销售净利率', expression: '净利润 / 营业收入 * 100', category: '盈利能力', enabled: true, version: 'v1.0', updateTime: '2026-01-20' },
  { id: 6, name: '营业收入增长率', expression: '(本期营业收入 - 上期营业收入) / 上期营业收入 * 100', category: '发展能力', enabled: true, version: 'v1.0', updateTime: '2026-01-20' }
])

const dialogVisible = ref(false)
const dialogTitle = ref('新增公式')
const formulaForm = reactive({
  id: null,
  name: '',
  expression: '',
  category: '偿债能力',
  enabled: true
})

const categoryOptions = ['偿债能力', '营运能力', '盈利能力', '发展能力']
const subjectOptions = ['流动资产', '流动负债', '存货', '负债总额', '资产总额', '营业收入', '净利润', '应收账款', '总资产']
const operatorOptions = ['+', '-', '*', '/', '(', ')', 'MAX', 'MIN', 'IF', 'ABS']

function handleAdd() {
  dialogTitle.value = '新增公式'
  Object.assign(formulaForm, { id: null, name: '', expression: '', category: '偿债能力', enabled: true })
  dialogVisible.value = true
}

function handleEdit(row) {
  dialogTitle.value = '编辑公式'
  Object.assign(formulaForm, { ...row })
  dialogVisible.value = true
}

function handleDelete(row) {
  formulas.value = formulas.value.filter(f => f.id !== row.id)
  ElMessage.success('删除成功')
}

function handleSave() {
  if (!formulaForm.name || !formulaForm.expression) {
    ElMessage.warning('请填写公式名称和表达式')
    return
  }
  ElMessage.success('保存成功，已自动生成新版本')
  dialogVisible.value = false
}

function handleValidate() {
  if (!formulaForm.expression) {
    ElMessage.warning('请输入表达式')
    return
  }
  ElMessage.success('表达式语法验证通过')
}

function insertSubject(subject) {
  formulaForm.expression += subject
}

function insertOperator(op) {
  formulaForm.expression += ` ${op} `
}
</script>

<template>
  <div class="page-container">
    <div class="page-header">
      <h2>公式配置</h2>
      <el-button type="primary" @click="handleAdd">
        <el-icon><Plus /></el-icon>
        新增公式
      </el-button>
    </div>

    <div class="search-bar">
      <el-input placeholder="搜索公式名称" style="width: 240px;" clearable />
      <el-select placeholder="公式分类" clearable style="width: 160px;">
        <el-option v-for="opt in categoryOptions" :key="opt" :label="opt" :value="opt" />
      </el-select>
      <el-button type="primary"><el-icon><Search /></el-icon>搜索</el-button>
    </div>

    <div class="card-container">
      <el-table :data="formulas" v-loading="loading" stripe>
        <el-table-column prop="name" label="公式名称" width="160" />
        <el-table-column prop="expression" label="表达式" min-width="280">
          <template #default="{ row }">
            <code class="expression-code">{{ row.expression }}</code>
          </template>
        </el-table-column>
        <el-table-column prop="category" label="分类" width="120" />
        <el-table-column prop="version" label="版本" width="80" />
        <el-table-column prop="enabled" label="状态" width="80">
          <template #default="{ row }">
            <el-switch v-model="row.enabled" />
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

    <el-dialog v-model="dialogVisible" :title="dialogTitle" width="680px">
      <el-form :model="formulaForm" label-width="100px">
        <el-form-item label="公式名称" required>
          <el-input v-model="formulaForm.name" placeholder="请输入公式名称" />
        </el-form-item>
        <el-form-item label="公式分类">
          <el-select v-model="formulaForm.category" style="width: 100%;">
            <el-option v-for="opt in categoryOptions" :key="opt" :label="opt" :value="opt" />
          </el-select>
        </el-form-item>
        <el-form-item label="表达式" required>
          <el-input v-model="formulaForm.expression" type="textarea" :rows="3" placeholder="请输入计算表达式" />
        </el-form-item>
        <el-form-item label="辅助输入">
          <div class="assist-panel">
            <div class="assist-section">
              <span class="assist-label">科目：</span>
              <div class="assist-tags">
                <el-tag v-for="s in subjectOptions" :key="s" size="small" class="assist-tag" @click="insertSubject(s)">{{ s }}</el-tag>
              </div>
            </div>
            <div class="assist-section" style="margin-top: 8px;">
              <span class="assist-label">运算符：</span>
              <div class="assist-tags">
                <el-tag v-for="op in operatorOptions" :key="op" size="small" type="info" class="assist-tag" @click="insertOperator(op)">{{ op }}</el-tag>
              </div>
            </div>
          </div>
        </el-form-item>
        <el-form-item label="是否启用">
          <el-switch v-model="formulaForm.enabled" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="handleValidate">验证表达式</el-button>
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

.assist-panel {
  width: 100%;
  background: #f5f7fa;
  border-radius: 6px;
  padding: 12px;
}

.assist-section {
  display: flex;
  align-items: flex-start;
}

.assist-label {
  font-size: 13px;
  color: #909399;
  width: 60px;
  flex-shrink: 0;
  line-height: 28px;
}

.assist-tags {
  display: flex;
  flex-wrap: wrap;
  gap: 6px;
}

.assist-tag {
  cursor: pointer;
  transition: all 0.2s;
}

.assist-tag:hover {
  opacity: 0.8;
}
</style>
