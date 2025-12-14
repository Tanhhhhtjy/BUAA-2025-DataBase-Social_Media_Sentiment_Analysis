-- ============================================================================
-- 手动填充Post_Sentiments表
-- ============================================================================
-- 说明: 由于存储过程在DAS中执行失败，使用SQL手动进行情感分析
-- 基于简单的关键词匹配规则，为每个帖子分配情感倾向和评分
-- ============================================================================

-- 情感分析规则:
-- 正面 (SentimentID=1): 包含"好"、"棒"、"喜欢"、"优秀"、"赞"等词
--       评分范围: 0.7-1.0
-- 中立 (SentimentID=2): 不包含明显正面或负面词汇
--       评分范围: 0.3-0.7
-- 负面 (SentimentID=3): 包含"差"、"烂"、"讨厌"、"糟糕"、"失望"等词
--       评分范围: 0.0-0.3

-- 首先清空Post_Sentiments表（如果已有数据）
-- DELETE FROM Post_Sentiments;

-- 分析正面内容
INSERT INTO Post_Sentiments (PostID, SentimentID, Score, CreatedAt)
SELECT DISTINCT
    p.PostID,
    1 AS SentimentID,
    CASE
        WHEN p.Content LIKE '%非常%' THEN 0.95
        WHEN p.Content LIKE '%真的%' THEN 0.90
        WHEN p.Content LIKE '%很%' THEN 0.85
        ELSE 0.75
    END AS Score,
    NOW() AS CreatedAt
FROM Posts p
WHERE (
    p.Content LIKE '%好%'
    OR p.Content LIKE '%棒%'
    OR p.Content LIKE '%喜欢%'
    OR p.Content LIKE '%优秀%'
    OR p.Content LIKE '%赞%'
    OR p.Content LIKE '%推荐%'
    OR p.Content LIKE '%精彩%'
    OR p.Content LIKE '%满意%'
    OR p.Content LIKE '%不错%'
)
AND p.Content NOT LIKE '%不好%'
AND p.Content NOT LIKE '%不满%'
AND NOT EXISTS (
    SELECT 1 FROM Post_Sentiments ps WHERE ps.PostID = p.PostID
);

-- 分析负面内容
INSERT INTO Post_Sentiments (PostID, SentimentID, Score, CreatedAt)
SELECT DISTINCT
    p.PostID,
    3 AS SentimentID,
    CASE
        WHEN p.Content LIKE '%非常%' THEN 0.15
        WHEN p.Content LIKE '%很%' THEN 0.20
        ELSE 0.25
    END AS Score,
    NOW() AS CreatedAt
FROM Posts p
WHERE (
    p.Content LIKE '%差%'
    OR p.Content LIKE '%烂%'
    OR p.Content LIKE '%讨厌%'
    OR p.Content LIKE '%糟糕%'
    OR p.Content LIKE '%失望%'
    OR p.Content LIKE '%问题%'
    OR p.Content LIKE '%下降%'
    OR p.Content LIKE '%不及时%'
    OR p.Content LIKE '%压力%'
)
AND p.Content NOT LIKE '%不差%'
AND NOT EXISTS (
    SELECT 1 FROM Post_Sentiments ps WHERE ps.PostID = p.PostID
);

-- 分析中立内容（未被归类为正面或负面的帖子）
INSERT INTO Post_Sentiments (PostID, SentimentID, Score, CreatedAt)
SELECT
    p.PostID,
    2 AS SentimentID,
    0.50 AS Score,
    NOW() AS CreatedAt
FROM Posts p
WHERE NOT EXISTS (
    SELECT 1 FROM Post_Sentiments ps WHERE ps.PostID = p.PostID
);

-- 验证插入结果
SELECT '填充Post_Sentiments结果：' AS 说明;
SELECT COUNT(*) AS '情感记录总数' FROM Post_Sentiments;

-- 按情感类型统计
SELECT
    s.Label AS 情感类型,
    COUNT(*) AS 数量,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM Post_Sentiments), 2) AS 占比,
    ROUND(AVG(ps.Score), 2) AS 平均评分
FROM Post_Sentiments ps
JOIN Sentiments s ON ps.SentimentID = s.SentimentID
GROUP BY ps.SentimentID, s.Label
ORDER BY 数量 DESC;

-- 显示每个帖子的情感分析结果
SELECT
    p.PostID,
    SUBSTRING(p.Content, 1, 50) AS 内容预览,
    s.Label AS 情感类型,
    ps.Score AS 评分,
    ps.CreatedAt AS 分析时间
FROM Posts p
JOIN Post_Sentiments ps ON p.PostID = ps.PostID
JOIN Sentiments s ON ps.SentimentID = s.SentimentID
ORDER BY p.PostID;
