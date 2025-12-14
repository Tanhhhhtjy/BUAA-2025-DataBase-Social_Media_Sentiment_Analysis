# BUAA-2025-DataBase-Social_Media_Sentiment_Analysis Constitution

## Core Principles

### I. 代码质量原则 (Code Quality Principles)

所有 SQL 必须手写，禁止使用 JPA/Hibernate/MyBatis-Plus 自动生成。后端代码遵循分层架构：Controller → Service → Mapper，职责清晰分离。前端组件采用 Vue 3 组合式 API，保持单一职责。所有数据库操作必须通过 MyBatis Mapper 接口，禁止在 Service 层拼接 SQL 字符串。

**Rationale**: 确保代码可控性和可维护性，符合课程要求的原生 SQL 实践，分层架构保证职责分离，便于测试和维护。

### II. 数据库设计原则 (Database Design Principles)

数据库设计必须满足第三范式（3NF），避免数据冗余和更新异常。所有表必须定义主键，关联表必须定义外键约束。针对高频查询字段（时间、话题、情感类型等）必须建立索引。删除操作需考虑级联影响，通过外键约束或业务逻辑保证数据一致性。

**Rationale**: 遵循数据库规范化理论，减少数据冗余，索引优化查询性能，外键约束保证数据完整性和一致性。

### III. 安全性原则 (Security Principles)

使用 JWT 进行用户认证，Token 必须设置合理过期时间。所有 SQL 必须使用参数绑定（预编译），禁止字符串拼接防止 SQL 注入。用户密码必须哈希存储，禁止明文保存。敏感接口必须进行权限校验。

**Rationale**: 保护用户数据安全，防止常见安全漏洞（SQL 注入、XSS 等），确保系统符合安全最佳实践。

### IV. 性能原则 (Performance Principles)

分页查询必须使用数据库层面的 LIMIT/OFFSET，禁止全量查询后内存分页。大模型调用应设计为异步任务，避免阻塞主流程。复杂统计查询需进行 SQL 优化，必要时使用 EXPLAIN 分析执行计划。

**Rationale**: 保证系统响应性能，合理利用数据库特性，避免内存溢出，优化用户体验。

### V. 测试原则 (Testing Principles)

核心业务逻辑（用户认证、情感分析、热点统计）必须有单元测试覆盖。复杂 SQL 查询需有独立测试用例验证正确性。API 接口需进行集成测试。

**Rationale**: 确保代码质量和功能正确性，通过测试保证系统稳定性，及早发现和修复问题。

## 技术决策治理 (Technical Decision Governance)

技术选型变更需评估对"手写 SQL"课程要求的影响。新增依赖需确认与 TaurusDB（MySQL 兼容）的兼容性。大模型调用失败时需有降级策略，不影响核心发帖功能。

**Rationale**: 确保技术决策符合项目约束和课程要求，保证系统稳定性和可靠性。

## Governance

本章程超越所有其他实践规范。所有变更必须记录并遵循版本控制。修改章程需提供文档说明、审批流程和迁移计划。所有 PR/代码审查必须验证合规性。复杂性必须有充分理由。使用 `.specify/templates/plan-template.md` 获取运行时开发指导。

**Versioning Policy**: 采用语义化版本（MAJOR.MINOR.PATCH）
- MAJOR：不兼容的治理变更或原则移除/重新定义
- MINOR：新增原则/章节或实质性扩展指导
- PATCH：澄清、用词、非语义性改进

**Compliance Review**:
- 所有代码提交必须通过 Constitution Check
- 复杂查询必须验证 SQL 手写要求
- 数据库设计变更需审查 3NF 规范化
- 安全相关代码变更需安全审查

**Version**: 1.0.0 | **Ratified**: 2025-12-15 | **Last Amended**: 2025-12-15
