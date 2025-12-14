# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

---

# 社交媒体舆情分析系统 - 开发指南

## 项目概述

本项目是一个社交媒体舆情分析系统，面向数据库课程设计场景，重点展示关系数据库建模和手写 SQL 能力。系统采用前后端分离架构，使用华为云 **TaurusDB** 作为数据库，展示关系数据库建模和 SQL 能力。

### 核心功能
- 用户注册、登录与认证（JWT）
- 帖子发布、浏览与分页
- 话题自动提取与管理
- 实时情感分析（AI 大模型）
- 热点话题排行榜
- 舆情趋势分析（折线图）
- 情感分布统计（饼图）
- 关键词预警管理

## 技术架构

### 后端技术栈
- **Java 17**: 主要编程语言
- **Spring Boot 3.x**: Web 应用框架
- **MyBatis**: 数据访问层（强制手写 SQL）
- **Spring AI**: 集成大模型 API 进行情感分析
- **JWT**: 用户认证与授权
- **Spring Validation**: 参数校验
- **HikariCP**: 数据库连接池

### 前端技术栈
- **Vue 3**: 前端框架（Composition API）
- **Vite**: 构建工具
- **Vue Router 4**: 路由管理
- **Pinia**: 状态管理
- **Element Plus**: UI 组件库
- **ECharts**: 数据可视化图表
- **Axios**: HTTP 客户端

### 数据库
- **TaurusDB**: 分布式关系数据库（MySQL 兼容）
- **JDBC**: 数据库连接
- **触发器**: 话题提取、情感分析触发
- **存储过程**: 热点排行、趋势分析

### 部署
- **后端**: Spring Boot 可执行 JAR
- **前端**: Nginx 托管或静态资源
- **数据库**: 华为云 TaurusDB 集群

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

## Git操作规范

本项目使用GitHub进行版本控制和协作跟踪。所有开发者必须遵循以下规范以保证代码质量和团队协作效率。

### 项目仓库

- **仓库地址**: https://github.com/Tanhhhhtjy/BUAA-2025-DataBase-Social_Media_Sentiment_Analysis.git
- **默认分支**: master（主分支）
- **连接方式**: HTTPS（推荐）或SSH

### 分支管理规范

**主要分支：**
- `master` - 主分支，包含稳定的、可发布的代码。每次提交需要经过审查
- `develop` - 开发分支，用于集成功能分支。应保持可运行状态

**功能分支命名规范：**
```
feature/功能名称      # 新功能开发
bugfix/问题名称       # 问题修复
docs/文档名称         # 文档更新
db/数据库功能名称     # 数据库相关修改
```

**示例：**
```
feature/user-sentiment-analysis      # 用户情感分析功能
bugfix/hashtag-extraction             # 话题提取问题修复
db/create-posts-table                 # 创建帖子表
docs/api-documentation                # API文档更新
```

### Commit 提交规范

**格式：**
```
<type>(<scope>): <subject>

<body>

<footer>
```

**Type 类型（必须）：**
- `feat`: 新增功能或数据库特性
- `fix`: 修复问题或SQL逻辑错误
- `docs`: 文档更新或说明
- `style`: 代码格式、注释等（不影响功能）
- `refactor`: 代码重构或SQL优化
- `test`: 测试相关
- `chore`: 依赖更新、构建工具等
- `db`: 数据库相关操作（建表、存储过程、触发器等）

**Scope 作用域（可选但推荐）：**
指定影响的范围，如：users、posts、comments、sentiments等表名或功能模块

**Subject 主题（必须）：**
- 使用祈使句（如 "add" 而不是 "added"）
- 不超过50个字符
- 首字母小写
- 不以句号结尾

**Body 主体（可选但建议）：**
- 对变更的详细描述
- 解释"是什么"和"为什么"，而不是"怎样"
- 每行不超过72个字符

**Footer 页脚（可选）：**
- 关闭相关Issue（如有）：Closes #123
- 破坏性改动说明：BREAKING CHANGE: ...

**Commit 示例：**

```
feat(users): add user sentiment preference table

Add a new table to store user sentiment preferences for better
personalization of recommendation system.

- Create Users_Sentiment_Prefs table with proper constraints
- Add foreign key to Users table
- Create index on UserID for query optimization

Closes #15
```

```
db(posts): optimize post query with composite index

Create a composite index on (CreatedAt, UserID) to improve
performance of trending posts queries.

Performance improvement: 40% faster query execution time
```

```
fix(comments): handle null sentiment values correctly

Fix the issue where NULL sentiment values were causing
exceptions in sentiment analysis trigger.
```

### 日常开发流程

**1. 更新本地仓库：**
```bash
git fetch origin                    # 获取远程最新信息
git pull origin master              # 拉取主分支最新代码
```

**2. 创建功能分支：**
```bash
# 基于master创建功能分支
git checkout -b feature/hashtag-optimization

# 或使用switch命令（Git 2.23+）
git switch -c feature/hashtag-optimization
```

**3. 开发和提交：**
```bash
# 查看改动
git status

# 添加更改
git add <file>              # 添加特定文件
git add .                   # 添加所有更改

# 提交
git commit -m "feat(hashtags): optimize hashtag extraction algorithm"
```

**4. 保持分支最新：**
```bash
# 定期同步主分支
git fetch origin
git rebase origin/master
```

**5. 推送到远程：**
```bash
# 首次推送（创建远程跟踪分支）
git push -u origin feature/hashtag-optimization

# 后续推送
git push origin feature/hashtag-optimization
```

**6. 创建Pull Request：**
- 在GitHub上创建PR，将功能分支合并到develop或master
- 填写详细的PR描述，说明修改内容和为什么需要这些修改
- 等待审核和CI检查通过
- 获得审批后合并PR

**7. 合并和清理：**
```bash
# 合并后删除本地分支
git branch -d feature/hashtag-optimization

# 删除远程分支
git push origin --delete feature/hashtag-optimization
```

### 常用命令快速参考

```bash
# 查看状态和日志
git status                              # 查看当前分支状态
git log --oneline -10                   # 查看最近10次提交
git log --all --graph --decorate        # 查看完整分支图
git diff                                # 查看未暂存的改动
git diff --staged                       # 查看已暂存的改动

# 分支操作
git branch -a                           # 列出所有分支
git branch -D <branch-name>             # 强制删除分支
git checkout <branch-name>              # 切换分支
git merge <branch-name>                 # 合并分支
git rebase <branch-name>                # 变基操作

# 撤销操作
git restore <file>                      # 撤销文件修改
git restore --staged <file>             # 取消暂存
git reset HEAD~1                        # 撤销最后一次提交（保留更改）
git reset --hard HEAD~1                 # 撤销最后一次提交（不保留更改）

# 远程操作
git fetch origin                        # 获取远程更新
git pull origin <branch>                # 拉取并合并
git push origin <branch>                # 推送到远程
```

### 合作规范

**代码审查（Code Review）：**
- 所有提交到master分支的代码必须通过Pull Request审查
- 至少需要一个团队成员的批准
- 审查者应检查：
  - SQL语法和逻辑正确性
  - 遵循命名规范和代码风格
  - 数据库约束的正确性
  - 性能影响
  - 测试覆盖

**冲突解决：**
- 如果出现merge冲突，手动编辑冲突文件
- 标记冲突区域已解决后继续merge
```bash
git add <resolved-file>
git commit -m "merge: resolve conflicts in <description>"
```

**大文件注意事项：**
- 不提交数据库dump文件（除非必要）
- 不提交敏感信息（密码、API密钥等）
- 不提交IDE生成的文件（在.gitignore中已配置）

### 工作量追踪

为了便于评估每个成员的工作量：
- 在commit message中清晰表明做了什么
- 使用有意义的分支名称
- 定期创建commit而不是一次性提交大量代码
- GitHub会自动统计contributors和commit数量

## 故障排除

**常见问题：**
- **权限不足** - 确保使用正确的IAM账户和数据库用户登录
- **连接失败** - 检查DAS配置，重新测试连接
- **数据不一致** - 验证约束设置和触发器逻辑
- **性能问题** - 检查索引设计，优化复杂查询

**Git相关问题：**
- **SSH连接失败** - 改用HTTPS方式：`git remote set-url origin https://github.com/...`
- **无法推送** - 检查权限，确保已设置GitHub凭证
- **Merge冲突** - 手动解决冲突后重新提交
- **提交历史混乱** - 使用rebase整理提交：`git rebase -i HEAD~n`
