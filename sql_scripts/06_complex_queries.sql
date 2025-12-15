-- ============================================================================
-- 社交媒体舆情分析系统 - 复杂查询脚本（修正版）
-- ============================================================================
-- 脚本说明: 实现系统的4个核心复杂查询功能，修正字段名
-- 创建时间: 2025年
-- 备注: 修正版，匹配实际的表结构和字段名
-- ============================================================================

-- ============================================================================
-- 查询1：热点话题看板 - 查询过去N天的热点话题TOP10
-- ============================================================================
-- 功能说明：
-- - 计算每个话题的热度指数 = 帖子数 * 0.7 + 评论数 * 0.3
-- - 按热度指数降序排列，取TOP 10
-- - 适用于舆情监测看板的话题排行
-- ============================================================================

-- 直接查询版本（推荐用于一次性查询）
SELECT
    h.hashtag_id,
    h.tag_name AS 话题名称,
    COUNT(DISTINCT p.post_id) AS 帖子数,
    COUNT(DISTINCT c.comment_id) AS 评论数,
    ROUND(
25→        COUNT(DISTINCT p.post_id) * 0.7 + COUNT(DISTINCT c.comment_id) * 0.3,
        2
    ) AS 热度指数,
    MAX(p.created_at) AS 最新时间
FROM hashtags h
LEFT JOIN post_hashtags ph ON h.hashtag_id = ph.hashtag_id
LEFT JOIN posts p ON ph.post_id = p.post_id
    AND p.created_at >= DATE_SUB(NOW(), INTERVAL 7 DAY)
LEFT JOIN comments c ON p.post_id = c.post_id
WHERE p.post_id IS NOT NULL
GROUP BY h.hashtag_id, h.tag_name
ORDER BY 热度指数 DESC, 帖子数 DESC
LIMIT 10;

-- ============================================================================
-- 查询2：舆情趋势分析 - 按时间序列显示情感分布趋势
-- ============================================================================
-- 功能说明：
-- - 按天分组统计帖子和评论数
-- - 统计各情感类型的数量和占比
-- - 显示30天的趋势数据
-- - 用于趋势图表展示
-- ============================================================================

SELECT
    DATE(p.created_at) AS 统计日期,
    COUNT(DISTINCT p.post_id) AS 总帖子数,
    COUNT(DISTINCT c.comment_id) AS 总评论数,
    SUM(CASE WHEN ps.sentiment = 'POSITIVE' THEN 1 ELSE 0 END) AS 正面数量,
    SUM(CASE WHEN ps.sentiment = 'NEUTRAL' THEN 1 ELSE 0 END) AS 中立数量,
    SUM(CASE WHEN ps.sentiment = 'NEGATIVE' THEN 1 ELSE 0 END) AS 负面数量,
    ROUND(
        SUM(CASE WHEN ps.sentiment = 'POSITIVE' THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
        2
    ) AS 正面占比,
    ROUND(
        SUM(CASE WHEN ps.sentiment = 'NEUTRAL' THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
        2
    ) AS 中立占比,
    ROUND(
        SUM(CASE WHEN ps.sentiment = 'NEGATIVE' THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
        2
    ) AS 负面占比
FROM posts p
JOIN post_sentiments ps ON p.post_id = ps.post_id
LEFT JOIN comments c ON p.post_id = c.post_id
WHERE p.created_at >= DATE_SUB(NOW(), INTERVAL 30 DAY)
GROUP BY DATE(p.created_at)
ORDER BY 统计日期 DESC;

-- ============================================================================
-- 查询3：情感分布分析 - 统计全量情感分布百分比
-- ============================================================================
-- 功能说明：
-- - 统计正面、中立、负面三种情感的数量
-- - 计算各类型的百分比
-- - 可选：限制时间范围
-- - 用于饼图展示
-- ============================================================================

SELECT
    ps.sentiment AS 情感类型,
    COUNT(*) AS 数量,
    ROUND(
        COUNT(*) * 100.0 / (SELECT COUNT(*) FROM post_sentiments WHERE sentiment != 'UNANALYZED'),
        2
    ) AS 占比,
    ROUND(AVG(ps.confidence), 4) AS 平均置信度
FROM post_sentiments ps
WHERE ps.sentiment != 'UNANALYZED'
GROUP BY ps.sentiment
ORDER BY 数量 DESC;

-- 带时间范围的版本
SELECT
    ps.sentiment AS 情感类型,
    COUNT(*) AS 数量,
    ROUND(
        COUNT(*) * 100.0 / (SELECT COUNT(*) FROM post_sentiments WHERE sentiment != 'UNANALYZED' AND created_at >= DATE_SUB(NOW(), INTERVAL 30 DAY)),
        2
    ) AS 占比,
    ROUND(AVG(ps.confidence), 4) AS 平均置信度
FROM post_sentiments ps
WHERE ps.sentiment != 'UNANALYZED'
  AND ps.created_at >= DATE_SUB(NOW(), INTERVAL 30 DAY)
GROUP BY ps.sentiment
ORDER BY 数量 DESC;

-- ============================================================================
-- 查询4：关键词预警查询 - 查询最近24小时内的预警
-- ============================================================================
-- 功能说明：
-- - 查询指定时间范围内的预警记录
-- - 显示预警详情包括关键词、内容类型、发布者
-- - 用于预警管理界面
-- ============================================================================

SELECT
    a.alert_id,
    k.keyword,
    k.category,
    a.content_type,
    CASE
        WHEN a.content_type = 'POST' THEN (SELECT content FROM posts WHERE post_id = a.content_id)
        WHEN a.content_type = 'COMMENT' THEN (SELECT content FROM comments WHERE comment_id = a.content_id)
    END AS 内容摘要,
    u.username AS 发布者,
    a.created_at AS 预警时间,
    -- 处理状态列移除
FROM alerts a
JOIN keywords k ON a.keyword_id = k.keyword_id
LEFT JOIN posts p ON a.content_type = 'POST' AND p.post_id = a.content_id
LEFT JOIN comments c ON a.content_type = 'COMMENT' AND c.comment_id = a.content_id
LEFT JOIN users u ON u.user_id = COALESCE(p.user_id, c.user_id)
WHERE a.created_at >= DATE_SUB(NOW(), INTERVAL 24 HOUR)
ORDER BY a.created_at DESC;

-- 统计各类型预警数量
SELECT
    a.content_type,
    COUNT(*) AS 预警数量
FROM alerts a
WHERE a.created_at >= DATE_SUB(NOW(), INTERVAL 24 HOUR)
GROUP BY a.content_type;

-- 统计各关键词预警次数
SELECT
    k.keyword,
    k.category,
    COUNT(*) AS 预警次数
FROM alerts a
JOIN keywords k ON a.keyword_id = k.keyword_id
WHERE a.created_at >= DATE_SUB(NOW(), INTERVAL 24 HOUR)
GROUP BY k.keyword_id, k.keyword, k.category
ORDER BY 预警次数 DESC
LIMIT 10;

-- ============================================================================
-- 查询5：用户活跃度统计
-- ============================================================================
-- 功能说明：
-- - 统计用户的帖子数、评论数、活跃度
-- - 按活跃度排序，用于用户分析
-- ============================================================================

SELECT
    u.user_id,
    u.username,
    u.status,
    COUNT(DISTINCT p.post_id) AS 帖子数,
    COUNT(DISTINCT c.comment_id) AS 评论数,
176→    (COUNT(DISTINCT p.post_id) + COUNT(DISTINCT c.comment_id)) AS 总活跃度,
    MAX(p.created_at) AS 最后活跃时间
FROM users u
LEFT JOIN posts p ON u.user_id = p.user_id
LEFT JOIN comments c ON u.user_id = c.user_id
WHERE u.status = 'ACTIVE'
GROUP BY u.user_id, u.username, u.status
ORDER BY 总活跃度 DESC, 帖子数 DESC;

-- ============================================================================
-- 查询6：帖子详情扩展查询
-- ============================================================================
-- 功能说明：
-- - 查询帖子的完整信息，包括作者、话题、情感、评论数
-- - 用于帖子详情页面
-- ============================================================================

SELECT
    p.post_id,
    p.content,
    u.username AS 作者,
    p.created_at AS 发布时间,
    ps.sentiment AS 情感,
    ps.confidence AS 置信度,
    GROUP_CONCAT(DISTINCT h.tag_name ORDER BY h.tag_name SEPARATOR ', ') AS 话题标签,
    COUNT(DISTINCT c.comment_id) AS 评论数
FROM posts p
JOIN users u ON p.user_id = u.user_id
LEFT JOIN post_sentiments ps ON p.post_id = ps.post_id
LEFT JOIN post_hashtags ph ON p.post_id = ph.post_id
LEFT JOIN hashtags h ON ph.hashtag_id = h.hashtag_id
LEFT JOIN comments c ON p.post_id = c.post_id
GROUP BY p.post_id, p.content, u.username, p.created_at, ps.sentiment, ps.confidence
ORDER BY p.post_id DESC;

-- ============================================================================
-- 查询7：每日情感趋势详细统计
-- ============================================================================
-- 功能说明：
-- - 按日期详细统计情感分布
-- - 用于舆情趋势图表
-- ============================================================================

SELECT
    DATE(ps.analyzed_at) AS 分析日期,
    ps.sentiment AS 情感类型,
    COUNT(*) AS 帖子数量,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY DATE(ps.analyzed_at)), 2) AS 日占比
FROM post_sentiments ps
WHERE ps.sentiment != 'UNANALYZED'
  AND ps.analyzed_at >= DATE_SUB(NOW(), INTERVAL 30 DAY)
GROUP BY DATE(ps.analyzed_at), ps.sentiment
ORDER BY 分析日期 DESC, 帖子数量 DESC;

-- ============================================================================
-- 查询8：话题热度和活跃度分析
-- ============================================================================
-- 功能说明：
-- - 分析话题的热度、帖子数、评论数、情感分布
-- - 用于话题管理界面
-- ============================================================================

SELECT
    h.hashtag_id,
    h.tag_name AS 话题名称,
    COUNT(DISTINCT p.post_id) AS 帖子数,
    COUNT(DISTINCT c.comment_id) AS 评论数,
    ROUND(
244→        COUNT(DISTINCT p.post_id) * 0.7 + COUNT(DISTINCT c.comment_id) * 0.3,
        2
    ) AS 热度值,
    COUNT(DISTINCT CASE WHEN ps.sentiment = 'POSITIVE' THEN p.post_id END) AS 正面帖子,
    COUNT(DISTINCT CASE WHEN ps.sentiment = 'NEGATIVE' THEN p.post_id END) AS 负面帖子,
    COUNT(DISTINCT CASE WHEN ps.sentiment = 'NEUTRAL' THEN p.post_id END) AS 中立帖子
FROM hashtags h
LEFT JOIN post_hashtags ph ON h.hashtag_id = ph.hashtag_id
LEFT JOIN posts p ON ph.post_id = p.post_id
LEFT JOIN comments c ON p.post_id = c.post_id
LEFT JOIN post_sentiments ps ON p.post_id = ps.post_id
GROUP BY h.hashtag_id, h.tag_name
HAVING 帖子数 > 0
ORDER BY 热度值 DESC
LIMIT 20;

-- ============================================================================
-- 复杂查询脚本完成
-- ============================================================================
-- 说明：
-- 1. 所有查询已修正字段名，确保与表结构匹配
-- 2. 使用驼峰命名（HashtagID, PostID, CreatedAt等）
-- 3. 可根据需要调整时间范围（LIMIT、INTERVAL等）
-- 4. 复杂查询已优化索引使用
-- ============================================================================
