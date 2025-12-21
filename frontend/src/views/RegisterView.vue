<template>
  <div class="register-container">
    <div class="left-panel">
      <div class="brand-content">
        <h1>加入我们</h1>
        <p>开启您的智能舆情分析之旅</p>
      </div>
    </div>
    <div class="right-panel">
      <div class="form-wrapper">
        <div class="form-header">
          <h2>创建账号</h2>
          <p class="sub-text">请填写以下信息完成注册</p>
        </div>

        <el-form
          ref="registerFormRef"
          :model="registerForm"
          :rules="registerRules"
          label-position="top"
          size="large"
          class="register-form"
        >
          <el-form-item label="用户名" prop="username" :error="usernameError">
            <el-input
              v-model="registerForm.username"
              placeholder="3-50个字符，只能包含字母、数字、下划线"
              :prefix-icon="User"
              @input="usernameError = ''"
            />
          </el-form-item>

          <el-form-item label="邮箱" prop="email" :error="emailError">
            <el-input
              v-model="registerForm.email"
              placeholder="请输入邮箱地址"
              :prefix-icon="Message"
              @input="emailError = ''"
            />
          </el-form-item>

          <el-form-item label="密码" prop="password" :error="passwordError">
            <el-input
              v-model="registerForm.password"
              type="password"
              placeholder="至少8位，包含字母和数字"
              :prefix-icon="Lock"
              show-password
              @input="passwordError = ''"
            />
          </el-form-item>

          <el-form-item label="确认密码" prop="confirmPassword">
            <el-input
              v-model="registerForm.confirmPassword"
              type="password"
              placeholder="请再次输入密码"
              :prefix-icon="Lock"
              show-password
            />
          </el-form-item>

          <div class="form-actions">
            <el-button type="primary" @click="handleRegister" :loading="loading" class="submit-btn">
              立即注册
            </el-button>
          </div>

          <div class="form-footer">
            <span class="has-account">已有账号？</span>
            <el-button type="primary" @click="$router.push('/login')"> 返回登录 </el-button>
          </div>
        </el-form>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '../stores/auth'
import { ElMessage } from 'element-plus'
import { User, Lock, Message } from '@element-plus/icons-vue'

const router = useRouter()
const authStore = useAuthStore()

const registerFormRef = ref()
const loading = ref(false)
const usernameError = ref('')
const emailError = ref('')
const passwordError = ref('')

const registerForm = reactive({
  username: '',
  email: '',
  password: '',
  confirmPassword: ''
})

const validateConfirmPassword = (rule, value, callback) => {
  if (value !== registerForm.password) {
    callback(new Error('两次输入的密码不一致'))
  } else {
    callback()
  }
}

const registerRules = {
  username: [
    { required: true, message: '请输入用户名', trigger: 'blur' },
    { min: 3, max: 50, message: '用户名长度必须在3-50个字符之间', trigger: 'blur' },
    { pattern: /^[a-zA-Z0-9_]+$/, message: '用户名只能包含字母、数字和下划线', trigger: 'blur' }
  ],
  email: [
    { required: true, message: '请输入邮箱', trigger: 'blur' },
    { type: 'email', message: '请输入正确的邮箱地址', trigger: 'blur' }
  ],
  password: [
    { required: true, message: '请输入密码', trigger: 'blur' },
    { min: 8, message: '密码长度不能少于8位', trigger: 'blur' },
    {
      pattern: /^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d@$!%*#?&]+$/,
      message: '密码必须包含字母和数字',
      trigger: 'blur'
    }
  ],
  confirmPassword: [
    { required: true, message: '请确认密码', trigger: 'blur' },
    { validator: validateConfirmPassword, trigger: 'blur' }
  ]
}

const handleRegister = async () => {
  if (!registerFormRef.value) return

  // Clear previous errors
  usernameError.value = ''
  emailError.value = ''
  passwordError.value = ''

  await registerFormRef.value.validate(async valid => {
    if (valid) {
      loading.value = true
      try {
        const result = await authStore.register({
          username: registerForm.username,
          email: registerForm.email,
          password: registerForm.password
        })
        if (result.success) {
          ElMessage.success('注册成功')
          router.push('/')
        } else {
          // Determine where to show the error
          const msg = result.message || '注册失败'
          if (
            msg.includes('用户') ||
            msg.includes('账号') ||
            msg.toLowerCase().includes('user') ||
            msg.toLowerCase().includes('account')
          ) {
            usernameError.value = msg
          } else if (
            msg.includes('邮箱') ||
            msg.includes('email') ||
            msg.toLowerCase().includes('mail')
          ) {
            emailError.value = msg
          } else if (msg.includes('密码') || msg.toLowerCase().includes('password')) {
            passwordError.value = msg
          } else {
            ElMessage.error(msg)
          }
        }
      } catch (error) {
        ElMessage.error(error.message || '注册失败')
      } finally {
        loading.value = false
      }
    }
  })
}
</script>

<style scoped>
.register-container {
  display: flex;
  min-height: 100vh;
  width: 100vw;
  background-color: #fff;
}

.left-panel {
  flex: 1;
  background: linear-gradient(135deg, #18181b 0%, #27272a 100%);
  display: flex;
  flex-direction: column;
  justify-content: center;
  padding: 80px;
  color: white;
  position: relative;
  overflow: hidden;
}

.left-panel::before {
  content: '';
  position: absolute;
  top: -50%;
  left: -50%;
  width: 200%;
  height: 200%;
  background: radial-gradient(circle at center, rgba(79, 70, 229, 0.15) 0%, transparent 50%);
  animation: rotate 20s linear infinite;
}

@keyframes rotate {
  from {
    transform: rotate(0deg);
  }
  to {
    transform: rotate(360deg);
  }
}

.brand-content {
  position: relative;
  z-index: 1;
}

.brand-content h1 {
  font-size: 48px;
  font-weight: 800;
  margin-bottom: 24px;
  letter-spacing: -1px;
}

.brand-content p {
  font-size: 20px;
  color: #a1a1aa;
  font-weight: 300;
}

.right-panel {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  background-color: #ffffff;
  padding: 40px;
}

.form-wrapper {
  width: 100%;
  max-width: 480px;
}

.form-header {
  margin-bottom: 40px;
  text-align: center;
}

.form-header h2 {
  font-size: 32px;
  font-weight: 700;
  color: #18181b;
  margin-bottom: 12px;
}

.sub-text {
  color: #71717a;
  font-size: 16px;
}

.register-form :deep(.el-input__wrapper) {
  background-color: #f4f4f5;
  box-shadow: none;
  border: 1px solid transparent;
  transition: all 0.2s;
  border-radius: 8px;
  padding: 4px 12px;
}

.register-form :deep(.el-input__wrapper.is-focus) {
  background-color: #ffffff;
  border-color: #4f46e5;
  box-shadow: 0 0 0 1px #4f46e5;
}

.register-form :deep(.el-form-item__label) {
  font-weight: 500;
  color: #3f3f46;
  padding-bottom: 8px;
}

.submit-btn {
  width: 100%;
  height: 48px;
  font-size: 16px;
  font-weight: 600;
  border-radius: 8px;
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

.form-footer {
  margin-top: 32px;
  text-align: center;
  display: flex;
  justify-content: center;
  align-items: center;
  gap: 6px;
}

.has-account {
  color: #71717a;
  font-size: 15px;
}

.form-footer :deep(.el-button) {
  font-size: 15px;
  font-weight: 600;
  height: 40px;
  padding: 0 24px;
  background-color: #18181b;
  border-color: #18181b;
  color: white;
  border-radius: 20px;
  margin-left: 6px;
  transition: all 0.2s;
}

.form-footer :deep(.el-button:hover) {
  background-color: #27272a;
  border-color: #27272a;
  transform: translateY(-1px);
}

@media (max-width: 900px) {
  .left-panel {
    display: none;
  }
}
</style>
