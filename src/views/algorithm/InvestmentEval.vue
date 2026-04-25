<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { calcInvestment, saveInvestmentScheme, getInvestmentSchemes } from '../../api/algorithm'

const investForm = reactive({
  projectName: '',
  initialInvestment: 1000,
  discountRate: 10,
  cashFlows: [
    { year: 1, amount: 200 },
    { year: 2, amount: 300 },
    { year: 3, amount: 350 },
    { year: 4, amount: 400 },
    { year: 5, amount: 450 }
  ]
})

const calcResults = ref({
  npv: null,
  irr: null,
  staticPayback: null,
  dynamicPayback: null
})

const calculated = ref(false)
const calculating = ref(false)
const schemes = ref([])

function addCashFlow() {
  const lastYear = investForm.cashFlows[investForm.cashFlows.length - 1]?.year || 0
  if (lastYear >= 20) {
    ElMessage.warning('最多支持20期现金流')
    return
  }
  investForm.cashFlows.push({ year: lastYear + 1, amount: 0 })
}

function removeCashFlow(index) {
  if (investForm.cashFlows.length <= 1) {
    ElMessage.warning('至少保留1期现金流')
    return
  }
  investForm.cashFlows.splice(index, 1)
}

async function handleCalculate() {
  if (!investForm.projectName) {
    ElMessage.warning('请输入项目名称')
    return
  }
  if (investForm.discountRate < 0) {
    ElMessage.warning('折现率不能为负数')
    return
  }
  calculating.value = true
  try {
    const res = await calcInvestment({
      projectName: investForm.projectName,
      initialInvestment: investForm.initialInvestment,
      discountRate: investForm.discountRate,
      cashFlows: investForm.cashFlows
    })
    calcResults.value = res.data || {}
    calculated.value = true
    ElMessage.success('计算完成')
  } catch (err) {
    ElMessage.error('计算失败: ' + (err.message || '未知错误'))
  } finally {
    calculating.value = false
  }
}

async function handleSave() {
  try {
    await saveInvestmentScheme({
      projectName: investForm.projectName,
      initialInvestment: investForm.initialInvestment,
      discountRate: investForm.discountRate,
      cashFlows: investForm.cashFlows,
      results: calcResults.value
    })
    ElMessage.success('测算方案已保存')
    await fetchSchemes()
  } catch (err) {
    ElMessage.error('保存方案失败: ' + (err.message || '未知错误'))
  }
}

function handleExport() {
  ElMessage.info('正在生成PDF报告...')
}

async function fetchSchemes() {
  try {
    const res = await getInvestmentSchemes()
    schemes.value = res.data || []
  } catch (err) {
    ElMessage.error('获取方案列表失败: ' + (err.message || '未知错误'))
  }
}

const discountTable = computed(() => {
  if (!calculated.value) return []
  let cumulative = -investForm.initialInvestment
  let cumulativeDiscounted = -investForm.initialInvestment
  const rate = investForm.discountRate / 100
  return investForm.cashFlows.map(cf => {
    cumulative += cf.amount
    const discounted = cf.amount / Math.pow(1 + rate, cf.year)
    cumulativeDiscounted += discounted
    return {
      year: cf.year,
      cashFlow: cf.amount,
      cumulative,
      discountFactor: 1 / Math.pow(1 + rate, cf.year),
      discountedCashFlow: discounted.toFixed(2),
      cumulativeDiscounted: cumulativeDiscounted.toFixed(2)
    }
  })
})

onMounted(() => {
  fetchSchemes()
})
</script>

<template>
  <div class="page-container">
    <div class="page-header">
      <h2>投资评估</h2>
    </div>

    <el-row :gutter="20">
      <el-col :span="10">
        <div class="card-container">
          <h3 class="section-title">投资参数</h3>
          <el-form :model="investForm" label-width="110px" style="margin-top: 16px;">
            <el-form-item label="项目名称" required>
              <el-input v-model="investForm.projectName" placeholder="请输入项目名称" />
            </el-form-item>
            <el-form-item label="初始投资额" required>
              <el-input-number v-model="investForm.initialInvestment" :min="0" :precision="2" style="width: 100%;" />
            </el-form-item>
            <el-form-item label="折现率(%)" required>
              <el-input-number v-model="investForm.discountRate" :min="0" :max="100" :precision="2" style="width: 100%;" />
            </el-form-item>
            <el-form-item label="各年净现金流">
              <div class="cashflow-list">
                <div v-for="(cf, index) in investForm.cashFlows" :key="index" class="cashflow-row">
                  <span class="year-label">第{{ cf.year }}年</span>
                  <el-input-number v-model="cf.amount" :precision="2" size="small" style="flex: 1;" />
                  <el-button type="danger" link size="small" @click="removeCashFlow(index)">
                    <el-icon><Delete /></el-icon>
                  </el-button>
                </div>
                <el-button type="primary" link @click="addCashFlow" style="margin-top: 8px;">
                  <el-icon><Plus /></el-icon>
                  添加年份
                </el-button>
              </div>
            </el-form-item>
            <el-form-item>
              <el-button type="primary" @click="handleCalculate" :loading="calculating">计算</el-button>
              <el-button @click="handleSave">保存方案</el-button>
              <el-button @click="handleExport" :disabled="!calculated">导出报告</el-button>
            </el-form-item>
          </el-form>
        </div>
      </el-col>

      <el-col :span="14">
        <div v-if="calculated" class="card-container">
          <h3 class="section-title">计算结果</h3>
          <div class="result-cards">
            <div class="result-card">
              <div class="result-label">净现值 (NPV)</div>
              <div class="result-value" :class="calcResults.npv >= 0 ? 'positive' : 'negative'">
                {{ calcResults.npv }} 万元
              </div>
              <div class="result-desc">{{ calcResults.npv >= 0 ? '项目可行' : '项目不可行' }}</div>
            </div>
            <div class="result-card">
              <div class="result-label">内部收益率 (IRR)</div>
              <div class="result-value positive">{{ calcResults.irr }}%</div>
              <div class="result-desc">{{ calcResults.irr > investForm.discountRate ? '高于折现率，项目可行' : '低于折现率，项目不可行' }}</div>
            </div>
            <div class="result-card">
              <div class="result-label">静态回收期</div>
              <div class="result-value">{{ calcResults.staticPayback }} 年</div>
            </div>
            <div class="result-card">
              <div class="result-label">动态回收期</div>
              <div class="result-value">{{ calcResults.dynamicPayback }} 年</div>
            </div>
          </div>

          <h3 class="section-title" style="margin-top: 24px;">现金流量折现表</h3>
          <el-table :data="discountTable" stripe size="small" style="margin-top: 12px;">
            <el-table-column prop="year" label="年份" width="80" align="center" />
            <el-table-column prop="cashFlow" label="净现金流(万元)" width="130" align="right" />
            <el-table-column prop="cumulative" label="累计现金流(万元)" width="140" align="right" />
            <el-table-column prop="discountFactor" label="折现系数" width="110" align="right" />
            <el-table-column prop="discountedCashFlow" label="折现值(万元)" width="130" align="right" />
            <el-table-column prop="cumulativeDiscounted" label="累计折现值(万元)" min-width="150" align="right" />
          </el-table>
        </div>
        <div v-else class="card-container empty-state">
          <el-icon size="64"><DataAnalysis /></el-icon>
          <p>请输入投资参数并点击"计算"按钮</p>
        </div>
      </el-col>
    </el-row>
  </div>
</template>

<style scoped>
.section-title {
  font-size: 16px;
  font-weight: 600;
  color: #303133;
}

.cashflow-list {
  width: 100%;
}

.cashflow-row {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 8px;
}

.year-label {
  width: 50px;
  font-size: 13px;
  color: #606266;
}

.result-cards {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 16px;
  margin-top: 16px;
}

.result-card {
  background: #f5f7fa;
  border-radius: 8px;
  padding: 20px;
  text-align: center;
}

.result-label {
  font-size: 13px;
  color: #909399;
  margin-bottom: 8px;
}

.result-value {
  font-size: 24px;
  font-weight: 700;
  color: #303133;
}

.result-value.positive {
  color: #67c23a;
}

.result-value.negative {
  color: #f56c6c;
}

.result-desc {
  font-size: 12px;
  color: #909399;
  margin-top: 6px;
}
</style>
