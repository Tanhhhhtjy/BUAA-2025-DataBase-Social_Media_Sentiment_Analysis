package com.socialmedia.sentiment.dto.response;

import com.socialmedia.sentiment.entity.Hashtag;
import com.socialmedia.sentiment.entity.Post;
import com.socialmedia.sentiment.entity.PostSentiment;

import java.time.LocalDateTime;
import java.util.List;

public class PostResponse {

    private Long postId;
    private Long userId;
    private String username;
    private String content;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private List<String> hashtags;
    private String sentiment;
    private Double confidence;
    private long commentCount;

    public PostResponse() {}

    public PostResponse(Post post) {
        this.postId = post.getPostId();
        this.userId = post.getUserId();
        this.content = post.getContent();
        this.createdAt = post.getCreatedAt();
        this.updatedAt = post.getUpdatedAt();
    }

    public Long getPostId() {
        return postId;
    }

    public void setPostId(Long postId) {
        this.postId = postId;
    }

    public Long getUserId() {
        return userId;
    }

    public void setUserId(Long userId) {
        this.userId = userId;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getContent() {
        return content;
    }

    public void setContent(String content) {
        this.content = content;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(LocalDateTime updatedAt) {
        this.updatedAt = updatedAt;
    }

    public List<String> getHashtags() {
        return hashtags;
    }

    public void setHashtags(List<String> hashtags) {
        this.hashtags = hashtags;
    }

    public String getSentiment() {
        return sentiment;
    }

    public void setSentiment(String sentiment) {
        this.sentiment = sentiment;
    }

    public Double getConfidence() {
        return confidence;
    }

    public void setConfidence(Double confidence) {
        this.confidence = confidence;
    }

    public long getCommentCount() {
        return commentCount;
    }

    public void setCommentCount(long commentCount) {
        this.commentCount = commentCount;
    }
}
