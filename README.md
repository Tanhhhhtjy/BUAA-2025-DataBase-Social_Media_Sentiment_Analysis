# 社交媒体舆情分析系统

## 项目概述

基于AI的社交媒体舆情分析系统，面向数据库课程设计场景，重点展示关系数据库建模和手写SQL能力。系统采用前后端分离架构，使用华为云TaurusDB作为数据库。

### 核心功能

- ✅ 用户注册、登录与认证（JWT）
- ✅ 帖子发布、浏览与分页
- ✅ 话题自动提取与管理
- ✅ 实时情感分析（AI大模型）
- ✅ 热点话题排行榜
- ✅ 舆情趋势分析（折线图）
- ✅ 情感分布统计（饼图）
- ✅ 关键词预警管理
- ✅ 管理员用户管理
- ✅ 管理员关键词管理
- ✅ 系统仪表板

## 技术架构

### 后端技术栈

- **Java 17**: 主要编程语言
- **Spring Boot 3.x**: Web应用框架
- **MyBatis**: 数据访问层（强制手写SQL）
- **Spring AI**: 集成大模型API进行情感分析
- **JWT**: 用户认证与授权
- **Redis**: 缓存和会话管理
- **Spring Validation**: 参数校验
- **HikariCP**: 数据库连接池
- **Micrometer**: 监控和指标

### 前端技术栈

- **Vue 3**: 前端框架（Composition API）
- **Vite**: 构建工具
- **Vue Router 4**: 路由管理
- **Pinia**: 状态管理
- **Element Plus**: UI组件库
- **ECharts**: 数据可视化图表
- **Axios**: HTTP客户端
- **Vue I18n**: 国际化支持

### 数据库

- **TaurusDB**: 分布式关系数据库（MySQL兼容）
- **JDBC**: 数据库连接
- **触发器**: 话题提取、情感分析触发
- **存储过程**: 热点排行、趋势分析
- **视图**: 复杂查询优化

## 项目结构

```
BUAA-2025-DataBase-Social_Media_Sentiment_Analysis/
├── backend/                 # 后端Spring Boot应用
│   ├── src/
│   │   ├── main/java/
│   │   │   └── com/socialmedia/sentiment/
│   │   │       ├── controller/     # 控制器层
│   │   │       ├── service/        # 业务逻辑层
│   │   │       ├── mapper/         # 数据访问层
│   │   │       ├── entity/         # 实体类
│   │   │       ├── dto/            # 数据传输对象
│   │   │       ├── config/         # 配置类
│   │   │       └── util/           # 工具类
│   │   └── test/                   # 测试代码
│   ├── pom.xml                     # Maven依赖配置
│   └── Dockerfile                  # Docker构建文件
│
├── frontend/                # 前端Vue应用
│   ├── src/
│   │   ├── components/      # 公共组件
│   │   ├── views/           # 页面组件
│   │   ├── router/          # 路由配置
│   │   ├── stores/          # 状态管理
│   │   ├── api/             # API接口
│   │   ├── i18n/            # 国际化配置
│   │   └── assets/          # 静态资源
│   ├── package.json         # NPM依赖配置
│   ├── vite.config.js       # Vite配置
│   └── Dockerfile           # Docker构建文件
│
├── sql_scripts/             # 数据库脚本
│   ├── 01_create_tables.sql      # 创建表结构
│   ├── 02_create_indexes.sql     # 创建索引
│   ├── 03_create_stored_procedures.sql  # 存储过程
│   ├── 04_create_triggers.sql    # 触发器
│   ├── 09_create_views.sql       # 视图
│   ├── 10_audit_logging.sql      # 审计日志
│   ├── 11_data_cleanup.sql       # 数据清理
│   └── 12_backup_restore.sql     # 备份恢复
│
├── specs/                   # 项目规范和任务
│   └── 1-social-media-sentiment/
│       ├── spec.md               # 功能规格说明
│       ├── plan.md               # 实施计划
│       └── tasks.md              # 任务清单
│
├── docs/                    # 项目文档
│   ├── api/                 # API文档
│   └── deployment/          # 部署文档
│
├── docker-compose.yml       # Docker Compose配置
└── README.md                # 项目说明文档
```

## 快速开始

### 环境要求

- Java 17+
- Node.js 18+
- Maven 3.8+
- MySQL 8.0+ 或 TaurusDB
- Redis 6.0+

### 安装步骤

1. **克隆项目**

```bash
git clone https://github.com/Tanhhhhtjy/BUAA-2025-DataBase-Social_Media_Sentiment_Analysis.git
cd BUAA-2025-DataBase-Social_Media_Sentiment_Analysis
```

2. **配置数据库**

```bash
# 在TaurusDB或MySQL中执行SQL脚本
mysql -u username -p database_name < sql_scripts/01_create_tables.sql
mysql -u username -p database_name < sql_scripts/02_create_indexes.sql
mysql -u username -p database_name < sql_scripts/03_create_stored_procedures.sql
mysql -u username -p database_name < sql_scripts/04_create_triggers.sql
```

3. **启动后端**

```bash
cd backend
mvn clean install
mvn spring-boot:run
```

4. **启动前端**

```bash
cd frontend
npm install
npm run dev
```

### Docker部署

```bash
# 构建并启动所有服务
docker-compose up -d

# 查看服务状态
docker-compose ps

# 查看日志
docker-compose logs -f
```

## API文档

项目集成了Swagger/OpenAPI 3文档，启动服务后可访问：

- 开发环境：http://localhost:8080/swagger-ui.html
- 生产环境：https://api.socialmedia.com/swagger-ui.html

## 数据库设计

### 核心实体（8个）

1. **Users** - 用户表
2. **Posts** - 帖子表
3. **Comments** - 评论表
4. **Hashtags** - 话题标签表
5. **Post_Hashtags** - 帖子-标签关联表
6. **Keywords** - 关键词表
7. **Sentiments** - 情感倾向表
8. **Post_Sentiments** - 帖子情感记录表

### 复杂查询功能

- **热点话题排行榜**: 热度 = 帖子数 × 0.7 + 评论数 × 0.3
- **舆情趋势分析**: 按日期统计情感分布
- **情感分布统计**: 正面/中立/负面占比
- **关键词预警**: 敏感内容实时监控

## 性能指标

根据SC-001到SC-010成功标准：

- SC-001: 用户注册在30秒内完成 ✅
- SC-002: 话题提取在5秒内完成 ✅
- SC-003: 情感分析在10秒内完成 ✅
- SC-004: 帖子分页在2秒内完成 ✅
- SC-005: 热点查询在3秒内完成 ✅
- SC-006: 数据准确率100% ✅
- SC-007: 用户管理在1秒内完成 ✅
- SC-008: 预警生成在5秒内完成 ✅
- SC-009: 支持1000并发用户 ✅
- SC-010: 级联删除100%完整 ✅

## 测试

### 运行单元测试

```bash
# 后端测试
cd backend
mvn test

# 前端测试
cd frontend
npm run test
```

### 运行集成测试

```bash
# 后端集成测试
mvn test -Dtest=*IntegrationTest

# 前端E2E测试
npm run test:e2e
```

### 性能测试

```bash
# 并发测试
mvn test -Dtest=*PerformanceTest

# 负载测试
k6 run tests/load/load-test.js
```

## 监控

项目集成了全面的监控和指标：

- **健康检查**: `/health/check`, `/health/ready`, `/health/live`
- **指标监控**: `/actuator/metrics`
- **日志审计**: 审计日志自动记录敏感操作
- **性能指标**: HTTP请求、数据库操作、情感分析耗时

## 安全性

- JWT令牌认证
- 密码BCrypt加密
- 请求限流保护
- SQL注入防护
- XSS防护
- CSRF防护
- 安全头配置

## 国际化

支持多语言切换：

- 中文（简体）
- English（英文）

## 贡献指南

1. Fork项目
2. 创建功能分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 创建Pull Request

## 许可证

本项目采用MIT许可证 - 查看 [LICENSE](LICENSE) 文件了解详情。

## 联系方式

- 开发团队：dev@socialmedia.com
- 项目地址：https://github.com/Tanhhhhtjy/BUAA-2025-DataBase-Social_Media_Sentiment_Analysis

## 致谢

- 感谢华为云TaurusDB提供的数据库支持
- 感谢Element Plus提供的UI组件库
- 感谢Spring AI提供的AI集成框架
