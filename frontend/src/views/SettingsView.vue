<template>
  <div class="settings-view">
    <div class="page-header">
      <h2>账户设置</h2>
      <p class="subtitle">管理您的个人资料与安全选项</p>
    </div>

    <div class="settings-panel">
      <div class="panel-header">
        <h3>修改密码</h3>
      </div>
      <el-form
        ref="passwordFormRef"
        :model="passwordForm"
        :rules="passwordRules"
        label-position="top"
        size="large"
        class="settings-form"
      >
        <el-form-item label="当前密码" prop="currentPassword">
          <el-input
            v-model="passwordForm.currentPassword"
            type="password"
            show-password
            placeholder="请输入当前密码"
          />
        </el-form-item>
        <el-form-item label="新密码" prop="newPassword">
          <el-input
            v-model="passwordForm.newPassword"
            type="password"
            show-password
            placeholder="请输入新密码（6-20位）"
          />
        </el-form-item>
        <el-form-item label="确认密码" prop="confirmPassword">
          <el-input
            v-model="passwordForm.confirmPassword"
            type="password"
            show-password
            placeholder="请再次输入新密码"
          />
        </el-form-item>
        <el-form-item>
          <el-button 
            type="primary" 
            @click="handleChangePassword" 
            :loading="loading"
            class="submit-btn"
          >
            保存修改
          </el-button>
        </el-form-item>
      </el-form>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '../stores/auth'
import { ElMessage } from 'element-plus'
import request from '../utils/request'

const router = useRouter()
const authStore = useAuthStore()

const passwordFormRef = ref(null)
const loading = ref(false)

const passwordForm = reactive({
  currentPassword: '',
  newPassword: '',
  confirmPassword: ''
})

const validateConfirmPassword = (rule, value, callback) => {
  if (value !== passwordForm.newPassword) {
    callback(new Error('两次输入的密码不一致'))
  } else {
    callback()
  }
}

const passwordRules = {
  currentPassword: [
    { required: true, message: '请输入当前密码', trigger: 'blur' }
  ],
  newPassword: [
    { required: true, message: '请输入新密码', trigger: 'blur' },
    { min: 6, max: 20, message: '密码长度必须在6-20位之间', trigger: 'blur' }
  ],
  confirmPassword: [
    { required: true, message: '请确认新密码', trigger: 'blur' },
    { validator: validateConfirmPassword, trigger: 'blur' }
  ]
}

const handleChangePassword = async () => {
  try {
    await passwordFormRef.value.validate()
  } catch {
    return
  }

  loading.value = true
  try {
    await request({
      url: '/auth/change-password',
      method: 'post',
      data: {
        currentPassword: passwordForm.currentPassword,
        newPassword: passwordForm.newPassword
      }
    })
    ElMessage.success('密码修改成功，请重新登录')
    authStore.logout()
    router.push('/login')
  } catch (error) {
    ElMessage.error(error.message || '密码修改失败')
  } finally {
    loading.value = false
  }
}

</script>

<style scoped>
.settings-view {
  padding: 40px 20px;
  max-width: 600px;
  margin: 0 auto;
}

.page-header {
  text-align: center;
  margin-bottom: 40px;
}

.page-header h2 {
  font-size: 32px;
  font-weight: 800;
  color: #18181b;
  margin: 0 0 8px 0;
  letter-spacing: -1px;
}

.subtitle {
  color: #71717a;
  font-size: 16px;
  margin: 0;
}

.settings-panel {
  background: #ffffff;
  border-radius: 24px;
  padding: 40px;
  box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04);
  border: none;
}

.panel-header {
  margin-bottom: 32px;
  border-bottom: 1px solid #f4f4f5;
  padding-bottom: 16px;
}

.panel-header h3 {
  margin: 0;
  font-size: 18px;
  font-weight: 700;
  color: #18181b;
}

/* Form Styles */
.settings-form :deep(.el-form-item__label) {
  font-weight: 500;
  color: #3f3f46;
  padding-bottom: 8px;
}

.settings-form :deep(.el-input__wrapper) {
  background-color: #f4f4f5;
  box-shadow: none;
  border: 1px solid transparent;
  transition: all 0.2s;
  border-radius: 12px;
  padding: 4px 12px;
}

.settings-form :deep(.el-input__wrapper.is-focus) {
  background-color: #ffffff;
  border-color: #18181b;
  box-shadow: 0 0 0 1px #18181b;
}

.submit-btn {
  width: 100%;
  height: 48px;
  font-size: 16px;
  font-weight: 600;
  border-radius: 12px;
  margin-top: 24px;
  background-color: #18181b;
  border-color: #18181b;
  transition: all 0.2s;
}

.submit-btn:hover {
  background-color: #27272a;
  border-color: #27272a;
  transform: translateY(-1px);
}
</style>
