<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { getUsers, createUser, updateUser, deleteUser, resetPassword, getRoles } from '../../api/system'

const activeTab = ref('user')
const loading = ref(false)

const users = ref([])
const roles = ref([])

const userDialogVisible = ref(false)
const userDialogTitle = ref('新增用户')
const userForm = reactive({
  id: null,
  username: '',
  name: '',
  department: '',
  role: '',
  status: 'active'
})

const roleOptions = ref([])
const statusLabel = { active: '正常', disabled: '禁用' }
const statusTagType = { active: 'success', disabled: 'info' }

onMounted(() => {
  fetchUsers()
  fetchRoles()
})

async function fetchUsers() {
  loading.value = true
  try {
    const res = await getUsers()
    users.value = res.data || res || []
  } catch (error) {
    ElMessage.error('获取用户列表失败')
    console.error(error)
  } finally {
    loading.value = false
  }
}

async function fetchRoles() {
  try {
    const res = await getRoles()
    roles.value = res.data || res || []
    roleOptions.value = roles.value.map(r => r.name)
  } catch (error) {
    ElMessage.error('获取角色列表失败')
    console.error(error)
  }
}

function handleAddUser() {
  userDialogTitle.value = '新增用户'
  Object.assign(userForm, { id: null, username: '', name: '', department: '', role: '', status: 'active' })
  userDialogVisible.value = true
}

function handleEditUser(row) {
  userDialogTitle.value = '编辑用户'
  Object.assign(userForm, { ...row })
  userDialogVisible.value = true
}

function handleDeleteUser(row) {
  if (row.role === '系统管理员' && users.value.filter(u => u.role === '系统管理员').length <= 1) {
    ElMessage.warning('不允许删除唯一管理员')
    return
  }
  ElMessageBox.confirm(`确认删除用户"${row.name}"？`, '提示', { type: 'warning' })
    .then(async () => {
      try {
        await deleteUser(row.id)
        ElMessage.success('删除成功')
        fetchUsers()
      } catch (error) {
        ElMessage.error('删除用户失败')
        console.error(error)
      }
    })
    .catch(() => {})
}

async function handleSaveUser() {
  if (!userForm.username || !userForm.name || !userForm.role) {
    ElMessage.warning('请填写完整信息')
    return
  }
  try {
    if (userForm.id) {
      await updateUser(userForm.id, { ...userForm })
    } else {
      await createUser({ ...userForm })
    }
    ElMessage.success('保存成功')
    userDialogVisible.value = false
    fetchUsers()
  } catch (error) {
    ElMessage.error('保存用户失败')
    console.error(error)
  }
}

function handleResetPassword(row) {
  ElMessageBox.confirm(`确认重置用户"${row.name}"的密码？`, '提示', { type: 'warning' })
    .then(async () => {
      try {
        await resetPassword(row.id)
        ElMessage.success('密码已重置为初始密码')
      } catch (error) {
        ElMessage.error('重置密码失败')
        console.error(error)
      }
    })
    .catch(() => {})
}

function handleEditRole(row) {
  ElMessage.info(`编辑角色权限: ${row.name}`)
}
</script>

<template>
  <div class="page-container">
    <div class="page-header">
      <h2>用户管理</h2>
    </div>

    <el-tabs v-model="activeTab">
      <el-tab-pane label="用户列表" name="user" />
      <el-tab-pane label="角色管理" name="role" />
    </el-tabs>

    <div v-if="activeTab === 'user'" class="card-container">
      <div class="search-bar">
        <el-input placeholder="搜索用户名/姓名" style="width: 240px;" clearable />
        <el-select placeholder="角色" clearable style="width: 160px;">
          <el-option v-for="opt in roleOptions" :key="opt" :label="opt" :value="opt" />
        </el-select>
        <el-button type="primary"><el-icon><Search /></el-icon>搜索</el-button>
        <el-button type="primary" @click="handleAddUser" style="margin-left: auto;">
          <el-icon><Plus /></el-icon>新增用户
        </el-button>
      </div>

      <el-table :data="users" v-loading="loading" stripe>
        <el-table-column prop="username" label="用户名" width="120" />
        <el-table-column prop="name" label="姓名" width="100" />
        <el-table-column prop="department" label="部门" width="140" />
        <el-table-column prop="role" label="角色" width="130" />
        <el-table-column prop="status" label="状态" width="80">
          <template #default="{ row }">
            <el-tag :type="statusTagType[row.status]" size="small">{{ statusLabel[row.status] }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="lastLogin" label="最近登录" width="170" />
        <el-table-column prop="createTime" label="创建时间" width="120" />
        <el-table-column label="操作" width="220" fixed="right">
          <template #default="{ row }">
            <el-button type="primary" link size="small" @click="handleEditUser(row)">编辑</el-button>
            <el-button type="warning" link size="small" @click="handleResetPassword(row)">重置密码</el-button>
            <el-button type="danger" link size="small" @click="handleDeleteUser(row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>
    </div>

    <div v-if="activeTab === 'role'" class="card-container">
      <el-table :data="roles" v-loading="loading" stripe>
        <el-table-column prop="name" label="角色名称" width="140" />
        <el-table-column prop="code" label="角色编码" width="120" />
        <el-table-column prop="description" label="描述" min-width="200" />
        <el-table-column prop="userCount" label="用户数" width="80" align="center" />
        <el-table-column prop="permissions" label="权限范围" min-width="240">
          <template #default="{ row }">
            <el-tag v-for="p in row.permissions" :key="p" size="small" style="margin: 2px;">{{ p }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="100" fixed="right">
          <template #default="{ row }">
            <el-button type="primary" link size="small" @click="handleEditRole(row)">编辑权限</el-button>
          </template>
        </el-table-column>
      </el-table>
    </div>

    <el-dialog v-model="userDialogVisible" :title="userDialogTitle" width="500px">
      <el-form :model="userForm" label-width="80px">
        <el-form-item label="用户名" required>
          <el-input v-model="userForm.username" placeholder="请输入用户名" />
        </el-form-item>
        <el-form-item label="姓名" required>
          <el-input v-model="userForm.name" placeholder="请输入姓名" />
        </el-form-item>
        <el-form-item label="部门">
          <el-input v-model="userForm.department" placeholder="请输入部门" />
        </el-form-item>
        <el-form-item label="角色" required>
          <el-select v-model="userForm.role" style="width: 100%;">
            <el-option v-for="opt in roleOptions" :key="opt" :label="opt" :value="opt" />
          </el-select>
        </el-form-item>
        <el-form-item label="状态">
          <el-switch v-model="userForm.status" active-value="active" inactive-value="disabled" active-text="正常" inactive-text="禁用" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="userDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleSaveUser">保存</el-button>
      </template>
    </el-dialog>
  </div>
</template>
