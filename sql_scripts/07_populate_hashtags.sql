-- ============================================================================
-- 手动填充Post_Hashtags表
-- ============================================================================
-- 说明: 由于触发器在DAS中执行失败，使用SQL手动匹配话题
-- 根据帖子内容与话题标签名称的匹配关系，建立Post_Hashtags关联
-- ============================================================================

-- 方法: 通过LIKE模糊匹配，关联每个帖子与相关的话题
-- 帖子内容中包含话题名称（或相关关键词）时，将该话题与帖子关联

INSERT INTO Post_Hashtags (PostID, HashtagID, CreatedAt)
SELECT DISTINCT
    p.PostID,
    h.HashtagID,
    NOW() AS CreatedAt
FROM Posts p
CROSS JOIN Hashtags h
WHERE (
    -- 科技话题
    (h.HashtagID = 1 AND (p.Content LIKE '%科技%' OR p.Content LIKE '%AI%' OR p.Content LIKE '%手机%'))
    -- 教育话题
    OR (h.HashtagID = 2 AND (p.Content LIKE '%教育%' OR p.Content LIKE '%学习%' OR p.Content LIKE '%教学%'))
    -- 体育话题
    OR (h.HashtagID = 3 AND (p.Content LIKE '%体育%' OR p.Content LIKE '%运动%' OR p.Content LIKE '%赛事%' OR p.Content LIKE '%运动员%'))
    -- 娱乐话题
    OR (h.HashtagID = 4 AND (p.Content LIKE '%电影%' OR p.Content LIKE '%音乐%' OR p.Content LIKE '%歌%' OR p.Content LIKE '%娱乐%'))
    -- 健康话题
    OR (h.HashtagID = 5 AND (p.Content LIKE '%健康%' OR p.Content LIKE '%健身%' OR p.Content LIKE '%锻炼%' OR p.Content LIKE '%健身房%'))
    -- 社会话题
    OR (h.HashtagID = 6 AND (p.Content LIKE '%社会%' OR p.Content LIKE '%生活%'))
    -- 政治话题
    OR (h.HashtagID = 7 AND p.Content LIKE '%政治%')
    -- 经济话题
    OR (h.HashtagID = 8 AND (p.Content LIKE '%经济%' OR p.Content LIKE '%工作%'))
    -- 环保话题
    OR (h.HashtagID = 9 AND (p.Content LIKE '%环保%' OR p.Content LIKE '%地球%'))
    -- 文化话题
    OR (h.HashtagID = 10 AND p.Content LIKE '%文化%')
)
AND NOT EXISTS (
    -- 避免重复插入
    SELECT 1 FROM Post_Hashtags ph
    WHERE ph.PostID = p.PostID AND ph.HashtagID = h.HashtagID
);

-- 验证插入结果
SELECT '插入Post_Hashtags结果：' AS 说明;
SELECT COUNT(*) AS '关联总数' FROM Post_Hashtags;
SELECT p.PostID, p.Content, GROUP_CONCAT(h.HashtagName SEPARATOR ',') AS 关联话题
FROM Posts p
LEFT JOIN Post_Hashtags ph ON p.PostID = ph.PostID
LEFT JOIN Hashtags h ON ph.HashtagID = h.HashtagID
GROUP BY p.PostID
ORDER BY p.PostID;
