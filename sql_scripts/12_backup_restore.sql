-- ============================================================================
-- 社交媒体舆情分析系统 - 备份恢复脚本
-- ============================================================================
-- 脚本说明: 创建数据库备份和恢复存储过程
-- 创建时间: 2025年
-- 备注: Phase 14 备份恢复功能
-- ============================================================================

DELIMITER //

-- ============================================================================
-- 1. 创建备份信息记录表
-- ============================================================================

CREATE TABLE IF NOT EXISTS backup_records (
    backup_id INT PRIMARY KEY AUTO_INCREMENT,
    backup_type VARCHAR(20) NOT NULL COMMENT 'FULL, INCREMENTAL, SCHEMA, DATA',
    backup_path VARCHAR(255),
    table_count INT,
    record_count BIGINT,
    backup_size_mb DECIMAL(10, 2),
    start_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    end_time TIMESTAMP NULL,
    status VARCHAR(20) DEFAULT 'RUNNING' COMMENT 'RUNNING, SUCCESS, FAILED',
    error_message TEXT,
    notes TEXT,
    INDEX idx_backup_type (backup_type),
    INDEX idx_backup_time (start_time),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- 2. 完整备份存储过程
-- ============================================================================
-- 备份所有表结构和数据

CREATE PROCEDURE sp_full_backup(IN backup_path VARCHAR(255), IN notes TEXT)
BEGIN
    DECLARE backup_id INT;
    DECLARE table_count INT DEFAULT 0;
    DECLARE total_records BIGINT DEFAULT 0;
    DECLARE backup_start_time TIMESTAMP DEFAULT NOW();
    DECLARE error_occurred INT DEFAULT FALSE;

    DECLARE table_name VARCHAR(50);
    DECLARE done INT DEFAULT FALSE;

    DECLARE table_cursor CURSOR FOR
        SELECT TABLE_NAME
        FROM information_schema.TABLES
        WHERE TABLE_SCHEMA = DATABASE()
        AND TABLE_TYPE = 'BASE TABLE'
        ORDER BY TABLE_NAME;

    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
        SET error_occurred = TRUE;
        UPDATE backup_records
        SET status = 'FAILED', end_time = NOW(), error_message = CONCAT('Error: ', SQLSTATE, ' - ', MESSAGE_TEXT)
        WHERE backup_records.backup_id = backup_id;
        RESIGNAL;
    END;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    -- 记录备份开始
    INSERT INTO backup_records (backup_type, backup_path, notes, status)
    VALUES ('FULL', backup_path, notes, 'RUNNING');

    SET backup_id = LAST_INSERT_ID();

    OPEN table_cursor;

    read_loop: LOOP
        FETCH table_cursor INTO table_name;
        IF done THEN
            LEAVE read_loop;
        END IF;

        -- 备份表结构
        SET @sql = CONCAT('CREATE TABLE IF NOT EXISTS ', backup_path, '.', table_name, '_backup LIKE ', table_name);
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;

        -- 备份表数据
        SET @sql = CONCAT('INSERT INTO ', backup_path, '.', table_name, '_backup SELECT * FROM ', table_name);
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;

        -- 统计记录数
        SET @sql = CONCAT('SELECT COUNT(*) INTO @record_count FROM ', table_name);
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;

        SET total_records = total_records + @record_count;
        SET table_count = table_count + 1;
    END LOOP;

    CLOSE table_cursor;

    -- 更新备份记录
    UPDATE backup_records
    SET
        table_count = table_count,
        record_count = total_records,
        end_time = NOW(),
        status = 'SUCCESS'
    WHERE backup_records.backup_id = backup_id;

    SELECT
        CONCAT('完整备份完成，共备份 ', table_count, ' 个表，', total_records, ' 条记录') as Result,
        backup_id as backup_id,
        table_count as table_count,
        total_records as total_records,
        TIMESTAMPDIFF(SECOND, backup_start_time, NOW()) as duration_seconds;
END//

-- ============================================================================
-- 3. 表结构备份存储过程
-- ============================================================================
-- 仅备份表结构，不备份数据

CREATE PROCEDURE sp_schema_backup(IN backup_path VARCHAR(255), IN notes TEXT)
BEGIN
    DECLARE backup_id INT;
    DECLARE table_count INT DEFAULT 0;
    DECLARE backup_start_time TIMESTAMP DEFAULT NOW();
    DECLARE error_occurred INT DEFAULT FALSE;

    DECLARE table_name VARCHAR(50);
    DECLARE done INT DEFAULT FALSE;

    DECLARE table_cursor CURSOR FOR
        SELECT TABLE_NAME
        FROM information_schema.TABLES
        WHERE TABLE_SCHEMA = DATABASE()
        AND TABLE_TYPE = 'BASE TABLE'
        ORDER BY TABLE_NAME;

    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
        SET error_occurred = TRUE;
        UPDATE backup_records
        SET status = 'FAILED', end_time = NOW(), error_message = CONCAT('Error: ', SQLSTATE, ' - ', MESSAGE_TEXT)
        WHERE backup_records.backup_id = backup_id;
        RESIGNAL;
    END;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    INSERT INTO backup_records (backup_type, backup_path, notes, status)
    VALUES ('SCHEMA', backup_path, notes, 'RUNNING');

    SET backup_id = LAST_INSERT_ID();

    OPEN table_cursor;

    read_loop: LOOP
        FETCH table_cursor INTO table_name;
        IF done THEN
            LEAVE read_loop;
        END IF;

        SET @sql = CONCAT('CREATE TABLE IF NOT EXISTS ', backup_path, '.', table_name, '_schema LIKE ', table_name);
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;

        SET table_count = table_count + 1;
    END LOOP;

    CLOSE table_cursor;

    UPDATE backup_records
    SET
        table_count = table_count,
        end_time = NOW(),
        status = 'SUCCESS'
    WHERE backup_records.backup_id = backup_id;

    SELECT
        CONCAT('表结构备份完成，共备份 ', table_count, ' 个表的结构') as Result,
        backup_id as backup_id,
        table_count as table_count;
END//

-- ============================================================================
-- 4. 增量备份存储过程
-- ============================================================================
-- 备份指定时间之后的数据变更

CREATE PROCEDURE sp_incremental_backup(
    IN backup_path VARCHAR(255),
    IN since_time TIMESTAMP,
    IN notes TEXT
)
BEGIN
    DECLARE backup_id INT;
    DECLARE total_records BIGINT DEFAULT 0;
    DECLARE backup_start_time TIMESTAMP DEFAULT NOW();
    DECLARE error_occurred INT DEFAULT FALSE;

    DECLARE table_name VARCHAR(50);
    DECLARE done INT DEFAULT FALSE;

    DECLARE table_cursor CURSOR FOR
        SELECT TABLE_NAME
        FROM information_schema.TABLES
        WHERE TABLE_SCHEMA = DATABASE()
        AND TABLE_TYPE = 'BASE TABLE'
        AND TABLE_NAME IN ('users', 'posts', 'comments', 'alerts', 'audit_logs')
        ORDER BY TABLE_NAME;

    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
        SET error_occurred = TRUE;
        UPDATE backup_records
        SET status = 'FAILED', end_time = NOW(), error_message = CONCAT('Error: ', SQLSTATE, ' - ', MESSAGE_TEXT)
        WHERE backup_records.backup_id = backup_id;
        RESIGNAL;
    END;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    INSERT INTO backup_records (backup_type, backup_path, notes, status)
    VALUES ('INCREMENTAL', backup_path, notes, 'RUNNING');

    SET backup_id = LAST_INSERT_ID();

    OPEN table_cursor;

    read_loop: LOOP
        FETCH table_cursor INTO table_name;
        IF done THEN
            LEAVE read_loop;
        END IF;

        -- 为有时间字段的表创建增量备份
        IF table_name IN ('users', 'posts', 'comments', 'alerts', 'audit_logs') THEN
            SET @sql = CONCAT('CREATE TABLE IF NOT EXISTS ', backup_path, '.', table_name, '_inc_', DATE_FORMAT(NOW(), '%Y%m%d_%H%i%S'), ' LIKE ', table_name);
            PREPARE stmt FROM @sql;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;

            IF table_name = 'audit_logs' THEN
                SET @sql = CONCAT('INSERT INTO ', backup_path, '.', table_name, '_inc_', DATE_FORMAT(NOW(), '%Y%m%d_%H%i%S'),
                                  ' SELECT * FROM ', table_name,
                                  ' WHERE operation_time >= ''', since_time, '''');
            ELSE
                SET @sql = CONCAT('INSERT INTO ', backup_path, '.', table_name, '_inc_', DATE_FORMAT(NOW(), '%Y%m%d_%H%i%S'),
                                  ' SELECT * FROM ', table_name,
                                  ' WHERE created_at >= ''', since_time, '''');
            END IF;
            PREPARE stmt FROM @sql;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;

            SET @record_count = ROW_COUNT();
            SET total_records = total_records + @record_count;
        END IF;
    END LOOP;

    CLOSE table_cursor;

    UPDATE backup_records
    SET
        record_count = total_records,
        end_time = NOW(),
        status = 'SUCCESS'
    WHERE backup_records.backup_id = backup_id;

    SELECT
        CONCAT('增量备份完成，共备份 ', total_records, ' 条记录（自 ', since_time, '）') as Result,
        backup_id as backup_id,
        total_records as total_records;
END//

-- ============================================================================
-- 5. 数据恢复存储过程
-- ============================================================================
-- 从备份恢复数据

CREATE PROCEDURE sp_restore_from_backup(
    IN backup_path VARCHAR(255),
    IN table_name VARCHAR(50),
    IN confirm_restore BOOLEAN
)
BEGIN
    DECLARE backup_table VARCHAR(100);
    DECLARE original_table_exists INT DEFAULT 0;
    DECLARE record_count INT DEFAULT 0;

    -- 检查表是否存在
    SELECT COUNT(*) INTO original_table_exists
    FROM information_schema.TABLES
    WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = table_name;

    -- 检查备份表是否存在
    SET backup_table = CONCAT(backup_path, '.', table_name, '_backup');

    SELECT COUNT(*) INTO @backup_exists
    FROM information_schema.TABLES
    WHERE TABLE_SCHEMA = backup_path
    AND TABLE_NAME = CONCAT(table_name, '_backup');

    IF @backup_exists = 0 THEN
        SELECT CONCAT('备份表 ', backup_table, ' 不存在') as error;
    ELSEIF original_table_exists = 0 THEN
        SELECT CONCAT('原表 ', table_name, ' 不存在') as error;
    ELSEIF confirm_restore = FALSE THEN
        SELECT '请设置 confirm_restore = TRUE 来确认恢复操作' as warning;
    ELSE
        -- 禁用外键检查
        SET @sql = 'SET FOREIGN_KEY_CHECKS = 0';
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;

        -- 清空原表
        SET @sql = CONCAT('TRUNCATE TABLE ', table_name);
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;

        -- 从备份恢复数据
        SET @sql = CONCAT('INSERT INTO ', table_name, ' SELECT * FROM ', backup_table);
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;

        SET record_count = ROW_COUNT();

        -- 启用外键检查
        SET @sql = 'SET FOREIGN_KEY_CHECKS = 1';
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;

    SELECT
        CONCAT('从备份恢复表 ', table_name, ' 成功，共恢复 ', record_count, ' 条记录') as result,
        record_count as restored_records;
    END IF;
END//

-- ============================================================================
-- 6. 备份验证存储过程
-- ============================================================================
-- 验证备份的完整性和一致性

CREATE PROCEDURE sp_verify_backup(IN backup_path VARCHAR(255))
BEGIN
    DECLARE backup_id INT;
    DECLARE verification_result TEXT DEFAULT '';
    DECLARE error_count INT DEFAULT 0;

    SELECT backup_id INTO backup_id
    FROM backup_records
    WHERE backup_records.backup_path = backup_path
    ORDER BY start_time DESC
    LIMIT 1;

    IF backup_id IS NULL THEN
        SELECT CONCAT('未找到路径为 ', backup_path, ' 的备份记录') as error;
    ELSE
        -- 检查备份表是否存在
        SELECT COUNT(*) INTO @backup_table_count
        FROM information_schema.TABLES
        WHERE TABLE_SCHEMA = backup_path;

        -- 验证表结构一致性
        SELECT COUNT(*) INTO @schema_diff
        FROM (
            SELECT TABLE_NAME FROM information_schema.TABLES WHERE TABLE_SCHEMA = DATABASE()
            UNION
            SELECT REPLACE(TABLE_NAME, '_backup', '') FROM information_schema.TABLES WHERE TABLE_SCHEMA = backup_path
        ) t
        GROUP BY TABLE_NAME
        HAVING COUNT(*) = 1;

        SET verification_result = CONCAT(
            '备份验证完成\n',
            '备份ID: ', backup_id, '\n',
            '备份路径: ', backup_path, '\n',
            '备份表数量: ', @backup_table_count, '\n',
            '结构差异: ', COALESCE(@schema_diff, 0), '\n',
            '验证状态: ', CASE WHEN COALESCE(@schema_diff, 0) = 0 THEN 'PASS' ELSE 'FAIL' END
        );

        UPDATE backup_records
        SET notes = CONCAT(COALESCE(notes, ''), '\n', 'Verification: ', verification_result)
        WHERE backup_records.backup_id = backup_id;

        SELECT verification_result as verification_result;
    END IF;
END//

-- ============================================================================
-- 7. 备份历史查询视图
-- ============================================================================

CREATE VIEW v_backup_history AS
SELECT
    backup_id,
    backup_type,
    backup_path,
    table_count,
    record_count,
    backup_size_mb,
    start_time,
    end_time,
    status,
    TIMESTAMPDIFF(SECOND, start_time, COALESCE(end_time, NOW())) as duration_seconds,
    CASE
        WHEN backup_type = 'FULL' THEN '完整备份'
        WHEN backup_type = 'SCHEMA' THEN '结构备份'
        WHEN backup_type = 'INCREMENTAL' THEN '增量备份'
        ELSE backup_type
    END as backup_type_cn,
    CASE
        WHEN status = 'SUCCESS' THEN '成功'
        WHEN status = 'FAILED' THEN '失败'
        WHEN status = 'RUNNING' THEN '运行中'
        ELSE status
    END as status_cn
FROM
    backup_records
ORDER BY
    start_time DESC;

-- ============================================================================
-- 8. 清理旧备份存储过程
-- ============================================================================

CREATE PROCEDURE sp_cleanup_old_backups(IN days_to_keep INT)
BEGIN
    DECLARE deleted_count INT DEFAULT 0;

    -- 删除指定天数之前的成功备份记录
    DELETE FROM backup_records
    WHERE start_time < DATE_SUB(NOW(), INTERVAL days_to_keep DAY)
    AND status = 'SUCCESS';

    SET deleted_count = ROW_COUNT();

    SELECT
        CONCAT('已清理 ', deleted_count, ' 条超过 ', days_to_keep, ' 天的备份记录') as result,
        deleted_count as deleted_records,
        days_to_keep as days_kept;
END//

DELIMITER ;

-- ============================================================================
-- 备份恢复脚本创建完成
-- ============================================================================
-- 使用说明：
-- 1. backup_records表 - 记录备份历史和状态
-- 2. sp_full_backup - 完整备份（结构和数据）
-- 3. sp_schema_backup - 仅备份表结构
-- 4. sp_incremental_backup - 增量备份（指定时间后）
-- 5. sp_restore_from_backup - 从备份恢复数据
-- 6. sp_verify_backup - 验证备份完整性
-- 7. sp_cleanup_old_backups - 清理旧备份记录
-- 8. v_backup_history - 查看备份历史
--
-- 备份策略建议：
-- 1. 每日增量备份：sp_incremental_backup('backup_db', DATE_SUB(NOW(), INTERVAL 1 DAY), 'Daily incremental backup');
-- 2. 每周完整备份：sp_full_backup('backup_db', 'Weekly full backup');
-- 3. 每月结构备份：sp_schema_backup('backup_db', 'Monthly schema backup');
--
-- 恢复示例：
-- 1. 恢复整个数据库：
--    CALL sp_restore_from_backup('backup_db', 'users', TRUE);
--    CALL sp_restore_from_backup('backup_db', 'posts', TRUE);
--    ... (逐个表恢复)
--
-- 注意事项：
-- 1. 备份和恢复操作会记录到backup_records表
-- 2. 恢复操作会覆盖原表数据，请谨慎使用
-- 3. 建议在恢复前先创建当前数据的备份
-- 4. 大表备份和恢复可能需要较长时间
-- 5. 增量备份仅适用于有created_at或operation_time字段的表
-- 6. 备份路径需要是已存在的数据库名
--
-- 示例调用：
-- 1. 创建完整备份：
--    CALL sp_full_backup('backup_20251215', 'Production backup 2025-12-15');
--
-- 2. 恢复用户表：
--    CALL sp_restore_from_backup('backup_20251215', 'users', FALSE);
--
-- 3. 验证备份：
--    CALL sp_verify_backup('backup_20251215');
-- ============================================================================
