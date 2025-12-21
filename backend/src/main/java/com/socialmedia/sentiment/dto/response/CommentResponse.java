package com.socialmedia.sentiment.dto.response;

import com.socialmedia.sentiment.entity.Comment;

import java.time.LocalDateTime;

public class CommentResponse {

    private Long commentId;
    private Long postId;
    private Long userId;
    private String username;
    private String content;
    private String postContent;
    private LocalDateTime createdAt;

    public CommentResponse() {}

    public CommentResponse(Comment comment) {
        this.commentId = comment.getCommentId();
        this.postId = comment.getPostId();
        this.userId = comment.getUserId();
        this.content = comment.getContent();
        this.createdAt = comment.getCreatedAt();
    }

    public Long getCommentId() {
        return commentId;
    }

    public void setCommentId(Long commentId) {
        this.commentId = commentId;
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

    public String getPostContent() {
        return postContent;
    }

    public void setPostContent(String postContent) {
        this.postContent = postContent;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }
}
