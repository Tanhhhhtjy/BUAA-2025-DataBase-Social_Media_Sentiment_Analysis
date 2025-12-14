-- ============================================================================
-- 社交媒体舆情分析系统 - 存储过程脚本
-- ============================================================================
-- 脚本说明: 创建数据库存储过程实现复杂业务逻辑
-- 创建时间: 2025年
-- ============================================================================

-- ============================================================================
-- 存储过程1: AnalyzeSentiment - 情感分析
-- ============================================================================
-- 目的：分析一条帖子的情感倾向（正面/中立/负面）并生成情感记录
-- 输入参数：PostID - 要分析的帖子ID
-- 实现方式：基于关键词匹配的Mock分析（可扩展为API调用）
-- ============================================================================

DELIMITER //

CREATE PROCEDURE AnalyzeSentiment(IN p_post_id INT)
BEGIN
    DECLARE v_content TEXT;
    DECLARE v_sentiment_id INT;
    DECLARE v_score DECIMAL(5, 2);
    DECLARE v_post_exists INT;

    -- 检查帖子是否存在
    SELECT COUNT(*) INTO v_post_exists
    FROM Posts
    WHERE PostID = p_post_id;

    IF v_post_exists = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = '帖子不存在';
    END IF;

    -- 获取帖子内容
    SELECT Content INTO v_content
    FROM Posts
    WHERE PostID = p_post_id;

    -- ========================================================================
    -- Mock情感分析逻辑
    -- 基于简单的关键词匹配规则
    -- ========================================================================

    -- 规则1：检测正面情感关键词
    IF v_content LIKE '%好%'
        OR v_content LIKE '%棒%'
        OR v_content LIKE '%喜欢%'
        OR v_content LIKE '%优秀%'
        OR v_content LIKE '%完美%'
        OR v_content LIKE '%满意%'
        OR v_content LIKE '%赞%'
        OR v_content LIKE '%爱%'
    THEN
        SET v_sentiment_id = 1;  -- 正面
        -- 评分：0.7-1.0之间
        SET v_score = 0.7 + (RAND() * 0.3);

    -- 规则2：检测负面情感关键词
    ELSEIF v_content LIKE '%差%'
        OR v_content LIKE '%烂%'
        OR v_content LIKE '%讨厌%'
        OR v_content LIKE '%糟糕%'
        OR v_content LIKE '%失望%'
        OR v_content LIKE '%生气%'
        OR v_content LIKE '%难受%'
        OR v_content LIKE '%垃圾%'
    THEN
        SET v_sentiment_id = 3;  -- 负面
        -- 评分：0-0.3之间
        SET v_score = RAND() * 0.3;

    -- 规则3：其他情况为中立
    ELSE
        SET v_sentiment_id = 2;  -- 中立
        -- 评分：0.3-0.7之间
        SET v_score = 0.3 + (RAND() * 0.4);
    END IF;

    -- ========================================================================
    -- 插入或更新情感记录
    -- ========================================================================
    -- 如果已存在相同的情感记录，则更新；否则插入新记录
    INSERT INTO Post_Sentiments (PostID, SentimentID, Score, CreatedAt)
    VALUES (p_post_id, v_sentiment_id, v_score, NOW())
    ON DUPLICATE KEY UPDATE
        Score = v_score,
        CreatedAt = NOW();

END//

DELIMITER ;

-- ============================================================================
-- 存储过程2: BatchAnalyzeSentiment - 批量情感分析
-- ============================================================================
-- 目的：批量分析多条帖子的情感
-- 输入参数：p_start_id - 开始PostID, p_end_id - 结束PostID（可选）
-- ============================================================================

DELIMITER //

CREATE PROCEDURE BatchAnalyzeSentiment(
    IN p_start_id INT,
    IN p_end_id INT
)
BEGIN
    DECLARE v_post_id INT;
    DECLARE v_cursor_finished INT DEFAULT FALSE;
    DECLARE v_posts_cursor CURSOR FOR
        SELECT PostID
        FROM Posts
        WHERE PostID >= p_start_id
        AND (p_end_id IS NULL OR PostID <= p_end_id)
        AND PostID NOT IN (
            SELECT DISTINCT PostID FROM Post_Sentiments
        );

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_cursor_finished = TRUE;

    -- 打开游标
    OPEN v_posts_cursor;

    -- 遍历游标中的每条记录
    cursor_loop: LOOP
        FETCH v_posts_cursor INTO v_post_id;

        IF v_cursor_finished THEN
            LEAVE cursor_loop;
        END IF;

        -- 调用单条分析过程
        CALL AnalyzeSentiment(v_post_id);
    END LOOP;

    -- 关闭游标
    CLOSE v_posts_cursor;

END//

DELIMITER ;

-- ============================================================================
-- 存储过程3: GenerateDailyReport - 生成日报
-- ============================================================================
-- 目的：生成每日的舆情统计报告
-- 输入参数：p_date - 报告日期（默认为今天）
-- ============================================================================

DELIMITER //

CREATE PROCEDURE GenerateDailyReport(IN p_date DATE)
BEGIN
    -- 声明变量
    DECLARE v_date DATE;
    DECLARE v_total_posts INT;
    DECLARE v_positive_count INT;
    DECLARE v_neutral_count INT;
    DECLARE v_negative_count INT;
    DECLARE v_total_comments INT;

    -- 设置日期（默认为今天）
    IF p_date IS NULL THEN
        SET v_date = CURDATE();
    ELSE
        SET v_date = p_date;
    END IF;

    -- 统计当日帖子总数
    SELECT COUNT(*) INTO v_total_posts
    FROM Posts
    WHERE DATE(CreatedAt) = v_date;

    -- 统计当日正面帖子数
    SELECT COUNT(*) INTO v_positive_count
    FROM Posts p
    JOIN Post_Sentiments ps ON p.PostID = ps.PostID
    JOIN Sentiments s ON ps.SentimentID = s.SentimentID
    WHERE DATE(p.CreatedAt) = v_date
    AND s.Label = '正面';

    -- 统计当日中立帖子数
    SELECT COUNT(*) INTO v_neutral_count
    FROM Posts p
    JOIN Post_Sentiments ps ON p.PostID = ps.PostID
    JOIN Sentiments s ON ps.SentimentID = s.SentimentID
    WHERE DATE(p.CreatedAt) = v_date
    AND s.Label = '中立';

    -- 统计当日负面帖子数
    SELECT COUNT(*) INTO v_negative_count
    FROM Posts p
    JOIN Post_Sentiments ps ON p.PostID = ps.PostID
    JOIN Sentiments s ON ps.SentimentID = s.SentimentID
    WHERE DATE(p.CreatedAt) = v_date
    AND s.Label = '负面';

    -- 统计当日评论总数
    SELECT COUNT(*) INTO v_total_comments
    FROM Comments
    WHERE DATE(CreatedAt) = v_date;

    -- 返回报告数据
    SELECT
        v_date AS 报告日期,
        v_total_posts AS 总帖子数,
        v_total_comments AS 总评论数,
        v_positive_count AS 正面帖子数,
        v_neutral_count AS 中立帖子数,
        v_negative_count AS 负面帖子数,
        ROUND(v_positive_count * 100.0 / NULLIF(v_total_posts, 0), 2) AS 正面占比,
        ROUND(v_neutral_count * 100.0 / NULLIF(v_total_posts, 0), 2) AS 中立占比,
        ROUND(v_negative_count * 100.0 / NULLIF(v_total_posts, 0), 2) AS 负面占比;

END//

DELIMITER ;

-- ============================================================================
-- 存储过程4: GetUserStatistics - 获取用户统计信息
-- ============================================================================
-- 目的：获取指定用户的发布统计信息
-- 输入参数：p_user_id - 用户ID
-- ============================================================================

DELIMITER //

CREATE PROCEDURE GetUserStatistics(IN p_user_id INT)
BEGIN
    SELECT
        u.UserID,
        u.Username,
        COUNT(DISTINCT p.PostID) AS 帖子总数,
        COUNT(DISTINCT c.CommentID) AS 评论总数,
        ROUND(AVG(ps.Score), 2) AS 平均情感评分
    FROM Users u
    LEFT JOIN Posts p ON u.UserID = p.UserID
    LEFT JOIN Comments c ON u.UserID = c.UserID
    LEFT JOIN Post_Sentiments ps ON p.PostID = ps.PostID
    WHERE u.UserID = p_user_id
    GROUP BY u.UserID, u.Username;

END//

DELIMITER ;

-- ============================================================================
-- 存储过程创建完成
-- ============================================================================
-- 总结：
--
-- 1. AnalyzeSentiment(PostID)
--    - 功能：分析单条帖子的情感
--    - 方式：Mock关键词匹配
--    - 用途：实时分析新发布的帖子
--
-- 2. BatchAnalyzeSentiment(start_id, end_id)
--    - 功能：批量分析帖子情感
--    - 方式：使用游标遍历
--    - 用途：批量处理历史帖子
--
-- 3. GenerateDailyReport(date)
--    - 功能：生成日报统计
--    - 包含：帖子数、评论数、情感分布
--    - 用途：舆情监测报告
--
-- 4. GetUserStatistics(user_id)
--    - 功能：获取用户统计
--    - 包含：发布数、评论数、平均情感评分
--    - 用途：用户行为分析
--
-- ============================================================================
-- 使用示例：
-- ============================================================================
-- CALL AnalyzeSentiment(1);  -- 分析PostID=1的帖子
-- CALL BatchAnalyzeSentiment(1, 100);  -- 分析PostID 1-100的帖子
-- CALL GenerateDailyReport('2025-01-01');  -- 获取指定日期的报告
-- CALL GetUserStatistics(1);  -- 获取用户ID=1的统计信息
-- ============================================================================
