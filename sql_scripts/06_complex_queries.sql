-- ============================================================================
-- 社交媒体舆情分析系统 - 复杂查询脚本
-- ============================================================================
-- 脚本说明: 实现系统的4个核心复杂查询功能
-- 创建时间: 2025年
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
    h.HashtagID,
    h.HashtagName AS 话题名称,
    COUNT(DISTINCT p.PostID) AS 帖子数,
    COUNT(DISTINCT c.CommentID) AS 评论数,
    ROUND(
        COUNT(DISTINCT p.PostID) * 0.7 + COUNT(DISTINCT c.CommentID) * 0.3,
        2
    ) AS 热度指数,
    MAX(p.CreatedAt) AS 最新时间
FROM Hashtags h
LEFT JOIN Post_Hashtags ph ON h.HashtagID = ph.HashtagID
LEFT JOIN Posts p ON ph.PostID = p.PostID
    AND p.CreatedAt >= DATE_SUB(NOW(), INTERVAL 7 DAY)
LEFT JOIN Comments c ON p.PostID = c.PostID
WHERE p.PostID IS NOT NULL  -- 只统计有帖子的话题
GROUP BY h.HashtagID, h.HashtagName
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
    DATE(p.CreatedAt) AS 统计日期,
    COUNT(DISTINCT p.PostID) AS 总帖子数,
    COUNT(DISTINCT c.CommentID) AS 总评论数,
    SUM(CASE WHEN s.Label = '正面' THEN 1 ELSE 0 END) AS 正面数量,
    SUM(CASE WHEN s.Label = '中立' THEN 1 ELSE 0 END) AS 中立数量,
    SUM(CASE WHEN s.Label = '负面' THEN 1 ELSE 0 END) AS 负面数量,
    ROUND(
        SUM(CASE WHEN s.Label = '正面' THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
        2
    ) AS 正面占比,
    ROUND(
        SUM(CASE WHEN s.Label = '中立' THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
        2
    ) AS 中立占比,
    ROUND(
        SUM(CASE WHEN s.Label = '负面' THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
        2
    ) AS 负面占比
FROM Posts p
JOIN Post_Sentiments ps ON p.PostID = ps.PostID
JOIN Sentiments s ON ps.SentimentID = s.SentimentID
LEFT JOIN Comments c ON p.PostID = c.PostID
WHERE p.CreatedAt >= DATE_SUB(NOW(), INTERVAL 30 DAY)
GROUP BY DATE(p.CreatedAt)
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
    s.SentimentID,
    s.Label AS 情感类型,
    COUNT(*) AS 数量,
    ROUND(
        COUNT(*) * 100.0 / (SELECT COUNT(*) FROM Post_Sentiments),
        2
    ) AS 占比,
    ROUND(AVG(ps.Score), 2) AS 平均评分
FROM Post_Sentiments ps
JOIN Sentiments s ON ps.SentimentID = s.SentimentID
GROUP BY s.SentimentID, s.Label
ORDER BY 数量 DESC;

-- 带时间范围的版本
SELECT
    s.SentimentID,
    s.Label AS 情感类型,
    COUNT(*) AS 数量,
    ROUND(
        COUNT(*) * 100.0 / (
            SELECT COUNT(*) FROM Post_Sentiments ps2
            WHERE ps2.CreatedAt >= DATE_SUB(NOW(), INTERVAL 7 DAY)
        ),
        2
    ) AS 占比
FROM Post_Sentiments ps
JOIN Sentiments s ON ps.SentimentID = s.SentimentID
WHERE ps.CreatedAt >= DATE_SUB(NOW(), INTERVAL 7 DAY)
GROUP BY s.SentimentID, s.Label
ORDER BY 数量 DESC;

-- ============================================================================
-- 查询4：关键词预警查询 - 检测24小时内的敏感关键词
-- ============================================================================
-- 功能说明：
-- - 检索最近24小时内包含敏感关键词的帖子和评论
-- - 显示内容类型、发布者、触发关键词、创建时间
-- - 用于舆情监测和预警
-- ============================================================================

SELECT
    '帖子' AS 内容类型,
    p.PostID AS 内容ID,
    u.Username AS 发布者,
    u.UserID,
    k.Keyword AS 触发关键词,
    k.Category AS 关键词分类,
    p.Content AS 内容预览,
    p.CreatedAt AS 发布时间,
    CASE
        WHEN ps.SentimentID = 1 THEN '正面'
        WHEN ps.SentimentID = 2 THEN '中立'
        WHEN ps.SentimentID = 3 THEN '负面'
        ELSE '未分析'
    END AS 情感倾向
FROM Posts p
JOIN Users u ON p.UserID = u.UserID
CROSS JOIN Keywords k
LEFT JOIN Post_Sentiments ps ON p.PostID = ps.PostID
WHERE
    -- 关键词匹配
    p.Content LIKE CONCAT('%', k.Keyword, '%')
    -- 24小时内
    AND p.CreatedAt >= DATE_SUB(NOW(), INTERVAL 24 HOUR)

UNION ALL

SELECT
    '评论' AS 内容类型,
    c.CommentID AS 内容ID,
    u.Username AS 发布者,
    u.UserID,
    k.Keyword AS 触发关键词,
    k.Category AS 关键词分类,
    c.Content AS 内容预览,
    c.CreatedAt AS 发布时间,
    '评论' AS 情感倾向  -- 评论没有单独的情感分析
FROM Comments c
JOIN Users u ON c.UserID = u.UserID
CROSS JOIN Keywords k
WHERE
    -- 关键词匹配
    c.Content LIKE CONCAT('%', k.Keyword, '%')
    -- 24小时内
    AND c.CreatedAt >= DATE_SUB(NOW(), INTERVAL 24 HOUR)

ORDER BY 发布时间 DESC;

-- ============================================================================
-- 附加查询1：用户活跃度排行
-- ============================================================================
-- 功能说明：按用户的发布和评论活跃度排序
-- ============================================================================

SELECT
    u.UserID,
    u.Username AS 用户名,
    u.Status AS 用户状态,
    COUNT(DISTINCT p.PostID) AS 帖子数,
    COUNT(DISTINCT c.CommentID) AS 评论数,
    COUNT(DISTINCT p.PostID) + COUNT(DISTINCT c.CommentID) AS 活跃度,
    MAX(GREATEST(MAX(p.CreatedAt), MAX(c.CreatedAt))) AS 最后活动时间
FROM Users u
LEFT JOIN Posts p ON u.UserID = p.UserID
LEFT JOIN Comments c ON u.UserID = c.UserID
GROUP BY u.UserID, u.Username, u.Status
ORDER BY 活跃度 DESC;

-- ============================================================================
-- 附加查询2：话题热度对比
-- ============================================================================
-- 功能说明：按话题比较多个维度的热度数据
-- ============================================================================

SELECT
    h.HashtagName AS 话题名称,
    COUNT(DISTINCT p.PostID) AS 帖子数,
    COUNT(DISTINCT c.CommentID) AS 评论数,
    COUNT(DISTINCT p.UserID) AS 参与用户数,
    ROUND(AVG(ps.Score), 2) AS 平均情感评分,
    MIN(p.CreatedAt) AS 首次出现,
    MAX(p.CreatedAt) AS 最近更新
FROM Hashtags h
LEFT JOIN Post_Hashtags ph ON h.HashtagID = ph.HashtagID
LEFT JOIN Posts p ON ph.PostID = p.PostID
LEFT JOIN Comments c ON p.PostID = c.PostID
LEFT JOIN Post_Sentiments ps ON p.PostID = ps.PostID
GROUP BY h.HashtagID, h.HashtagName
HAVING COUNT(DISTINCT p.PostID) > 0
ORDER BY 帖子数 DESC;

-- ============================================================================
-- 附加查询3：敏感信息统计
-- ============================================================================
-- 功能说明：统计包含敏感关键词的内容
-- ============================================================================

SELECT
    k.Keyword AS 敏感关键词,
    k.Category AS 分类,
    SUM(
        (SELECT COUNT(*) FROM Posts p
         WHERE p.Content LIKE CONCAT('%', k.Keyword, '%')
         AND p.CreatedAt >= DATE_SUB(NOW(), INTERVAL 24 HOUR))
    ) AS 24小时帖子数,
    SUM(
        (SELECT COUNT(*) FROM Comments c
         WHERE c.Content LIKE CONCAT('%', k.Keyword, '%')
         AND c.CreatedAt >= DATE_SUB(NOW(), INTERVAL 24 HOUR))
    ) AS 24小时评论数
FROM Keywords k
GROUP BY k.KeywordID, k.Keyword, k.Category
ORDER BY (
    (SELECT COUNT(*) FROM Posts p WHERE p.Content LIKE CONCAT('%', k.Keyword, '%'))
    +
    (SELECT COUNT(*) FROM Comments c WHERE c.Content LIKE CONCAT('%', k.Keyword, '%'))
) DESC;

-- ============================================================================
-- 查询脚本完成
-- ============================================================================
-- 总结：
--
-- 核心查询（4个）：
-- 1. 热点话题看板：TOP10话题，按热度指数排序
-- 2. 舆情趋势分析：按天统计情感分布变化
-- 3. 情感分布分析：全量和时间范围的情感百分比
-- 4. 关键词预警：24小时内的敏感词检测
--
-- 附加查询（3个）：
-- 5. 用户活跃度排行：按发布/评论活跃度排序
-- 6. 话题热度对比：多维度话题热度分析
-- 7. 敏感信息统计：关键词出现频率统计
--
-- 这些查询可以导出为视图或API，供前端调用
-- ============================================================================
