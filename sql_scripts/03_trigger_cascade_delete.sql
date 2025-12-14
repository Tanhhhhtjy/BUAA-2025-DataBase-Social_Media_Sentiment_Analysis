-- ============================================================================
-- 触发器2: cascade_delete_comments - 级联删除 (极简化版)
-- ============================================================================
-- 说明：DAS专用版本，删除帖子时自动清理关联数据
-- 执行方式：新建查询，直接复制粘贴此语句，点击执行
-- 注意：此触发器可选（外键CASCADE已支持自动删除）

CREATE TRIGGER cascade_delete_comments
BEFORE DELETE ON Posts
FOR EACH ROW
BEGIN
  DELETE FROM Comments WHERE PostID = OLD.PostID;
  DELETE FROM Post_Hashtags WHERE PostID = OLD.PostID;
  DELETE FROM Post_Sentiments WHERE PostID = OLD.PostID;
END;
