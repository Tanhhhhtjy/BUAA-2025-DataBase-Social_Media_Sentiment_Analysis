-- ============================================================================
-- 社交媒体舆情分析系统 - 数据库表创建脚本
-- ============================================================================
-- 脚本说明: 创建8个核心实体表及其关系
-- 创建时间: 2025年
-- 备注: 已更新以匹配设计文档 v1.0.0
-- ============================================================================

-- 1. 用户表 - Users
-- 存储系统用户信息
CREATE TABLE Users (
    UserID BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '用户ID',
    Username VARCHAR(50) NOT NULL UNIQUE COMMENT '用户名（唯一）',
    Email VARCHAR(100) NOT NULL UNIQUE COMMENT '邮箱（唯一）',
    PasswordHash VARCHAR(255) NOT NULL COMMENT '密码哈希值',
    Role ENUM('USER', 'ADMIN') NOT NULL DEFAULT 'USER' COMMENT '用户角色（USER/ADMIN）',
    Status ENUM('ACTIVE', 'DISABLED') NOT NULL DEFAULT 'ACTIVE' COMMENT '用户状态（ACTIVE/DISABLED）',
    CreatedAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    UpdatedAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',

    INDEX idx_username (Username),
    INDEX idx_email (Email),
    INDEX idx_status (Status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户表';

-- 2. 帖子表 - Posts
-- 存储用户发布的内容
CREATE TABLE Posts (
    PostID BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '帖子ID',
    UserID BIGINT NOT NULL COMMENT '发布者用户ID',
    Content TEXT NOT NULL COMMENT '帖子内容',
    CreatedAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    UpdatedAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',

    FOREIGN KEY (UserID) REFERENCES Users(UserID) ON DELETE CASCADE,
    INDEX idx_user_id (UserID),
    INDEX idx_created_at (CreatedAt DESC),
    INDEX idx_user_created (UserID, CreatedAt DESC)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='帖子表';

-- 3. 评论表 - Comments
-- 存储对帖子的评论
CREATE TABLE Comments (
    CommentID BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '评论ID',
    PostID BIGINT NOT NULL COMMENT '所属帖子ID',
    UserID BIGINT NOT NULL COMMENT '评论者用户ID',
    Content VARCHAR(500) NOT NULL COMMENT '评论内容',
    CreatedAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',

    FOREIGN KEY (PostID) REFERENCES Posts(PostID) ON DELETE CASCADE,
    FOREIGN KEY (UserID) REFERENCES Users(UserID) ON DELETE CASCADE,
    INDEX idx_post_id (PostID),
    INDEX idx_user_id (UserID),
    INDEX idx_created_at (CreatedAt)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='评论表';

-- 4. 话题标签表 - Hashtags
-- 存储预定义的话题标签
CREATE TABLE Hashtags (
    HashtagID BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '话题ID',
    HashtagName VARCHAR(100) NOT NULL UNIQUE COMMENT '话题名称（唯一）',
    CreatedAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',

    INDEX idx_hashtag_name (HashtagName)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='话题标签表';

-- 5. 帖子-话题关联表 - Post_Hashtags (M:N关系)
-- 存储帖子与话题的关联关系
CREATE TABLE Post_Hashtags (
    PostID BIGINT NOT NULL COMMENT '帖子ID',
    HashtagID BIGINT NOT NULL COMMENT '话题ID',
    CreatedAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',

    PRIMARY KEY (PostID, HashtagID),
    FOREIGN KEY (PostID) REFERENCES Posts(PostID) ON DELETE CASCADE,
    FOREIGN KEY (HashtagID) REFERENCES Hashtags(HashtagID) ON DELETE CASCADE,
    INDEX idx_hashtag_id (HashtagID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='帖子-话题关联表';

-- 6. 帖子情感分析结果表 - Post_Sentiments
-- 存储帖子的情感分析结果（直接存储，非关联表）
CREATE TABLE Post_Sentiments (
    SentimentID BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '情感分析记录ID',
    PostID BIGINT NOT NULL UNIQUE COMMENT '关联帖子ID',
    Sentiment ENUM('POSITIVE', 'NEUTRAL', 'NEGATIVE', 'UNANALYZED') NOT NULL COMMENT '情感类别',
    Confidence DECIMAL(5,4) NULL COMMENT '置信度（0.0000-1.0000）',
    AnalyzedAt TIMESTAMP NULL COMMENT '分析时间',
    CreatedAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',

    FOREIGN KEY (PostID) REFERENCES Posts(PostID) ON DELETE CASCADE,
    INDEX idx_sentiment (Sentiment),
    INDEX idx_analyzed_at (AnalyzedAt)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='帖子情感分析结果表';

-- 7. 敏感关键词表 - Keywords
-- 存储舆情监测的关键词（用于敏感词预警）
CREATE TABLE Keywords (
    KeywordID BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '关键词ID',
    Keyword VARCHAR(100) NOT NULL COMMENT '关键词内容',
    Category VARCHAR(50) NOT NULL COMMENT '关键词类别',
    CreatedAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    UpdatedAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',

    UNIQUE KEY unique_keyword_category (Keyword, Category),
    INDEX idx_category (Category)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='敏感关键词表';

-- 8. 预警记录表 - Alerts
-- 记录命中敏感关键词的内容
CREATE TABLE Alerts (
    AlertID BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '预警ID',
    ContentType ENUM('POST', 'COMMENT') NOT NULL COMMENT '内容类型',
    ContentID BIGINT NOT NULL COMMENT '内容ID（帖子或评论）',
    KeywordID BIGINT NOT NULL COMMENT '关联关键词ID',
    Summary VARCHAR(200) NULL COMMENT '内容摘要',
    CreatedAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',

    FOREIGN KEY (KeywordID) REFERENCES Keywords(KeywordID),
    INDEX idx_created_at (CreatedAt DESC),
    INDEX idx_keyword_id (KeywordID)
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
