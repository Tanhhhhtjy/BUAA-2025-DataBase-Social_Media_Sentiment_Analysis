SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci;
SET collation_connection = 'utf8mb4_unicode_ci';
-- ============================================================================
-- 社交媒体舆情分析系统 - 触发器脚本（修正版）
-- ============================================================================
-- 脚本说明: 创建数据库触发器，修正字段名和表名匹配问题
-- 创建时间: 2025年
-- 备注: 修正版，匹配实际的表结构和字段名
-- ============================================================================

DELIMITER //

DROP TRIGGER IF EXISTS tr_user_before_update;
DROP TRIGGER IF EXISTS tr_post_before_delete;
DROP TRIGGER IF EXISTS tr_comment_before_delete;
DROP TRIGGER IF EXISTS tr_user_before_delete;
DROP TRIGGER IF EXISTS tr_post_extract_hashtags;

-- ============================================================================
-- 1. 帖子创建时自动初始化情感分析记录
-- ============================================================================
DROP TRIGGER IF EXISTS tr_post_after_insert;

CREATE TRIGGER tr_post_after_insert
AFTER INSERT ON posts
FOR EACH ROW
BEGIN
    IF NOT EXISTS (SELECT 1 FROM post_sentiments WHERE post_id = NEW.post_id) THEN
        INSERT INTO post_sentiments (post_id, sentiment, confidence, analyzed_at, created_at)
        VALUES (NEW.post_id, 'UNANALYZED', NULL, NULL, NOW());
    END IF;
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

        INSERT INTO alerts (keyword_id, content_type, content_id, summary, created_at)
        SELECT
            v_keyword_id,
            'POST',
            NEW.post_id,
            CONCAT('帖子包含敏感关键词: ', v_keyword),
            NOW()
        FROM DUAL
        WHERE NOT EXISTS (
            SELECT 1 FROM alerts a
            WHERE a.keyword_id = v_keyword_id
              AND a.content_type = 'POST'
              AND a.content_id = NEW.post_id
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

        INSERT INTO alerts (keyword_id, content_type, content_id, summary, created_at)
        SELECT
            v_keyword_id,
            'COMMENT',
            NEW.comment_id,
            CONCAT('评论包含敏感关键词: ', v_keyword),
            NOW()
        FROM DUAL
        WHERE NOT EXISTS (
            SELECT 1 FROM alerts a
            WHERE a.keyword_id = v_keyword_id
              AND a.content_type = 'COMMENT'
              AND a.content_id = NEW.comment_id
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
