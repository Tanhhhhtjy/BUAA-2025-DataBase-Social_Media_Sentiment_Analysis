-- ============================================================================
-- 手动填充Post_Hashtags表
-- ============================================================================
-- 说明: 由于触发器在DAS中执行失败，使用SQL手动匹配话题
-- 根据帖子内容与话题标签名称的匹配关系，建立Post_Hashtags关联
-- ============================================================================

-- 方法: 通过LIKE模糊匹配，关联每个帖子与相关的话题
-- 帖子内容中包含话题名称（或相关关键词）时，将该话题与帖子关联

INSERT INTO post_hashtags (post_id, hashtag_id, created_at)
SELECT DISTINCT
    p.post_id,
    h.hashtag_id,
    NOW() AS created_at
FROM posts p
CROSS JOIN hashtags h
WHERE (
    -- 科技话题
    (h.hashtag_id = 1 AND (p.content LIKE '%科技%' OR p.content LIKE '%AI%' OR p.content LIKE '%手机%'))
    -- 教育话题
    OR (h.hashtag_id = 2 AND (p.content LIKE '%教育%' OR p.content LIKE '%学习%' OR p.content LIKE '%教学%'))
    -- 体育话题
    OR (h.hashtag_id = 3 AND (p.content LIKE '%体育%' OR p.content LIKE '%运动%' OR p.content LIKE '%赛事%' OR p.content LIKE '%运动员%'))
    -- 娱乐话题
    OR (h.hashtag_id = 4 AND (p.content LIKE '%电影%' OR p.content LIKE '%音乐%' OR p.content LIKE '%歌%' OR p.content LIKE '%娱乐%'))
    -- 健康话题
    OR (h.hashtag_id = 5 AND (p.content LIKE '%健康%' OR p.content LIKE '%健身%' OR p.content LIKE '%锻炼%' OR p.content LIKE '%健身房%'))
    -- 社会话题
    OR (h.hashtag_id = 6 AND (p.content LIKE '%社会%' OR p.content LIKE '%生活%'))
    -- 政治话题
    OR (h.hashtag_id = 7 AND p.content LIKE '%政治%')
    -- 经济话题
    OR (h.hashtag_id = 8 AND (p.content LIKE '%经济%' OR p.content LIKE '%工作%'))
    -- 环保话题
    OR (h.hashtag_id = 9 AND (p.content LIKE '%环保%' OR p.content LIKE '%地球%'))
    -- 文化话题
    OR (h.hashtag_id = 10 AND p.content LIKE '%文化%')
)
AND NOT EXISTS (
    -- 避免重复插入
    SELECT 1 FROM post_hashtags ph
    WHERE ph.post_id = p.post_id AND ph.hashtag_id = h.hashtag_id
);

-- 验证插入结果
SELECT '插入Post_Hashtags结果：' AS 说明;
SELECT COUNT(*) AS '关联总数' FROM post_hashtags;
SELECT p.post_id, p.content, GROUP_CONCAT(h.tag_name SEPARATOR ',') AS 关联话题
FROM posts p
LEFT JOIN post_hashtags ph ON p.post_id = ph.post_id
LEFT JOIN hashtags h ON ph.hashtag_id = h.hashtag_id
GROUP BY p.post_id
ORDER BY p.post_id;
