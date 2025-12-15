package com.socialmedia.sentiment.entity;

import java.time.LocalDateTime;

public class Hashtag {
    private Long hashtagId;
    private String tagName;
    private LocalDateTime createdAt;

    public Hashtag() {}

    public Hashtag(String tagName) {
        this.tagName = tagName;
    }

    public Long getHashtagId() {
        return hashtagId;
    }

    public void setHashtagId(Long hashtagId) {
        this.hashtagId = hashtagId;
    }

    public String getTagName() {
        return tagName;
    }

    public void setTagName(String tagName) {
        this.tagName = tagName;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }
}
