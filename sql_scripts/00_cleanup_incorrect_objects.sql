-- ============================================================================
-- 清理错误的数据库对象脚本
-- ============================================================================
-- 脚本说明: 删除因脚本错误而创建的触发器和存储过程
-- 创建时间: 2025年
-- 备注: 在重新执行修正版脚本前必须执行
-- ============================================================================

-- ============================================================================
-- 删除错误的触发器
-- ============================================================================
-- 注意：如果触发器不存在，DROP TRIGGER语句会报错，可以使用以下方法：
-- 方法1：使用DROP TRIGGER IF EXISTS（MySQL 5.7.2+支持）
-- 方法2：先查看有哪些触发器，再逐个删除

-- 删除触发器
DROP TRIGGER IF EXISTS tr_post_after_insert;
DROP TRIGGER IF EXISTS tr_user_before_update;
DROP TRIGGER IF EXISTS tr_post_before_delete;
DROP TRIGGER IF EXISTS tr_comment_before_delete;
DROP TRIGGER IF EXISTS tr_user_before_delete;
DROP TRIGGER IF EXISTS tr_post_extract_hashtags;
DROP TRIGGER IF EXISTS tr_keyword_audit_update;
DROP TRIGGER IF EXISTS tr_keyword_audit_insert;
DROP TRIGGER IF EXISTS tr_keyword_audit_delete;
DROP TRIGGER IF EXISTS tr_post_keyword_check;
DROP TRIGGER IF EXISTS tr_comment_keyword_check;

-- ============================================================================
-- 删除错误的存储过程
-- ============================================================================
DROP PROCEDURE IF EXISTS sp_calculate_hot_topics;
DROP PROCEDURE IF EXISTS sp_sentiment_trend;
DROP PROCEDURE IF EXISTS sp_sentiment_distribution;
DROP PROCEDURE IF EXISTS sp_detect_keyword_alerts;
DROP PROCEDURE IF EXISTS sp_cleanup_old_alerts;
DROP PROCEDURE IF EXISTS sp_hard_delete_users;
DROP PROCEDURE IF EXISTS sp_cleanup_orphaned_hashtags;
DROP PROCEDURE IF EXISTS sp_cleanup_orphaned_sentiments;
DROP PROCEDURE IF EXISTS sp_rebuild_indexes;
DROP PROCEDURE IF EXISTS sp_update_statistics;
DROP PROCEDURE IF EXISTS sp_comprehensive_cleanup;
DROP PROCEDURE IF EXISTS sp_full_backup;
DROP PROCEDURE IF EXISTS sp_schema_backup;
DROP PROCEDURE IF EXISTS sp_incremental_backup;
DROP PROCEDURE IF EXISTS sp_restore_from_backup;
DROP PROCEDURE IF EXISTS sp_verify_backup;
DROP PROCEDURE IF EXISTS sp_cleanup_old_backups;

DROP TRIGGER IF EXISTS tr_users_audit_insert;
DROP TRIGGER IF EXISTS tr_users_audit_update;
DROP TRIGGER IF EXISTS tr_users_audit_delete;
DROP TRIGGER IF EXISTS tr_posts_audit_insert;
DROP TRIGGER IF EXISTS tr_posts_audit_update;
DROP TRIGGER IF EXISTS tr_posts_audit_delete;
DROP TRIGGER IF EXISTS tr_keywords_audit_insert;
DROP TRIGGER IF EXISTS tr_keywords_audit_update;
DROP TRIGGER IF EXISTS tr_keywords_audit_delete;

DROP VIEW IF EXISTS v_user_stats;
DROP VIEW IF EXISTS v_hashtag_stats;
DROP VIEW IF EXISTS v_sentiment_trend;
DROP VIEW IF EXISTS v_alert_stats;
DROP VIEW IF EXISTS v_admin_dashboard;
DROP VIEW IF EXISTS v_user_activity;
DROP VIEW IF EXISTS v_keyword_stats;
DROP VIEW IF EXISTS v_post_details;
DROP VIEW IF EXISTS v_audit_logs;
DROP VIEW IF EXISTS v_audit_daily_stats;
DROP VIEW IF EXISTS v_cleanup_status;
DROP VIEW IF EXISTS v_backup_history;

SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS post_hashtags;
DROP TABLE IF EXISTS post_sentiments;
DROP TABLE IF EXISTS alerts;
DROP TABLE IF EXISTS comments;
DROP TABLE IF EXISTS posts;
DROP TABLE IF EXISTS hashtags;
DROP TABLE IF EXISTS keywords;
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS audit_logs;
DROP TABLE IF EXISTS Post_Hashtags;
DROP TABLE IF EXISTS Post_Sentiments;
DROP TABLE IF EXISTS Alerts;
DROP TABLE IF EXISTS Comments;
DROP TABLE IF EXISTS Posts;
DROP TABLE IF EXISTS Hashtags;
DROP TABLE IF EXISTS Keywords;
DROP TABLE IF EXISTS Users;
DROP TABLE IF EXISTS AuditLogs;
DROP TABLE IF EXISTS BackupRecords;
DROP TABLE IF EXISTS backup_records;
SET FOREIGN_KEY_CHECKS = 1;

-- ============================================================================
-- 删除错误的函数（如果有）
-- ============================================================================
-- （本项目中暂无函数）

-- ============================================================================
-- 验证清理结果
-- ============================================================================
SELECT '=== 验证触发器删除结果 ===' AS 说明;
SHOW TRIGGERS;

SELECT '=== 验证存储过程删除结果 ===' AS 说明;
SHOW PROCEDURE STATUS WHERE Db = DATABASE();

SELECT '=== 清理完成 ===' AS 说明;
SELECT '请重新执行修正版脚本：' AS 说明;
SELECT '1. 03_create_stored_procedures_fixed.sql' AS 脚本名称;
SELECT '2. 04_create_triggers_fixed.sql' AS 脚本名称;

-- ============================================================================
-- 清理完成提示
-- ============================================================================
/*
清理说明：
1. 已删除所有错误的触发器和存储过程
2. 表结构和数据保持不变
3. 接下来需要重新执行修正版脚本：
   - 03_create_stored_procedures_fixed.sql
   - 04_create_triggers_fixed.sql
4. 执行顺序很重要，先存储过程，后触发器
*/
