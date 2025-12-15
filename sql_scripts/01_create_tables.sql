-- ============================================================================
-- 社交媒体舆情分析系统 - 数据库表创建脚本
-- ============================================================================
-- 脚本说明: 创建8个核心实体表及其关系
-- 创建时间: 2025年
-- 备注: 已更新以匹配设计文档 v1.0.0
-- ============================================================================

-- 1. 用户表 - users
-- 存储系统用户信息
CREATE TABLE users (
    user_id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '用户ID',
    username VARCHAR(50) NOT NULL UNIQUE COMMENT '用户名（唯一）',
    email VARCHAR(100) NOT NULL UNIQUE COMMENT '邮箱（唯一）',
    password_hash VARCHAR(255) NOT NULL COMMENT '密码哈希值',
    role ENUM('USER', 'ADMIN') NOT NULL DEFAULT 'USER' COMMENT '用户角色（USER/ADMIN）',
    status ENUM('ACTIVE', 'DISABLED') NOT NULL DEFAULT 'ACTIVE' COMMENT '用户状态（ACTIVE/DISABLED）',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',

    INDEX idx_username (username),
    INDEX idx_email (email),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户表';

-- 2. 帖子表 - posts
-- 存储用户发布的内容
CREATE TABLE posts (
    post_id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '帖子ID',
    user_id BIGINT NOT NULL COMMENT '发布者用户ID',
    content TEXT NOT NULL COMMENT '帖子内容',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',

    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_created_at (created_at DESC),
    INDEX idx_user_created (user_id, created_at DESC)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='帖子表';

-- 3. 评论表 - comments
-- 存储对帖子的评论
CREATE TABLE comments (
    comment_id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '评论ID',
    post_id BIGINT NOT NULL COMMENT '所属帖子ID',
    user_id BIGINT NOT NULL COMMENT '评论者用户ID',
    content VARCHAR(500) NOT NULL COMMENT '评论内容',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',

    FOREIGN KEY (post_id) REFERENCES posts(post_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    INDEX idx_post_id (post_id),
    INDEX idx_user_id (user_id),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='评论表';

-- 4. 话题标签表 - hashtags
-- 存储预定义的话题标签
CREATE TABLE hashtags (
    hashtag_id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '话题ID',
    tag_name VARCHAR(100) NOT NULL UNIQUE COMMENT '话题名称（唯一）',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',

    INDEX idx_hashtag_name (tag_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='话题标签表';

-- 5. 帖子-话题关联表 - post_hashtags (M:N关系)
-- 存储帖子与话题的关联关系
CREATE TABLE post_hashtags (
    post_id BIGINT NOT NULL COMMENT '帖子ID',
    hashtag_id BIGINT NOT NULL COMMENT '话题ID',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',

    PRIMARY KEY (post_id, hashtag_id),
    FOREIGN KEY (post_id) REFERENCES posts(post_id) ON DELETE CASCADE,
    FOREIGN KEY (hashtag_id) REFERENCES hashtags(hashtag_id) ON DELETE CASCADE,
    INDEX idx_hashtag_id (hashtag_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='帖子-话题关联表';

-- 6. 帖子情感分析结果表 - post_sentiments
-- 存储帖子的情感分析结果（直接存储，非关联表）
CREATE TABLE post_sentiments (
    sentiment_id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '情感分析记录ID',
    post_id BIGINT NOT NULL UNIQUE COMMENT '关联帖子ID',
    sentiment ENUM('POSITIVE', 'NEUTRAL', 'NEGATIVE', 'UNANALYZED') NOT NULL COMMENT '情感类别',
    confidence DECIMAL(5,4) NULL COMMENT '置信度（0.0000-1.0000）',
    analyzed_at TIMESTAMP NULL COMMENT '分析时间',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',

    FOREIGN KEY (post_id) REFERENCES posts(post_id) ON DELETE CASCADE,
    INDEX idx_sentiment (sentiment),
    INDEX idx_analyzed_at (analyzed_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='帖子情感分析结果表';

-- 7. 敏感关键词表 - keywords
-- 存储舆情监测的关键词（用于敏感词预警）
CREATE TABLE keywords (
    keyword_id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '关键词ID',
    keyword VARCHAR(100) NOT NULL COMMENT '关键词内容',
    category VARCHAR(50) NOT NULL COMMENT '关键词类别',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',

    UNIQUE KEY unique_keyword_category (keyword, category),
    INDEX idx_category (category)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='敏感关键词表';

-- 8. 预警记录表 - alerts
-- 记录命中敏感关键词的内容
CREATE TABLE alerts (
    alert_id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '预警ID',
    content_type ENUM('POST', 'COMMENT') NOT NULL COMMENT '内容类型',
    content_id BIGINT NOT NULL COMMENT '内容ID（帖子或评论）',
    keyword_id BIGINT NOT NULL COMMENT '关联关键词ID',
    summary VARCHAR(200) NULL COMMENT '内容摘要',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',

    FOREIGN KEY (keyword_id) REFERENCES keywords(keyword_id),
    INDEX idx_created_at (created_at DESC),
    INDEX idx_keyword_id (keyword_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='预警记录表';

-- ============================================================================
-- 表创建完成
-- ============================================================================
-- 总结：
-- - 创建了8个核心表（Users, Posts, Comments, Hashtags, Post_Hashtags, Post_Sentiments, Keywords, Alerts）
-- - 设置了PRIMARY KEY（主键约束），使用BIGINT类型
-- - 设置了FOREIGN KEY（外键约束）带ON DELETE CASCADE（级联删除）
-- - 设置了UNIQUE约束（唯一约束）
-- - 设置了NOT NULL约束（非空约束）
-- - 设置了DEFAULT值（默认值）
-- - 设置了TIMESTAMP自动更新（时间字段）
-- - 为常用字段创建了INDEX（索引）
-- - Post_Sentiments表采用直接存储模式（非关联表）
-- - 新增Alerts表用于关键词预警功能
-- - Users表新增Role和Status枚举字段
-- ============================================================================
