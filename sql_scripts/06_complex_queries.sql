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
    SUM(CASE WHEN ps.Sentiment = 'POSITIVE' THEN 1 ELSE 0 END) AS 正面数量,
    SUM(CASE WHEN ps.Sentiment = 'NEUTRAL' THEN 1 ELSE 0 END) AS 中立数量,
    SUM(CASE WHEN ps.Sentiment = 'NEGATIVE' THEN 1 ELSE 0 END) AS 负面数量,
    ROUND(
        SUM(CASE WHEN ps.Sentiment = 'POSITIVE' THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
        2
    ) AS 正面占比,
    ROUND(
        SUM(CASE WHEN ps.Sentiment = 'NEUTRAL' THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
        2
    ) AS 中立占比,
    ROUND(
        SUM(CASE WHEN ps.Sentiment = 'NEGATIVE' THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
        2
    ) AS 负面占比
FROM Posts p
JOIN Post_Sentiments ps ON p.PostID = ps.PostID
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
    ps.Sentiment AS 情感类型,
    COUNT(*) AS 数量,
    ROUND(
        COUNT(*) * 100.0 / (SELECT COUNT(*) FROM Post_Sentiments WHERE Sentiment != 'UNANALYZED'),
        2
    ) AS 占比,
    ROUND(AVG(ps.Confidence), 4) AS 平均置信度
FROM Post_Sentiments ps
WHERE ps.Sentiment != 'UNANALYZED'
GROUP BY ps.Sentiment
ORDER BY 数量 DESC;

-- 带时间范围的版本
SELECT
    ps.Sentiment AS 情感类型,
    COUNT(*) AS 数量,
    ROUND(
        COUNT(*) * 100.0 / (
            SELECT COUNT(*) FROM Post_Sentiments ps2
            WHERE ps2.AnalyzedAt >= DATE_SUB(NOW(), INTERVAL 7 DAY)
            AND ps2.Sentiment != 'UNANALYZED'
        ),
        2
    ) AS 占比
FROM Post_Sentiments ps
WHERE ps.AnalyzedAt >= DATE_SUB(NOW(), INTERVAL 7 DAY)
AND ps.Sentiment != 'UNANALYZED'
GROUP BY ps.Sentiment
ORDER BY 数量 DESC;

-- ============================================================================
-- 查询4：关键词预警查询 - 从预警记录表查询24小时内的敏感关键词
-- ============================================================================
-- 功能说明：
-- - 从Alerts表查询最近24小时内的预警记录
-- - 显示内容类型、发布者、触发关键词、创建时间
-- - 用于舆情监测和预警
-- ============================================================================

SELECT
    a.ContentType AS 内容类型,
    a.ContentID AS 内容ID,
    u.Username AS 发布者,
    k.Keyword AS 触发关键词,
    k.Category AS 关键词分类,
    a.Summary AS 内容摘要,
    a.CreatedAt AS 发布时间,
    CASE
        WHEN ps.Sentiment = 'POSITIVE' THEN '正面'
        WHEN ps.Sentiment = 'NEUTRAL' THEN '中立'
        WHEN ps.Sentiment = 'NEGATIVE' THEN '负面'
        WHEN ps.Sentiment = 'UNANALYZED' THEN '未分析'
        ELSE NULL
    END AS 情感倾向
FROM Alerts a
JOIN Keywords k ON a.KeywordID = k.KeywordID
JOIN Users u ON
    CASE
        WHEN a.ContentType = 'POST' THEN (SELECT UserID FROM Posts WHERE PostID = a.ContentID)
        WHEN a.ContentType = 'COMMENT' THEN (SELECT UserID FROM Comments WHERE CommentID = a.ContentID)
    END = u.UserID
LEFT JOIN Post_Sentiments ps ON
    a.ContentType = 'POST' AND ps.PostID = a.ContentID
WHERE a.CreatedAt >= DATE_SUB(NOW(), INTERVAL 24 HOUR)
ORDER BY a.CreatedAt DESC;

-- ============================================================================
-- 附加查询4.1：关键词预警统计 - 按类别统计预警数量
-- ============================================================================
-- 功能说明：统计各关键词类别的预警数量
-- ============================================================================

SELECT
    k.Category AS 关键词类别,
    COUNT(*) AS 预警数量,
    COUNT(DISTINCT a.ContentID) AS 涉及内容数,
    COUNT(DISTINCT u.UserID) AS 涉及用户数
FROM Alerts a
JOIN Keywords k ON a.KeywordID = k.KeywordID
JOIN Users u ON
    CASE
        WHEN a.ContentType = 'POST' THEN (SELECT UserID FROM Posts WHERE PostID = a.ContentID)
        WHEN a.ContentType = 'COMMENT' THEN (SELECT UserID FROM Comments WHERE CommentID = a.ContentID)
    END = u.UserID
WHERE a.CreatedAt >= DATE_SUB(NOW(), INTERVAL 24 HOUR)
GROUP BY k.Category
ORDER BY 预警数量 DESC;

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
    MAX(p.CreatedAt) AS 最后活动时间
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
    ROUND(AVG(ps.Confidence), 4) AS 平均置信度,
    MIN(p.CreatedAt) AS 首次出现,
    MAX(p.CreatedAt) AS 最近更新
FROM Hashtags h
LEFT JOIN Post_Hashtags ph ON h.HashtagID = ph.HashtagID
LEFT JOIN Posts p ON ph.PostID = p.PostID
LEFT JOIN Comments c ON p.PostID = c.PostID
LEFT JOIN Post_Sentiments ps ON p.PostID = ps.PostID AND ps.Sentiment != 'UNANALYZED'
GROUP BY h.HashtagID, h.HashtagName
HAVING COUNT(DISTINCT p.PostID) > 0
ORDER BY 帖子数 DESC;

-- ============================================================================
-- 附加查询3：敏感信息统计
-- ============================================================================
-- 功能说明：统计包含敏感关键词的内容及预警情况
-- ============================================================================

SELECT
    k.Keyword AS 敏感关键词,
    k.Category AS 分类,
    (SELECT COUNT(*) FROM Posts p
     WHERE p.Content LIKE CONCAT('%', k.Keyword, '%')
     AND p.CreatedAt >= DATE_SUB(NOW(), INTERVAL 24 HOUR)) AS 24小时帖子数,
    (SELECT COUNT(*) FROM Comments c
     WHERE c.Content LIKE CONCAT('%', k.Keyword, '%')
     AND c.CreatedAt >= DATE_SUB(NOW(), INTERVAL 24 HOUR)) AS 24小时评论数,
    (SELECT COUNT(*) FROM Alerts a
     WHERE a.KeywordID = k.KeywordID
     AND a.CreatedAt >= DATE_SUB(NOW(), INTERVAL 24 HOUR)) AS 24小时预警数
FROM Keywords k
ORDER BY 24小时预警数 DESC;

-- ============================================================================
-- 查询脚本完成
-- ============================================================================
-- 总结：
--
-- 核心查询（4个）：
-- 1. 热点话题看板：TOP10话题，按热度指数排序（帖子数*0.7 + 评论数*0.3）
-- 2. 舆情趋势分析：按天统计情感分布变化（POSITIVE/NEUTRAL/NEGATIVE）
-- 3. 情感分布分析：全量和时间范围的情感百分比（含平均置信度）
-- 4. 关键词预警：从Alerts表查询24小时内的敏感词预警记录
--
-- 附加查询（6个）：
-- 5. 用户活跃度排行：按发布/评论活跃度排序
-- 6. 话题热度对比：多维度话题热度分析（含平均置信度）
-- 7. 敏感信息统计：关键词出现频率及预警统计
-- 8. 关键词预警统计：按类别统计预警数量（新增）
--
-- 技术特点：
-- - Post_Sentiments表采用直接存储模式（非关联表）
-- - 情感字段使用枚举：POSITIVE/NEUTRAL/NEGATIVE/UNANALYZED
-- - 置信度字段使用DECIMAL(5,4)提高精度
-- - 新增Alerts表专门用于关键词预警
-- - 所有查询已针对新表结构优化
--
-- 这些查询可以导出为视图或API，供前端调用
-- ============================================================================
