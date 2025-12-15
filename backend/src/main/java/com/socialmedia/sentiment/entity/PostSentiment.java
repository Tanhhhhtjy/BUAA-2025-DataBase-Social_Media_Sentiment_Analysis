package com.socialmedia.sentiment.entity;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public class PostSentiment {
    private Long sentimentId;
    private Long postId;
    private String sentiment; // POSITIVE, NEUTRAL, NEGATIVE, UNANALYZED
    private BigDecimal confidence; // 0.0000-1.0000
    private LocalDateTime analyzedAt;
    private LocalDateTime createdAt;

    public PostSentiment() {}

    public PostSentiment(Long postId, String sentiment, BigDecimal confidence) {
        this.postId = postId;
        this.sentiment = sentiment;
        this.confidence = confidence;
    }

    public Long getSentimentId() {
        return sentimentId;
    }

    public void setSentimentId(Long sentimentId) {
        this.sentimentId = sentimentId;
    }

    public Long getPostId() {
        return postId;
    }

    public void setPostId(Long postId) {
        this.postId = postId;
    }

    public String getSentiment() {
        return sentiment;
    }

    public void setSentiment(String sentiment) {
        this.sentiment = sentiment;
    }

    public BigDecimal getConfidence() {
        return confidence;
    }

    public void setConfidence(BigDecimal confidence) {
        this.confidence = confidence;
    }

    public LocalDateTime getAnalyzedAt() {
        return analyzedAt;
    }

    public void setAnalyzedAt(LocalDateTime analyzedAt) {
        this.analyzedAt = analyzedAt;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public boolean isAnalyzed() {
        return !("UNANALYZED".equals(sentiment));
    }

    public boolean isPositive() {
        return "POSITIVE".equals(sentiment);
    }

    public boolean isNegative() {
        return "NEGATIVE".equals(sentiment);
    }

    public boolean isNeutral() {
        return "NEUTRAL".equals(sentiment);
    }
}
