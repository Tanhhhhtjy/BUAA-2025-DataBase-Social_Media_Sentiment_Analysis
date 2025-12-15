-- ============================================================================
-- 社交媒体舆情分析系统 - 触发器脚本（修正版）
-- ============================================================================
-- 脚本说明: 创建数据库触发器，修正字段名和表名匹配问题
-- 创建时间: 2025年
-- 备注: 修正版，匹配实际的表结构和字段名
-- ============================================================================

DELIMITER //

-- ============================================================================
-- 1. 帖子创建时自动初始化情感分析记录
-- ============================================================================
DROP TRIGGER IF EXISTS tr_post_after_insert;

CREATE TRIGGER tr_post_after_insert
AFTER INSERT ON posts
FOR EACH ROW
BEGIN
    -- 自动创建初始情感分析记录（状态为UNANALYZED）
    INSERT INTO post_sentiments (post_id, sentiment, confidence, analyzed_at, created_at)
    VALUES (NEW.post_id, 'UNANALYZED', NULL, NULL, NOW());
END//

-- ============================================================================
-- 2. 用户更新时间自动维护触发器
-- ============================================================================
DROP TRIGGER IF EXISTS tr_user_before_update;

CREATE TRIGGER tr_user_before_update
BEFORE UPDATE ON users
FOR EACH ROW
BEGIN
    SET NEW.updated_at = NOW();
END//

-- ============================================================================
-- 3. 帖子删除时级联清理触发器
-- ============================================================================
DROP TRIGGER IF EXISTS tr_post_before_delete;

CREATE TRIGGER tr_post_before_delete
BEFORE DELETE ON posts
FOR EACH ROW
BEGIN
    -- 删除关联的评论
    DELETE FROM comments WHERE post_id = OLD.post_id;

    -- 删除关联的话题标签
    DELETE FROM post_hashtags WHERE post_id = OLD.post_id;

    -- 删除关联的情感分析记录
    DELETE FROM post_sentiments WHERE post_id = OLD.post_id;

    -- 删除关联的预警记录
    DELETE FROM alerts WHERE content_type = 'POST' AND content_id = OLD.post_id;
END//

-- ============================================================================
-- 4. 评论删除时清理预警记录触发器
-- ============================================================================
DROP TRIGGER IF EXISTS tr_comment_before_delete;

CREATE TRIGGER tr_comment_before_delete
BEFORE DELETE ON comments
FOR EACH ROW
BEGIN
    -- 删除关联的预警记录
    DELETE FROM alerts WHERE content_type = 'COMMENT' AND content_id = OLD.comment_id;
END//

-- ============================================================================
-- 5. 用户删除时级联清理触发器
-- ============================================================================
DROP TRIGGER IF EXISTS tr_user_before_delete;

CREATE TRIGGER tr_user_before_delete
BEFORE DELETE ON users
FOR EACH ROW
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_post_id BIGINT;
    DECLARE post_cursor CURSOR FOR SELECT post_id FROM posts WHERE user_id = OLD.user_id;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    -- 删除用户的所有评论
    DELETE FROM comments WHERE user_id = OLD.user_id;

    -- 遍历删除用户的所有帖子（会触发帖子删除触发器）
    OPEN post_cursor;
    read_loop: LOOP
        FETCH post_cursor INTO v_post_id;
        IF done THEN
            LEAVE read_loop;
        END IF;
        -- 触发帖子删除触发器
        DELETE FROM posts WHERE post_id = v_post_id;
    END LOOP;
    CLOSE post_cursor;

    -- 删除用户的预警记录
END//

-- ============================================================================
-- 6. 帖子内容话题提取触发器
-- ============================================================================
DROP TRIGGER IF EXISTS tr_post_extract_hashtags;

CREATE TRIGGER tr_post_extract_hashtags
AFTER INSERT ON posts
FOR EACH ROW
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE hashtag_name VARCHAR(50);
    DECLARE hashtag_id BIGINT;
    DECLARE pos INT;
    DECLARE extracted_hashtag VARCHAR(50);

    -- 使用游标遍历帖子内容中的#话题#
    DECLARE hashtag_cursor CURSOR FOR
        SELECT DISTINCT TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(NEW.content, '#', numbers.n), '#', -1)) as hashtag
        FROM (
            SELECT 1 n UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5
            UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9 UNION SELECT 10
        ) numbers
        WHERE CHAR_LENGTH(NEW.content) - CHAR_LENGTH(REPLACE(NEW.content, '#', '')) >= numbers.n * 2
        AND TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(NEW.content, '#', numbers.n * 2), '#', -1)) != '';

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN hashtag_cursor;
    read_loop: LOOP
        FETCH hashtag_cursor INTO extracted_hashtag;
        IF done THEN
            LEAVE read_loop;
        END IF;

        -- 检查话题是否已存在
        SELECT hashtag_id INTO hashtag_id FROM hashtags WHERE tag_name = extracted_hashtag LIMIT 1;

        -- 如果话题不存在，创建新话题
        IF hashtag_id IS NULL THEN
            INSERT INTO hashtags (tag_name, created_at) VALUES (extracted_hashtag, NOW());
            SET hashtag_id = LAST_INSERT_ID();
        END IF;

        -- 关联帖子和话题
        INSERT IGNORE INTO post_hashtags (post_id, hashtag_id) VALUES (NEW.post_id, hashtag_id);
    END LOOP;
    CLOSE hashtag_cursor;
END//

-- ============================================================================
-- 7. 关键词更新时审计日志触发器
-- ============================================================================
DROP TRIGGER IF EXISTS tr_keyword_audit_update;

CREATE TRIGGER tr_keyword_audit_update
AFTER UPDATE ON keywords
FOR EACH ROW
BEGIN
    INSERT INTO audit_logs (table_name, operation, record_id, old_values, new_values, operation_time, status)
    VALUES (
        'keywords',
        'UPDATE',
        NEW.keyword_id,
        JSON_OBJECT('Keyword', OLD.keyword, 'Category', OLD.category),
        JSON_OBJECT('Keyword', NEW.keyword, 'Category', NEW.category),
        NOW(),
        'SUCCESS'
    );
END//

-- ============================================================================
-- 8. 关键词插入时审计日志触发器
-- ============================================================================
DROP TRIGGER IF EXISTS tr_keyword_audit_insert;

CREATE TRIGGER tr_keyword_audit_insert
AFTER INSERT ON keywords
FOR EACH ROW
BEGIN
    INSERT INTO audit_logs (table_name, operation, record_id, new_values, operation_time, status)
    VALUES (
        'keywords',
        'INSERT',
        NEW.keyword_id,
        JSON_OBJECT('KeywordID', NEW.keyword_id, 'Keyword', NEW.keyword, 'Category', NEW.category),
        NOW(),
        'SUCCESS'
    );
END//

-- ============================================================================
-- 9. 关键词删除时审计日志触发器
-- ============================================================================
DROP TRIGGER IF EXISTS tr_keyword_audit_delete;

CREATE TRIGGER tr_keyword_audit_delete
AFTER DELETE ON keywords
FOR EACH ROW
BEGIN
    INSERT INTO audit_logs (table_name, operation, record_id, old_values, operation_time, status)
    VALUES (
        'keywords',
        'DELETE',
        OLD.keyword_id,
        JSON_OBJECT('KeywordID', OLD.keyword_id, 'Keyword', OLD.keyword, 'Category', OLD.category),
        NOW(),
        'SUCCESS'
    );
END//

-- ============================================================================
-- 10. 帖子关键词检测触发器
-- ============================================================================
DROP TRIGGER IF EXISTS tr_post_keyword_check;

CREATE TRIGGER tr_post_keyword_check
AFTER INSERT ON posts
FOR EACH ROW
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_keyword_id BIGINT;
    DECLARE v_keyword VARCHAR(100);
    DECLARE v_category VARCHAR(50);

    DECLARE keyword_cursor CURSOR FOR
        SELECT keyword_id, keyword, category
        FROM keywords
        WHERE NEW.content LIKE CONCAT('%', keyword, '%');

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN keyword_cursor;
    read_loop: LOOP
        FETCH keyword_cursor INTO v_keyword_id, v_keyword, v_category;
        IF done THEN
            LEAVE read_loop;
        END IF;

        -- 创建预警记录
        INSERT INTO alerts (keyword_id, content_type, content_id, summary, created_at)
        VALUES (
            v_keyword_id,
            'POST',
            NEW.post_id,
            CONCAT('帖子包含敏感关键词: ', v_keyword),
            NOW()
        );
    END LOOP;
    CLOSE keyword_cursor;
END//

-- ============================================================================
-- 11. 评论关键词检测触发器
-- ============================================================================
DROP TRIGGER IF EXISTS tr_comment_keyword_check;

CREATE TRIGGER tr_comment_keyword_check
AFTER INSERT ON comments
FOR EACH ROW
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_keyword_id BIGINT;
    DECLARE v_keyword VARCHAR(100);
    DECLARE v_category VARCHAR(50);
    DECLARE v_user_id BIGINT;

    DECLARE keyword_cursor CURSOR FOR
        SELECT keyword_id, keyword, category
        FROM keywords
        WHERE NEW.content LIKE CONCAT('%', keyword, '%');

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    -- 获取评论者ID
    SET v_user_id = NEW.user_id;

    OPEN keyword_cursor;
    read_loop: LOOP
        FETCH keyword_cursor INTO v_keyword_id, v_keyword, v_category;
        IF done THEN
            LEAVE read_loop;
        END IF;

        -- 创建预警记录
        INSERT INTO alerts (keyword_id, content_type, content_id, summary, created_at)
        VALUES (
            v_keyword_id,
            'COMMENT',
            NEW.comment_id,
            CONCAT('评论包含敏感关键词: ', v_keyword),
            NOW()
        );
    END LOOP;
    CLOSE keyword_cursor;
END//

DELIMITER ;

-- ============================================================================
-- 触发器创建完成
-- ============================================================================
-- 验证触发器创建：
-- SHOW TRIGGERS;
-- ============================================================================
