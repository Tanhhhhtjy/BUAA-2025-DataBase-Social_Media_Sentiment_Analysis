# 社交媒体舆情分析系统 - DAS执行指南

## 概述
本指南说明如何在华为云DAS中依次执行SQL脚本，完成系统数据库的完整构建。

---

## 执行顺序

### 第1步：创建表结构 (01_create_tables.sql)
**目的：** 创建8个核心表及其约束

**表列表：**
- Users (用户表)
- Posts (帖子表)
- Comments (评论表)
- Hashtags (话题标签表)
- Post_Hashtags (帖子-标签关联表)
- Sentiments (情感分类表)
- Post_Sentiments (帖子-情感记录表)
- Keywords (敏感关键词表)

**预期结果：**
- 执行成功，无错误
- 可通过 `SHOW TABLES;` 查看所有表

**验证查询：**
```sql
SHOW TABLES;
```

---

### 第2步：创建索引 (02_create_indexes.sql)
**目的：** 优化查询性能

**创建的索引：**
- `idx_posts_user_id` - Posts表用户ID索引
- `idx_posts_created_at` - Posts表创建时间索引
- `idx_comments_post_id` - Comments表帖子ID索引
- `idx_post_hashtags_post_id` - Post_Hashtags表帖子ID索引
- `idx_post_hashtags_hashtag_id` - Post_Hashtags表话题ID索引
- `idx_post_sentiments_post_id` - Post_Sentiments表帖子ID索引
- `idx_post_sentiments_sentiment_id` - Post_Sentiments表情感ID索引
- 等其他复合索引

**预期结果：**
- 所有索引创建成功

**验证查询：**
```sql
SHOW INDEXES FROM Posts;
SHOW INDEXES FROM Post_Hashtags;
```

---

### 第3步：插入测试数据 (05_insert_test_data_simple.sql)
**目的：** 插入系统运行所需的基础数据

**数据内容：**
- **Sentiments:** 3条数据（正面、中立、负面）
- **Hashtags:** 10条数据（科技、教育、体育、娱乐、健康、社会、政治、经济、环保、文化）
- **Keywords:** 7条敏感关键词（垃圾、骚扰、歧视、暴力、虚假、诈骗、冒充）
- **Users:** 8条用户数据
- **Posts:** 13条帖子数据
- **Comments:** 16条评论数据

**执行注意：**
- 脚本中包含验证查询，可查看插入结果

**预期结果：**
```
用户总数: 8
帖子总数: 13
评论总数: 16
话题总数: 10
关键词总数: 7
情感分类: 3
```

**验证查询：**
```sql
SELECT COUNT(*) AS total_users FROM Users;
SELECT COUNT(*) AS total_posts FROM Posts;
SELECT COUNT(*) AS total_comments FROM Comments;
```

---

### 第4步：填充话题关联数据 (07_populate_hashtags.sql)
**目的：** 自动匹配帖子与话题标签

**原理：**
- 根据帖子内容与话题名称的关键词匹配
- 如果帖子内容包含话题关键词，则建立Post_Hashtags关联

**匹配规则示例：**
- 科技话题：包含"科技"、"AI"、"手机"等词
- 教育话题：包含"教育"、"学习"、"教学"等词
- 体育话题：包含"体育"、"运动"、"赛事"、"运动员"等词
- 娱乐话题：包含"电影"、"音乐"、"歌"、"娱乐"等词
- 健康话题：包含"健康"、"健身"、"锻炼"、"健身房"等词

**预期结果：**
- Post_Hashtags表包含多个帖子-话题关联记录

**验证查询：**
```sql
SELECT COUNT(*) AS total_associations FROM Post_Hashtags;
SELECT p.PostID, p.Content, GROUP_CONCAT(h.HashtagName SEPARATOR ',') AS topics
FROM Posts p
LEFT JOIN Post_Hashtags ph ON p.PostID = ph.PostID
LEFT JOIN Hashtags h ON ph.HashtagID = h.HashtagID
GROUP BY p.PostID
ORDER BY p.PostID;
```

---

### 第5步：填充情感分析数据 (08_populate_sentiments.sql)
**目的：** 自动分析帖子的情感倾向

**分析规则：**

#### 正面情感 (SentimentID=1)
- **判断条件：** 包含"好"、"棒"、"喜欢"、"优秀"、"赞"、"推荐"、"精彩"、"满意"、"不错"等词
- **评分范围：** 0.7-1.0
- **打分规则：**
  - 包含"非常"：0.95分
  - 包含"真的"：0.90分
  - 包含"很"：0.85分
  - 其他：0.75分

#### 负面情感 (SentimentID=3)
- **判断条件：** 包含"差"、"烂"、"讨厌"、"糟糕"、"失望"、"问题"、"下降"、"不及时"、"压力"等词
- **评分范围：** 0.0-0.3
- **打分规则：**
  - 包含"非常"：0.15分
  - 包含"很"：0.20分
  - 其他：0.25分

#### 中立情感 (SentimentID=2)
- **判断条件：** 未被归类为正面或负面的帖子
- **评分：** 0.50分（固定）

**预期结果：**
- Post_Sentiments表包含所有帖子的情感分析记录
- 情感分布大致为：正面若干、中立若干、负面若干

**验证查询：**
```sql
SELECT COUNT(*) AS total_sentiments FROM Post_Sentiments;
SELECT
    s.Label AS sentiment_type,
    COUNT(*) AS count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM Post_Sentiments), 2) AS percentage,
    ROUND(AVG(ps.Score), 2) AS avg_score
FROM Post_Sentiments ps
JOIN Sentiments s ON ps.SentimentID = s.SentimentID
GROUP BY ps.SentimentID, s.Label
ORDER BY count DESC;
```

---

### 第6步：执行复杂查询验证 (06_complex_queries.sql)
**目的：** 验证系统功能并获取分析结果

#### 查询1：热点话题看板
**功能：** 查询过去7天的TOP10热点话题

**热度指数计算公式：**
```
热度指数 = 帖子数 × 0.7 + 评论数 × 0.3
```

**预期结果：** 返回10个热度最高的话题

**示例输出：**
```
话题名称 | 帖子数 | 评论数 | 热度指数 | 最新时间
科技    |  3    |  5    |  3.80   | 2025-01-15
体育    |  2    |  4    |  2.20   | 2025-01-15
...
```

---

#### 查询2：舆情趋势分析
**功能：** 按时间序列显示情感分布趋势（30天）

**预期结果：** 返回每天的帖子数、评论数及各情感类型占比

**示例输出：**
```
统计日期 | 总帖子数 | 正面数量 | 中立数量 | 负面数量 | 正面占比
2025-01-15 |   5    |   2    |   2    |   1    |  40.00%
2025-01-14 |   3    |   1    |   1    |   1    |  33.33%
...
```

---

#### 查询3：情感分布分析
**功能：** 统计全量情感分布百分比

**预期结果：** 返回正面、中立、负面的数量和占比

**示例输出：**
```
情感类型 | 数量 | 占比    | 平均评分
正面    |  6   | 46.15% | 0.85
中立    |  4   | 30.77% | 0.50
负面    |  3   | 23.08% | 0.23
```

---

#### 查询4：关键词预警查询
**功能：** 检测24小时内的敏感关键词

**预期结果：** 返回包含敏感词的帖子和评论

**示例输出：**
```
内容类型 | 内容ID | 发布者 | 触发关键词 | 关键词分类 | 发布时间
帖子    | 1    | 用户A | 垃圾     | 不当言论  | 2025-01-15
评论    | 5    | 用户B | 骚扰     | 有害内容  | 2025-01-15
...
```

---

#### 查询5：用户活跃度排行
**功能：** 按发布和评论活跃度排序用户

**预期结果：** 返回用户的帖子数、评论数和活跃度

**示例输出：**
```
用户名 | 用户状态 | 帖子数 | 评论数 | 活跃度 | 最后活动时间
用户A  | active  | 3    | 4    | 7     | 2025-01-15
用户B  | active  | 2    | 5    | 7     | 2025-01-15
...
```

---

#### 查询6：话题热度对比
**功能：** 按多维度比较话题热度

**预期结果：** 返回话题的多维度热度数据

**示例输出：**
```
话题名称 | 帖子数 | 评论数 | 参与用户数 | 平均情感评分 | 首次出现 | 最近更新
科技    | 3     | 5     | 4        | 0.75        | 2025-01-10 | 2025-01-15
...
```

---

#### 查询7：敏感信息统计
**功能：** 统计包含敏感关键词的内容频率

**预期结果：** 返回各敏感词的出现次数

**示例输出：**
```
敏感关键词 | 分类      | 24小时帖子数 | 24小时评论数 | 总出现次数
垃圾     | 不当言论  | 1         | 0           | 1
骚扰     | 有害内容  | 0         | 1           | 1
...
```

---

## 常见问题与解决方案

### Q1: 查询返回0行数据
**可能原因：** Post_Hashtags或Post_Sentiments表为空

**解决方案：**
1. 检查07_populate_hashtags.sql是否执行成功
2. 检查08_populate_sentiments.sql是否执行成功
3. 使用验证查询检查数据是否插入

```sql
-- 检查Post_Hashtags数据
SELECT COUNT(*) FROM Post_Hashtags;

-- 检查Post_Sentiments数据
SELECT COUNT(*) FROM Post_Sentiments;
```

---

### Q2: 情感分析数据不符合预期
**可能原因：** 帖子内容不包含分析规则中的关键词

**解决方案：**
- 检查测试数据中帖子的实际内容
- 修改08_populate_sentiments.sql中的关键词规则
- 重新执行填充脚本

---

### Q3: 复杂查询返回的结果为空或不完整
**可能原因：** 数据关联不完整或时间范围问题

**解决方案：**
1. 检查Posts表的CreatedAt字段是否为当前时间附近
2. 确认Post_Hashtags和Post_Sentiments的关联是否完整
3. 使用如下查询诊断：

```sql
-- 检查数据完整性
SELECT '用户总数' AS 检查项, COUNT(*) AS 数量 FROM Users
UNION ALL
SELECT '帖子总数', COUNT(*) FROM Posts
UNION ALL
SELECT '评论总数', COUNT(*) FROM Comments
UNION ALL
SELECT '话题关联总数', COUNT(*) FROM Post_Hashtags
UNION ALL
SELECT '情感记录总数', COUNT(*) FROM Post_Sentiments;
```

---

## 总结

完成以上6个步骤后，系统即可运行。数据流如下：

```
基础数据（Step 1-3）
    ↓
表结构 + 索引 + 基础数据
    ↓
话题关联 (Step 4)
    ↓
Post_Hashtags表有数据
    ↓
情感分析 (Step 5)
    ↓
Post_Sentiments表有数据
    ↓
复杂查询 (Step 6)
    ↓
得到完整的分析结果
```

---

## 后续步骤

数据库功能完成后，可以：
1. 将测试结果保存为截图或导出为CSV
2. 进行Django应用开发（使用本地MySQL模拟）
3. 构建舆情分析看板前端
4. 准备系统演示和总结报告
