# Implementation Plan: 社交媒体舆情分析系统

**Branch**: `1-social-media-sentiment` | **Date**: 2025-12-15 | **Spec**: [Link to spec.md](./spec.md)
**Input**: Feature specification from `/specs/1-social-media-sentiment/spec.md`

## Summary

基于规格说明，实现一个完整的社交媒体舆情分析系统，包括用户管理、内容发布、话题提取、情感分析、热点排行等功能。系统采用 Java 17 + Spring Boot 3.x 后端和 Vue 3 前端，使用 TaurusDB 数据库，通过 MyBatis 进行手写 SQL 操作，展示关系数据库建模和 SQL 能力。

## Technical Context

**Language/Version**: Java 17
**Primary Dependencies**: Spring Boot 3.x, MyBatis, Spring AI, JWT, Spring Validation
**Storage**: TaurusDB（分布式关系数据库，兼容 MySQL 协议和语法）
**Testing**: JUnit 5, Mockito, Spring Boot Test
**Target Platform**: Linux server（云端部署）
**Project Type**: Web application（前后端分离架构）
**Performance Goals**: 支持 1000 并发用户，帖子列表加载 < 2秒，情感分析 < 10秒
**Constraints**: 所有 SQL 必须手写，JWT 令牌有效期 24小时，话题提取在发布时同步进行
**Scale/Scope**: 支持万级用户量，百万级帖子数据

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

**代码质量原则检查**:
- [x] 所有 SQL 查询是否手写而非使用 ORM 自动生成（MyBatis 强制手写 SQL）
- [x] 后端是否采用 Controller → Service → Mapper 分层架构（已定义）
- [x] 前端是否使用 Vue 3 组合式 API（Vue 3 + Composition API）

**数据库设计原则检查**:
- [x] 数据库设计是否满足 3NF 规范化（E-R 图设计阶段）
- [x] 所有表是否定义主键和必要的外键约束（DDL 设计阶段）
- [x] 高频查询字段是否已建立索引（索引设计阶段）

**安全性原则检查**:
- [x] 用户认证是否使用 JWT 并设置合理过期时间（JWT 24小时）
- [x] SQL 操作是否使用参数绑定防止注入（MyBatis 参数化查询）
- [x] 用户密码是否哈希存储（BCrypt 加密）

**性能原则检查**:
- [x] 分页查询是否使用 LIMIT/OFFSET 而非内存分页（MySQL LIMIT/OFFSET）
- [x] 大模型调用是否设计为异步任务（Spring AI 异步调用 + 消息队列）

**测试原则检查**:
- [x] 核心业务逻辑是否有单元测试覆盖（JUnit 5 + Mockito）
- [x] 复杂 SQL 查询是否有独立测试用例（集成测试）

如有任何检查项未通过，必须在实施前提供充分的理由和风险评估。

## Project Structure

### Documentation (this feature)

```text
specs/1-social-media-sentiment/
├── plan.md              # This file (/speckit.plan command output)
├── research.md          # Phase 0 output (/speckit.plan command)
├── data-model.md        # Phase 1 output (/speckit.plan command)
├── quickstart.md        # Phase 1 output (/speckit.plan command)
├── contracts/           # Phase 1 output (/speckit.plan command)
│   ├── openapi.yaml     # OpenAPI 3.0 specification
│   └── endpoints/       # Individual endpoint definitions
└── tasks.md             # Phase 2 output (/speckit.tasks command - NOT created by /speckit.plan)
```

### Source Code (repository root)

```text
# Backend: Spring Boot 3.x application
backend/
├── src/main/java/com/socialmedia/sentiment/
│   ├── controller/          # REST API 控制器层
│   │   ├── AuthController.java
│   │   ├── UserController.java
│   │   ├── PostController.java
│   │   ├── CommentController.java
│   │   ├── AnalyticsController.java
│   │   └── AdminController.java
│   ├── service/            # 业务逻辑层
│   │   ├── AuthService.java
│   │   ├── UserService.java
│   │   ├── PostService.java
│   │   ├── CommentService.java
│   │   ├── SentimentService.java
│   │   └── AnalyticsService.java
│   ├── mapper/             # MyBatis 数据访问层（手写 SQL）
│   │   ├── UserMapper.java
│   │   ├── PostMapper.java
│   │   ├── CommentMapper.java
│   │   ├── HashtagMapper.java
│   │   ├── SentimentMapper.java
│   │   └── KeywordMapper.java
│   ├── entity/             # 数据库实体类
│   │   ├── User.java
│   │   ├── Post.java
│   │   ├── Comment.java
│   │   ├── Hashtag.java
│   │   ├── SentimentAnalysis.java
│   │   └── SensitiveKeyword.java
│   ├── dto/                # 数据传输对象
│   │   ├── request/
│   │   └── response/
│   ├── config/             # 配置类
│   │   ├── SecurityConfig.java
│   │   ├── MyBatisConfig.java
│   │   ├── SpringAIConfig.java
│   │   └── CorsConfig.java
│   ├── util/               # 工具类
│   │   ├── JwtUtil.java
│   │   ├── PasswordUtil.java
│   │   └── HashtagExtractor.java
│   └── SentimentAnalysisApplication.java
├── src/main/resources/
│   ├── mapper/             # MyBatis XML 映射文件（手写 SQL）
│   │   ├── UserMapper.xml
│   │   ├── PostMapper.xml
│   │   └── ...
│   ├── db/migration/       # 数据库迁移脚本
│   │   ├── V1__Create_tables.sql
│   │   ├── V2__Add_indexes.sql
│   │   └── V3__Create_triggers.sql
│   └── application.yml     # 应用配置
└── src/test/java/          # 测试代码
    ├── unit/               # 单元测试
    └── integration/        # 集成测试

# Frontend: Vue 3 application
frontend/
├── public/
│   └── index.html
├── src/
│   ├── views/              # 页面组件
│   │   ├── LoginView.vue
│   │   ├── RegisterView.vue
│   │   ├── PostListView.vue
│   │   ├── PostDetailView.vue
│   │   ├── AnalyticsView.vue
│   │   └── AdminView.vue
│   ├── components/         # 通用组件
│   │   ├── PostCard.vue
│   │   ├── CommentList.vue
│   │   ├── HashtagList.vue
│   │   └── SentimentChart.vue
│   ├── api/                # 接口封装
│   │   ├── auth.js
│   │   ├── posts.js
│   │   └── analytics.js
│   ├── stores/             # Pinia 状态管理
│   │   ├── auth.js
│   │   ├── posts.js
│   │   └── analytics.js
│   ├── router/             # 路由配置
│   │   └── index.js
│   ├── utils/              # 工具函数
│   │   ├── request.js      # Axios 封装
│   │   └── helpers.js
│   └── main.js             # 应用入口
├── package.json
├── vite.config.js
└── README.md

# Database
sql/
├── schema.sql              # 数据库 DDL 脚本
├── triggers.sql            # 触发器定义
├── procedures.sql          # 存储过程定义
├── indexes.sql             # 索引定义
└── test-data.sql           # 测试数据
```

**Structure Decision**: 采用前后端分离的 Web 应用架构，后端使用 Spring Boot 3.x + MyBatis（强制手写 SQL），前端使用 Vue 3 + Vite。数据库采用 TaurusDB（MySQL 兼容），展示关系数据库建模和 SQL 能力。情感分析通过 Spring AI 异步调用实现。

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| 异步情感分析 | 避免阻塞发帖主流程，提升用户体验 | 同步调用会降低发帖速度，影响用户体验 |
| 分布式数据库（TaurusDB） | 课程要求使用华为云数据库，展示分布式特性 | 单机数据库无法满足课程要求 |

---

## Phase 0: Research & Planning

### Research Tasks

基于技术选型需要进行以下研究：

- [x] 研究 Spring Boot 3.x 最佳实践和配置
- [x] 研究 MyBatis 手写 SQL 的最佳实践
- [x] 研究 TaurusDB 与 MySQL 的兼容性和特性
- [x] 研究 Spring AI 集成大模型 API 的最佳实践
- [x] 研究 Vue 3 + Composition API 开发模式
- [x] 研究 ECharts 数据可视化集成
- [x] 研究 JWT 认证和 Spring Security 集成
- [x] 研究数据库触发器和存储过程设计模式

### Research Findings

✅ **Completed**: All research tasks completed successfully.
- **Document**: `research.md` (10 sections, production-ready code examples)
- **Coverage**: Backend, Frontend, Database, AI Integration, Security
- **Status**: Ready for implementation

---

## Phase 1: Design & Contracts

### Data Model Design

✅ **Completed**: Comprehensive data model designed.
- **Document**: `data-model.md`
- **Entities**: 8 core tables (Users, Posts, Comments, Hashtags, etc.)
- **Relationships**: 1:N, N:M with proper foreign keys
- **Constraints**: PK, FK, UNIQUE, CHECK constraints defined
- **Indexes**: Optimized for common queries
- **Status**: Ready for DDL implementation

### API Contracts

✅ **Completed**: Full OpenAPI 3.0 specification.
- **Document**: `contracts/openapi.yaml`
- **Endpoints**: 30+ RESTful endpoints
- **Authentication**: JWT Bearer token
- **Documentation**: Request/response schemas, examples
- **Status**: Ready for code generation and implementation

### Quick Start Guide

✅ **Completed**: Comprehensive setup and deployment guide.
- **Document**: `quickstart.md`
- **Contents**: Environment setup, configuration, running instructions
- **Tools**: Docker, Postman, troubleshooting
- **Status**: Ready for onboarding new developers

### Agent Context Update

⏳ **Pending**: Update agent-specific context files
- **Action**: Run update-agent-context.ps1
- **Purpose**: Preserve technical knowledge for future sessions

---
