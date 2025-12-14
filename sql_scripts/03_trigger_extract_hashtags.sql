-- ============================================================================
-- 触发器1: extract_hashtags - 帖子话题自动提取 (极简化版)
-- ============================================================================
-- 说明：DAS专用版本，完全简化语法，避免多行解析问题
-- 执行方式：直接在DAS复制粘贴此语句，点击执行

CREATE TRIGGER extract_hashtags
AFTER INSERT ON Posts
FOR EACH ROW
BEGIN
  INSERT IGNORE INTO Post_Hashtags (PostID, HashtagID, CreatedAt)
  SELECT NEW.PostID, h.HashtagID, NOW()
  FROM Hashtags h
  WHERE NEW.Content LIKE CONCAT('%', h.HashtagName, '%');
END;
