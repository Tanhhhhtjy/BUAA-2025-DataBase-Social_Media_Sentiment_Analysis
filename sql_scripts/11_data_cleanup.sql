-- ============================================================================
-- 社交媒体舆情分析系统 - 数据清理存储过程脚本
-- ============================================================================
-- 脚本说明: 创建数据清理和归档存储过程
-- 创建时间: 2025年
-- 备注: Phase 14 数据清理功能
-- ============================================================================

DELIMITER //

-- ============================================================================
-- 1. 清理过期预警数据
-- ============================================================================
-- 清理指定天数之前的预警数据，避免预警表过大

CREATE PROCEDURE sp_cleanup_old_alerts(IN days_to_keep INT)
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE cleaned_count INT DEFAULT 0;
    DECLARE alerts_deleted INT DEFAULT 0;

    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    -- 删除过期的预警记录
    DELETE FROM alerts
    WHERE created_at < DATE_SUB(NOW(), INTERVAL days_to_keep DAY);

    SET alerts_deleted = ROW_COUNT();

    -- 记录清理操作到审计日志
    INSERT INTO audit_logs (
        table_name, operation, new_values, operation_time, status
    ) VALUES (
        'alerts',
        'CLEANUP',
        JSON_OBJECT(
            'Action', 'Cleanup Old Alerts',
            'DaysKept', days_to_keep,
            'DeletedCount', alerts_deleted
        ),
        NOW(),
        'SUCCESS'
    );

    COMMIT;

    SELECT
        CONCAT('已清理 ', alerts_deleted, ' 条超过 ', days_to_keep, ' 天的预警记录') as result,
        alerts_deleted as deleted_records,
        days_to_keep as days_kept;
END//

-- ============================================================================
-- 2. 归档和删除软删除的用户数据
-- ============================================================================
-- 彻底删除状态为DELETED的用户及其相关数据

CREATE PROCEDURE sp_hard_delete_users(IN days_to_keep INT)
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE users_deleted INT DEFAULT 0;
    DECLARE posts_deleted INT DEFAULT 0;
    DECLARE comments_deleted INT DEFAULT 0;

    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    -- 统计要删除的数据量
    SELECT COUNT(*) INTO users_deleted
    FROM users
    WHERE status = 'DISABLED' AND created_at < DATE_SUB(NOW(), INTERVAL days_to_keep DAY);

    -- 删除用户相关的评论
    DELETE FROM comments
    WHERE user_id IN (
        SELECT user_id FROM users
        WHERE status = 'DISABLED' AND created_at < DATE_SUB(NOW(), INTERVAL days_to_keep DAY)
    );

    SET comments_deleted = ROW_COUNT();

    -- 删除用户相关的帖子（级联删除会自动处理）
    -- Posts表的外键约束会触发级联删除（帖子删除会自动删除评论和标签关联）
    DELETE FROM posts
    WHERE user_id IN (
        SELECT user_id FROM users
        WHERE status = 'DISABLED' AND created_at < DATE_SUB(NOW(), INTERVAL days_to_keep DAY)
    );

    SET posts_deleted = ROW_COUNT();

    -- 删除用户
    DELETE FROM users
    WHERE status = 'DISABLED' AND created_at < DATE_SUB(NOW(), INTERVAL days_to_keep DAY);

    -- 记录清理操作
    INSERT INTO audit_logs (
        table_name, operation, new_values, operation_time, status
    ) VALUES (
        'users',
        'HARD_DELETE',
        JSON_OBJECT(
            'Action', 'Hard Delete Users',
            'DaysKept', days_to_keep,
            'UsersDeleted', users_deleted,
            'PostsDeleted', posts_deleted,
            'CommentsDeleted', comments_deleted
        ),
        NOW(),
        'SUCCESS'
    );

    COMMIT;

    SELECT
        CONCAT('已硬删除 ', users_deleted, ' 个用户及其相关数据') as result,
        users_deleted as users_deleted,
        posts_deleted as posts_deleted,
        comments_deleted as comments_deleted,
        days_to_keep as days_kept;
END//

-- ============================================================================
-- 3. 清理孤立的标签数据
-- ============================================================================
-- 删除没有被任何帖子引用的标签

CREATE PROCEDURE sp_cleanup_orphaned_hashtags()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE hashtags_deleted INT DEFAULT 0;

    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    -- 删除没有被帖子引用的标签
    DELETE FROM hashtags
    WHERE hashtag_id NOT IN (
        SELECT DISTINCT hashtag_id FROM post_hashtags
    );

    SET hashtags_deleted = ROW_COUNT();

    -- 记录清理操作
    INSERT INTO audit_logs (
        table_name, operation, new_values, operation_time, status
    ) VALUES (
        'hashtags',
        'CLEANUP',
        JSON_OBJECT(
            'Action', 'Cleanup Orphaned Hashtags',
            'DeletedCount', hashtags_deleted
        ),
        NOW(),
        'SUCCESS'
    );

    COMMIT;

    SELECT
        CONCAT('已清理 ', hashtags_deleted, ' 个孤立标签') as result,
        hashtags_deleted as deleted_records;
END//

-- ============================================================================
-- 4. 清理孤立的情感分析数据
-- ============================================================================
-- 删除没有对应帖子的情感分析记录

CREATE PROCEDURE sp_cleanup_orphaned_sentiments()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE sentiments_deleted INT DEFAULT 0;

    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    -- 删除没有对应帖子的情感分析记录
    DELETE FROM post_sentiments
    WHERE post_id NOT IN (
        SELECT post_id FROM posts
    );

    SET sentiments_deleted = ROW_COUNT();

    -- 记录清理操作
    INSERT INTO audit_logs (
        table_name, operation, new_values, operation_time, status
    ) VALUES (
        'post_sentiments',
        'CLEANUP',
        JSON_OBJECT(
            'Action', 'Cleanup Orphaned Sentiments',
            'DeletedCount', sentiments_deleted
        ),
        NOW(),
        'SUCCESS'
    );

    COMMIT;

    SELECT
        CONCAT('已清理 ', sentiments_deleted, ' 条孤立情感分析记录') as result,
        sentiments_deleted as deleted_records;
END//

-- ============================================================================
-- 5. 重建所有索引
-- ============================================================================
-- 清理数据后重建索引以优化性能

CREATE PROCEDURE sp_rebuild_indexes()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE table_name VARCHAR(50);
    DECLARE index_count INT DEFAULT 0;

    DECLARE table_cursor CURSOR FOR
        SELECT DISTINCT TABLE_NAME
        FROM information_schema.TABLES
        WHERE TABLE_SCHEMA = DATABASE()
        AND TABLE_NAME IN ('users', 'posts', 'comments', 'hashtags', 'post_hashtags', 'post_sentiments', 'keywords', 'alerts', 'audit_logs');

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    OPEN table_cursor;

    read_loop: LOOP
        FETCH table_cursor INTO table_name;
        IF done THEN
            LEAVE read_loop;
        END IF;

        -- 重建表索引
        SET @sql = CONCAT('ALTER TABLE ', table_name, ' ENGINE=InnoDB');
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;

        SET index_count = index_count + 1;
    END LOOP;

    CLOSE table_cursor;

    -- 记录操作
    INSERT INTO audit_logs (
        table_name, operation, new_values, operation_time, status
    ) VALUES (
        'SYSTEM',
        'MAINTENANCE',
        JSON_OBJECT(
            'Action', 'Rebuild Indexes',
            'TablesProcessed', index_count
        ),
        NOW(),
        'SUCCESS'
    );

    COMMIT;

    SELECT
        CONCAT('已重建 ', index_count, ' 个表的索引') as result,
        index_count as tables_processed;
END//

-- ============================================================================
-- 6. 数据库统计信息更新
-- ============================================================================
-- 更新表的统计信息以优化查询执行计划

CREATE PROCEDURE sp_update_statistics()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE table_name VARCHAR(50);
    DECLARE table_count INT DEFAULT 0;

    DECLARE table_cursor CURSOR FOR
        SELECT DISTINCT TABLE_NAME
        FROM information_schema.TABLES
        WHERE TABLE_SCHEMA = DATABASE()
        AND TABLE_NAME IN ('users', 'posts', 'comments', 'hashtags', 'post_hashtags', 'post_sentiments', 'keywords', 'alerts', 'audit_logs');

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
        -- 忽略错误，继续处理
    END;

    OPEN table_cursor;

    read_loop: LOOP
        FETCH table_cursor INTO table_name;
        IF done THEN
            LEAVE read_loop;
        END IF;

        -- 更新统计信息
        SET @sql = CONCAT('ANALYZE TABLE ', table_name);
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;

        SET table_count = table_count + 1;
    END LOOP;

    CLOSE table_cursor;

    SELECT
        CONCAT('已更新 ', table_count, ' 个表的统计信息') as result,
        table_count as tables_processed;
END//

-- ============================================================================
-- 7. 综合数据清理存储过程
-- ============================================================================
-- 执行完整的数据清理流程

CREATE PROCEDURE sp_comprehensive_cleanup(
    IN alerts_days_to_keep INT,
    IN deleted_users_days_to_keep INT
)
BEGIN
    DECLARE cleanup_start_time TIMESTAMP DEFAULT NOW();
    DECLARE total_records_cleaned INT DEFAULT 0;
    DECLARE error_occurred INT DEFAULT FALSE;

    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
        SET error_occurred = TRUE;
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    -- 1. 清理过期预警数据
    CALL sp_cleanup_old_alerts(alerts_days_to_keep);
    SET total_records_cleaned = total_records_cleaned + ROW_COUNT();

    -- 2. 归档和删除软删除的用户数据
    CALL sp_hard_delete_users(deleted_users_days_to_keep);
    SET total_records_cleaned = total_records_cleaned + ROW_COUNT();

    -- 3. 清理孤立标签
    CALL sp_cleanup_orphaned_hashtags();
    SET total_records_cleaned = total_records_cleaned + ROW_COUNT();

    -- 4. 清理孤立情感分析数据
    CALL sp_cleanup_orphaned_sentiments();
    SET total_records_cleaned = total_records_cleaned + ROW_COUNT();

    -- 5. 重建索引
    CALL sp_rebuild_indexes();

    -- 6. 更新统计信息
    CALL sp_update_statistics();

    -- 记录综合清理操作
    INSERT INTO audit_logs (
        table_name, operation, new_values, operation_time, status
    ) VALUES (
        'SYSTEM',
        'COMPREHENSIVE_CLEANUP',
        JSON_OBJECT(
            'Action', 'Comprehensive Data Cleanup',
            'AlertsDaysKept', alerts_days_to_keep,
            'DeletedUsersDaysKept', deleted_users_days_to_keep,
            'TotalRecordsCleaned', total_records_cleaned,
            'DurationSeconds', TIMESTAMPDIFF(SECOND, cleanup_start_time, NOW())
        ),
        NOW(),
        'SUCCESS'
    );

    COMMIT;

    SELECT
        CONCAT('综合数据清理完成，耗时 ', TIMESTAMPDIFF(SECOND, cleanup_start_time, NOW()), ' 秒') as Result,
        total_records_cleaned as total_records_cleaned,
        alerts_days_to_keep as alerts_days_kept,
        deleted_users_days_to_keep as deleted_users_days_kept,
        TIMESTAMPDIFF(SECOND, cleanup_start_time, NOW()) as duration_seconds;
END//

-- ============================================================================
-- 8. 数据清理任务调度视图
-- ============================================================================
-- 用于查看数据清理的状态和统计信息

CREATE VIEW v_cleanup_status AS
SELECT
    'Old Alerts' as cleanup_type,
    COUNT(*) as record_count,
    MIN(created_at) as oldest_record,
    MAX(created_at) as newest_record,
    CONCAT('DELETE WHERE created_at < DATE_SUB(NOW(), INTERVAL 30 DAY)') as cleanup_query
FROM alerts
WHERE created_at < DATE_SUB(NOW(), INTERVAL 30 DAY)

UNION ALL

SELECT
    'Deleted Users' as cleanup_type,
    COUNT(*) as record_count,
    MIN(created_at) as oldest_record,
    MAX(created_at) as newest_record,
    CONCAT('DELETE FROM users WHERE status = ''DISABLED''') as cleanup_query
FROM users
WHERE status = 'DISABLED'

UNION ALL

SELECT
    'Orphaned Hashtags' as cleanup_type,
    COUNT(*) as record_count,
    MIN(h.created_at) as oldest_record,
    MAX(h.created_at) as newest_record,
    CONCAT('DELETE FROM hashtags WHERE hashtag_id NOT IN (SELECT hashtag_id FROM post_hashtags)') as cleanup_query
FROM hashtags h
WHERE h.hashtag_id NOT IN (SELECT hashtag_id FROM post_hashtags)

UNION ALL

SELECT
    'Orphaned Sentiments' as cleanup_type,
    COUNT(*) as record_count,
    MIN(ps.analyzed_at) as oldest_record,
    MAX(ps.analyzed_at) as newest_record,
    CONCAT('DELETE FROM post_sentiments WHERE post_id NOT IN (SELECT post_id FROM posts)') as cleanup_query
FROM post_sentiments ps
WHERE ps.post_id NOT IN (SELECT post_id FROM posts);

DELIMITER //
CREATE PROCEDURE sp_cleanup_script5_data()
BEGIN
    DECLARE deleted_alerts INT DEFAULT 0;
    DECLARE deleted_comments INT DEFAULT 0;
    DECLARE deleted_posts INT DEFAULT 0;
    DECLARE deleted_hashtags INT DEFAULT 0;
    DECLARE deleted_users INT DEFAULT 0;
    DECLARE deleted_keywords INT DEFAULT 0;

    START TRANSACTION;

    DELETE FROM alerts
    WHERE (content_type = 'POST' AND content_id IN (
        SELECT post_id FROM posts WHERE content IN (
            '今天参加了一个关于科技的研讨会，演讲内容很精彩！科技发展真是太快了。',
            '刚买的新手机，性能很棒，体验非常好，强烈推荐！',
            '在线教育平台的内容很丰富，学习体验不错，有助于自我提升。',
            '学校的教学质量有所下降，教材更新不及时，需要改进。',
            '今天去健身房运动了，锻炼身体真的很重要，大家要坚持运动。',
            '最近的体育赛事很精彩，运动员们的表现非常出色，让人印象深刻。',
            '看了最新的电影，剧情很差劲，演技也不理想，有点失望。',
            '新发布的音乐太赞了！歌手的嗓音很好听，旋律也很动人。',
            '坚持健康饮食和运动，身体状态越来越好，精力充沛。',
            '最近工作压力很大，健康状况有所下降，需要好好调理。',
            '科技进步让生活更便利，但也带来了不少社会问题需要关注。',
            '教育改革是必要的，要培养更多适应时代发展的人才。',
            '环保工作刻不容缓，大家要为地球做出贡献。',
            '这部电影真的很精彩，剧情跌宕起伏，演员演技在线。',
            '最近经济形势不太好，工作压力很大，希望早点好转。',
            '文化传承很重要，我们要保护和发扬优秀的传统文化。'
        )
    )) OR (content_type = 'COMMENT' AND content_id IN (
        SELECT comment_id FROM comments WHERE content IN (
            '同意！AI技术确实改变了世界，很期待未来的发展。',
            '现在学AI的人很多，竞争也很激烈。',
            '这款手机我也在用，真的很不错！',
            '价格有点贵，但性能确实值得。',
            '在线学习很方便，但需要自律。',
            '完全同意你的看法，教材确实需要更新。',
            '教学质量要提高，需要更好的师资。',
            '运动确实很重要，我也在坚持锻炼。',
            '没时间运动，压力太大了。',
            '运动员确实很敬业，值得学习。',
            '这部电影我也看过，确实不太好看。',
            '演技一般般，故事情节也很平凡。',
            '这首歌太好听了！已经循环播放了。',
            '歌手的唱功真的一流，音乐品质很高。',
            '坚持运动很棒！希望能保持这个习惯。',
            '压力大很正常，要学会放松调节。',
            '科技发展是双刃剑，需要理性看待。',
            '教育改革需要循序渐进，不能急于求成。',
            '环保人人有责，从小事做起。',
            '这部电影确实值得一看，推荐大家观看。',
            '经济不好是暂时的，要保持信心。',
            '传统文化是我们的根，不能丢失。'
        )
    ));
    SET deleted_alerts = ROW_COUNT();

    DELETE FROM comments
    WHERE content IN (
        '同意！AI技术确实改变了世界，很期待未来的发展。',
        '现在学AI的人很多，竞争也很激烈。',
        '这款手机我也在用，真的很不错！',
        '价格有点贵，但性能确实值得。',
        '在线学习很方便，但需要自律。',
        '完全同意你的看法，教材确实需要更新。',
        '教学质量要提高，需要更好的师资。',
        '运动确实很重要，我也在坚持锻炼。',
        '没时间运动，压力太大了。',
        '运动员确实很敬业，值得学习。',
        '这部电影我也看过，确实不太好看。',
        '演技一般般，故事情节也很平凡。',
        '这首歌太好听了！已经循环播放了。',
        '歌手的唱功真的一流，音乐品质很高。',
        '坚持运动很棒！希望能保持这个习惯。',
        '压力大很正常，要学会放松调节。',
        '科技发展是双刃剑，需要理性看待。',
        '教育改革需要循序渐进，不能急于求成。',
        '环保人人有责，从小事做起。',
        '这部电影确实值得一看，推荐大家观看。',
        '经济不好是暂时的，要保持信心。',
        '传统文化是我们的根，不能丢失。'
    );
    SET deleted_comments = ROW_COUNT();

    DELETE FROM posts
    WHERE content IN (
        '今天参加了一个关于科技的研讨会，演讲内容很精彩！科技发展真是太快了。',
        '刚买的新手机，性能很棒，体验非常好，强烈推荐！',
        '在线教育平台的内容很丰富，学习体验不错，有助于自我提升。',
        '学校的教学质量有所下降，教材更新不及时，需要改进。',
        '今天去健身房运动了，锻炼身体真的很重要，大家要坚持运动。',
        '最近的体育赛事很精彩，运动员们的表现非常出色，让人印象深刻。',
        '看了最新的电影，剧情很差劲，演技也不理想，有点失望。',
        '新发布的音乐太赞了！歌手的嗓音很好听，旋律也很动人。',
        '坚持健康饮食和运动，身体状态越来越好，精力充沛。',
        '最近工作压力很大，健康状况有所下降，需要好好调理。',
        '科技进步让生活更便利，但也带来了不少社会问题需要关注。',
        '教育改革是必要的，要培养更多适应时代发展的人才。',
        '环保工作刻不容缓，大家要为地球做出贡献。',
        '这部电影真的很精彩，剧情跌宕起伏，演员演技在线。',
        '最近经济形势不太好，工作压力很大，希望早点好转。',
        '文化传承很重要，我们要保护和发扬优秀的传统文化。'
    );
    SET deleted_posts = ROW_COUNT();

    DELETE FROM post_hashtags
    WHERE hashtag_id IN (
        SELECT hashtag_id FROM hashtags
        WHERE tag_name IN ('科技','教育','体育','娱乐','健康','社会','政治','经济','环保','文化')
    );

    DELETE FROM hashtags
    WHERE tag_name IN ('科技','教育','体育','娱乐','健康','社会','政治','经济','环保','文化');
    SET deleted_hashtags = ROW_COUNT();

    DELETE FROM users
    WHERE username IN ('admin','用户A','用户B','用户C','用户D','用户E','用户F','用户G','用户H');
    SET deleted_users = ROW_COUNT();

    DELETE FROM keywords
    WHERE (keyword, category) IN (
        ('垃圾', '不当言论'),
        ('骚扰', '有害内容'),
        ('歧视', '有害内容'),
        ('暴力', '有害内容'),
        ('虚假', '虚假信息'),
        ('诈骗', '违法行为'),
        ('冒充', '有害内容'),
        ('政治敏感', '政治敏感'),
        ('色情低俗', '色情低俗'),
        ('暴力恐怖', '暴力恐怖')
    );
    SET deleted_keywords = ROW_COUNT();

    INSERT INTO audit_logs (table_name, operation, new_values, operation_time, status)
    VALUES (
        'SYSTEM',
        'CLEANUP',
        JSON_OBJECT(
            'action','cleanup_script5_data',
            'deleted_alerts',deleted_alerts,
            'deleted_comments',deleted_comments,
            'deleted_posts',deleted_posts,
            'deleted_hashtags',deleted_hashtags,
            'deleted_users',deleted_users,
            'deleted_keywords',deleted_keywords
        ),
        NOW(),
        'SUCCESS'
    );

    COMMIT;

    SELECT
        deleted_alerts as deleted_alerts,
        deleted_comments as deleted_comments,
        deleted_posts as deleted_posts,
        deleted_hashtags as deleted_hashtags,
        deleted_users as deleted_users,
        deleted_keywords as deleted_keywords;
END//
DELIMITER ;

DELIMITER ;

-- ============================================================================
-- 数据清理存储过程创建完成
-- ============================================================================
-- 使用说明：
-- 1. sp_cleanup_old_alerts - 清理过期预警数据
-- 2. sp_hard_delete_users - 彻底删除软删除的用户数据
-- 3. sp_cleanup_orphaned_hashtags - 清理孤立标签
-- 4. sp_cleanup_orphaned_sentiments - 清理孤立情感数据
-- 5. sp_rebuild_indexes - 重建索引
-- 6. sp_update_statistics - 更新统计信息
-- 7. sp_comprehensive_cleanup - 综合清理（推荐使用）
-- 8. v_cleanup_status - 查看清理状态
--
-- 定时清理建议：
-- 1. 每周执行一次：sp_cleanup_old_alerts(30)
-- 2. 每月执行一次：sp_cleanup_orphaned_hashtags()
-- 3. 每季度执行一次：sp_comprehensive_cleanup(30, 90)
--
-- 注意事项：
-- 1. 数据清理是不可逆操作，执行前请备份数据
-- 2. 建议在业务低峰期执行清理操作
-- 3. 清理大表数据时注意事务超时问题
-- 4. 清理操作会记录到审计日志中
-- 5. 建议定期监控清理效果和性能影响
--
-- 示例调用：
-- 1. 清理30天前的预警数据：
--    CALL sp_cleanup_old_alerts(30);
--
-- 2. 综合清理（保留30天预警，保留90天的已删除用户）：
--    CALL sp_comprehensive_cleanup(30, 90);
--
-- 3. 查看清理状态：
--    SELECT * FROM v_cleanup_status;
-- ============================================================================
