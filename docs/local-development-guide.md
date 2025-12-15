# 本地开发指南

## 概述

本指南详细说明如何在本地IDEA中运行和开发社交媒体舆情分析系统。

## 系统要求

### 必需软件

- **JDK**: 17 或更高版本
- **Maven**: 3.8 或更高版本
- **Node.js**: 18 或更高版本
- **MySQL**: 8.0 或更高版本（或华为云TaurusDB）
- **Redis**: 6.0 或更高版本（可选，用于缓存）

### IDEA插件

- Lombok Plugin
- Vue.js
- Node.js
- Maven（通常内置）
- MySQL（可选）

## 快速开始

### 1. 打开项目

#### 方法1: 打开整个项目
```bash
File -> Open -> 选择项目根目录
D:\Project\DB_project\BUAA-2025-DataBase-Social_Media_Sentiment_Analysis
```

#### 方法2: 分别打开后端和前端
```bash
# 建议直接打开根目录，IDEA会自动识别Maven项目结构
```

### 2. 配置项目结构

#### 设置JDK版本
```bash
# Project Structure (Ctrl+Alt+Shift+S)
# Project -> Project SDK -> 选择 JDK 17
# Project language level -> 17
```

#### 配置Maven
```bash
# File -> Settings -> Build, Execution, Deployment -> Build Tools -> Maven
# Maven home directory -> 选择Maven路径
# User settings file -> 使用默认或自定义settings.xml
```

## 后端配置和启动

### 步骤1: 配置数据库连接

编辑 `backend/src/main/resources/application.yml`：

```yaml
spring:
  application:
    name: social-media-sentiment

  # 数据库配置
  datasource:
    url: jdbc:mysql://localhost:3306/social_media?useUnicode=true&characterEncoding=utf8&useSSL=false&serverTimezone=Asia/Shanghai
    username: your_username
    password: your_password
    driver-class-name: com.mysql.cj.jdbc.Driver
    hikari:
      maximum-pool-size: 20
      minimum-idle: 5
      connection-timeout: 30000
      idle-timeout: 600000
      max-lifetime: 1800000

  # Redis配置（可选）
  redis:
    host: localhost
    port: 6379
    password: # 如果Redis设置了密码
    timeout: 2000ms
    lettuce:
      pool:
        max-active: 8
        max-wait: -1ms
        max-idle: 8
        min-idle: 0

  # 日志配置
  logging:
    level:
      com.socialmedia.sentiment: DEBUG
      org.springframework.web: INFO
      org.mybatis: DEBUG

  # AI配置（根据需要调整）
  ai:
    openai:
      api-key: your_openai_api_key
      chat:
        options:
          model: gpt-3.5-turbo
```

### 步骤2: 创建数据库

```sql
-- 登录MySQL
mysql -u root -p

-- 创建数据库
CREATE DATABASE social_media CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 创建用户（可选）
CREATE USER 'appuser'@'localhost' IDENTIFIED BY 'apppassword';
GRANT ALL PRIVILEGES ON social_media.* TO 'appuser'@'localhost';
FLUSH PRIVILEGES;
```

### 步骤3: 初始化数据库

按以下顺序执行SQL脚本：

```bash
# 方法1: 使用MySQL命令行
mysql -u username -p social_media < sql_scripts/01_create_tables.sql
mysql -u username -p social_media < sql_scripts/02_create_indexes.sql
mysql -u username -p social_media < sql_scripts/03_create_stored_procedures.sql
mysql -u username -p social_media < sql_scripts/04_create_triggers.sql
mysql -u username -p social_media < sql_scripts/09_create_views.sql
mysql -u username -p social_media < sql_scripts/10_audit_logging.sql

# 可选：插入测试数据
mysql -u username -p social_media < sql_scripts/05_insert_test_data_simple.sql

# 方法2: 在DAS（华为云数据库管理服务）中执行
# 登录DAS，切换到对应的数据库实例
# 逐个执行SQL脚本
```

### 步骤4: 启动后端

#### 方法1: Maven命令行
```bash
cd backend

# 下载依赖
mvn dependency:resolve

# 编译项目
mvn clean compile

# 运行项目
mvn spring-boot:run

# 或打包后运行
mvn clean package -DskipTests
java -jar target/social-media-sentiment-1.0.0.jar
```

#### 方法2: IDEA中运行
```bash
# 1. 右键点击backend模块
# 2. 选择 "Run 'SocialMediaApplication'"
# 或
# 1. 定位到 SocialMediaApplication.java
# 2. 右键选择 "Run 'SocialMediaApplication'"
```

#### 方法3: Maven窗口
```bash
# 打开Maven工具窗口（View -> Tool Windows -> Maven）
# 在Lifecycle节点下双击执行
# clean -> compile -> spring-boot:run
```

### 步骤5: 验证后端启动

```bash
# 检查健康状态
curl http://localhost:8080/health/check

# 期望返回
{
  "status": "UP",
  "timestamp": "2025-12-15T10:30:00",
  "service": "social-media-sentiment-api",
  "version": "1.0.0"
}

# 查看详细健康信息
curl http://localhost:8080/health/detailed
```

## 前端配置和启动

### 步骤1: 安装依赖

```bash
cd frontend

# 方法1: 使用npm
npm install

# 方法2: 使用yarn
yarn install

# 方法3: 使用pnpm
pnpm install
```

#### 国内用户建议使用淘宝镜像

```bash
# 临时使用
npm install --registry=https://registry.npmmirror.com

# 全局配置
npm config set registry https://registry.npmmirror.com

# 或使用cnpm
npm install -g cnpm --registry=https://registry.npmmirror.com
cnpm install
```

### 步骤2: 配置API地址（可选）

编辑 `frontend/src/api/request.js`：

```javascript
// 开发环境配置
const devConfig = {
  baseURL: 'http://localhost:8080/api',
  timeout: 10000
}

// 生产环境配置
const prodConfig = {
  baseURL: '/api',
  timeout: 10000
}

export default {
  baseURL: import.meta.env.DEV ? devConfig.baseURL : prodConfig.baseURL,
  timeout: import.meta.env.DEV ? devConfig.timeout : prodConfig.timeout
}
```

### 步骤3: 启动开发服务器

#### 方法1: 命令行
```bash
cd frontend

# 启动开发服务器
npm run dev

# 或指定端口
npm run dev -- --port 3000

# 或指定host
npm run dev -- --host 0.0.0.0
```

#### 方法2: IDEA中运行
```bash
# 1. 打开frontend目录下的package.json
# 2. 右键点击"dev"脚本
# 3. 选择"Run 'dev'"
# 或
# 1. 安装Node.js插件
# 2. 在Run/Debug Configurations中创建新配置
# 3. 选择npm
# 4. Package.json: frontend/package.json
# 5. Scripts: dev
```

### 步骤4: 访问应用

```bash
# 前端地址
http://localhost:5173

# 后端API
http://localhost:8080

# API文档（Swagger）
http://localhost:8080/swagger-ui.html
```

## 完整启动顺序

### 启动所有服务

```bash
# 1. 启动MySQL数据库
# Windows: 启动MySQL服务
net start mysql

# 或使用XAMPP/WAMP等集成环境

# 2. 启动Redis（可选）
redis-server

# 或Windows服务
net start redis

# 3. 启动后端（新终端）
cd backend
mvn spring-boot:run

# 4. 启动前端（新终端）
cd frontend
npm run dev

# 5. 访问应用
# 前端: http://localhost:5173
# 后端API: http://localhost:8080
# API文档: http://localhost:8080/swagger-ui.html
```

### 使用Docker启动（替代方案）

```bash
# 一键启动所有服务
docker-compose up -d

# 查看服务状态
docker-compose ps

# 查看日志
docker-compose logs -f backend
docker-compose logs -f frontend

# 停止服务
docker-compose down
```

## 开发调试

### 后端调试

#### 设置断点
```java
// 在代码中设置断点，F8逐步执行
@RestController
public class UserController {
    @PostMapping("/register")
    public ResponseEntity<?> register(@RequestBody User user) {
        // 断点设置在这一行
        User result = userService.register(user);
        return ResponseEntity.ok(result);
    }
}
```

#### 日志调试
```java
private static final Logger logger = LoggerFactory.getLogger(UserService.class);

public void registerUser(String username, String email, String password) {
    logger.debug("开始注册用户: {}", username);
    logger.info("用户注册成功: {}", username);

    try {
        // 业务逻辑
    } catch (Exception e) {
        logger.error("用户注册失败: {}", username, e);
        throw e;
    }
}
```

#### 查看SQL日志
```yaml
# application.yml
mybatis:
  configuration:
    log-impl: org.apache.ibatis.logging.stdout.StdOutImpl
```

### 前端调试

#### 浏览器开发者工具
```javascript
// 在组件中使用console.log
const fetchData = async () => {
  console.log('开始获取数据')
  try {
    const data = await api.getData()
    console.log('数据获取成功:', data)
  } catch (error) {
    console.error('数据获取失败:', error)
  }
}
```

#### Vue DevTools
```bash
# 安装浏览器扩展
# Chrome: https://chrome.google.com/webstore/detail/vuejs-devtools
# Firefox: https://addons.mozilla.org/en-US/firefox/addon/vue-js-devtools/
```

#### 网络请求调试
```javascript
// 查看所有API请求
// 打开Network选项卡
// 查看请求和响应详情
```

## 常见问题解决

### 后端问题

#### 问题1: 端口8080被占用
```bash
# 检查端口占用
netstat -ano | findstr :8080

# 杀死进程
taskkill /PID <PID> /F

# 或修改端口
# application.yml
server:
  port: 8081
```

#### 问题2: 数据库连接失败
```yaml
# 检查配置
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/social_media?useSSL=false&serverTimezone=Asia/Shanghai
    username: root
    password: password

# 检查服务状态
mysql -u root -p -e "SELECT VERSION();"

# 检查网络连通
telnet localhost 3306
```

#### 问题3: Maven依赖下载慢
```xml
<!-- pom.xml 中添加镜像 -->
<repositories>
    <repository>
        <id>aliyun</id>
        <url>https://maven.aliyun.com/repository/public</url>
    </repository>
</repositories>

<pluginRepositories>
    <pluginRepository>
        <id>aliyun</id>
        <url>https://maven.aliyun.com/repository/public</url>
    </pluginRepository>
</pluginRepositories>
```

#### 问题4: 编译错误
```bash
# 清理项目
mvn clean

# 重新下载依赖
mvn dependency:resolve

# 编译
mvn compile

# 如果仍有问题，删除本地仓库
# Windows: 删除 C:\Users\<username>\.m2\repository
```

### 前端问题

#### 问题1: 端口5173被占用
```bash
# 检查端口占用
netstat -ano | findstr :5173

# 杀死进程
taskkill /PID <PID> /F

# 或使用其他端口
npm run dev -- --port 3000
```

#### 问题2: 依赖安装失败
```bash
# 清除缓存
npm cache clean --force
rm -rf node_modules package-lock.json

# 重新安装
npm install

# 或使用yarn
yarn install

# 或使用cnpm
npm install -g cnpm --registry=https://registry.npmmirror.com
cnpm install
```

#### 问题3: CORS跨域问题
```java
// 后端配置CORS
@Configuration
public class WebConfig implements WebMvcConfigurer {
    @Override
    public void addCorsMappings(CorsRegistry registry) {
        registry.addMapping("/api/**")
                .allowedOrigins("http://localhost:5173")
                .allowedMethods("GET", "POST", "PUT", "DELETE")
                .allowCredentials(true);
    }
}
```

#### 问题4: 编译错误
```bash
# 检查Node.js版本
node --version  # 应为18或更高

# 检查npm版本
npm --version

# 重新安装依赖
rm -rf node_modules
npm install

# 检查ESLint错误
npm run lint
```

## 性能优化建议

### 后端优化

#### 1. 启用缓存
```java
@Service
@CacheConfig(cacheNames = "users")
public class UserService {
    @Cacheable(key = "#username")
    public User findByUsername(String username) {
        return userMapper.findByUsername(username);
    }
}
```

#### 2. 配置数据库连接池
```yaml
spring:
  datasource:
    hikari:
      maximum-pool-size: 20
      minimum-idle: 5
      connection-timeout: 30000
      idle-timeout: 600000
      max-lifetime: 1800000
```

#### 3. 启用Gzip压缩
```yaml
server:
  compression:
    enabled: true
    mime-types: text/html,text/xml,text/plain,text/css,application/javascript,application/json
```

### 前端优化

#### 1. 启用代码分割
```javascript
// 路由懒加载
const routes = [
  {
    path: '/admin',
    name: 'Admin',
    component: () => import('../views/admin/AdminView.vue')
  }
]
```

#### 2. 启用Tree Shaking
```javascript
// vite.config.js
export default defineConfig({
  build: {
    rollupOptions: {
      output: {
        manualChunks: {
          vendor: ['vue', 'vue-router'],
          element: ['element-plus']
        }
      }
    }
  }
})
```

#### 3. 启用CDN
```html
<!-- index.html -->
<script src="https://unpkg.com/vue@3/dist/vue.global.js"></script>
```

## 环境配置

### 开发环境

#### 后端: application-dev.yml
```yaml
spring:
  profiles:
    active: dev
  datasource:
    url: jdbc:mysql://localhost:3306/social_media_dev
  redis:
    host: localhost
  logging:
    level:
      com.socialmedia.sentiment: DEBUG
```

#### 前端: .env.development
```env
VITE_API_URL=http://localhost:8080/api
VITE_APP_TITLE=社交媒体舆情分析系统
VITE_APP_ENV=development
```

### 测试环境

#### 后端: application-test.yml
```yaml
spring:
  profiles:
    active: test
  datasource:
    url: jdbc:mysql://localhost:3306/social_media_test
  logging:
    level:
      com.socialmedia.sentiment: INFO
```

### 生产环境

#### 后端: application-prod.yml
```yaml
spring:
  profiles:
    active: prod
  datasource:
    url: jdbc:mysql://prod-db:3306/social_media
    hikari:
      maximum-pool-size: 50
  redis:
    host: prod-redis
    password: ${REDIS_PASSWORD}
  logging:
    level:
      com.socialmedia.sentiment: WARN
```

#### 前端: .env.production
```env
VITE_API_URL=https://api.socialmedia.com/api
VITE_APP_TITLE=社交媒体舆情分析系统
VITE_APP_ENV=production
```

## 测试

### 运行后端测试

```bash
cd backend

# 运行所有测试
mvn test

# 运行特定测试类
mvn test -Dtest=UserServiceTest

# 运行测试并生成覆盖率报告
mvn jacoco:report

# 查看报告
open target/site/jacoco/index.html
```

### 运行前端测试

```bash
cd frontend

# 运行单元测试
npm run test:unit

# 运行E2E测试
npm run test:e2e

# 运行所有测试
npm run test
```

## 验证安装

### 检查清单

- [ ] MySQL服务已启动
- [ ] 数据库已创建并初始化
- [ ] 后端服务已启动 (http://localhost:8080/health/check)
- [ ] 前端服务已启动 (http://localhost:5173)
- [ ] 能够访问API文档 (http://localhost:8080/swagger-ui.html)
- [ ] 前后端可以正常通信

### 快速验证脚本

#### 后端验证
```bash
# 检查服务状态
curl http://localhost:8080/health/check

# 检查API端点
curl http://localhost:8080/api/posts?page=0&size=10

# 期望返回JSON响应
```

#### 前端验证
```bash
# 访问首页
# http://localhost:5173
# 应该看到登录页面

# 检查控制台无错误
# F12 -> Console -> 无红色错误
```

## 生产部署准备

### 打包

```bash
# 后端打包
cd backend
mvn clean package -DskipTests -Pprod

# 前端打包
cd frontend
npm run build

# 生成的文件在 dist/ 目录
```

### Docker镜像

```bash
# 构建镜像
docker-compose build

# 推送镜像（可选）
docker-compose push
```

### 部署检查清单

- [ ] 所有环境变量已配置
- [ ] 数据库连接正常
- [ ] API密钥已配置
- [ ] 日志配置已调整
- [ ] 安全配置已启用
- [ ] 监控已配置

## 获取帮助

### 文档资源

- [项目README](../README.md)
- [API文档](http://localhost:8080/swagger-ui.html)
- [数据库设计文档](./database-design.md)

### 联系方式

- 项目GitHub: https://github.com/Tanhhhhtjy/BUAA-2025-DataBase-Social_Media_Sentiment_Analysis
- 开发团队: dev@socialmedia.com

### 常见资源

- [Spring Boot文档](https://spring.io/projects/spring-boot)
- [Vue 3文档](https://cn.vuejs.org/)
- [MySQL文档](https://dev.mysql.com/doc/)
- [Redis文档](https://redis.io/documentation)

## 总结

按照本指南操作，您应该能够在本地IDEA中成功运行和开发社交媒体舆情分析系统。如果遇到问题，请参考"常见问题解决"章节或查看项目文档。

祝您开发愉快！🎉
