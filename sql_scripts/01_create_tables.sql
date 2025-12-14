-- ============================================================================
-- 社交媒体舆情分析系统 - 数据库表创建脚本
-- ============================================================================
-- 脚本说明: 创建8个核心实体表及其关系
-- 创建时间: 2025年
-- ============================================================================

-- 1. 用户表 - Users
-- 存储系统用户信息
CREATE TABLE Users (
    UserID INT PRIMARY KEY AUTO_INCREMENT COMMENT '用户ID',
    Username VARCHAR(50) NOT NULL UNIQUE COMMENT '用户名（唯一）',
    Email VARCHAR(100) NOT NULL UNIQUE COMMENT '邮箱（唯一）',
    PasswordHash VARCHAR(255) NOT NULL COMMENT '密码哈希值',
    Status VARCHAR(20) NOT NULL DEFAULT 'active' COMMENT '用户状态（active/inactive/banned）',
    CreatedAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    UpdatedAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',

    INDEX idx_username (Username),
    INDEX idx_email (Email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户表';

-- 2. 帖子表 - Posts
-- 存储用户发布的内容
CREATE TABLE Posts (
    PostID INT PRIMARY KEY AUTO_INCREMENT COMMENT '帖子ID',
    UserID INT NOT NULL COMMENT '发布者用户ID',
    Content TEXT NOT NULL COMMENT '帖子内容',
    CreatedAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    UpdatedAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',

    FOREIGN KEY (UserID) REFERENCES Users(UserID) ON DELETE CASCADE COMMENT '外键：关联Users表',
    INDEX idx_user_id (UserID),
    INDEX idx_created_at (CreatedAt)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='帖子表';

-- 3. 评论表 - Comments
-- 存储对帖子的评论
CREATE TABLE Comments (
    CommentID INT PRIMARY KEY AUTO_INCREMENT COMMENT '评论ID',
    PostID INT NOT NULL COMMENT '所属帖子ID',
    UserID INT NOT NULL COMMENT '评论者用户ID',
    Content TEXT NOT NULL COMMENT '评论内容',
    CreatedAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    UpdatedAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',

    FOREIGN KEY (PostID) REFERENCES Posts(PostID) ON DELETE CASCADE COMMENT '外键：关联Posts表',
    FOREIGN KEY (UserID) REFERENCES Users(UserID) ON DELETE CASCADE COMMENT '外键：关联Users表',
    INDEX idx_post_id (PostID),
    INDEX idx_user_id (UserID),
    INDEX idx_created_at (CreatedAt)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='评论表';

-- 4. 话题标签表 - Hashtags
-- 存储预定义的话题标签
CREATE TABLE Hashtags (
    HashtagID INT PRIMARY KEY AUTO_INCREMENT COMMENT '话题ID',
    HashtagName VARCHAR(100) NOT NULL UNIQUE COMMENT '话题名称（唯一）',
    CreatedAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',

    INDEX idx_hashtag_name (HashtagName)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='话题标签表';

-- 5. 帖子-话题关联表 - Post_Hashtags (M:N关系)
-- 存储帖子与话题的关联关系
CREATE TABLE Post_Hashtags (
    PostHashtagID INT PRIMARY KEY AUTO_INCREMENT COMMENT '帖子-话题关联ID',
    PostID INT NOT NULL COMMENT '帖子ID',
    HashtagID INT NOT NULL COMMENT '话题ID',
    CreatedAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',

    FOREIGN KEY (PostID) REFERENCES Posts(PostID) ON DELETE CASCADE COMMENT '外键：关联Posts表',
    FOREIGN KEY (HashtagID) REFERENCES Hashtags(HashtagID) ON DELETE CASCADE COMMENT '外键：关联Hashtags表',
    UNIQUE KEY unique_post_hashtag (PostID, HashtagID) COMMENT '复合唯一约束：防止重复关联',
    INDEX idx_post_id (PostID),
    INDEX idx_hashtag_id (HashtagID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='帖子-话题关联表';

-- 6. 情感倾向表 - Sentiments
-- 存储情感分类标签（正面/中立/负面）
CREATE TABLE Sentiments (
    SentimentID INT PRIMARY KEY AUTO_INCREMENT COMMENT '情感ID',
    Label VARCHAR(20) NOT NULL UNIQUE COMMENT '情感标签（正面/中立/负面）',
    Description TEXT COMMENT '情感描述',

    INDEX idx_label (Label)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='情感倾向表';

-- 7. 帖子-情感关联表 - Post_Sentiments (M:N关系)
-- 存储帖子的情感分析结果
CREATE TABLE Post_Sentiments (
    PostSentimentID INT PRIMARY KEY AUTO_INCREMENT COMMENT '帖子-情感关联ID',
    PostID INT NOT NULL COMMENT '帖子ID',
    SentimentID INT NOT NULL COMMENT '情感ID',
    Score DECIMAL(5, 2) NOT NULL DEFAULT 0.5 COMMENT '情感评分（0-1之间）',
    CreatedAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',

    FOREIGN KEY (PostID) REFERENCES Posts(PostID) ON DELETE CASCADE COMMENT '外键：关联Posts表',
    FOREIGN KEY (SentimentID) REFERENCES Sentiments(SentimentID) ON DELETE CASCADE COMMENT '外键：关联Sentiments表',
    UNIQUE KEY unique_post_sentiment (PostID, SentimentID) COMMENT '复合唯一约束：每个帖子每个情感最多一条记录',
    INDEX idx_post_id (PostID),
    INDEX idx_sentiment_id (SentimentID),
    INDEX idx_score (Score)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='帖子-情感关联表';

-- 8. 关键词表 - Keywords
-- 存储舆情监测的关键词（用于敏感词预警）
CREATE TABLE Keywords (
    KeywordID INT PRIMARY KEY AUTO_INCREMENT COMMENT '关键词ID',
    Keyword VARCHAR(100) NOT NULL UNIQUE COMMENT '关键词（唯一）',
    Category VARCHAR(50) NOT NULL COMMENT '关键词分类（如：政治敏感词、不当言论等）',
    CreatedAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',

    INDEX idx_keyword (Keyword),
    INDEX idx_category (Category)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='舆情监测关键词表';

-- ============================================================================
-- 表创建完成
-- ============================================================================
-- 总结：
-- - 创建了8个核心表
-- - 设置了PRIMARY KEY（主键约束）
-- - 设置了FOREIGN KEY（外键约束）带ON DELETE CASCADE（级联删除）
-- - 设置了UNIQUE约束（唯一约束）
-- - 设置了NOT NULL约束（非空约束）
-- - 设置了DEFAULT值（默认值）
-- - 设置了TIMESTAMP自动更新（时间字段）
-- - 为常用字段创建了INDEX（索引）
-- ============================================================================
