-- ============================================================================
-- 社交媒体舆情分析系统 - 审计日志脚本
-- ============================================================================
-- 脚本说明: 创建审计日志表和触发器，记录敏感操作
-- 创建时间: 2025年
-- 备注: Phase 14 审计日志功能
-- ============================================================================

-- ============================================================================
-- 1. 创建审计日志表
-- ============================================================================

-- 审计日志主表
CREATE TABLE IF NOT EXISTS audit_logs (
    log_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    table_name VARCHAR(50) NOT NULL,
    operation VARCHAR(10) NOT NULL COMMENT 'INSERT, UPDATE, DELETE',
    record_id BIGINT,
    old_values JSON,
    new_values JSON,
    user_id BIGINT,
    username VARCHAR(50),
    ip_address VARCHAR(45),
    user_agent TEXT,
    operation_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) DEFAULT 'SUCCESS' COMMENT 'SUCCESS, FAILED',
    error_message TEXT,
    INDEX idx_table_operation (table_name, operation),
    INDEX idx_user_time (user_id, operation_time),
    INDEX idx_operation_time (operation_time),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- 2. 创建审计日志触发器 - Users表
-- ============================================================================

-- Users表 - INSERT触发器
DELIMITER //
CREATE TRIGGER tr_users_audit_insert
AFTER INSERT ON users
FOR EACH ROW
BEGIN
    INSERT INTO audit_logs (
        table_name, operation, record_id, new_values, user_id, username, operation_time
    ) VALUES (
        'users',
        'INSERT',
        NEW.user_id,
        JSON_OBJECT(
            'UserID', NEW.user_id,
            'Username', NEW.username,
            'Email', NEW.email,
            'Status', NEW.status,
            'Role', NEW.role
        ),
        NEW.user_id,
        NEW.username,
        NOW()
    );
END//

-- Users表 - UPDATE触发器
CREATE TRIGGER tr_users_audit_update
AFTER UPDATE ON users
FOR EACH ROW
BEGIN
    INSERT INTO audit_logs (
        table_name, operation, record_id, old_values, new_values, user_id, username, operation_time
    ) VALUES (
        'users',
        'UPDATE',
        NEW.user_id,
        JSON_OBJECT(
            'Status', OLD.status,
            'Role', OLD.role
        ),
        JSON_OBJECT(
            'Status', NEW.status,
            'Role', NEW.role
        ),
        NEW.user_id,
        NEW.username,
        NOW()
    );
END//

-- Users表 - DELETE触发器
CREATE TRIGGER tr_users_audit_delete
AFTER DELETE ON users
FOR EACH ROW
BEGIN
    INSERT INTO audit_logs (
        table_name, operation, record_id, old_values, user_id, username, operation_time
    ) VALUES (
        'users',
        'DELETE',
        OLD.user_id,
        JSON_OBJECT(
            'UserID', OLD.user_id,
            'Username', OLD.username,
            'Status', OLD.status
        ),
        OLD.user_id,
        OLD.username,
        NOW()
    );
END//
DELIMITER ;

-- ============================================================================
-- 3. 创建审计日志触发器 - Posts表
-- ============================================================================

-- Posts表 - INSERT触发器
DELIMITER //
CREATE TRIGGER tr_posts_audit_insert
AFTER INSERT ON posts
FOR EACH ROW
BEGIN
    INSERT INTO audit_logs (
        table_name, operation, record_id, new_values, user_id, username, operation_time
    ) VALUES (
        'posts',
        'INSERT',
        NEW.post_id,
        JSON_OBJECT(
            'PostID', NEW.post_id,
            'Content', NEW.content,
            'UserID', NEW.user_id
        ),
        NEW.user_id,
        (SELECT username FROM users WHERE user_id = NEW.user_id),
        NOW()
    );
END//

-- Posts表 - UPDATE触发器
CREATE TRIGGER tr_posts_audit_update
AFTER UPDATE ON posts
FOR EACH ROW
BEGIN
    INSERT INTO audit_logs (
        table_name, operation, record_id, old_values, new_values, user_id, username, operation_time
    ) VALUES (
        'posts',
        'UPDATE',
        NEW.post_id,
        NULL,
        NULL,
        NEW.user_id,
        (SELECT username FROM users WHERE user_id = NEW.user_id),
        NOW()
    );
END//

-- Posts表 - DELETE触发器
CREATE TRIGGER tr_posts_audit_delete
AFTER DELETE ON posts
FOR EACH ROW
BEGIN
    INSERT INTO audit_logs (
        table_name, operation, record_id, old_values, user_id, username, operation_time
    ) VALUES (
        'posts',
        'DELETE',
        OLD.post_id,
        JSON_OBJECT(
            'PostID', OLD.post_id,
            'Content', LEFT(OLD.content, 100)
        ),
        OLD.user_id,
        (SELECT username FROM users WHERE user_id = OLD.user_id),
        NOW()
    );
END//
DELIMITER ;

-- ============================================================================
-- 4. 创建审计日志触发器 - Keywords表
-- ============================================================================

-- Keywords表 - INSERT触发器
DELIMITER //
CREATE TRIGGER tr_keywords_audit_insert
AFTER INSERT ON keywords
FOR EACH ROW
BEGIN
    DECLARE admin_user_id BIGINT DEFAULT 1;
    DECLARE admin_username VARCHAR(50) DEFAULT 'admin';

    INSERT INTO audit_logs (
        table_name, operation, record_id, new_values, user_id, username, operation_time
    ) VALUES (
        'keywords',
        'INSERT',
        NEW.keyword_id,
        JSON_OBJECT(
            'KeywordID', NEW.keyword_id,
            'Keyword', NEW.keyword,
            'Category', NEW.category
        ),
        admin_user_id,
        admin_username,
        NOW()
    );
END//

-- Keywords表 - UPDATE触发器
CREATE TRIGGER tr_keywords_audit_update
AFTER UPDATE ON keywords
FOR EACH ROW
BEGIN
    DECLARE admin_user_id BIGINT DEFAULT 1;
    DECLARE admin_username VARCHAR(50) DEFAULT 'admin';

    INSERT INTO audit_logs (
        table_name, operation, record_id, old_values, new_values, user_id, username, operation_time
    ) VALUES (
        'keywords',
        'UPDATE',
        NEW.keyword_id,
        JSON_OBJECT(
            'Keyword', OLD.keyword,
            'Category', OLD.category
        ),
        JSON_OBJECT(
            'Keyword', NEW.keyword,
            'Category', NEW.category
        ),
        admin_user_id,
        admin_username,
        NOW()
    );
END//

-- Keywords表 - DELETE触发器
CREATE TRIGGER tr_keywords_audit_delete
AFTER DELETE ON keywords
FOR EACH ROW
BEGIN
    DECLARE admin_user_id BIGINT DEFAULT 1;
    DECLARE admin_username VARCHAR(50) DEFAULT 'admin';

    INSERT INTO audit_logs (
        table_name, operation, record_id, old_values, user_id, username, operation_time
    ) VALUES (
        'keywords',
        'DELETE',
        OLD.keyword_id,
        JSON_OBJECT(
            'KeywordID', OLD.keyword_id,
            'Keyword', OLD.keyword,
            'Category', OLD.category
        ),
        admin_user_id,
        admin_username,
        NOW()
    );
END//
DELIMITER ;

-- ============================================================================
-- 5. 创建审计日志查询视图
-- ============================================================================

-- 审计日志详细视图
CREATE VIEW v_audit_logs AS
SELECT
    log_id,
    table_name,
    operation,
    record_id,
    JSON_EXTRACT(old_values, '$.Status') as old_status,
    JSON_EXTRACT(new_values, '$.Status') as new_status,
    user_id,
    username,
    operation_time,
    status as operation_status,
    CASE
        WHEN table_name = 'users' THEN '用户管理'
        WHEN table_name = 'posts' THEN '帖子管理'
        WHEN table_name = 'comments' THEN '评论管理'
        WHEN table_name = 'keywords' THEN '关键词管理'
        WHEN table_name = 'alerts' THEN '预警管理'
        ELSE table_name
    END as table_name_cn,
    CASE
        WHEN operation = 'INSERT' THEN '新增'
        WHEN operation = 'UPDATE' THEN '更新'
        WHEN operation = 'DELETE' THEN '删除'
        ELSE operation
    END as operation_cn
FROM
    audit_logs
ORDER BY
    operation_time DESC;

-- ============================================================================
-- 6. 创建审计日志清理存储过程
-- ============================================================================

DELIMITER //
CREATE PROCEDURE sp_cleanup_audit_logs(IN days_to_keep INT)
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE deleted_count INT DEFAULT 0;
    DECLARE cutoff_time TIMESTAMP;

    -- 计算清理的时间阈值并删除指定天数之前的审计日志
    SET cutoff_time = DATE_SUB(NOW(), INTERVAL days_to_keep DAY);
    DELETE FROM audit_logs
    WHERE operation_time < cutoff_time;

    SET deleted_count = ROW_COUNT();

    SELECT CONCAT('已清理 ', deleted_count, ' 条超过 ', days_to_keep, ' 天的审计日志记录') as result;
END//
DELIMITER ;

-- ============================================================================
-- 7. 创建审计日志统计视图
-- ============================================================================

-- 每日审计统计
CREATE VIEW v_audit_daily_stats AS
SELECT
    DATE(operation_time) as stats_date,
    table_name,
    operation,
    COUNT(*) as operation_count,
    COUNT(DISTINCT user_id) as user_count,
    COUNT(CASE WHEN status = 'FAILED' THEN 1 END) as failed_count,
    ROUND(COUNT(CASE WHEN status = 'FAILED' THEN 1 END) * 100.0 / COUNT(*), 2) as failure_rate
FROM
    audit_logs
WHERE
    operation_time >= DATE_SUB(NOW(), INTERVAL 30 DAY)
GROUP BY
    DATE(operation_time), table_name, operation
ORDER BY
    stats_date DESC, table_name, operation;

-- ============================================================================
-- 审计日志创建完成
-- ============================================================================
-- 使用说明：
-- 1. 审计日志表会自动记录所有敏感表的增删改操作
-- 2. 触发器会在数据变更时自动创建审计记录
-- 3. 可以通过v_audit_logs视图查看审计日志
-- 4. 可以通过sp_cleanup_audit_logs存储过程清理旧日志
-- 5. 可以通过v_audit_daily_stats查看审计统计信息
--
-- 注意事项：
-- - 审计日志会增加数据库写入开销，建议定期清理
-- - 可以通过设置日志级别来控制记录哪些操作
-- - 敏感信息（如密码）不应该记录在审计日志中
-- - 建议为审计日志表单独分配存储空间
--
-- 示例查询：
-- 1. 查看最近24小时的用户管理操作：
--    SELECT * FROM v_audit_logs WHERE TableName = 'Users' AND OperationTime >= DATE_SUB(NOW(), INTERVAL 24 HOUR);
--
-- 2. 查看失败的操作：
--    SELECT * FROM v_audit_logs WHERE OperationStatus = 'FAILED';
--
-- 3. 清理30天前的审计日志：
--    CALL sp_cleanup_audit_logs(30);
-- ============================================================================
