# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

---

# 社交媒体舆情分析系统 - 开发指南

## 项目概述

本项目是一个社交媒体舆情分析系统，重点在于后端数据存储与处理的核心实现。系统使用华为云数据库 **GaussDB(for MySQL)** 作为数据库管理系统，实现社交媒体数据的高效管理和舆情分析功能。

### 核心功能
- 用户、帖子、评论数据管理
- 话题标签和关键词追踪
- 情感倾向分析
- 热点话题看板
- 舆情趋势分析
- 情感分布分析
- 关键词预警查询

## 项目分工

**团队成员：**
- 同学A（刘琛琛）：系统功能设计与部分数据库操作实现（50%）
- 同学B（田锦煜）：系统数据库设计与部分数据库操作实现（50%）

## 数据库架构

### 核心实体（8个）
1. **Users** - 用户表
2. **Posts** - 帖子/文章表
3. **Comments** - 评论表
4. **Hashtags** - 话题标签表
5. **Post_Hashtags** - 帖子-标签关联表（M:N）
6. **Keywords** - 关键词表
7. **Sentiments** - 情感倾向表
8. **Post_Sentiments** - 帖子情感记录表（M:N）

### 核心关系
- Users 1:N Posts（发布关系）
- Users 1:N Comments（发表关系）
- Posts 1:N Comments（拥有关系）
- Posts M:N Hashtags（标记关系，通过Post_Hashtags）
- Posts M:N Sentiments（具有关系，通过Post_Sentiments）

## 数据库环境

**平台：** 华为云 GaussDB(for MySQL)
**版本：** GaussDB(for MySQL) 服务
**配置：** 4核 | 16GB

**访问工具：**
- IAM（Identity and Access Management）- 身份认证
- DAS（Data Admin Service）- 数据库管理服务（可视化客户端，无需安装本地客户端）

### 连接信息
- **IAM登录地址：** https://auth.huaweicloud.com/authui/login?id=beihangdb
- **租户名：** beihangdb
- **DAS实例：** gauss-7a55（具体以教师提供的实例为准）

**注意：** 学生用户无创建数据库和修改实例配置的权限，只能进行数据库基本操作（建表、增删查改、创建视图、创建索引、创建存储过程和触发器）。

## 开发任务清单

### 第一部分：数据库设计（系统功能设计）

**负责人：同学A**

1. **需求分析** - 明确系统需求和业务规则
2. **系统功能设计** - 绘制数据流图，定义功能模块
3. **系统设计报告** - 撰写【需求分析】和【系统功能设计】部分

**复杂查询功能实现：**
- 热点话题看板查询
- 舆情趋势分析查询
- 情感分布分析查询
- 关键词预警查询

### 第二部分：数据库实现（系统数据库设计）

**负责人：同学B**

1. **概念设计** - 绘制完整的E-R图
2. **逻辑设计** - 设计关系模式，规范化至3NF
3. **物理设计** - 设计索引和存取方法
4. **系统设计报告** - 撰写【数据库概念/逻辑/物理设计】部分

**数据库操作实现：**
- 数据定义（DDL）- 创建表结构
- 数据操作（DML）- INSERT/UPDATE/DELETE操作
- 存储过程 - 情感分析、日报生成等复杂业务逻辑
- 触发器 - 话题提取、级联删除等自动化处理

## 关键技术要求

### 数据库操作规范

1. **使用原生SQL** - 所有数据读写操作必须使用原生SQL语句，不允许使用ORM框架的查询封装（如Django的filter）
2. **高级框架限制** - 如使用Django等框架，仅允许在建表时使用框架提供的接口（如models），其余操作必须用SQL实现
3. **分布式特性体验** - 在DAS中体验读写分离，可在主库执行写操作，备库执行读操作

### 存储过程和触发器

**常见实现场景：**
- **情感分析过程** - 自动分析帖子和评论的情感倾向
- **日报生成过程** - 生成每日舆情统计报告
- **话题提取触发器** - 帖子保存时自动识别和标记话题
- **级联删除触发器** - 用户删除时自动删除相关帖子和评论

### 索引设计

- 对频繁查询的字段建立索引（如用户ID、时间戳）
- 对外键字段建立索引以优化JOIN性能
- 考虑复合索引优化多字段查询

## 实现流程

### 阶段1：系统设计（第8周前完成）
- 完成E-R图设计
- 完成逻辑模式设计和3NF规范化
- 设计物理结构和索引方案

### 阶段2：数据库实现（第12周前完成）
- 在GaussDB中创建所有表结构
- 实现数据操作功能（CRUD）
- 创建存储过程和触发器
- 准备测试数据（至少每个实体3+条记录）

### 阶段3：功能验证（第15周前完成）
- 验证所有查询功能正确性
- 验证触发器和存储过程功能
- 记录操作截图和SQL语句
- 撰写完整的系统设计和实现报告

### 阶段4：系统演示（第16周）
- 演示所有核心功能
- 回答相关技术问题

## 重要提示

1. **数据持久化** - 操作完成后，不要撤销或删除任何操作（建表、视图、存储过程等），留存数据库中的数据将作为查验依据
2. **分库分表** - GaussDB支持128T海量存储，本项目无需分库分表
3. **高可用性** - 可配置1主15只读的高扩展性架构，但本项目主要操作主库即可
4. **截图记录** - 操作截图中必须包含IAM用户名，作为身份验证

## 常见SQL操作示例模式

```sql
-- 创建表时明确约束
CREATE TABLE Users (
    UserID INT PRIMARY KEY AUTO_INCREMENT,
    Username VARCHAR(50) NOT NULL UNIQUE,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_user_role FOREIGN KEY (RoleID) REFERENCES Roles(RoleID)
);

-- 创建索引
CREATE INDEX idx_username ON Users(Username);

-- 创建存储过程
DELIMITER //
CREATE PROCEDURE AnalyzeSentiment(IN post_id INT)
BEGIN
    -- 存储过程实现逻辑
    INSERT INTO Post_Sentiments ...
END //
DELIMITER ;

-- 创建触发器
DELIMITER //
CREATE TRIGGER extract_hashtags
BEFORE INSERT ON Posts
FOR EACH ROW
BEGIN
    -- 触发器实现逻辑
    INSERT INTO Post_Hashtags ...
END //
DELIMITER ;
```

## 报告提交内容清单

### 系统设计报告
- [ ] 需求分析
- [ ] 系统功能设计和数据流图
- [ ] E-R图（初步和基本）
- [ ] 关系模式定义
- [ ] 范式分析和3NF规范化说明
- [ ] 物理设计和索引说明

### 系统实现报告
- [ ] 数据库基本表定义（SQL语句和类型约束表）
- [ ] 触发器和存储过程的实现说明
- [ ] 各功能数据库操作SQL语句及运行结果截图
- [ ] 每位同学的任务总结和体会

### 源代码和数据库
- [ ] 所有SQL操作脚本
- [ ] 数据库备份或导出
- [ ] 项目源代码（如有应用层实现）

## 故障排除

**常见问题：**
- **权限不足** - 确保使用正确的IAM账户和数据库用户登录
- **连接失败** - 检查DAS配置，重新测试连接
- **数据不一致** - 验证约束设置和触发器逻辑
- **性能问题** - 检查索引设计，优化复杂查询
