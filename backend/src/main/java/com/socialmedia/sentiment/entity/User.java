package com.socialmedia.sentiment.entity;

import java.time.LocalDateTime;

public class User {
    private Long userId;
    private String username;
    private String email;
    private String passwordHash;
    private String role; // USER or ADMIN
    private String status; // ACTIVE or DISABLED
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    public User() {}

    public User(String username, String email, String passwordHash, String role, String status) {
        this.username = username;
        this.email = email;
        this.passwordHash = passwordHash;
        this.role = role;
        this.status = status;
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

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPasswordHash() {
        return passwordHash;
    }

    public void setPasswordHash(String passwordHash) {
        this.passwordHash = passwordHash;
    }

    public String getRole() {
        return role;
    }

    public void setRole(String role) {
        this.role = role;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
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

    public boolean isAdmin() {
        return "ADMIN".equals(role);
    }

    public boolean isActive() {
        return "ACTIVE".equals(status);
    }
}
