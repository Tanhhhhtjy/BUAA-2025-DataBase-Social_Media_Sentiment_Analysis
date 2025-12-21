<template>
  <div class="login-container">
    <div class="left-panel">
      <div class="brand-content">
        <h1>Social Sentiment</h1>
        <p>洞察每一条评论背后的情感温度</p>
      </div>
    </div>
    <div class="right-panel">
      <div class="form-wrapper">
        <div class="form-header">
          <h2>欢迎回来</h2>
          <p class="sub-text">请输入您的账号信息以登录</p>
        </div>

        <el-form
          ref="loginFormRef"
          :model="loginForm"
          :rules="loginRules"
          label-position="top"
          size="large"
          class="login-form"
        >
          <el-form-item label="账号" prop="usernameOrEmail" :error="usernameError">
            <el-input
              v-model="loginForm.usernameOrEmail"
              placeholder="请输入用户名或邮箱"
              :prefix-icon="User"
              @input="usernameError = ''"
            />
          </el-form-item>

          <el-form-item label="密码" prop="password" :error="passwordError">
            <el-input
              v-model="loginForm.password"
              type="password"
              placeholder="请输入密码"
              :prefix-icon="Lock"
              show-password
              @input="passwordError = ''"
            />
          </el-form-item>

          <div class="form-actions">
            <el-button type="primary" @click="handleLogin" :loading="loading" class="submit-btn">
              登 录
            </el-button>
          </div>

          <div class="form-footer">
            <span class="no-account">还没有账号？</span>
            <el-button type="primary" @click="$router.push('/register')"> 立即注册 </el-button>
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
import { User, Lock } from '@element-plus/icons-vue'

const router = useRouter()
const authStore = useAuthStore()

const loginFormRef = ref()
const loading = ref(false)
const usernameError = ref('')
const passwordError = ref('')

const loginForm = reactive({
  usernameOrEmail: '',
  password: ''
})

const loginRules = {
  usernameOrEmail: [{ required: true, message: '请输入用户名或邮箱', trigger: 'blur' }],
  password: [
    { required: true, message: '请输入密码', trigger: 'blur' },
    { min: 8, message: '密码长度不能少于8位', trigger: 'blur' }
  ]
}

const handleLogin = async () => {
  if (!loginFormRef.value) return

  // Clear previous errors
  usernameError.value = ''
  passwordError.value = ''

  await loginFormRef.value.validate(async valid => {
    if (valid) {
      loading.value = true
      try {
        const result = await authStore.login(loginForm)
        if (result.success) {
          ElMessage.success('登录成功')
          router.push('/')
        } else {
          // Determine where to show the error
          const msg = result.message || '登录失败'
          if (
            msg.includes('用户') ||
            msg.includes('账号') ||
            msg.toLowerCase().includes('user') ||
            msg.toLowerCase().includes('account')
          ) {
            usernameError.value = msg
          } else if (msg.includes('密码') || msg.toLowerCase().includes('password')) {
            passwordError.value = msg
          } else {
            // Generic error, show toast
            ElMessage.error(msg)
          }
        }
      } catch (error) {
        ElMessage.error(error.message || '登录失败')
      } finally {
        loading.value = false
      }
    }
  })
}
</script>

<style scoped>
.login-container {
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

/* 装饰性背景纹理 */
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
  max-width: 420px;
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

.login-form :deep(.el-input__wrapper) {
  background-color: #f4f4f5;
  box-shadow: none;
  border: 1px solid transparent;
  transition: all 0.2s;
  border-radius: 8px;
  padding: 4px 12px;
}

.login-form :deep(.el-input__wrapper.is-focus) {
  background-color: #ffffff;
  border-color: #4f46e5;
  box-shadow: 0 0 0 1px #4f46e5;
}

.login-form :deep(.el-form-item__label) {
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

.no-account {
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
