package com.socialmedia.sentiment.entity;

import java.time.LocalDateTime;

public class PostHashtag {
    private Long postId;
    private Long hashtagId;
    private LocalDateTime createdAt;

    public PostHashtag() {}

    public PostHashtag(Long postId, Long hashtagId) {
        this.postId = postId;
        this.hashtagId = hashtagId;
    }

    public Long getPostId() {
        return postId;
    }

    public void setPostId(Long postId) {
        this.postId = postId;
    }

    public Long getHashtagId() {
        return hashtagId;
    }

    public void setHashtagId(Long hashtagId) {
        this.hashtagId = hashtagId;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }
}
