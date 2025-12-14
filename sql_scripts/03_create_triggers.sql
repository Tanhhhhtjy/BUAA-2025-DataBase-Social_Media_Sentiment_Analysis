-- ============================================================================
-- 社交媒体舆情分析系统 - 触发器脚本
-- ============================================================================
-- 脚本说明: 创建数据库触发器实现自动业务逻辑
-- 创建时间: 2025年
-- ============================================================================

-- ============================================================================
-- 触发器1: extract_hashtags - 帖子话题自动提取
-- ============================================================================
-- 目的：当插入新帖子时，自动从帖子内容中识别并提取预定义的话题标签
-- 实现方式：使用LIKE匹配从Hashtags表中查找包含的话题
-- 触发时机：AFTER INSERT ON Posts
-- ============================================================================

CREATE TRIGGER extract_hashtags
AFTER INSERT ON Posts
FOR EACH ROW
BEGIN
    -- 声明变量
    DECLARE hashtag_count INT;

    -- 从Hashtags表中查找帖子内容中包含的所有话题
    -- 插入匹配的话题到Post_Hashtags表
    -- 确保不会插入重复的关联关系

    INSERT INTO Post_Hashtags (PostID, HashtagID, CreatedAt)
    SELECT
        NEW.PostID,
        h.HashtagID,
        NOW()
    FROM Hashtags h
    WHERE
        -- 使用LIKE匹配，实现模糊查询
        -- 话题名称在帖子内容中出现则匹配
        NEW.Content LIKE CONCAT('%', h.HashtagName, '%')
        -- 避免插入重复的Post_Hashtags记录
        AND NOT EXISTS (
            SELECT 1
            FROM Post_Hashtags ph
            WHERE ph.PostID = NEW.PostID
            AND ph.HashtagID = h.HashtagID
        )
    ;

    -- 记录提取的话题数量（可选，用于日志）
    SELECT COUNT(*) INTO hashtag_count
    FROM Post_Hashtags
    WHERE PostID = NEW.PostID;

END;

-- ============================================================================
-- 触发器工作示例：
-- ============================================================================
-- 假设Hashtags表中有以下话题：
-- - 科技 (#Technology)
-- - 教育 (#Education)
-- - 体育 (#Sports)
--
-- 如果插入一条Post，Content为：
-- "今天参加了一个关于科技和教育的研讨会，收获很大"
--
-- 触发器会自动匹配"科技"和"教育"，并在Post_Hashtags表中创建两条记录：
-- - PostID: [新帖子ID], HashtagID: [科技ID]
-- - PostID: [新帖子ID], HashtagID: [教育ID]
-- ============================================================================

-- ============================================================================
-- 触发器2: cascade_delete_comments - 评论级联删除（可选，MySQL支持FK CASCADE）
-- ============================================================================
-- 注意：这个触发器是可选的，因为我们在外键约束中已经设置了ON DELETE CASCADE
-- 当删除Post时，Comments会自动级联删除
-- 此触发器作为备份/演示之用
-- ============================================================================

CREATE TRIGGER cascade_delete_comments
BEFORE DELETE ON Posts
FOR EACH ROW
BEGIN
    -- 删除该帖子的所有评论
    DELETE FROM Comments
    WHERE PostID = OLD.PostID;

    -- 删除该帖子的所有话题关联
    DELETE FROM Post_Hashtags
    WHERE PostID = OLD.PostID;

    -- 删除该帖子的所有情感记录
    DELETE FROM Post_Sentiments
    WHERE PostID = OLD.PostID;

END;

-- ============================================================================
-- 触发器3: update_post_timestamp - 更新帖子时间戳
-- ============================================================================
-- 注意：这个触发器是可选的，因为我们在字段定义中使用了
-- DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
-- MySQL会自动处理时间戳更新，不需要额外的触发器

-- ============================================================================
-- 触发器创建完成
-- ============================================================================
-- 总结：
-- 1. extract_hashtags：核心触发器，自动提取话题标签
--    - 时机：新帖子插入后
--    - 功能：自动匹配Hashtags表中的话题
--    - 方式：LIKE模糊匹配
--
-- 2. cascade_delete_comments：级联删除演示
--    - 时机：删除帖子前
--    - 功能：删除相关的评论、话题关联、情感记录
--    - 说明：MySQL外键已支持，此触发器为补充
--
-- 3. update_post_timestamp：时间戳更新（通过MySQL字段选项实现）
--    - 无需额外触发器
-- ============================================================================
