# Quick Start Guide: 社交媒体舆情分析系统

**Version**: 1.0.0
**Date**: 2025-12-15

## Overview

本指南将帮助您快速搭建和运行社交媒体舆情分析系统。系统采用前后端分离架构，后端使用 Spring Boot 3.x + MyBatis，前端使用 Vue 3 + ECharts，数据库使用 TaurusDB。

---

## Prerequisites

### System Requirements
- **Java**: JDK 17 或更高版本
- **Node.js**: 18.x 或更高版本
- **Maven**: 3.8.x 或更高版本
- **MySQL Client**: 用于连接 TaurusDB
- **Git**: 用于版本控制

### Required Accounts
- **华为云账户**: 访问 TaurusDB 数据库
- **OpenAI API Key** (或兼容的大模型 API): 用于情感分析

---

## Environment Setup

### 1. Clone Repository

```bash
git clone https://github.com/Tanhhhhtjy/BUAA-2025-DataBase-Social_Media_Sentiment_Analysis.git
cd BUAA-2025-DataBase-Social_Media_Sentiment_Analysis
git checkout 1-social-media-sentiment
```

### 2. Database Setup

#### 2.1 Connect to TaurusDB

使用 DAS (Data Admin Service) 连接到华为云 TaurusDB：

1. 登录华为云控制台
2. 进入 DAS 服务
3. 连接到数据库实例: `gauss-7a55`
4. 获取连接信息（主机、端口、用户名、密码）

#### 2.2 Create Database

```sql
CREATE DATABASE social_media CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE social_media;
```

#### 2.3 Run Schema Migration

```bash
# 执行数据库迁移脚本
mysql -h <taurusdb_host> -P <port> -u <username> -p<password> < sql/schema.sql
```

或者通过 DAS 控制台执行 `sql/schema.sql` 文件中的 SQL 语句。

#### 2.4 Create Default Admin

```sql
INSERT INTO users (username, email, password_hash, role, status)
VALUES (
    'admin',
    'admin@example.com',
    '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj86wL0fOaY6', -- password: admin123
    'ADMIN',
    'ACTIVE'
);
```

### 3. Backend Configuration

#### 3.1 Configure Application Properties

创建 `backend/src/main/resources/application.yml`:

```yaml
server:
  port: 8080
  servlet:
    context-path: /api

spring:
  application:
    name: sentiment-analysis

  datasource:
    url: jdbc:mysql://${DB_HOST:localhost}:${DB_PORT:3306}/social_media?useUnicode=true&characterEncoding=utf8&useSSL=false&serverTimezone=Asia/Shanghai
    username: ${DB_USERNAME}
    password: ${DB_PASSWORD}
    driver-class-name: com.mysql.cj.jdbc.Driver
    hikari:
      maximum-pool-size: 20
      minimum-idle: 5
      idle-timeout: 300000
      max-lifetime: 900000
      connection-timeout: 20000

  mybatis:
    mapper-locations: classpath:mapper/*.xml
    type-aliases-package: com.socialmedia.sentiment.entity
    configuration:
      map-underscore-to-camel-case: true
      cache-enabled: true
      log-impl: org.apache.ibatis.logging.stdout.StdOutImpl

  ai:
    openai:
      api-key: ${OPENAI_API_KEY}
      base-url: ${OPENAI_BASE_URL:https://api.openai.com/v1}
      chat:
        options:
          model: ${OPENAI_MODEL:gpt-3.5-turbo}
          temperature: 0.3

# JWT Configuration
jwt:
  secret: ${JWT_SECRET:mySecretKey123456789012345678901234567890}
  expiration: 24 # hours

# Logging
logging:
  level:
    com.socialmedia.sentiment: DEBUG
    org.springframework.security: DEBUG
  pattern:
    console: "%d{yyyy-MM-dd HH:mm:ss} - %msg%n"
    file: "%d{yyyy-MM-dd HH:mm:ss} [%thread] %-5level %logger{36} - %msg%n"
  file:
    name: logs/sentiment-analysis.log

---
# Production Profile
spring:
  config:
    activate:
      on-profile: prod
  datasource:
    url: jdbc:mysql://taurusdb-prod:3306/social_media?useSSL=true&serverTimezone=Asia/Shanghai
  mybatis:
    configuration:
      log-impl: org.apache.ibatis.logging.nologging.NoLoggingImpl
  ai:
    openai:
      api-key: ${OPENAI_API_KEY}
```

#### 3.2 Set Environment Variables

创建 `.env` 文件：

```bash
# Database Configuration
DB_HOST=your-taurusdb-host
DB_PORT=3306
DB_USERNAME=your-username
DB_PASSWORD=your-password

# JWT Configuration
JWT_SECRET=your-256-bit-secret-key

# OpenAI Configuration
OPENAI_API_KEY=your-openai-api-key
OPENAI_BASE_URL=https://api.openai.com/v1
OPENAI_MODEL=gpt-3.5-turbo
```

#### 3.3 Build Backend

```bash
cd backend
mvn clean package -DskipTests
```

### 4. Frontend Setup

#### 4.1 Install Dependencies

```bash
cd frontend
npm install
```

#### 4.2 Configure API Base URL

修改 `src/utils/request.js`:

```javascript
const http = axios.create({
  baseURL: import.meta.env.VITE_API_BASE_URL || 'http://localhost:8080/api',
  timeout: 10000
})
```

创建 `.env` 文件：

```bash
VITE_API_BASE_URL=http://localhost:8080/api
```

#### 4.3 Build Frontend

```bash
npm run build
```

---

## Running the Application

### Option 1: Run Separately

#### Start Backend

```bash
cd backend
java -jar target/sentiment-analysis-1.0.0.jar
```

Backend 将在 `http://localhost:8080/api` 启动

#### Start Frontend (Dev Mode)

```bash
cd frontend
npm run dev
```

Frontend 将在 `http://localhost:5173` 启动

### Option 2: Docker Compose

创建 `docker-compose.yml`:

```yaml
version: '3.8'

services:
  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile
    ports:
      - "8080:8080"
    environment:
      - DB_HOST=taurusdb
      - DB_USERNAME=${DB_USERNAME}
      - DB_PASSWORD=${DB_PASSWORD}
      - OPENAI_API_KEY=${OPENAI_API_KEY}
    depends_on:
      - taurusdb
    restart: unless-stopped

  frontend:
    build:
      context: ./frontend
      dockerfile: Dockerfile
    ports:
      - "80:80"
    depends_on:
      - backend
    restart: unless-stopped

  taurusdb:
    image: mysql:8.0
    environment:
      MYSQL_ROOT_PASSWORD: ${DB_PASSWORD}
      MYSQL_DATABASE: social_media
    volumes:
      - db_data:/var/lib/mysql
      - ./sql/schema.sql:/docker-entrypoint-initdb.d/schema.sql
    restart: unless-stopped

volumes:
  db_data:
```

启动：

```bash
docker-compose up -d
```

---

## First Steps

### 1. Access the Application

- **Frontend**: http://localhost:5173 (dev mode) 或 http://localhost (production)
- **Backend API**: http://localhost:8080/api
- **API Documentation**: http://localhost:8080/api/v3/api-docs (Swagger)

### 2. Login as Admin

使用默认管理员账号登录：
- **用户名**: admin
- **密码**: admin123

### 3. Create Test Data

#### Add Sensitive Keywords

通过 API 添加关键词：

```bash
curl -X POST http://localhost:8080/api/keywords \
  -H "Authorization: Bearer <admin-token>" \
  -H "Content-Type: application/json" \
  -d '{
    "keyword": "政治敏感",
    "category": "政治"
  }'
```

#### Create Test Users

使用注册接口创建普通用户：

```bash
curl -X POST http://localhost:8080/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser",
    "email": "test@example.com",
    "password": "password123"
  }'
```

#### Create Test Posts

登录后创建帖子：

```bash
curl -X POST http://localhost:8080/api/posts \
  -H "Authorization: Bearer <user-token>" \
  -H "Content-Type: application/json" \
  -d '{
    "content": "今天天气真好！#天气#心情#"
  }'
```

---

## API Testing with Postman

### 1. Import Collection

导入 `contracts/openapi.yaml` 到 Postman：

1. Open Postman
2. Click "Import"
3. Select "OpenAPI 3.0"
4. Upload `contracts/openapi.yaml`
5. API Collection 导入完成

### 2. Set Environment Variables

创建环境变量：

```
baseUrl: http://localhost:8080/api
token: {{token}}
```

### 3. Test Authentication Flow

1. **Register**:
   ```
   POST /auth/register
   Body: { "username": "user1", "email": "user1@test.com", "password": "pass123" }
   ```

2. **Login**:
   ```
   POST /auth/login
   Body: { "usernameOrEmail": "user1", "password": "pass123" }
   ```

3. **Get Token**: 从响应中提取 `token` 并设置环境变量

4. **Test Protected Routes**:
   ```
   GET /posts (需要 Authorization: Bearer {{token}})
   POST /posts (需要 Authorization: Bearer {{token}})
   ```

---

## Common Operations

### View Logs

#### Backend Logs

```bash
tail -f backend/logs/sentiment-analysis.log
```

或使用 Docker：

```bash
docker-compose logs -f backend
```

#### Database Logs

通过 DAS 控制台查看数据库慢查询日志。

### Reset Database

```bash
# 删除所有表
mysql -h <host> -u <user> -p -e "DROP DATABASE social_media; CREATE DATABASE social_media;"

# 重新执行迁移
mysql -h <host> -u <user> -p social_media < sql/schema.sql
```

### Clear Cache

重启应用清除缓存：

```bash
# Backend
sudo systemctl restart sentiment-backend

# Frontend
# 清除浏览器缓存 (Ctrl+Shift+R)
```

---

## Troubleshooting

### Issue 1: Database Connection Failed

**Error**: `Communications link failure`

**Solution**:
1. 检查 TaurusDB 连接信息是否正确
2. 确认网络连通性
3. 验证用户名和密码
4. 检查安全组配置（华为云）

### Issue 2: CORS Error

**Error**: `Access to fetch at 'http://localhost:8080/api/...' from origin 'http://localhost:5173' has been blocked by CORS policy`

**Solution**: 确保后端配置了 CORS：

```java
@Configuration
@EnableWebMvc
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

### Issue 3: JWT Token Expired

**Error**: `401 Unauthorized`

**Solution**:
1. 重新登录获取新 token
2. 检查 JWT 过期时间配置
3. 确认服务器时间正确

### Issue 4: Sentiment Analysis Failed

**Error**: `Failed to analyze sentiment`

**Solution**:
1. 检查 OpenAI API Key 是否有效
2. 验证网络连接
3. 查看后端日志获取详细错误信息
4. 确认 API 配额未超限

### Issue 5: Frontend Build Failed

**Error**: `npm run build failed`

**Solution**:
```bash
# 清除缓存
rm -rf node_modules package-lock.json
npm install
npm run build
```

---

## Development Workflow

### 1. Code Structure

```
backend/
├── src/main/java/com/socialmedia/sentiment/
│   ├── controller/     # REST 控制器
│   ├── service/        # 业务逻辑
│   ├── mapper/         # MyBatis 数据访问
│   ├── entity/         # 实体类
│   ├── dto/            # 数据传输对象
│   ├── config/         # 配置类
│   └── util/           # 工具类
└── src/main/resources/
    ├── mapper/         # MyBatis XML 映射文件
    ├── db/migration/   # 数据库迁移脚本
    └── application.yml

frontend/
├── src/
│   ├── views/          # 页面组件
│   ├── components/     # 通用组件
│   ├── api/            # API 接口
│   ├── stores/         # Pinia 状态管理
│   └── utils/          # 工具函数
└── public/
```

### 2. Making Changes

#### Backend Changes

1. **修改实体类**:
   - 更新 `entity/` 目录下的类
   - 更新对应的数据库表结构（如果需要）

2. **修改数据库**:
   - 创建新的迁移脚本 `sql/migration/V{n}__Description.sql`
   - 执行迁移

3. **修改 API**:
   - 更新 Controller
   - 更新 DTO
   - 更新 MyBatis Mapper
   - 更新 OpenAPI 规范

#### Frontend Changes

1. **修改页面**:
   - 更新 `views/` 目录下的 Vue 组件
   - 使用 Composition API

2. **修改 API**:
   - 更新 `api/` 目录下的接口封装
   - 更新类型定义

3. **添加新页面**:
   - 创建 Vue 组件
   - 配置路由
   - 添加菜单项

### 3. Testing

#### Backend Tests

```bash
cd backend
mvn test
```

#### Frontend Tests

```bash
cd frontend
npm test
```

#### Integration Tests

```bash
mvn verify
```

---

## Production Deployment

### 1. Build Artifacts

```bash
# Backend
mvn clean package -Pprod -DskipTests

# Frontend
npm run build
```

### 2. Deploy to Cloud

#### Option 1: Huawei Cloud

1. **构建镜像**:
   ```bash
   docker build -t sentiment-analysis:latest .
   ```

2. **推送到 SWR**:
   ```bash
   docker tag sentiment-analysis:latest swr.cn-north-1.myhuaweicloud.com/namespace/sentiment-analysis:latest
   docker push swr.cn-north-1.myhuaweicloud.com/namespace/sentiment-analysis:latest
   ```

3. **部署到 CCE**:
   - 创建工作负载
   - 配置服务
   - 设置自动伸缩

#### Option 2: Kubernetes

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sentiment-backend
spec:
  replicas: 3
  selector:
    matchLabels:
      app: sentiment-backend
  template:
    metadata:
      labels:
        app: sentiment-backend
    spec:
      containers:
      - name: backend
        image: sentiment-analysis:latest
        ports:
        - containerPort: 8080
        env:
        - name: DB_HOST
          valueFrom:
            secretKeyRef:
              name: db-secret
              key: host
        - name: OPENAI_API_KEY
          valueFrom:
            secretKeyRef:
              name: ai-secret
              key: api-key
```

---

## Performance Tuning

### 1. Database Optimization

```sql
-- 分析慢查询
EXPLAIN SELECT * FROM posts WHERE user_id = 1 ORDER BY created_at DESC LIMIT 10;

-- 查看索引使用情况
SHOW INDEX FROM posts;

-- 优化查询
CREATE INDEX idx_posts_user_created ON posts(user_id, created_at DESC);
```

### 2. Application Optimization

- 启用缓存 (`@Cacheable`)
- 使用连接池 (HikariCP)
- 配置分页查询
- 异步处理耗时操作

### 3. Frontend Optimization

- 路由懒加载
- 组件懒加载
- 图片压缩
- CDN 加速

---

## Monitoring

### 1. Application Monitoring

- 使用 Spring Boot Actuator
- 集成 Micrometer + Prometheus
- 配置 Grafana 看板

### 2. Database Monitoring

- 华为云 RDS 监控
- 慢查询分析
- 连接池监控

### 3. Alerting

配置关键指标告警：
- CPU 使用率 > 80%
- 内存使用率 > 80%
- 响应时间 > 2s
- 错误率 > 5%

---

## Support & Resources

### Documentation
- [Spring Boot 3.x Documentation](https://docs.spring.io/spring-boot/docs/3.1.0/reference/html/)
- [Vue 3 Documentation](https://vuejs.org/guide/introduction.html)
- [MyBatis Documentation](https://mybatis.org/mybatis-3/)
- [TaurusDB Documentation](https://support.huaweicloud.com/taurusdb/)

### Tools
- [Postman](https://www.postman.com/) - API 测试
- [DBeaver](https://dbeaver.io/) - 数据库管理
- [VSCode](https://code.visualstudio.com/) - 代码编辑
- [IntelliJ IDEA](https://www.jetbrains.com/idea/) - Java 开发

### Community
- 华为云论坛: https://bbs.huaweicloud.com/
- Stack Overflow: https://stackoverflow.com/
- GitHub Issues: https://github.com/Tanhhhhtjy/BUAA-2025-DataBase-Social_Media_Sentiment_Analysis/issues

---

## Next Steps

完成快速开始后，您可以：

1. **阅读完整文档**:
   - 查看 `data-model.md` 了解数据模型
   - 查看 `research.md` 了解技术实现细节
   - 查看 `contracts/openapi.yaml` 了解 API 规范

2. **开始开发**:
   - 运行 `/speckit.tasks` 生成任务清单
   - 按任务清单逐步实现功能
   - 编写单元测试和集成测试

3. **扩展功能**:
   - 添加更多图表类型
   - 实现实时通知
   - 集成消息队列
   - 添加文件上传功能

---

**Quick Start Guide Version**: 1.0.0
**Last Updated**: 2025-12-15
**Status**: ✅ Ready for Use

Happy Coding! 🚀
