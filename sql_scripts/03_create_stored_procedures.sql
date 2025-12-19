SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci;
SET collation_connection = 'utf8mb4_unicode_ci';
-- ============================================================================
-- 社交媒体舆情分析系统 - 存储过程脚本（修正版）
-- ============================================================================
-- 脚本说明: 创建数据库存储过程，修正字段名和表名匹配问题
-- 创建时间: 2025年
-- 备注: 修正版，匹配实际的表结构和字段名
-- ============================================================================

DELIMITER //

-- ============================================================================
-- 1. 热点话题计算存储过程
-- 热度 = 帖子数 × 0.7 + 评论数 × 0.3
-- ============================================================================
DROP PROCEDURE IF EXISTS sp_calculate_hot_topics;

CREATE PROCEDURE sp_calculate_hot_topics(
    IN p_start_date DATETIME,
    IN p_end_date DATETIME,
    IN p_limit INT
)
BEGIN
    SELECT
        h.hashtag_id,
        h.tag_name,
        COUNT(DISTINCT p.post_id) AS post_count,
        COALESCE(SUM(comment_counts.comment_count), 0) AS comment_count,
        ROUND(COUNT(DISTINCT p.post_id) * 0.7 + COALESCE(SUM(comment_counts.comment_count), 0) * 0.3, 2) AS heat_score
    FROM hashtags h
    INNER JOIN post_hashtags ph ON h.hashtag_id = ph.hashtag_id
    INNER JOIN posts p ON ph.post_id = p.post_id
    LEFT JOIN (
        SELECT post_id, COUNT(*) AS comment_count
        FROM comments
        WHERE created_at BETWEEN p_start_date AND p_end_date
        GROUP BY post_id
    ) comment_counts ON p.post_id = comment_counts.post_id
    WHERE p.created_at BETWEEN p_start_date AND p_end_date
    GROUP BY h.hashtag_id, h.tag_name
    ORDER BY heat_score DESC
    LIMIT p_limit;
END//

-- ============================================================================
-- 2. 舆情趋势分析存储过程
-- 返回每日正面/中立/负面帖子数量
-- ============================================================================
DROP PROCEDURE IF EXISTS sp_sentiment_trend;

CREATE PROCEDURE sp_sentiment_trend(
    IN p_start_date DATETIME,
    IN p_end_date DATETIME
)
BEGIN
    SELECT
        DATE(p.created_at) AS trend_date,
        SUM(CASE WHEN ps.sentiment = 'POSITIVE' THEN 1 ELSE 0 END) AS positive_count,
        SUM(CASE WHEN ps.sentiment = 'NEUTRAL' THEN 1 ELSE 0 END) AS neutral_count,
        SUM(CASE WHEN ps.sentiment = 'NEGATIVE' THEN 1 ELSE 0 END) AS negative_count,
        COUNT(*) AS total_count
    FROM posts p
    LEFT JOIN post_sentiments ps ON p.post_id = ps.post_id
    WHERE p.created_at BETWEEN p_start_date AND p_end_date
    GROUP BY DATE(p.created_at)
    ORDER BY trend_date;
END//

-- ============================================================================
-- 3. 情感分布统计存储过程
-- 返回各情感类别的数量和占比
-- ============================================================================
DROP PROCEDURE IF EXISTS sp_sentiment_distribution;

CREATE PROCEDURE sp_sentiment_distribution(
    IN p_start_date DATETIME,
    IN p_end_date DATETIME
)
BEGIN
    DECLARE v_total INT;

    SELECT COUNT(*) INTO v_total
    FROM posts p
    INNER JOIN post_sentiments ps ON p.post_id = ps.post_id
    WHERE p.created_at BETWEEN p_start_date AND p_end_date
      AND ps.sentiment != 'UNANALYZED';

    SELECT
        ps.sentiment,
        COUNT(*) AS count,
        ROUND(COUNT(*) * 100.0 / NULLIF(v_total, 0), 2) AS percentage
    FROM posts p
    INNER JOIN post_sentiments ps ON p.post_id = ps.post_id
    WHERE p.created_at BETWEEN p_start_date AND p_end_date
      AND ps.sentiment != 'UNANALYZED'
    GROUP BY ps.sentiment
    ORDER BY count DESC;
END//

-- ============================================================================
-- 4. 关键词预警检测存储过程
-- ============================================================================
DROP PROCEDURE IF EXISTS sp_detect_keyword_alerts;

CREATE PROCEDURE sp_detect_keyword_alerts()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_keyword_id BIGINT;
    DECLARE v_keyword VARCHAR(100);
    DECLARE v_category VARCHAR(50);
    DECLARE v_post_id BIGINT;
    DECLARE v_user_id BIGINT;
    DECLARE v_content TEXT;

    DECLARE keyword_cursor CURSOR FOR
        SELECT keyword_id, keyword, category FROM keywords;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN keyword_cursor;
    read_loop: LOOP
        FETCH keyword_cursor INTO v_keyword_id, v_keyword, v_category;
        IF done THEN
            LEAVE read_loop;
        END IF;

        -- 检测帖子中的关键词
        INSERT INTO alerts (keyword_id, content_type, content_id, summary, created_at)
        SELECT
            v_keyword_id,
            'POST',
            p.post_id,
            CONCAT('帖子包含敏感关键词: ', v_keyword),
            NOW()
        FROM posts p
        WHERE p.content LIKE CONCAT('%', v_keyword, '%')
        AND NOT EXISTS (
            SELECT 1 FROM alerts a
            WHERE a.keyword_id = v_keyword_id
            AND a.content_type = 'POST'
            AND a.content_id = p.post_id
        );

        -- 检测评论中的关键词
        INSERT INTO alerts (keyword_id, content_type, content_id, summary, created_at)
        SELECT
            v_keyword_id,
            'COMMENT',
            c.comment_id,
            CONCAT('评论包含敏感关键词: ', v_keyword),
            NOW()
        FROM comments c
        WHERE c.content LIKE CONCAT('%', v_keyword, '%')
        AND NOT EXISTS (
            SELECT 1 FROM alerts a
            WHERE a.keyword_id = v_keyword_id
            AND a.content_type = 'COMMENT'
            AND a.content_id = c.comment_id
        );
    END LOOP;
    CLOSE keyword_cursor;
END//

DELIMITER ;

-- ============================================================================
-- 存储过程创建完成
-- ============================================================================
-- 验证存储过程创建：
-- SHOW PROCEDURE STATUS WHERE Db = 'your_database_name';
-- ============================================================================
