<script setup>
import { ref } from 'vue'
import { ElMessage } from 'element-plus'

const loading = ref(false)
const dateRange = ref([])
const filterUser = ref('')
const filterType = ref('')

const auditLogs = ref([
  { id: 1, user: '张三', operation: '数据导入', module: '数据接入', detail: '导入资产负债表_2026Q1.xlsx', ip: '192.168.1.50', time: '2026-04-24 14:30:00' },
  { id: 2, user: '张三', operation: '配置修改', module: '配置管理', detail: '修改流动比率预警阈值', ip: '192.168.1.50', time: '2026-04-24 11:20:00' },
  { id: 3, user: 'admin', operation: '用户管理', module: '系统支撑', detail: '新增用户: 赵六', ip: '192.168.1.10', time: '2026-04-24 10:00:00' },
  { id: 4, user: '李四', operation: '数据导入', module: '数据接入', detail: '导入利润表_2026Q1.xlsx（失败）', ip: '192.168.1.55', time: '2026-04-23 16:45:00' },
  { id: 5, user: '张三', operation: '报告生成', module: '可视化报表', detail: '生成2026年Q1财务分析报告', ip: '192.168.1.50', time: '2026-04-23 15:30:00' },
  { id: 6, user: 'admin', operation: '权限变更', module: '系统支撑', detail: '修改角色"财务分析人员"的权限', ip: '192.168.1.10', time: '2026-04-22 09:15:00' },
  { id: 7, user: '张三', operation: '公式修改', module: '配置管理', detail: '新增现金比率公式(v1.3)', ip: '192.168.1.50', time: '2026-04-20 14:10:00' },
  { id: 8, user: 'admin', operation: 'ETL操作', module: '数据接入', detail: '手动触发ETL任务', ip: '192.168.1.10', time: '2026-04-20 08:00:00' }
])

const operationTypes = ['数据导入', '配置修改', '用户管理', '权限变更', '报告生成', '公式修改', 'ETL操作']

function handleSearch() {
  ElMessage.info('筛选日志')
}

function handleExport() {
  ElMessage.success('审计日志导出成功')
}

function handleReset() {
  dateRange.value = []
  filterUser.value = ''
  filterType.value = ''
}
</script>

<template>
  <div class="page-container">
    <div class="page-header">
      <h2>审计日志</h2>
      <el-button @click="handleExport"><el-icon><Download /></el-icon>导出CSV</el-button>
    </div>

    <div class="card-container">
      <div class="search-bar">
        <el-date-picker
          v-model="dateRange"
          type="daterange"
          range-separator="至"
          start-placeholder="开始日期"
          end-placeholder="结束日期"
          style="width: 280px;"
        />
        <el-input v-model="filterUser" placeholder="操作人" style="width: 140px;" clearable />
        <el-select v-model="filterType" placeholder="操作类型" clearable style="width: 160px;">
          <el-option v-for="opt in operationTypes" :key="opt" :label="opt" :value="opt" />
        </el-select>
        <el-button type="primary" @click="handleSearch"><el-icon><Search /></el-icon>搜索</el-button>
        <el-button @click="handleReset">重置</el-button>
      </div>

      <el-table :data="auditLogs" v-loading="loading" stripe>
        <el-table-column prop="time" label="操作时间" width="170" sortable />
        <el-table-column prop="user" label="操作人" width="100" />
        <el-table-column prop="operation" label="操作类型" width="120">
          <template #default="{ row }">
            <el-tag size="small">{{ row.operation }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="module" label="功能模块" width="120" />
        <el-table-column prop="detail" label="操作详情" min-width="260" show-overflow-tooltip />
        <el-table-column prop="ip" label="IP地址" width="140" />
      </el-table>

      <div class="pagination-wrapper">
        <el-pagination
          background
          layout="total, sizes, prev, pager, next, jumper"
          :total="8"
          :page-sizes="[10, 20, 50]"
          :page-size="10"
        />
      </div>
    </div>
  </div>
</template>
