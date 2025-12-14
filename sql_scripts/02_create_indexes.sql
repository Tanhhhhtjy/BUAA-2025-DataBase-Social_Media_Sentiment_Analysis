-- ============================================================================
-- 社交媒体舆情分析系统 - 数据库索引优化脚本
-- ============================================================================
-- 脚本说明: 创建额外的索引以优化查询性能
-- 创建时间: 2025年
-- ============================================================================

-- ============================================================================
-- 1. Users表 - 用户查询优化
-- ============================================================================
-- 这些索引已在建表脚本中创建，这里仅作备注
-- INDEX idx_username (Username) - 用户名快速查询
-- INDEX idx_email (Email) - 邮箱快速查询

-- ============================================================================
-- 2. Posts表 - 帖子查询优化
-- ============================================================================

-- 复合索引：用于热点话题查询（按创建时间和用户分组）
CREATE INDEX idx_posts_created_user ON Posts(CreatedAt DESC, UserID);

-- 复合索引：用于用户的所有帖子查询
CREATE INDEX idx_posts_user_created ON Posts(UserID, CreatedAt DESC);

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
-- INDEX idx_post_id (PostID) - 按帖子查询标签
-- INDEX idx_hashtag_id (HashtagID) - 按标签查询帖子

-- 复合索引：用于热点话题的聚合查询
CREATE INDEX idx_post_hashtags_hashtag_post ON Post_Hashtags(HashtagID, PostID);

-- ============================================================================
-- 5. Post_Sentiments表 - 情感关联查询优化
-- ============================================================================
-- 这些索引已在建表脚本中创建
-- INDEX idx_post_id (PostID)
-- INDEX idx_sentiment_id (SentimentID)
-- INDEX idx_score (Score)

-- 复合索引：用于情感趋势分析（按时间和情感分组）
CREATE INDEX idx_post_sentiments_created_sentiment ON Post_Sentiments(CreatedAt DESC, SentimentID);

-- ============================================================================
-- 6. 跨表关联查询优化 - 外键字段索引确认
-- ============================================================================
-- 外键字段已在建表时创建索引，以下是确认：
-- Comments.PostID, Comments.UserID 已索引
-- Posts.UserID 已索引
-- Post_Hashtags.PostID, Post_Hashtags.HashtagID 已索引
-- Post_Sentiments.PostID, Post_Sentiments.SentimentID 已索引

-- ============================================================================
-- 7. 复杂查询优化索引
-- ============================================================================

-- 为热点话题查询优化 - 用户创建时间段聚合
-- SELECT h.HashtagName, COUNT(*) FROM Hashtags h
-- JOIN Post_Hashtags ph ON h.HashtagID = ph.HashtagID
-- JOIN Posts p ON ph.PostID = p.PostID
-- WHERE p.CreatedAt >= DATE_SUB(NOW(), INTERVAL 7 DAY)
-- 需要索引：Posts(CreatedAt), Post_Hashtags(PostID, HashtagID)
-- 已在上面创建

-- 为舆情趋势分析优化
-- SELECT DATE(p.CreatedAt), s.Label, COUNT(*)
-- FROM Posts p
-- JOIN Post_Sentiments ps ON p.PostID = ps.PostID
-- JOIN Sentiments s ON ps.SentimentID = s.SentimentID
-- WHERE p.CreatedAt >= DATE_SUB(NOW(), INTERVAL 30 DAY)
-- GROUP BY DATE(p.CreatedAt), s.Label
-- 需要索引：Posts(CreatedAt), Post_Sentiments(PostID, SentimentID)
-- 已在上面创建

-- ============================================================================
-- 索引创建完成
-- ============================================================================
-- 索引总结：
-- 1. Users表：username, email索引 - 用于用户登录/查询
-- 2. Posts表：user_id, created_at索引 - 用于帖子列表、用户帖子、时间范围查询
-- 3. Comments表：post_id, user_id, created_at索引 - 用于评论列表、统计
-- 4. Hashtags表：hashtag_name索引 - 用于标签查询
-- 5. Post_Hashtags表：post_id, hashtag_id, 复合索引 - 用于关联查询
-- 6. Sentiments表：label索引 - 用于快速查询
-- 7. Post_Sentiments表：post_id, sentiment_id, created_at, score索引 - 用于情感分析
-- 8. Keywords表：keyword, category索引 - 用于关键词预警
--
-- 复合索引优化：
-- - idx_posts_created_user: 用于按时间范围、按用户的帖子查询
-- - idx_comments_post_created: 用于帖子的评论统计
-- - idx_post_hashtags_hashtag_post: 用于热点话题的聚合
-- - idx_post_sentiments_created_sentiment: 用于按时间的情感分布查询
--
-- 注意：这些索引已根据设计的4个复杂查询场景进行优化
-- ============================================================================
