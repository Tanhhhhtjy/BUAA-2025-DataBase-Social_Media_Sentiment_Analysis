# Data Model Design: 社交媒体舆情分析系统

**Date**: 2025-12-15
**Version**: 1.0.0
**Status**: Draft

## Overview

本文档定义了社交媒体舆情分析系统的完整数据模型，包括实体关系、字段定义、约束规则和验证逻辑。数据模型基于 TaurusDB（MySQL 兼容）设计，满足 3NF 规范化要求。

---

## Entity Relationship Diagram (Textual)

```
Users (1) ----< (N) Posts
Users (1) ----< (N) Comments
Posts (1) ----< (N) Comments
Posts (1) ----< (N) Post_Hashtags >---- (1) Hashtags
Posts (1) ----< (1) Post_Sentiments
Users (1) ----< (N) Keywords
Keywords (1) ----< (N) Alerts
```

---

## Entity Definitions

### 1. Users (用户表)

**Purpose**: 存储系统用户信息，包括普通用户和管理员

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| user_id | BIGINT | PK, AUTO_INCREMENT | 用户唯一标识 |
| username | VARCHAR(50) | NOT NULL, UNIQUE | 用户名，唯一 |
| email | VARCHAR(100) | NOT NULL, UNIQUE | 邮箱，唯一 |
| password_hash | VARCHAR(255) | NOT NULL | BCrypt 加密密码 |
| role | ENUM('USER', 'ADMIN') | NOT NULL, DEFAULT 'USER' | 用户角色 |
| status | ENUM('ACTIVE', 'DISABLED') | NOT NULL, DEFAULT 'ACTIVE' | 账户状态 |
| created_at | TIMESTAMP | NOT NULL, DEFAULT CURRENT_TIMESTAMP | 创建时间 |
| updated_at | TIMESTAMP | NOT NULL, DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP | 更新时间 |

**Relationships**:
- 1:N → Posts (一个用户可以发布多篇帖子)
- 1:N → Comments (一个用户可以发表多条评论)
- 1:N → Keywords (管理员可以配置多个关键词)

**Validation Rules**:
- username: 3-50 字符，只能包含字母、数字、下划线
- email: 符合 RFC 5322 标准格式
- password: 至少 8 位，包含字母和数字

**State Transitions**:
```
ACTIVE → DISABLED (管理员禁用)
DISABLED → ACTIVE (管理员启用)
```

### 2. Posts (帖子表)

**Purpose**: 存储用户发布的帖子内容

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| post_id | BIGINT | PK, AUTO_INCREMENT | 帖子唯一标识 |
| user_id | BIGINT | NOT NULL, FK → Users.user_id | 发布者 ID |
| content | TEXT | NOT NULL | 帖子内容 |
| created_at | TIMESTAMP | NOT NULL, DEFAULT CURRENT_TIMESTAMP | 创建时间 |
| updated_at | TIMESTAMP | NOT NULL, DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP | 更新时间 |

**Relationships**:
- N:1 → Users (多篇帖子属于一个用户)
- 1:N → Comments (一篇帖子可以有多条评论)
- 1:N → Post_Hashtags (一篇帖子可以关联多个话题)
- 1:1 → Post_Sentiments (一篇帖子对应一个情感分析结果)

**Validation Rules**:
- content: 1-5000 字符
- 自动提取 #话题# 格式的标签

**State Transitions**:
- 帖子创建后自动触发话题提取
- 帖子创建后自动触发情感分析

### 3. Comments (评论表)

**Purpose**: 存储用户对帖子的评论

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| comment_id | BIGINT | PK, AUTO_INCREMENT | 评论唯一标识 |
| post_id | BIGINT | NOT NULL, FK → Posts.post_id | 关联帖子 ID |
| user_id | BIGINT | NOT NULL, FK → Users.user_id | 评论者 ID |
| content | VARCHAR(500) | NOT NULL | 评论内容 |
| created_at | TIMESTAMP | NOT NULL, DEFAULT CURRENT_TIMESTAMP | 创建时间 |

**Relationships**:
- N:1 → Posts (多条评论属于一篇帖子)
- N:1 → Users (多条评论来自一个用户)

**Validation Rules**:
- content: 1-500 字符
- 用户只能删除自己的评论

### 4. Hashtags (话题表)

**Purpose**: 存储系统中的话题标签

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| hashtag_id | BIGINT | PK, AUTO_INCREMENT | 话题唯一标识 |
| tag_name | VARCHAR(100) | NOT NULL, UNIQUE | 话题名称 |
| created_at | TIMESTAMP | NOT NULL, DEFAULT CURRENT_TIMESTAMP | 创建时间 |

**Relationships**:
- 1:N → Post_Hashtags (一个话题可以关联多篇帖子)

**Validation Rules**:
- tag_name: 2-100 字符，去除 # 符号
- 自动转换为小写存储

### 5. Post_Hashtags (帖子话题关联表)

**Purpose**: 实现 Posts 和 Hashtags 的多对多关系

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| post_id | BIGINT | PK1, FK → Posts.post_id | 帖子 ID |
| hashtag_id | BIGINT | PK2, FK → Hashtags.hashtag_id | 话题 ID |
| created_at | TIMESTAMP | NOT NULL, DEFAULT CURRENT_TIMESTAMP | 关联时间 |

**Relationships**:
- N:1 → Posts (多对一是主键的一部分)
- N:1 → Hashtags (多对一是主键的一部分)

**Constraints**:
- 复合主键 (post_id, hashtag_id)
- ON DELETE CASCADE: 删除帖子时自动删除关联
- ON DELETE CASCADE: 删除话题时自动删除关联

### 6. Post_Sentiments (帖子情感分析结果表)

**Purpose**: 存储帖子的情感分析结果

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| sentiment_id | BIGINT | PK, AUTO_INCREMENT | 情感分析记录 ID |
| post_id | BIGINT | NOT NULL, UNIQUE, FK → Posts.post_id | 关联帖子 ID |
| sentiment | ENUM('POSITIVE', 'NEUTRAL', 'NEGATIVE', 'UNANALYZED') | NOT NULL | 情感类别 |
| confidence | DECIMAL(5,4) | NULL | 置信度 (0.0000-1.0000) |
| analyzed_at | TIMESTAMP | NULL | 分析时间 |
| created_at | TIMESTAMP | NOT NULL, DEFAULT CURRENT_TIMESTAMP | 创建时间 |

**Relationships**:
- 1:1 → Posts (一个帖子对应一个分析结果)

**Validation Rules**:
- confidence: 当 sentiment ≠ 'UNANALYZED' 时必须非空且在 0-1 范围内
- analyzed_at: 当 sentiment ≠ 'UNANALYZED' 时必须非空

**State Transitions**:
```
UNANALYZED → POSITIVE/NEUTRAL/NEGATIVE (分析完成后)
```

### 7. Keywords (敏感关键词表)

**Purpose**: 存储管理员配置的敏感关键词

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| keyword_id | BIGINT | PK, AUTO_INCREMENT | 关键词唯一标识 |
| keyword | VARCHAR(100) | NOT NULL | 关键词内容 |
| category | VARCHAR(50) | NOT NULL | 关键词类别 |
| created_at | TIMESTAMP | NOT NULL, DEFAULT CURRENT_TIMESTAMP | 创建时间 |
| updated_at | TIMESTAMP | NOT NULL, DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP | 更新时间 |

**Relationships**:
- 1:N → Alerts (一个关键词可以产生多个预警)

**Constraints**:
- UNIQUE KEY (keyword, category)

**Validation Rules**:
- keyword: 2-100 字符
- category: 2-50 字符
- 支持中文字符

### 8. Alerts (预警记录表)

**Purpose**: 记录命中敏感关键词的内容

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| alert_id | BIGINT | PK, AUTO_INCREMENT | 预警唯一标识 |
| content_type | ENUM('POST', 'COMMENT') | NOT NULL | 内容类型 |
| content_id | BIGINT | NOT NULL | 内容 ID (帖子或评论) |
| keyword_id | BIGINT | NOT NULL, FK → Keywords.keyword_id | 关联关键词 ID |
| summary | VARCHAR(200) | NULL | 内容摘要 |
| created_at | TIMESTAMP | NOT NULL, DEFAULT CURRENT_TIMESTAMP | 创建时间 |

**Relationships**:
- N:1 → Keywords (多个预警可以关联一个关键词)

**Validation Rules**:
- summary: 自动截取内容前 200 字符

---

## Database Constraints

### Primary Keys
- 所有表都有自增主键（BIGINT 或 INT）
- 关联表使用复合主键

### Foreign Keys
```sql
-- Posts 表外键
FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE

-- Comments 表外键
FOREIGN KEY (post_id) REFERENCES posts(post_id) ON DELETE CASCADE
FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE

-- Post_Hashtags 表外键
FOREIGN KEY (post_id) REFERENCES posts(post_id) ON DELETE CASCADE
FOREIGN KEY (hashtag_id) REFERENCES hashtags(hashtag_id) ON DELETE CASCADE

-- Post_Sentiments 表外键
FOREIGN KEY (post_id) REFERENCES posts(post_id) ON DELETE CASCADE

-- Alerts 表外键
FOREIGN KEY (keyword_id) REFERENCES keywords(keyword_id)
```

### Unique Constraints
```sql
-- Users 表
UNIQUE (username)
UNIQUE (email)

-- Hashtags 表
UNIQUE (tag_name)

-- Keywords 表
UNIQUE (keyword, category)

-- Post_Sentiments 表
UNIQUE (post_id)
```

### Check Constraints
```sql
-- Post_Sentiments 表
CHECK (confidence IS NULL OR (confidence >= 0.0 AND confidence <= 1.0))
CHECK (analyzed_at IS NULL OR sentiment != 'UNANALYZED')
CHECK (confidence IS NULL OR sentiment != 'UNANALYZED')
```

---

## Indexes

### Primary Indexes
```sql
-- Users 表
PRIMARY KEY (user_id)
UNIQUE INDEX idx_username (username)
UNIQUE INDEX idx_email (email)
INDEX idx_status (status)
INDEX idx_created_at (created_at)

-- Posts 表
PRIMARY KEY (post_id)
INDEX idx_user_id (user_id)
INDEX idx_created_at (created_at DESC)
INDEX idx_user_created (user_id, created_at DESC)

-- Comments 表
PRIMARY KEY (comment_id)
INDEX idx_post_id (post_id)
INDEX idx_user_id (user_id)
INDEX idx_created_at (created_at)

-- Hashtags 表
PRIMARY KEY (hashtag_id)
UNIQUE INDEX idx_tag_name (tag_name)
INDEX idx_created_at (created_at)

-- Post_Hashtags 表
PRIMARY KEY (post_id, hashtag_id)
INDEX idx_hashtag_id (hashtag_id)

-- Post_Sentiments 表
PRIMARY KEY (sentiment_id)
UNIQUE INDEX idx_post_id (post_id)
INDEX idx_sentiment (sentiment)
INDEX idx_analyzed_at (analyzed_at)

-- Keywords 表
PRIMARY KEY (keyword_id)
UNIQUE INDEX idx_keyword_category (keyword, category)
INDEX idx_category (category)

-- Alerts 表
PRIMARY KEY (alert_id)
INDEX idx_created_at (created_at DESC)
INDEX idx_keyword_id (keyword_id)
```

### Composite Indexes (Performance Optimization)
```sql
-- Posts 列表查询优化
INDEX idx_posts_list (status, created_at DESC)

-- Comments 列表查询优化
INDEX idx_comments_list (post_id, created_at DESC)

-- 热点话题查询优化
INDEX idx_hot_topics (hashtag_id, created_at)

-- 预警查询优化
INDEX idx_alerts_recent (created_at DESC, keyword_id)
```

---

## Data Lifecycle

### User Deletion
```sql
-- 级联删除规则
DELETE FROM users WHERE user_id = ?
-- 自动删除:
-- 1. 该用户的所有帖子
-- 2. 帖子的所有评论
-- 3. 帖子的情感分析记录
-- 4. 帖子的话题关联
-- 5. 该用户的所有评论
```

### Post Deletion
```sql
DELETE FROM posts WHERE post_id = ?
-- 自动删除:
-- 1. 帖子的所有评论
-- 2. 帖子的情感分析记录
-- 3. 帖子的话题关联
```

### Hashtag Deletion
- 当话题不再被任何帖子使用时，可以被删除
- 通过定时任务清理未使用的话题

---

## Audit Fields

所有表都包含以下审计字段：
- `created_at`: 记录创建时间
- `updated_at`: 记录更新时间（自动维护）

---

## Performance Considerations

### Partitioning Strategy
对于大数据量场景（>1000 万条帖子）：
```sql
-- 按时间分区（推荐）
ALTER TABLE posts PARTITION BY RANGE (YEAR(created_at)) (
    PARTITION p2023 VALUES LESS THAN (2024),
    PARTITION p2024 VALUES LESS THAN (2025),
    PARTITION p2025 VALUES LESS THAN (2026),
    PARTITION pmax VALUES LESS THAN MAXVALUE
);
```

### Read/Write Splitting
- 写操作：主库 (Primary)
- 读操作：从库 (Replica)
- 读一致性要求：情感分析查询可以接受一定延迟

### Caching Strategy
- 热点话题排行榜：缓存 5 分钟
- 舆情趋势数据：缓存 1 小时
- 用户会话信息：缓存 30 分钟

---

## Data Validation

### Application Level Validation
```java
// 用户名验证
@Pattern(regexp = "^[a-zA-Z0-9_]{3,50}$", message = "用户名格式不正确")
private String username;

// 邮箱验证
@Email(message = "邮箱格式不正确")
private String email;

// 密码验证
@Size(min = 8, message = "密码至少8位")
@Pattern(regexp = "^(?=.*[A-Za-z])(?=.*\\d)[A-Za-z\\d@$!%*#?&]{8,}$",
         message = "密码必须包含字母和数字")
private String password;
```

### Database Level Validation
- 外键约束保证参照完整性
- CHECK 约束保证业务规则
- 触发器保证业务逻辑

---

## Security Considerations

### Data Encryption
- 密码：BCrypt 哈希存储
- JWT Secret：Base64 编码存储
- 敏感字段：可考虑加密存储

### Access Control
- 行级安全：用户只能访问自己的数据
- 角色级安全：管理员可以访问所有数据
- 敏感操作：需要额外授权

### Audit Logging
```sql
-- 创建审计日志表
CREATE TABLE audit_logs (
    log_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT,
    action VARCHAR(50) NOT NULL,
    table_name VARCHAR(50) NOT NULL,
    record_id BIGINT,
    old_values JSON,
    new_values JSON,
    ip_address VARCHAR(45),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_user_id (user_id),
    INDEX idx_created_at (created_at)
);
```

---

## Migration Strategy

### Version Control
使用 Flyway 或 Liquibase 进行数据库版本管理：
```
db/migration/
├── V1__Create_tables.sql
├── V2__Add_indexes.sql
├── V3__Create_triggers.sql
├── V4__Create_stored_procedures.sql
└── V5__Add_audit_logs.sql
```

### Initial Data
- 创建默认管理员账户
- 初始化基础配置数据
- 插入测试数据

---

## Summary

本数据模型设计具备以下特点：

1. **规范化**: 满足 3NF 要求，消除数据冗余
2. **完整性**: 通过外键和 CHECK 约束保证数据一致性
3. **性能**: 通过索引优化查询性能
4. **可扩展**: 支持分区、读写分离等扩展策略
5. **可审计**: 完整的审计字段和日志记录
6. **安全性**: 多层次的数据保护和访问控制

**Next Steps**:
1. 创建 DDL 脚本
2. 设计触发器和存储过程
3. 定义 API 合同
4. 准备测试数据

---

**Data Model Version**: 1.0.0
**Created**: 2025-12-15
**Last Updated**: 2025-12-15
**Status**: ✅ Ready for Implementation
