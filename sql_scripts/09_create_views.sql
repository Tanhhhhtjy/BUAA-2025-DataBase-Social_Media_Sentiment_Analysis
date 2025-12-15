-- ============================================================================
-- 社交媒体舆情分析系统 - 数据库视图脚本
-- ============================================================================
-- 脚本说明: 创建复杂查询视图，简化常用数据查询
-- 创建时间: 2025年
-- 备注: Phase 14 数据库视图优化
-- ============================================================================

-- ============================================================================
-- 1. 用户帖子统计视图
-- ============================================================================
-- 用于快速查看用户的帖子数量、评论数量、活跃度等信息

CREATE VIEW v_user_stats AS
SELECT
    u.user_id,
    u.username,
    u.email,
    u.status,
    u.role,
    u.created_at as user_created_at,
    COUNT(DISTINCT p.post_id) as post_count,
    COUNT(DISTINCT c.comment_id) as comment_count,
    COUNT(DISTINCT ps.post_id) as analyzed_post_count,
    COALESCE(AVG(CASE WHEN ps.sentiment = 'POSITIVE' THEN 1 WHEN ps.sentiment = 'NEGATIVE' THEN -1 ELSE 0 END), 0) as avg_sentiment_score
FROM
    users u
    LEFT JOIN posts p ON u.user_id = p.user_id
    LEFT JOIN comments c ON u.user_id = c.user_id
    LEFT JOIN post_sentiments ps ON p.post_id = ps.post_id
WHERE
    1=1
GROUP BY
    u.user_id, u.username, u.email, u.status, u.role, u.created_at;

-- ============================================================================
-- 2. 热门话题统计视图
-- ============================================================================
-- 用于快速查看话题的帖子数量、评论数量、热度值等信息

CREATE VIEW v_hashtag_stats AS
SELECT
    h.hashtag_id,
    h.tag_name,
    h.created_at as hashtag_created_at,
    COUNT(DISTINCT ph.post_id) as post_count,
    COUNT(DISTINCT c.comment_id) as comment_count,
    (COUNT(DISTINCT ph.post_id) * 0.7 + COUNT(DISTINCT c.comment_id) * 0.3) as heat_score,
    COUNT(DISTINCT CASE WHEN ps.sentiment = 'POSITIVE' THEN ph.post_id END) as positive_posts,
    COUNT(DISTINCT CASE WHEN ps.sentiment = 'NEGATIVE' THEN ph.post_id END) as negative_posts,
    COUNT(DISTINCT CASE WHEN ps.sentiment = 'NEUTRAL' THEN ph.post_id END) as neutral_posts
FROM
    hashtags h
    JOIN post_hashtags ph ON h.hashtag_id = ph.hashtag_id
    JOIN posts p ON ph.post_id = p.post_id
    LEFT JOIN comments c ON p.post_id = c.post_id
    LEFT JOIN post_sentiments ps ON p.post_id = ps.post_id
WHERE
    1=1
GROUP BY
    h.hashtag_id, h.tag_name, h.created_at;

-- ============================================================================
-- 3. 舆情趋势统计视图
-- ============================================================================
-- 用于查看每日/每周的情感分布统计

CREATE VIEW v_sentiment_trend AS
SELECT
    DATE(p.created_at) as trend_date,
    ps.sentiment,
    COUNT(DISTINCT p.post_id) as post_count,
    COUNT(DISTINCT c.comment_id) as comment_count,
    ROUND(COUNT(DISTINCT p.post_id) * 100.0 / SUM(COUNT(DISTINCT p.post_id)) OVER (PARTITION BY DATE(p.created_at)), 2) as sentiment_percentage
FROM
    posts p
    JOIN post_sentiments ps ON p.post_id = ps.post_id
    LEFT JOIN comments c ON p.post_id = c.post_id
WHERE
    1=1
GROUP BY
    DATE(p.created_at), ps.sentiment
ORDER BY
    trend_date DESC, ps.sentiment;

-- ============================================================================
-- 4. 预警统计视图
-- ============================================================================
-- 用于快速查看关键词预警情况

CREATE VIEW v_alert_stats AS
SELECT
    a.alert_id,
    a.content_type,
    a.summary,
    k.keyword,
    k.category,
    u.username,
    a.created_at as alert_time
FROM
    alerts a
    JOIN keywords k ON a.keyword_id = k.keyword_id
    LEFT JOIN posts p ON a.content_type = 'POST' AND a.content_id = p.post_id
    LEFT JOIN comments c ON a.content_type = 'COMMENT' AND c.comment_id = a.content_id
    LEFT JOIN users u ON u.user_id = COALESCE(p.user_id, c.user_id)
ORDER BY
    a.created_at DESC;

-- ============================================================================
-- 5. 管理员仪表板视图
-- ============================================================================
-- 用于管理员快速查看系统整体情况

CREATE VIEW v_admin_dashboard AS
SELECT
    -- 用户统计
    (SELECT COUNT(*) FROM users WHERE status = 'ACTIVE') as active_users,
    (SELECT COUNT(*) FROM users WHERE status = 'DISABLED') as disabled_users,
    (SELECT COUNT(*) FROM users WHERE role = 'ADMIN') as admin_count,

    -- 内容统计
    (SELECT COUNT(*) FROM posts) as active_posts,
    (SELECT COUNT(*) FROM posts WHERE DATE(created_at) = CURDATE()) as posts_today,

    -- 评论统计
    (SELECT COUNT(*) FROM comments) as active_comments,
    (SELECT COUNT(*) FROM comments WHERE DATE(created_at) = CURDATE()) as comments_today,

    -- 情感分析统计
    (SELECT COUNT(*) FROM post_sentiments WHERE sentiment = 'POSITIVE') as positive_posts,
    (SELECT COUNT(*) FROM post_sentiments WHERE sentiment = 'NEGATIVE') as negative_posts,
    (SELECT COUNT(*) FROM post_sentiments WHERE sentiment = 'NEUTRAL') as neutral_posts,

    -- 预警统计
    (SELECT COUNT(*) FROM alerts WHERE DATE(created_at) = CURDATE()) as alerts_today,
    (SELECT COUNT(*) FROM alerts WHERE created_at >= DATE_SUB(NOW(), INTERVAL 24 HOUR)) as alerts_last_24h,

    -- 话题统计
    (SELECT COUNT(*) FROM hashtags) as total_hashtags,
    (SELECT COUNT(DISTINCT hashtag_id) FROM post_hashtags WHERE post_id IN (SELECT post_id FROM posts WHERE created_at >= DATE_SUB(NOW(), INTERVAL 7 DAY))) as active_hashtags_this_week;

-- ============================================================================
-- 6. 用户活跃度视图
-- ============================================================================
-- 用于查看用户活跃度排行

CREATE VIEW v_user_activity AS
SELECT
    u.user_id,
    u.username,
    u.status,
    u.created_at as join_date,
    COUNT(DISTINCT p.post_id) as posts_last_7_days,
    COUNT(DISTINCT c.comment_id) as comments_last_7_days,
    (COUNT(DISTINCT p.post_id) + COUNT(DISTINCT c.comment_id)) as total_activity_last_7_days,
    (SELECT COUNT(*) FROM posts WHERE user_id = u.user_id) as total_posts,
    (SELECT COUNT(*) FROM comments WHERE user_id = u.user_id) as total_comments
FROM
    users u
    LEFT JOIN posts p ON u.user_id = p.user_id AND p.created_at >= DATE_SUB(NOW(), INTERVAL 7 DAY)
    LEFT JOIN comments c ON u.user_id = c.user_id AND c.created_at >= DATE_SUB(NOW(), INTERVAL 7 DAY)
WHERE
    u.status = 'ACTIVE'
GROUP BY
    u.user_id, u.username, u.status, u.created_at
ORDER BY
    total_activity_last_7_days DESC;

-- ============================================================================
-- 7. 关键词热度视图
-- ============================================================================
-- 用于查看关键词被触发的次数和类别分布

CREATE VIEW v_keyword_stats AS
SELECT
    k.keyword_id,
    k.keyword,
    k.category,
    k.created_at as keyword_created_at,
    COUNT(DISTINCT a.alert_id) as alert_count,
    COUNT(DISTINCT CASE WHEN a.content_type = 'POST' THEN a.alert_id END) as post_alerts,
    COUNT(DISTINCT CASE WHEN a.content_type = 'COMMENT' THEN a.alert_id END) as comment_alerts,
    COUNT(DISTINCT CASE WHEN a.created_at >= DATE_SUB(NOW(), INTERVAL 24 HOUR) THEN a.alert_id END) as alerts_last_24h,
    COUNT(DISTINCT CASE WHEN a.created_at >= DATE_SUB(NOW(), INTERVAL 7 DAY) THEN a.alert_id END) as alerts_last_7_days
FROM
    keywords k
    LEFT JOIN alerts a ON k.keyword_id = a.keyword_id
GROUP BY
    k.keyword_id, k.keyword, k.category, k.created_at
ORDER BY
    AlertCount DESC;

-- ============================================================================
-- 8. 帖子详情扩展视图
-- ============================================================================
-- 用于查看帖子的完整信息，包括作者、标签、情感、评论数等

CREATE VIEW v_post_details AS
SELECT
    p.post_id,
    p.content,
    p.created_at,
    u.username as author,
    u.user_id as author_id,
    GROUP_CONCAT(DISTINCT h.tag_name ORDER BY h.tag_name SEPARATOR ', ') as hashtags,
    ps.sentiment,
    ps.confidence,
    ps.analyzed_at,
    COUNT(DISTINCT c.comment_id) as comment_count
FROM
    posts p
    JOIN users u ON p.user_id = u.user_id
    LEFT JOIN post_hashtags ph ON p.post_id = ph.post_id
    LEFT JOIN hashtags h ON ph.hashtag_id = h.hashtag_id
    LEFT JOIN post_sentiments ps ON p.post_id = ps.post_id
    LEFT JOIN comments c ON p.post_id = c.post_id
WHERE
    1=1
GROUP BY
    p.post_id, p.content, p.created_at, u.username, u.user_id, ps.sentiment, ps.confidence, ps.analyzed_at
ORDER BY
    p.created_at DESC;

-- ============================================================================
-- 视图创建完成
-- ============================================================================
-- 视图使用说明：
-- 1. v_user_stats - 查看用户统计信息，可用于用户排行、活跃度分析
-- 2. v_hashtag_stats - 查看话题热度排行，用于热点话题展示
-- 3. v_sentiment_trend - 查看舆情趋势，用于趋势图表展示
-- 4. v_alert_stats - 查看预警列表，用于预警管理
-- 5. v_admin_dashboard - 查看系统整体情况，用于管理员仪表板
-- 6. v_user_activity - 查看用户活跃度，用于用户分析
-- 7. v_keyword_stats - 查看关键词统计，用于关键词管理
-- 8. v_post_details - 查看帖子详情，用于帖子列表展示
--
-- 注意事项：
-- - 视图是虚拟表，不存储实际数据，每次查询都会执行底层SQL
-- - 复杂视图可能会影响查询性能，建议在关键场景使用索引优化
-- - 可以为视图创建索引来优化性能（MySQL 8.0+支持）
-- - 定期检查视图的使用情况，优化不必要的视图
-- ============================================================================
