-- ============================================================================
-- 存储过程: AnalyzeSentiment - 情感分析 (DAS优化版)
-- ============================================================================
-- 说明：分析单条帖子的情感倾向，基于关键词匹配
-- 执行方式：新建查询，直接复制粘贴此语句，点击执行
-- 使用示例：CALL AnalyzeSentiment(1);

CREATE PROCEDURE AnalyzeSentiment(IN p_post_id INT)
BEGIN
  DECLARE v_content TEXT;
  DECLARE v_sentiment_id INT;
  DECLARE v_score DECIMAL(5, 2);

  SELECT Content INTO v_content FROM Posts WHERE PostID = p_post_id;

  IF v_content LIKE '%好%' OR v_content LIKE '%棒%' OR v_content LIKE '%喜欢%'
    OR v_content LIKE '%优秀%' OR v_content LIKE '%完美%' OR v_content LIKE '%满意%'
    OR v_content LIKE '%赞%' OR v_content LIKE '%爱%' THEN
    SET v_sentiment_id = 1;
    SET v_score = 0.75;
  ELSEIF v_content LIKE '%差%' OR v_content LIKE '%烂%' OR v_content LIKE '%讨厌%'
    OR v_content LIKE '%糟糕%' OR v_content LIKE '%失望%' OR v_content LIKE '%生气%'
    OR v_content LIKE '%难受%' OR v_content LIKE '%垃圾%' THEN
    SET v_sentiment_id = 3;
    SET v_score = 0.25;
  ELSE
    SET v_sentiment_id = 2;
    SET v_score = 0.5;
  END IF;

  INSERT IGNORE INTO Post_Sentiments (PostID, SentimentID, Score, CreatedAt)
  VALUES (p_post_id, v_sentiment_id, v_score, NOW());
END;
