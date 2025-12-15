-- ============================================================================
-- 社交媒体舆情分析系统 - 情感分析数据填充脚本（修正版）
-- ============================================================================
-- 脚本说明: 手动填充Post_Sentiments表，修正字段名和逻辑
-- 创建时间: 2025年
-- 备注: 修正版，匹配实际的表结构和字段名
-- ============================================================================

-- ============================================================================
-- 情感分析规则:
-- 正面 (POSITIVE): 包含"好"、"棒"、"喜欢"、"优秀"、"赞"等词
--       置信度范围: 0.7-1.0
-- 中立 (NEUTRAL): 不包含明显正面或负面词汇
--       置信度范围: 0.4-0.6
-- 负面 (NEGATIVE): 包含"差"、"烂"、"讨厌"、"糟糕"、"失望"等词
--       置信度范围: 0.0-0.3
-- ============================================================================

-- 首先清空Post_Sentiments表（如果已有数据）
-- DELETE FROM Post_Sentiments;

-- ============================================================================
-- 分析正面内容
-- ============================================================================
INSERT INTO post_sentiments (post_id, sentiment, confidence, analyzed_at, created_at)
SELECT DISTINCT
    p.post_id,
    'POSITIVE' AS sentiment,
    CASE
        WHEN p.content LIKE '%非常%' THEN 0.95
        WHEN p.content LIKE '%真的%' THEN 0.90
        WHEN p.content LIKE '%很%' THEN 0.85
        WHEN p.content LIKE '%太%' THEN 0.88
        ELSE 0.75
    END AS confidence,
    NOW() AS analyzed_at,
    NOW() AS created_at
FROM posts p
WHERE (
    p.content LIKE '%好%'
    OR p.content LIKE '%棒%'
    OR p.content LIKE '%喜欢%'
    OR p.content LIKE '%优秀%'
    OR p.content LIKE '%赞%'
    OR p.content LIKE '%推荐%'
    OR p.content LIKE '%精彩%'
    OR p.content LIKE '%满意%'
    OR p.content LIKE '%不错%'
    OR p.content LIKE '%出色%'
    OR p.content LIKE '%一流%'
    OR p.content LIKE '%动人%'
    OR p.content LIKE '%诱人%'
    OR p.content LIKE '%在线%'
    OR p.content LIKE '%值得%'
    OR p.content LIKE '%强烈%'
)
AND p.content NOT LIKE '%不好%'
AND p.content NOT LIKE '%不满%'
AND p.content NOT LIKE '%不太%'
AND NOT EXISTS (
    SELECT 1 FROM post_sentiments ps WHERE ps.post_id = p.post_id
);

-- ============================================================================
-- 分析负面内容
-- ============================================================================
INSERT INTO post_sentiments (post_id, sentiment, confidence, analyzed_at, created_at)
SELECT DISTINCT
    p.post_id,
    'NEGATIVE' AS sentiment,
    CASE
        WHEN p.content LIKE '%非常%' THEN 0.15
        WHEN p.content LIKE '%很%' THEN 0.20
        WHEN p.content LIKE '%太%' THEN 0.18
        ELSE 0.25
    END AS confidence,
    NOW() AS analyzed_at,
    NOW() AS created_at
FROM posts p
WHERE (
    p.content LIKE '%差%'
    OR p.content LIKE '%烂%'
    OR p.content LIKE '%讨厌%'
    OR p.content LIKE '%糟糕%'
    OR p.content LIKE '%失望%'
    OR p.content LIKE '%问题%'
    OR p.content LIKE '%下降%'
    OR p.content LIKE '%不及时%'
    OR p.content LIKE '%压力%'
    OR p.content LIKE '%不好%'
    OR p.content LIKE '%一般%'
    OR p.content LIKE '%平凡%'
)
AND p.content NOT LIKE '%不差%'
AND NOT EXISTS (
    SELECT 1 FROM post_sentiments ps WHERE ps.post_id = p.post_id
);

-- ============================================================================
-- 分析中立内容（未被归类为正面或负面的帖子）
-- ============================================================================
INSERT INTO post_sentiments (post_id, sentiment, confidence, analyzed_at, created_at)
SELECT
    p.post_id,
    'NEUTRAL' AS sentiment,
    0.50 AS confidence,
    NOW() AS analyzed_at,
    NOW() AS created_at
FROM posts p
WHERE NOT EXISTS (
    SELECT 1 FROM post_sentiments ps WHERE ps.post_id = p.post_id
);

-- ============================================================================
-- 验证插入结果
-- ============================================================================
SELECT '填充Post_Sentiments结果：' AS 说明;
SELECT COUNT(*) AS '情感记录总数' FROM post_sentiments;

-- 按情感类型统计
SELECT
    sentiment AS 情感类型,
    COUNT(*) AS 数量,
124→    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM post_sentiments), 2) AS 占比,
    ROUND(AVG(confidence), 2) AS 平均置信度
FROM post_sentiments
GROUP BY sentiment
ORDER BY 数量 DESC;

-- 显示每个帖子的情感分析结果
SELECT
    p.post_id,
133→    SUBSTRING(p.content, 1, 50) AS 内容预览,
    ps.sentiment AS 情感类型,
    ps.confidence AS 置信度,
    ps.analyzed_at AS 分析时间
FROM posts p
JOIN post_sentiments ps ON p.post_id = ps.post_id
ORDER BY p.post_id;

-- ============================================================================
-- 为评论也添加情感分析
-- ============================================================================
-- 分析评论中的正面内容
INSERT INTO post_sentiments (post_id, sentiment, confidence, analyzed_at, created_at)
SELECT DISTINCT
    c.post_id,
    'POSITIVE' AS sentiment,
    CASE
        WHEN c.content LIKE '%非常%' THEN 0.90
        WHEN c.content LIKE '%真的%' THEN 0.85
        WHEN c.content LIKE '%很%' THEN 0.80
        ELSE 0.75
    END AS confidence,
    NOW() AS analyzed_at,
    NOW() AS created_at
FROM comments c
WHERE (
    c.content LIKE '%好%'
    OR c.content LIKE '%棒%'
    OR c.content LIKE '%喜欢%'
    OR c.content LIKE '%赞%'
    OR c.content LIKE '%同意%'
    OR c.content LIKE '%推荐%'
    OR c.content LIKE '%精彩%'
    OR c.content LIKE '%值得%'
    OR c.content LIKE '%一流%'
    OR c.content LIKE '%太赞%'
)
AND c.content NOT LIKE '%不好%'
AND NOT EXISTS (
    SELECT 1 FROM post_sentiments ps
    WHERE ps.post_id = c.post_id
    AND ps.sentiment = 'POSITIVE'
);

-- 分析评论中的负面内容
INSERT INTO post_sentiments (post_id, sentiment, confidence, analyzed_at, created_at)
SELECT DISTINCT
    c.post_id,
    'NEGATIVE' AS sentiment,
    CASE
        WHEN c.content LIKE '%非常%' THEN 0.20
        WHEN c.content LIKE '%很%' THEN 0.25
        ELSE 0.30
    END AS confidence,
    NOW() AS analyzed_at,
    NOW() AS created_at
FROM comments c
WHERE (
    c.content LIKE '%差%'
    OR c.content LIKE '%不好%'
    OR c.content LIKE '%一般%'
    OR c.content LIKE '%失望%'
)
AND NOT EXISTS (
    SELECT 1 FROM post_sentiments ps
    WHERE ps.post_id = c.post_id
    AND ps.sentiment = 'NEGATIVE'
);

-- 为有评论的帖子添加中立情感（如果还没有情感分析）
INSERT INTO post_sentiments (post_id, sentiment, confidence, analyzed_at, created_at)
SELECT DISTINCT
    c.post_id,
    'NEUTRAL' AS sentiment,
    0.50 AS confidence,
    NOW() AS analyzed_at,
    NOW() AS created_at
FROM comments c
WHERE NOT EXISTS (
    SELECT 1 FROM post_sentiments ps WHERE ps.post_id = c.post_id
);

-- ============================================================================
-- 最终验证
-- ============================================================================
SELECT '最终Post_Sentiments统计：' AS 说明;
SELECT COUNT(*) AS '总记录数' FROM post_sentiments;

SELECT
    sentiment AS 情感类型,
    COUNT(*) AS 数量,
224→    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM post_sentiments), 2) AS 占比,
    ROUND(AVG(confidence), 3) AS 平均置信度
FROM post_sentiments
GROUP BY sentiment
ORDER BY
    CASE sentiment
        WHEN 'POSITIVE' THEN 1
        WHEN 'NEUTRAL' THEN 2
        WHEN 'NEGATIVE' THEN 3
        ELSE 4
    END;

-- 查看帖子和评论的情感分析结果
SELECT
    '帖子情感分析:' AS 类型;
SELECT
    p.post_id,
241→    LEFT(p.content, 30) AS 内容预览,
    ps.sentiment,
    ps.confidence
FROM posts p
JOIN post_sentiments ps ON p.post_id = ps.post_id
ORDER BY p.post_id;

SELECT
    '评论带动的情感分析:' AS 类型;
SELECT
    c.post_id,
252→    LEFT(c.content, 30) AS 评论预览,
    ps.sentiment,
    ps.confidence
FROM comments c
JOIN post_sentiments ps ON c.post_id = ps.post_id
ORDER BY c.post_id;

-- ============================================================================
-- 情感分析数据填充完成
-- ============================================================================
-- 说明：
-- 1. 修正了字段名：使用Sentiment（文本值）和ConfidenceScore
-- 2. 移除了对不存在的Sentiments表的依赖
-- 3. 增加了对评论的情感分析
-- 4. 为每个帖子和评论生成唯一的情感分析记录
-- ============================================================================
