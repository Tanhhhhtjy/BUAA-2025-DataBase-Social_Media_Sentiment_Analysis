-- ============================================================================
-- 批量情感分析脚本
-- ============================================================================
-- 说明：为所有帖子批量调用AnalyzeSentiment存储过程
-- 执行方式：新建查询，直接复制粘贴此语句，点击执行

CALL AnalyzeSentiment(1);
CALL AnalyzeSentiment(2);
CALL AnalyzeSentiment(3);
CALL AnalyzeSentiment(4);
CALL AnalyzeSentiment(5);
CALL AnalyzeSentiment(6);
CALL AnalyzeSentiment(7);
CALL AnalyzeSentiment(8);
CALL AnalyzeSentiment(9);
CALL AnalyzeSentiment(10);
CALL AnalyzeSentiment(11);
CALL AnalyzeSentiment(12);
CALL AnalyzeSentiment(13);

-- 验证情感分析结果
SELECT s.Label as 情感类型, COUNT(*) as 数量
FROM Post_Sentiments ps
JOIN Sentiments s ON ps.SentimentID = s.SentimentID
GROUP BY s.Label;
