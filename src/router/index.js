import { createRouter, createWebHistory } from 'vue-router'

const routes = [
  {
    path: '/login',
    name: 'Login',
    component: () => import('../views/login/LoginView.vue'),
    meta: { title: '登录', requiresAuth: false }
  },
  {
    path: '/',
    component: () => import('../layout/MainLayout.vue'),
    redirect: '/dashboard',
    meta: { requiresAuth: true },
    children: [
      {
        path: 'dashboard',
        name: 'Dashboard',
        component: () => import('../views/dashboard/DashboardView.vue'),
        meta: { title: '仪表盘', icon: 'Odometer' }
      },
      {
        path: 'data',
        name: 'DataAccess',
        redirect: '/data/etl',
        meta: { title: '数据接入', icon: 'Upload' },
        children: [
          {
            path: 'etl',
            name: 'EtlManage',
            component: () => import('../views/data/EtlManage.vue'),
            meta: { title: 'ETL管理' }
          },
          {
            path: 'import',
            name: 'ExcelImport',
            component: () => import('../views/data/ExcelImport.vue'),
            meta: { title: 'Excel导入' }
          },
          {
            path: 'validation',
            name: 'ValidationConfig',
            component: () => import('../views/data/ValidationConfig.vue'),
            meta: { title: '数据校验配置' }
          },
          {
            path: 'mapping',
            name: 'SubjectMapping',
            component: () => import('../views/data/SubjectMapping.vue'),
            meta: { title: '科目映射' }
          }
        ]
      },
      {
        path: 'algorithm',
        name: 'Algorithm',
        redirect: '/algorithm/ratio',
        meta: { title: '算法引擎', icon: 'Cpu' },
        children: [
          {
            path: 'ratio',
            name: 'RatioAnalysis',
            component: () => import('../views/algorithm/RatioAnalysis.vue'),
            meta: { title: '比率分析' }
          },
          {
            path: 'warning',
            name: 'WarningModel',
            component: () => import('../views/algorithm/WarningModel.vue'),
            meta: { title: '预警模型' }
          },
          {
            path: 'investment',
            name: 'InvestmentEval',
            component: () => import('../views/algorithm/InvestmentEval.vue'),
            meta: { title: '投资评估' }
          },
          {
            path: 'forecast',
            name: 'ProfitForecast',
            component: () => import('../views/algorithm/ProfitForecast.vue'),
            meta: { title: '损益预测' }
          },
          {
            path: 'trend',
            name: 'TrendAnalysis',
            component: () => import('../views/algorithm/TrendAnalysis.vue'),
            meta: { title: '趋势与杜邦分析' }
          }
        ]
      },
      {
        path: 'config',
        name: 'ConfigManage',
        redirect: '/config/formula',
        meta: { title: '配置管理', icon: 'Setting' },
        children: [
          {
            path: 'formula',
            name: 'FormulaConfig',
            component: () => import('../views/config/FormulaConfig.vue'),
            meta: { title: '公式配置' }
          },
          {
            path: 'threshold',
            name: 'ThresholdConfig',
            component: () => import('../views/config/ThresholdConfig.vue'),
            meta: { title: '预警阈值配置' }
          },
          {
            path: 'knowledge',
            name: 'KnowledgeBase',
            component: () => import('../views/config/KnowledgeBase.vue'),
            meta: { title: '知识库配置' }
          },
          {
            path: 'version',
            name: 'VersionManage',
            component: () => import('../views/config/VersionManage.vue'),
            meta: { title: '模型版本管理' }
          }
        ]
      },
      {
        path: 'report',
        name: 'Report',
        redirect: '/report/charts',
        meta: { title: '可视化报表', icon: 'DataAnalysis' },
        children: [
          {
            path: 'charts',
            name: 'ChartView',
            component: () => import('../views/report/ChartView.vue'),
            meta: { title: '图表展示' }
          },
          {
            path: 'pdf',
            name: 'PdfReport',
            component: () => import('../views/report/PdfReport.vue'),
            meta: { title: 'PDF报告' }
          },
          {
            path: 'benchmark',
            name: 'IndustryBenchmark',
            component: () => import('../views/report/IndustryBenchmark.vue'),
            meta: { title: '行业对标' }
          }
        ]
      },
      {
        path: 'system',
        name: 'System',
        redirect: '/system/user',
        meta: { title: '系统支撑', icon: 'Tools' },
        children: [
          {
            path: 'user',
            name: 'UserManage',
            component: () => import('../views/system/UserManage.vue'),
            meta: { title: '用户管理' }
          },
          {
            path: 'audit',
            name: 'AuditLog',
            component: () => import('../views/system/AuditLog.vue'),
            meta: { title: '审计日志' }
          },
          {
            path: 'etl-monitor',
            name: 'EtlMonitor',
            component: () => import('../views/system/EtlMonitor.vue'),
            meta: { title: 'ETL任务监控' }
          },
          {
            path: 'params',
            name: 'SystemParams',
            component: () => import('../views/system/SystemParams.vue'),
            meta: { title: '系统参数' }
          }
        ]
      }
    ]
  },
  {
    path: '/:pathMatch(.*)*',
    redirect: '/dashboard'
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

router.beforeEach((to, from, next) => {
  const token = localStorage.getItem('token')
  if (to.meta.requiresAuth !== false && !token) {
    next('/login')
  } else if (to.path === '/login' && token) {
    next('/dashboard')
  } else {
    next()
  }
})

export default router
