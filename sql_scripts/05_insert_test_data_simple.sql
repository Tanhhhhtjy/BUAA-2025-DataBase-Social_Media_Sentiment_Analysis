-- ============================================================================
-- 社交媒体舆情分析系统 - 测试数据插入脚本（修正版）
-- ============================================================================
-- 脚本说明: 插入测试数据，修正字段值不匹配问题
-- 创建时间: 2025年
-- 备注: 修正版，确保数据值与表约束匹配
-- ============================================================================

-- ============================================================================
-- 第1部分：插入预定义话题标签
-- ============================================================================
INSERT IGNORE INTO hashtags (tag_name) VALUES
('科技'),
('教育'),
('体育'),
('娱乐'),
('健康'),
('社会'),
('政治'),
('经济'),
('环保'),
('文化');

-- ============================================================================
-- 第2部分：插入敏感关键词
-- ============================================================================
INSERT IGNORE INTO keywords (keyword, category) VALUES
('垃圾', '不当言论'),
('骚扰', '有害内容'),
('歧视', '有害内容'),
('暴力', '有害内容'),
('虚假', '虚假信息'),
('诈骗', '违法行为'),
('冒充', '有害内容'),
('政治敏感', '政治敏感'),
('色情低俗', '色情低俗'),
('暴力恐怖', '暴力恐怖');

-- ============================================================================
-- 第3部分：插入用户数据
-- ============================================================================
INSERT IGNORE INTO users (username, email, password_hash, role, status) VALUES
('admin', 'admin@example.com', 
'$2a$10$PseJpihbuJhJ2txGfcxAd.HTmDJL47vfEVau4exzqe2X6gLTnvQv.', 'ADMIN', 'ACTIVE'),
('用户A', 'user_a@example.com', '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj86wL0fOaY6', 'USER', 'ACTIVE'),
('用户B', 'user_b@example.com', '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj86wL0fOaY6', 'USER', 'ACTIVE'),
('用户C', 'user_c@example.com', '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj86wL0fOaY6', 'USER', 'ACTIVE'),
('用户D', 'user_d@example.com', '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj86wL0fOaY6', 'USER', 'ACTIVE'),
('用户E', 'user_e@example.com', '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj86wL0fOaY6', 'USER', 'ACTIVE'),
('用户F', 'user_f@example.com', '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj86wL0fOaY6', 'USER', 'ACTIVE'),
('用户G', 'user_g@example.com', '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj86wL0fOaY6', 'USER', 'DISABLED'),
('用户H', 'user_h@example.com', '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj86wL0fOaY6', 'USER', 'ACTIVE');

-- ============================================================================
-- 第4部分：插入帖子数据
-- ============================================================================
INSERT INTO posts (user_id, content) VALUES
(1, '今天参加了一个关于科技的研讨会，演讲内容很精彩！科技发展真是太快了。'),
(1, '刚买的新手机，性能很棒，体验非常好，强烈推荐！'),
(2, '在线教育平台的内容很丰富，学习体验不错，有助于自我提升。'),
(2, '学校的教学质量有所下降，教材更新不及时，需要改进。'),
(3, '今天去健身房运动了，锻炼身体真的很重要，大家要坚持运动。'),
(3, '最近的体育赛事很精彩，运动员们的表现非常出色，让人印象深刻。'),
(4, '看了最新的电影，剧情很差劲，演技也不理想，有点失望。'),
(4, '新发布的音乐太赞了！歌手的嗓音很好听，旋律也很动人。'),
(5, '坚持健康饮食和运动，身体状态越来越好，精力充沛。'),
(5, '最近工作压力很大，健康状况有所下降，需要好好调理。'),
(6, '科技进步让生活更便利，但也带来了不少社会问题需要关注。'),
(6, '教育改革是必要的，要培养更多适应时代发展的人才。'),
(6, '环保工作刻不容缓，大家要为地球做出贡献。'),
(7, '这部电影真的很精彩，剧情跌宕起伏，演员演技在线。'),
(8, '最近经济形势不太好，工作压力很大，希望早点好转。'),
(9, '文化传承很重要，我们要保护和发扬优秀的传统文化。');

-- ============================================================================
-- 第5部分：插入评论数据
-- ============================================================================
INSERT INTO comments (post_id, user_id, content) VALUES
(1, 2, '同意！AI技术确实改变了世界，很期待未来的发展。'),
(1, 3, '现在学AI的人很多，竞争也很激烈。'),
(2, 3, '这款手机我也在用，真的很不错！'),
(2, 4, '价格有点贵，但性能确实值得。'),
(3, 4, '在线学习很方便，但需要自律。'),
(4, 5, '完全同意你的看法，教材确实需要更新。'),
(4, 6, '教学质量要提高，需要更好的师资。'),
(5, 6, '运动确实很重要，我也在坚持锻炼。'),
(5, 7, '没时间运动，压力太大了。'),
(6, 1, '运动员确实很敬业，值得学习。'),
(7, 2, '这部电影我也看过，确实不太好看。'),
(7, 4, '演技一般般，故事情节也很平凡。'),
(8, 3, '这首歌太好听了！已经循环播放了。'),
(8, 5, '歌手的唱功真的一流，音乐品质很高。'),
(9, 4, '坚持运动很棒！希望能保持这个习惯。'),
(10, 8, '压力大很正常，要学会放松调节。'),
(11, 1, '科技发展是双刃剑，需要理性看待。'),
(12, 2, '教育改革需要循序渐进，不能急于求成。'),
(13, 3, '环保人人有责，从小事做起。'),
(14, 5, '这部电影确实值得一看，推荐大家观看。'),
(15, 6, '经济不好是暂时的，要保持信心。'),
(16, 7, '传统文化是我们的根，不能丢失。');

-- ============================================================================
-- 第6部分：手动关联帖子和话题
-- ============================================================================
INSERT IGNORE INTO post_hashtags (post_id, hashtag_id) VALUES
-- 科技话题 (HashtagID = 1)
(1, 1), (2, 1), (11, 1),
-- 教育话题 (HashtagID = 2)
(3, 2), (4, 2), (12, 2),
-- 体育话题 (HashtagID = 3)
(5, 3), (6, 3),
-- 娱乐话题 (HashtagID = 4)
(7, 4), (8, 4), (14, 4),
-- 健康话题 (HashtagID = 5)
(9, 5), (10, 5),
-- 社会话题 (HashtagID = 6)
(11, 6),
-- 政治话题 (HashtagID = 7)
-- 没有明确政治话题的帖子
-- 经济话题 (HashtagID = 8)
(15, 8),
-- 环保话题 (HashtagID = 9)
(13, 9),
-- 文化话题 (HashtagID = 10)
(16, 10);

-- ============================================================================
-- 第7部分：插入情感分析数据
-- ============================================================================
INSERT INTO post_sentiments (post_id, sentiment, confidence, analyzed_at, created_at) VALUES
-- 正面情感
(1, 'POSITIVE', 0.95, NOW(), NOW()),
(2, 'POSITIVE', 0.90, NOW(), NOW()),
(3, 'POSITIVE', 0.85, NOW(), NOW()),
(5, 'POSITIVE', 0.90, NOW(), NOW()),
(6, 'POSITIVE', 0.88, NOW(), NOW()),
(8, 'POSITIVE', 0.92, NOW(), NOW()),
(9, 'POSITIVE', 0.87, NOW(), NOW()),
(14, 'POSITIVE', 0.93, NOW(), NOW()),
-- 负面情感
(4, 'NEGATIVE', 0.75, NOW(), NOW()),
(7, 'NEGATIVE', 0.80, NOW(), NOW()),
(10, 'NEGATIVE', 0.78, NOW(), NOW()),
(15, 'NEGATIVE', 0.72, NOW(), NOW()),
-- 中立情感
(11, 'NEUTRAL', 0.50, NOW(), NOW()),
(12, 'NEUTRAL', 0.50, NOW(), NOW()),
(13, 'NEUTRAL', 0.50, NOW(), NOW()),
(16, 'NEUTRAL', 0.50, NOW(), NOW())
ON DUPLICATE KEY UPDATE
  sentiment = VALUES(sentiment),
  confidence = VALUES(confidence),
  analyzed_at = VALUES(analyzed_at),
  created_at = created_at;

-- ============================================================================
-- 第8部分：插入预警数据（演示用）
-- ============================================================================
INSERT INTO alerts (keyword_id, content_type, content_id, summary, created_at) VALUES
(1, 'POST', 7, '帖子包含敏感关键词: 垃圾', NOW()),
(4, 'POST', 7, '帖子包含敏感关键词: 暴力', NOW()),
(9, 'POST', 13, '帖子包含敏感关键词: 暴力恐怖', NOW());

-- ============================================================================
-- 验证数据是否插入成功
-- ============================================================================
SELECT COUNT(*) as 用户总数 FROM users;
SELECT COUNT(*) as 帖子总数 FROM posts;
SELECT COUNT(*) as 评论总数 FROM comments;
SELECT COUNT(*) as 话题总数 FROM hashtags;
SELECT COUNT(*) as 关键词总数 FROM keywords;
SELECT COUNT(*) as 情感记录总数 FROM post_sentiments;
SELECT COUNT(*) as 预警总数 FROM alerts;
SELECT COUNT(*) as 话题关联总数 FROM post_hashtags;

-- ============================================================================
-- 查看测试数据详情
-- ============================================================================
SELECT '用户列表:' AS 说明;
SELECT user_id, username, email, role, status FROM users;

SELECT '帖子列表:' AS 说明;
SELECT post_id, user_id, LEFT(content, 50) AS ContentPreview, created_at FROM posts;

SELECT '评论列表:' AS 说明;
SELECT comment_id, post_id, user_id, LEFT(content, 50) AS ContentPreview FROM comments;

SELECT '情感分析结果:' AS 说明;
SELECT ps.post_id, ps.sentiment, ps.confidence, p.content
FROM post_sentiments ps
JOIN posts p ON ps.post_id = p.post_id;

SELECT '话题关联:' AS 说明;
SELECT ph.post_id, h.tag_name, p.content
FROM post_hashtags ph
JOIN hashtags h ON ph.hashtag_id = h.hashtag_id
JOIN posts p ON ph.post_id = p.post_id;

SELECT '预警列表:' AS 说明;
SELECT a.alert_id, k.keyword, a.content_type, a.summary
FROM alerts a
JOIN keywords k ON a.keyword_id = k.keyword_id;

-- ============================================================================
-- 测试数据插入完成
-- ============================================================================
-- 提示：
-- 1. 所有密码哈希值均为 'admin123' 的BCrypt哈希
-- 2. 管理员账户：admin / admin123
-- 3. 普通用户账户：用户A/B/C/D/E/F/G/H / admin123
-- ============================================================================
