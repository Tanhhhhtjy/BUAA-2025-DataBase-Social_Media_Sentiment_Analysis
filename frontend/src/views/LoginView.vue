<template>
  <div class="login-view">
    <el-card class="login-card">
      <template #header>
        <h2>用户登录</h2>
      </template>

      <el-form
        ref="loginFormRef"
        :model="loginForm"
        :rules="loginRules"
        label-width="100px"
      >
        <el-form-item label="用户名/邮箱" prop="usernameOrEmail">
          <el-input
            v-model="loginForm.usernameOrEmail"
            placeholder="请输入用户名或邮箱"
            :prefix-icon="User"
          />
        </el-form-item>

        <el-form-item label="密码" prop="password">
          <el-input
            v-model="loginForm.password"
            type="password"
            placeholder="请输入密码"
            :prefix-icon="Lock"
            show-password
          />
        </el-form-item>

        <el-form-item>
          <el-button
            type="primary"
            @click="handleLogin"
            :loading="loading"
            style="width: 100%"
          >
            登录
          </el-button>
        </el-form-item>

        <el-form-item>
          <div class="form-footer">
            <span>还没有账号？</span>
            <el-button type="text" @click="$router.push('/register')">
              立即注册
            </el-button>
          </div>
        </el-form-item>
      </el-form>
    </el-card>
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

const loginForm = reactive({
  usernameOrEmail: '',
  password: ''
})

const loginRules = {
  usernameOrEmail: [
    { required: true, message: '请输入用户名或邮箱', trigger: 'blur' }
  ],
  password: [
    { required: true, message: '请输入密码', trigger: 'blur' },
    { min: 8, message: '密码长度不能少于8位', trigger: 'blur' }
  ]
}

const handleLogin = async () => {
  if (!loginFormRef.value) return

  await loginFormRef.value.validate(async (valid) => {
    if (valid) {
      loading.value = true
      try {
        const result = await authStore.login(loginForm)
        if (result.success) {
          ElMessage.success('登录成功')
          router.push('/')
        } else {
          ElMessage.error(result.message || '登录失败')
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
.login-view {
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 60vh;
  padding: 20px;
}

.login-card {
  width: 100%;
  max-width: 450px;
}

.login-card h2 {
  text-align: center;
  margin: 0;
  color: #303133;
}

.form-footer {
  display: flex;
  justify-content: center;
  align-items: center;
  width: 100%;
}
</style>
