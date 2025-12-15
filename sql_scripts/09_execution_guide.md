# SQL脚本执行指南

## 📋 概述

本文档说明sql_scripts目录中各脚本的执行顺序和用途。**所有脚本已经过修正，可安全使用。**

---

## 📅 执行顺序

### 🚀 快速开始（仅需4个核心脚本）

```bash
# 1. 创建表结构
mysql -u username -p database_name < 01_create_tables.sql

# 2. 创建索引
mysql -u username -p database_name < 02_create_indexes.sql

# 3. 创建存储过程
mysql -u username -p database_name < 03_create_stored_procedures.sql

# 4. 创建触发器
mysql -u username -p database_name < 04_create_triggers.sql

# 可选：插入测试数据
mysql -u username -p database_name < 05_insert_test_data_simple.sql
```

---

### ⭐ 推荐配置（6个脚本）

```bash
# 核心脚本
mysql -u username -p database_name < 01_create_tables.sql
mysql -u username -p database_name < 02_create_indexes.sql
mysql -u username -p database_name < 03_create_stored_procedures.sql
mysql -u username -p database_name < 04_create_triggers.sql

# 优化脚本（强烈推荐）
mysql -u username -p database_name < 02_advanced_indexes.sql
mysql -u username -p database_name < 09_create_views.sql

# 可选：测试数据
mysql -u username -p database_name < 05_insert_test_data_simple.sql
```

---

### 🚀 完整配置（生产环境）

```bash
# 核心脚本
mysql -u username -p database_name < 01_create_tables.sql
mysql -u username -p database_name < 02_create_indexes.sql
mysql -u username -p database_name < 03_create_stored_procedures.sql
mysql -u username -p database_name < 04_create_triggers.sql

# 优化脚本
mysql -u username -p database_name < 02_advanced_indexes.sql
mysql -u username -p database_name < 09_create_views.sql

# 高级功能（生产环境推荐）
mysql -u username -p database_name < 10_audit_logging.sql
mysql -u username -p database_name < 11_data_cleanup.sql
mysql -u username -p database_name < 12_backup_restore.sql
```

---

## 📝 脚本详情

### 🔴 核心脚本（必须）

| 脚本 | 用途 | 重要性 | 执行时机 |
|------|------|--------|----------|
| **01_create_tables.sql** | 创建8个核心数据表 | ⭐⭐⭐⭐⭐ | 第一个执行 |
| **02_create_indexes.sql** | 创建基础索引 | ⭐⭐⭐⭐⭐ | 表创建后 |
| **03_create_stored_procedures.sql** | 创建业务逻辑存储过程 | ⭐⭐⭐⭐⭐ | 索引创建后 |
| **04_create_triggers.sql** | 创建自动化触发器 | ⭐⭐⭐⭐⭐ | 存储过程后 |

---

### 🟡 重要脚本（推荐）

| 脚本 | 用途 | 重要性 | 执行时机 |
|------|------|--------|----------|
| **02_advanced_indexes.sql** | 创建高级性能索引 | ⭐⭐⭐⭐ | 基础索引后 |
| **09_create_views.sql** | 创建8个业务视图 | ⭐⭐⭐⭐ | 触发器后 |

---

### 🟢 可选脚本

| 脚本 | 用途 | 重要性 | 执行时机 |
|------|------|--------|----------|
| **05_insert_test_data_simple.sql** | 插入测试数据 | ⭐⭐ | 开发/测试时 |
| **07_populate_hashtags.sql** | 手动关联话题 | ⭐ | 需要话题数据时 |
| **08_populate_sentiments.sql** | 手动填充情感分析 | ⭐ | 需要情感数据时 |
| **06_complex_queries.sql** | 复杂查询示例 | ⭐ | 参考用 |

---

### 🛠️ 维护脚本

| 脚本 | 用途 | 重要性 | 执行时机 |
|------|------|--------|----------|
| **10_audit_logging.sql** | 审计日志系统 | ⭐⭐⭐ | 生产环境 |
| **11_data_cleanup.sql** | 数据清理存储过程 | ⭐⭐⭐ | 定期维护 |
| **12_backup_restore.sql** | 备份恢复功能 | ⭐⭐⭐ | 定期备份 |
| **00_cleanup_incorrect_objects.sql** | 清理错误的数据库对象 | ⭐⭐ | 修复问题时 |

---

## ⚙️ 使用说明

### 在DAS中执行

1. 登录DAS (https://das.huaweicloud.com)
2. 选择数据库实例 (gauss-7a55)
3. 创建数据库（如果不存在）：
   ```sql
   CREATE DATABASE social_media CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
   ```
4. 逐个执行脚本（在SQL窗口中复制粘贴）

### 验证执行结果

```sql
-- 检查表
SHOW TABLES;

-- 检查存储过程
SHOW PROCEDURE STATUS WHERE Db = 'social_media';

-- 检查触发器
SHOW TRIGGERS;

-- 检查数据
SELECT COUNT(*) FROM Users;
SELECT COUNT(*) FROM Posts;
```

---

## 📊 执行时间估算

| 脚本组合 | 执行时间 | 说明 |
|----------|----------|------|
| 仅核心脚本（01-04） | 2-3分钟 | 最小配置 |
| 核心+优化（01-04+02高级+09） | 4-5分钟 | 推荐配置 |
| 完整配置（全部） | 8-10分钟 | 生产环境 |

---

## ⚠️ 注意事项

1. **执行顺序**：必须按编号顺序执行（01→02→03→04→...）
2. **权限要求**：需要CREATE、ALTER、TRIGGER等权限
3. **兼容性**：MySQL 8.0+ 或 TaurusDB
4. **错误处理**：如果遇到错误，先检查权限和表结构

---

## 🗑️ 错误处理

如果执行过程中遇到错误：

### 触发器创建失败
```sql
-- 先清理错误的触发器
mysql -u username -p database_name < 00_cleanup_incorrect_objects.sql

-- 重新执行
mysql -u username -p database_name < 04_create_triggers.sql
```

### 存储过程创建失败
```sql
-- 重新执行存储过程脚本
mysql -u username -p database_name < 03_create_stored_procedures.sql
```

### 表已存在错误
```sql
-- 删除现有表（仅限开发环境）
DROP TABLE IF EXISTS Post_Sentiments, Alerts, Keywords, Post_Hashtags, Hashtags, Comments, Posts, Users;
```

---

## 📞 支持

如果遇到问题：
1. 查看 `../docs/sql-scripts-fix-summary.md` 了解历史问题
2. 检查数据库版本兼容性
3. 验证用户权限

---

## 🎯 最佳实践

### 开发环境
```
执行：01-04 + 02高级 + 09 + 05
理由：性能优化 + 简化开发 + 有数据演示
```

### 测试环境
```
执行：01-04 + 02高级 + 09
理由：标准配置，完整功能
```

### 生产环境
```
执行：01-04 + 02高级 + 09 + 10 + 11 + 12
理由：完整功能 + 安全 + 维护 + 备份
```

---

**所有脚本已修正并测试，可安全使用！** 🎉
