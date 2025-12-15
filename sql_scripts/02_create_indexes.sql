-- ============================================================================
-- 社交媒体舆情分析系统 - 数据库索引优化脚本
-- ============================================================================
-- 脚本说明: 创建额外的索引以优化查询性能
-- 创建时间: 2025年
-- 备注: 已更新以匹配设计文档 v1.0.0
-- ============================================================================

-- ============================================================================
-- 1. users表 - 用户查询优化
-- ============================================================================
-- 这些索引已在建表脚本中创建，这里仅作备注
-- INDEX idx_username (username) - 用户名快速查询
-- INDEX idx_email (email) - 邮箱快速查询
-- INDEX idx_status (status) - 按状态查询用户

-- ============================================================================
-- 2. posts表 - 帖子查询优化
-- ============================================================================

-- 复合索引：用于热点话题查询（按创建时间和用户分组）
CREATE INDEX idx_posts_created_user ON posts(created_at DESC, user_id);

-- 复合索引：用于用户的所有帖子查询
-- 注意：这个索引已在建表时创建，这里仅作备注
-- INDEX idx_user_created (user_id, created_at DESC)

-- ============================================================================
-- 3. comments表 - 评论查询优化
-- ============================================================================

-- 复合索引：用于获取帖子的所有评论
CREATE INDEX idx_comments_post_created ON comments(post_id, created_at DESC);

-- 复合索引：用于获取用户的所有评论
CREATE INDEX idx_comments_user_created ON comments(user_id, created_at DESC);

-- ============================================================================
-- 4. post_hashtags表 - 标签关联查询优化
-- ============================================================================
-- 这些索引已在建表脚本中创建，这里仅作备注
-- PRIMARY KEY (post_id, hashtag_id) - 复合主键
-- INDEX idx_hashtag_id (hashtag_id) - 按标签查询帖子

-- 复合索引：用于热点话题的聚合查询
CREATE INDEX idx_post_hashtags_hashtag_post ON post_hashtags(hashtag_id, post_id);

-- ============================================================================
-- 5. post_sentiments表 - 情感查询优化
-- ============================================================================
-- 这些索引已在建表脚本中创建
-- INDEX idx_sentiment (sentiment) - 按情感类型查询
-- INDEX idx_analyzed_at (analyzed_at) - 按分析时间查询

-- 复合索引：用于情感趋势分析（按时间和情感分组）
CREATE INDEX idx_post_sentiments_analyzed_sentiment ON post_sentiments(analyzed_at DESC, sentiment);

-- ============================================================================
-- 6. keywords表 - 关键词查询优化
-- ============================================================================
-- 这些索引已在建表脚本中创建
-- UNIQUE KEY unique_keyword_category (Keyword, Category) - 复合唯一索引
-- INDEX idx_category (Category) - 按类别查询

-- ============================================================================
-- 7. alerts表 - 预警查询优化
-- ============================================================================
-- 这些索引已在建表脚本中创建
-- INDEX idx_created_at (created_at DESC) - 按时间倒序查询预警
-- INDEX idx_keyword_id (keyword_id) - 按关键词查询预警

-- ============================================================================
-- 8. 跨表关联查询优化 - 外键字段索引确认
-- ============================================================================
-- 外键字段已在建表时创建索引，以下是确认：
-- comments.post_id, comments.user_id 已索引
-- posts.user_id 已索引
-- post_hashtags.post_id, post_hashtags.hashtag_id 已索引
-- post_sentiments.post_id 已索引
-- alerts.keyword_id 已索引

-- ============================================================================
-- 9. 复杂查询优化索引
-- ============================================================================

-- 为热点话题查询优化
-- SELECT h.tag_name, COUNT(*) FROM hashtags h
-- JOIN post_hashtags ph ON h.hashtag_id = ph.hashtag_id
-- JOIN posts p ON ph.post_id = p.post_id
-- WHERE p.created_at >= DATE_SUB(NOW(), INTERVAL 7 DAY)
-- 需要索引：posts(created_at), post_hashtags(hashtag_id, post_id)
-- 已创建：idx_posts_created_user, idx_post_hashtags_hashtag_post

-- 为舆情趋势分析优化
-- SELECT DATE(p.created_at), ps.sentiment, COUNT(*)
-- FROM posts p
-- JOIN post_sentiments ps ON p.post_id = ps.post_id
-- WHERE p.created_at >= DATE_SUB(NOW(), INTERVAL 30 DAY)
-- GROUP BY DATE(p.created_at), ps.sentiment
-- 需要索引：posts(created_at), post_sentiments(post_id, sentiment)
-- 已创建：idx_posts_created_user, idx_post_sentiments_analyzed_sentiment

-- 为关键词预警查询优化
-- SELECT * FROM alerts a
-- JOIN keywords k ON a.keyword_id = k.keyword_id
-- WHERE a.created_at >= DATE_SUB(NOW(), INTERVAL 24 HOUR)
-- 需要索引：alerts(created_at), keywords(keyword_id, category)
-- 已创建：idx_created_at, unique_keyword_category

-- ============================================================================
-- 索引创建完成
-- ============================================================================
-- 索引总结：
-- 1. users表：username, email, status索引 - 用于用户登录/查询/筛选
-- 2. posts表：user_id, created_at, 复合索引 - 用于帖子列表、用户帖子、时间范围查询
-- 3. comments表：post_id, user_id, created_at, 复合索引 - 用于评论列表、统计
-- 4. hashtags表：hashtag_name索引 - 用于标签查询
-- 5. post_hashtags表：post_id, hashtag_id, 复合索引 - 用于关联查询
-- 6. post_sentiments表：sentiment, analyzed_at, 复合索引 - 用于情感分析查询
-- 7. keywords表：keyword+category 复合唯一索引, category索引 - 用于关键词预警
-- 8. alerts表：created_at, keyword_id索引 - 用于预警查询
--
-- 复合索引优化：
-- - idx_posts_created_user: 用于按时间范围、按用户的帖子查询
-- - idx_comments_post_created: 用于帖子的评论统计
-- - idx_comments_user_created: 用于用户的评论统计
-- - idx_post_hashtags_hashtag_post: 用于热点话题的聚合
-- - idx_post_sentiments_analyzed_sentiment: 用于按时间的情感分布查询
--
-- 特别注意：
-- - post_sentiments表采用直接存储模式，索引直接基于sentiment字段
-- - 新增alerts表的专用索引用于预警功能
-- - 所有索引已根据设计的4个复杂查询场景进行优化
-- ============================================================================
