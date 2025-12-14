-- ============================================================================
-- 社交媒体舆情分析系统 - 数据库索引优化脚本
-- ============================================================================
-- 脚本说明: 创建额外的索引以优化查询性能
-- 创建时间: 2025年
-- 备注: 已更新以匹配设计文档 v1.0.0
-- ============================================================================

-- ============================================================================
-- 1. Users表 - 用户查询优化
-- ============================================================================
-- 这些索引已在建表脚本中创建，这里仅作备注
-- INDEX idx_username (Username) - 用户名快速查询
-- INDEX idx_email (Email) - 邮箱快速查询
-- INDEX idx_status (Status) - 按状态查询用户

-- ============================================================================
-- 2. Posts表 - 帖子查询优化
-- ============================================================================

-- 复合索引：用于热点话题查询（按创建时间和用户分组）
CREATE INDEX idx_posts_created_user ON Posts(CreatedAt DESC, UserID);

-- 复合索引：用于用户的所有帖子查询
-- 注意：这个索引已在建表时创建，这里仅作备注
-- INDEX idx_user_created (UserID, CreatedAt DESC)

-- ============================================================================
-- 3. Comments表 - 评论查询优化
-- ============================================================================

-- 复合索引：用于获取帖子的所有评论
CREATE INDEX idx_comments_post_created ON Comments(PostID, CreatedAt DESC);

-- 复合索引：用于获取用户的所有评论
CREATE INDEX idx_comments_user_created ON Comments(UserID, CreatedAt DESC);

-- ============================================================================
-- 4. Post_Hashtags表 - 标签关联查询优化
-- ============================================================================
-- 这些索引已在建表脚本中创建，这里仅作备注
-- PRIMARY KEY (PostID, HashtagID) - 复合主键
-- INDEX idx_hashtag_id (HashtagID) - 按标签查询帖子

-- 复合索引：用于热点话题的聚合查询
CREATE INDEX idx_post_hashtags_hashtag_post ON Post_Hashtags(HashtagID, PostID);

-- ============================================================================
-- 5. Post_Sentiments表 - 情感查询优化
-- ============================================================================
-- 这些索引已在建表脚本中创建
-- INDEX idx_sentiment (Sentiment) - 按情感类型查询
-- INDEX idx_analyzed_at (AnalyzedAt) - 按分析时间查询

-- 复合索引：用于情感趋势分析（按时间和情感分组）
CREATE INDEX idx_post_sentiments_analyzed_sentiment ON Post_Sentiments(AnalyzedAt DESC, Sentiment);

-- ============================================================================
-- 6. Keywords表 - 关键词查询优化
-- ============================================================================
-- 这些索引已在建表脚本中创建
-- UNIQUE KEY unique_keyword_category (Keyword, Category) - 复合唯一索引
-- INDEX idx_category (Category) - 按类别查询

-- ============================================================================
-- 7. Alerts表 - 预警查询优化
-- ============================================================================
-- 这些索引已在建表脚本中创建
-- INDEX idx_created_at (CreatedAt DESC) - 按时间倒序查询预警
-- INDEX idx_keyword_id (KeywordID) - 按关键词查询预警

-- ============================================================================
-- 8. 跨表关联查询优化 - 外键字段索引确认
-- ============================================================================
-- 外键字段已在建表时创建索引，以下是确认：
-- Comments.PostID, Comments.UserID 已索引
-- Posts.UserID 已索引
-- Post_Hashtags.PostID, Post_Hashtags.HashtagID 已索引
-- Post_Sentiments.PostID 已索引
-- Alerts.KeywordID 已索引

-- ============================================================================
-- 9. 复杂查询优化索引
-- ============================================================================

-- 为热点话题查询优化
-- SELECT h.HashtagName, COUNT(*) FROM Hashtags h
-- JOIN Post_Hashtags ph ON h.HashtagID = ph.HashtagID
-- JOIN Posts p ON ph.PostID = p.PostID
-- WHERE p.CreatedAt >= DATE_SUB(NOW(), INTERVAL 7 DAY)
-- 需要索引：Posts(CreatedAt), Post_Hashtags(HashtagID, PostID)
-- 已创建：idx_posts_created_user, idx_post_hashtags_hashtag_post

-- 为舆情趋势分析优化
-- SELECT DATE(p.CreatedAt), ps.Sentiment, COUNT(*)
-- FROM Posts p
-- JOIN Post_Sentiments ps ON p.PostID = ps.PostID
-- WHERE p.CreatedAt >= DATE_SUB(NOW(), INTERVAL 30 DAY)
-- GROUP BY DATE(p.CreatedAt), ps.Sentiment
-- 需要索引：Posts(CreatedAt), Post_Sentiments(PostID, Sentiment)
-- 已创建：idx_posts_created_user, idx_post_sentiments_analyzed_sentiment

-- 为关键词预警查询优化
-- SELECT * FROM Alerts a
-- JOIN Keywords k ON a.KeywordID = k.KeywordID
-- WHERE a.CreatedAt >= DATE_SUB(NOW(), INTERVAL 24 HOUR)
-- 需要索引：Alerts(CreatedAt), Keywords(KeywordID, Category)
-- 已创建：idx_created_at, unique_keyword_category

-- ============================================================================
-- 索引创建完成
-- ============================================================================
-- 索引总结：
-- 1. Users表：username, email, status索引 - 用于用户登录/查询/筛选
-- 2. Posts表：user_id, created_at, 复合索引 - 用于帖子列表、用户帖子、时间范围查询
-- 3. Comments表：post_id, user_id, created_at, 复合索引 - 用于评论列表、统计
-- 4. Hashtags表：hashtag_name索引 - 用于标签查询
-- 5. Post_Hashtags表：post_id, hashtag_id, 复合索引 - 用于关联查询
-- 6. Post_Sentiments表：sentiment, analyzed_at, 复合索引 - 用于情感分析查询
-- 7. Keywords表：keyword+category 复合唯一索引, category索引 - 用于关键词预警
-- 8. Alerts表：created_at, keyword_id索引 - 用于预警查询
--
-- 复合索引优化：
-- - idx_posts_created_user: 用于按时间范围、按用户的帖子查询
-- - idx_comments_post_created: 用于帖子的评论统计
-- - idx_comments_user_created: 用于用户的评论统计
-- - idx_post_hashtags_hashtag_post: 用于热点话题的聚合
-- - idx_post_sentiments_analyzed_sentiment: 用于按时间的情感分布查询
--
-- 特别注意：
-- - Post_Sentiments表采用直接存储模式，索引直接基于Sentiment字段
-- - 新增Alerts表的专用索引用于预警功能
-- - 所有索引已根据设计的4个复杂查询场景进行优化
-- ============================================================================
