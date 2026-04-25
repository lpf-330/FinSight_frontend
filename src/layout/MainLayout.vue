<script setup>
import { ref, computed, watch } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { useAppStore } from '../stores/app'
import { useUserStore } from '../stores/user'
import {
  Odometer,
  Upload,
  Cpu,
  Setting,
  DataAnalysis,
  Tools,
  Fold,
  Expand,
  User,
  SwitchButton,
  ArrowRight
} from '@element-plus/icons-vue'

const router = useRouter()
const route = useRoute()
const appStore = useAppStore()
const userStore = useUserStore()

const menuList = [
  {
    index: '/dashboard',
    title: '仪表盘',
    icon: Odometer
  },
  {
    index: '/data',
    title: '数据接入',
    icon: Upload,
    children: [
      { index: '/data/etl', title: 'ETL管理' },
      { index: '/data/import', title: 'Excel导入' },
      { index: '/data/validation', title: '数据校验配置' },
      { index: '/data/mapping', title: '科目映射' }
    ]
  },
  {
    index: '/algorithm',
    title: '算法引擎',
    icon: Cpu,
    children: [
      { index: '/algorithm/ratio', title: '比率分析' },
      { index: '/algorithm/warning', title: '预警模型' },
      { index: '/algorithm/investment', title: '投资评估' },
      { index: '/algorithm/forecast', title: '损益预测' },
      { index: '/algorithm/trend', title: '趋势与杜邦分析' }
    ]
  },
  {
    index: '/config',
    title: '配置管理',
    icon: Setting,
    children: [
      { index: '/config/formula', title: '公式配置' },
      { index: '/config/threshold', title: '预警阈值配置' },
      { index: '/config/knowledge', title: '知识库配置' },
      { index: '/config/version', title: '模型版本管理' }
    ]
  },
  {
    index: '/report',
    title: '可视化报表',
    icon: DataAnalysis,
    children: [
      { index: '/report/charts', title: '图表展示' },
      { index: '/report/pdf', title: 'PDF报告' },
      { index: '/report/benchmark', title: '行业对标' }
    ]
  },
  {
    index: '/system',
    title: '系统支撑',
    icon: Tools,
    children: [
      { index: '/system/user', title: '用户管理' },
      { index: '/system/audit', title: '审计日志' },
      { index: '/system/etl-monitor', title: 'ETL任务监控' },
      { index: '/system/params', title: '系统参数' }
    ]
  }
]

const sidebarWidth = computed(() =>
  appStore.sidebarCollapsed ? '64px' : '220px'
)

const breadcrumbItems = computed(() => {
  const matched = route.matched.filter(item => item.meta?.title)
  return matched.map(item => ({
    title: item.meta.title,
    path: item.path
  }))
})

const defaultActive = computed(() => route.path)

function handleMenuSelect(index) {
  router.push(index)
}

function handleLogout() {
  userStore.logout()
  router.push('/login')
}

watch(
  () => route.path,
  () => {
    const list = route.matched
      .filter(item => item.meta?.title)
      .map(item => ({ title: item.meta.title, path: item.path }))
    appStore.setBreadcrumb(list)
  },
  { immediate: true }
)
</script>

<template>
  <div class="main-layout">
    <aside class="sidebar" :class="{ collapsed: appStore.sidebarCollapsed }">
      <div class="sidebar-logo">
        <h1 v-if="!appStore.sidebarCollapsed">FinSight</h1>
        <h1 v-else>FS</h1>
      </div>
      <el-menu
        :default-active="defaultActive"
        :collapse="appStore.sidebarCollapsed"
        :collapse-transition="false"
        background-color="#1d1e2c"
        text-color="#a3a6b7"
        active-text-color="#409eff"
        router
        class="sidebar-menu"
      >
        <template v-for="menu in menuList" :key="menu.index">
          <el-sub-menu v-if="menu.children" :index="menu.index">
            <template #title>
              <el-icon><component :is="menu.icon" /></el-icon>
              <span>{{ menu.title }}</span>
            </template>
            <el-menu-item
              v-for="child in menu.children"
              :key="child.index"
              :index="child.index"
            >
              {{ child.title }}
            </el-menu-item>
          </el-sub-menu>
          <el-menu-item v-else :index="menu.index">
            <el-icon><component :is="menu.icon" /></el-icon>
            <span>{{ menu.title }}</span>
          </el-menu-item>
        </template>
      </el-menu>
    </aside>

    <div class="main-container" :style="{ marginLeft: sidebarWidth }">
      <header class="header">
        <div class="header-left">
          <el-icon
            class="collapse-btn"
            @click="appStore.toggleSidebar"
          >
            <component :is="appStore.sidebarCollapsed ? Expand : Fold" />
          </el-icon>
          <el-breadcrumb separator="/">
            <el-breadcrumb-item
              v-for="item in breadcrumbItems"
              :key="item.path"
            >
              {{ item.title }}
            </el-breadcrumb-item>
          </el-breadcrumb>
        </div>
        <div class="header-right">
          <el-dropdown trigger="click">
            <span class="user-info">
              <el-icon><User /></el-icon>
              <span class="username">{{ userStore.userInfo.username || '管理员' }}</span>
            </span>
            <template #dropdown>
              <el-dropdown-menu>
                <el-dropdown-item @click="handleLogout">
                  <el-icon><SwitchButton /></el-icon>
                  退出登录
                </el-dropdown-item>
              </el-dropdown-menu>
            </template>
          </el-dropdown>
        </div>
      </header>

      <main class="content">
        <router-view />
      </main>
    </div>
  </div>
</template>

<style scoped>
.main-layout {
  width: 100%;
  height: 100%;
}

.sidebar {
  position: fixed;
  top: 0;
  left: 0;
  bottom: 0;
  width: 220px;
  background-color: #1d1e2c;
  transition: width 0.3s ease;
  z-index: 100;
  overflow: hidden;
}

.sidebar.collapsed {
  width: 64px;
}

.sidebar-logo {
  height: 56px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-bottom: 1px solid rgba(255, 255, 255, 0.08);
}

.sidebar-logo h1 {
  color: #409eff;
  font-size: 20px;
  font-weight: 700;
  white-space: nowrap;
}

.sidebar-menu {
  border-right: none;
  height: calc(100% - 56px);
  overflow-y: auto;
}

.sidebar-menu::-webkit-scrollbar {
  width: 4px;
}

.sidebar-menu::-webkit-scrollbar-thumb {
  background: rgba(255, 255, 255, 0.1);
  border-radius: 2px;
}

.main-container {
  min-height: 100%;
  transition: margin-left 0.3s ease;
}

.header {
  height: 56px;
  background: #fff;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 20px;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.06);
  position: sticky;
  top: 0;
  z-index: 99;
}

.header-left {
  display: flex;
  align-items: center;
  gap: 16px;
}

.collapse-btn {
  font-size: 20px;
  cursor: pointer;
  color: #606266;
  transition: color 0.2s;
}

.collapse-btn:hover {
  color: #409eff;
}

.header-right {
  display: flex;
  align-items: center;
}

.user-info {
  display: flex;
  align-items: center;
  gap: 6px;
  cursor: pointer;
  color: #606266;
  font-size: 14px;
}

.user-info:hover {
  color: #409eff;
}

.content {
  padding: 20px;
  min-height: calc(100vh - 56px);
  background: #f5f7fa;
}
</style>
