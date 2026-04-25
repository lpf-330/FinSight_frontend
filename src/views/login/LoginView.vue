<script setup>
import { ref, reactive } from 'vue'
import { useRouter } from 'vue-router'
import { useUserStore } from '../../stores/user'
import { ElMessage } from 'element-plus'

const router = useRouter()
const userStore = useUserStore()

const loginForm = reactive({
  username: '',
  password: ''
})

const loginRules = {
  username: [{ required: true, message: '请输入用户名', trigger: 'blur' }],
  password: [{ required: true, message: '请输入密码', trigger: 'blur' }]
}

const formRef = ref(null)
const loading = ref(false)

async function handleLogin() {
  const valid = await formRef.value.validate().catch(() => false)
  if (!valid) return

  loading.value = true
  try {
    userStore.setToken('mock-token-' + Date.now())
    userStore.setUserInfo({
      username: loginForm.username,
      roles: ['admin'],
      name: loginForm.username
    })
    ElMessage.success('登录成功')
    router.push('/dashboard')
  } catch (e) {
    ElMessage.error('登录失败，请检查用户名和密码')
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <div class="login-page">
    <div class="login-container">
      <div class="login-left">
        <div class="brand-section">
          <h1 class="brand-title">FinSight</h1>
          <h2 class="brand-subtitle">金融财务分析系统</h2>
          <p class="brand-desc">
            面向企业财务决策支持的Web系统，提供轻量化、可配置、自动化的财务分析与预警服务
          </p>
          <div class="feature-list">
            <div class="feature-item">
              <el-icon size="20"><DataAnalysis /></el-icon>
              <span>智能比率分析</span>
            </div>
            <div class="feature-item">
              <el-icon size="20"><Warning /></el-icon>
              <span>多级资金预警</span>
            </div>
            <div class="feature-item">
              <el-icon size="20"><TrendCharts /></el-icon>
              <span>趋势与杜邦分析</span>
            </div>
            <div class="feature-item">
              <el-icon size="20"><Money /></el-icon>
              <span>投资评估测算</span>
            </div>
          </div>
        </div>
      </div>
      <div class="login-right">
        <div class="login-form-wrapper">
          <h3 class="form-title">用户登录</h3>
          <el-form
            ref="formRef"
            :model="loginForm"
            :rules="loginRules"
            size="large"
            @keyup.enter="handleLogin"
          >
            <el-form-item prop="username">
              <el-input
                v-model="loginForm.username"
                placeholder="请输入用户名"
                prefix-icon="User"
              />
            </el-form-item>
            <el-form-item prop="password">
              <el-input
                v-model="loginForm.password"
                type="password"
                placeholder="请输入密码"
                prefix-icon="Lock"
                show-password
              />
            </el-form-item>
            <el-form-item>
              <el-button
                type="primary"
                :loading="loading"
                class="login-btn"
                @click="handleLogin"
              >
                登 录
              </el-button>
            </el-form-item>
          </el-form>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.login-page {
  width: 100%;
  height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, #1d1e2c 0%, #2d3a5c 100%);
}

.login-container {
  display: flex;
  width: 900px;
  min-height: 500px;
  border-radius: 16px;
  overflow: hidden;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
}

.login-left {
  flex: 1;
  background: linear-gradient(135deg, #409eff 0%, #1d6fce 100%);
  padding: 60px 40px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.brand-section {
  color: #fff;
}

.brand-title {
  font-size: 42px;
  font-weight: 800;
  margin-bottom: 8px;
  letter-spacing: 2px;
}

.brand-subtitle {
  font-size: 20px;
  font-weight: 400;
  margin-bottom: 20px;
  opacity: 0.9;
}

.brand-desc {
  font-size: 14px;
  line-height: 1.8;
  opacity: 0.8;
  margin-bottom: 36px;
}

.feature-list {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 16px;
}

.feature-item {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 14px;
  opacity: 0.9;
}

.login-right {
  flex: 1;
  background: #fff;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 60px 40px;
}

.login-form-wrapper {
  width: 100%;
  max-width: 340px;
}

.form-title {
  font-size: 24px;
  font-weight: 600;
  color: #303133;
  margin-bottom: 32px;
  text-align: center;
}

.login-btn {
  width: 100%;
  height: 44px;
  font-size: 16px;
}
</style>
