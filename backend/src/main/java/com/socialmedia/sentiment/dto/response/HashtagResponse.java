package com.socialmedia.sentiment.dto.response;

import com.socialmedia.sentiment.entity.Hashtag;

import java.time.LocalDateTime;

public class HashtagResponse {

    private Long hashtagId;
    private String tagName;
    private LocalDateTime createdAt;
    private long postCount;

    public HashtagResponse() {}

    public HashtagResponse(Hashtag hashtag) {
        this.hashtagId = hashtag.getHashtagId();
        this.tagName = hashtag.getTagName();
        this.createdAt = hashtag.getCreatedAt();
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

    public long getPostCount() {
        return postCount;
    }

    public void setPostCount(long postCount) {
        this.postCount = postCount;
    }
}
