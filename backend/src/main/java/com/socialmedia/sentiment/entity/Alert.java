package com.socialmedia.sentiment.entity;

import java.time.LocalDateTime;

public class Alert {
    private Long alertId;
    private String contentType; // POST or COMMENT
    private Long contentId;
    private Long keywordId;
    private String summary;
    private Integer status; // 0: Unhandled, 1: Handled
    private LocalDateTime createdAt;

    public Alert() {
    }

    public Alert(String contentType, Long contentId, Long keywordId, String summary) {
        this.contentType = contentType;
        this.contentId = contentId;
        this.keywordId = keywordId;
        this.summary = summary;
        this.status = 0;
    }

    public Long getAlertId() {
        return alertId;
    }

    public void setAlertId(Long alertId) {
        this.alertId = alertId;
    }

    public String getContentType() {
        return contentType;
    }

    public void setContentType(String contentType) {
        this.contentType = contentType;
    }

    public Long getContentId() {
        return contentId;
    }

    public void setContentId(Long contentId) {
        this.contentId = contentId;
    }

    public Long getKeywordId() {
        return keywordId;
    }

    public void setKeywordId(Long keywordId) {
        this.keywordId = keywordId;
    }

    public String getSummary() {
        return summary;
    }

    public void setSummary(String summary) {
        this.summary = summary;
    }

    public Integer getStatus() {
        return status;
    }

    public void setStatus(Integer status) {
        this.status = status;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    // 关联字段 (用于查询结果)
    private String keyword;
    private String username;
    private Long userId;

    public String getKeyword() {
        return keyword;
    }

    public void setKeyword(String keyword) {
        this.keyword = keyword;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public Long getUserId() {
        return userId;
    }

    public void setUserId(Long userId) {
        this.userId = userId;
    }
}
