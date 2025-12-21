package com.socialmedia.sentiment.controller;

import com.socialmedia.sentiment.dto.response.PageResponse;
import com.socialmedia.sentiment.dto.response.UserResponse;
import com.socialmedia.sentiment.entity.Alert;
import com.socialmedia.sentiment.entity.Keyword;
import com.socialmedia.sentiment.service.AlertService;
import com.socialmedia.sentiment.service.KeywordService;
import com.socialmedia.sentiment.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/admin")
public class AdminController {

    private final UserService userService;
    private final KeywordService keywordService;
    private final AlertService alertService;

    @Autowired
    public AdminController(UserService userService, KeywordService keywordService, AlertService alertService) {
        this.userService = userService;
        this.keywordService = keywordService;
        this.alertService = alertService;
    }

    @GetMapping("/users")
    public ResponseEntity<PageResponse<UserResponse>> getAllUsers(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {

        List<UserResponse> users = userService.findAll(page, size);
        long total = userService.count();

        PageResponse<UserResponse> response = new PageResponse<>();
        response.setContent(users);
        response.setPage(page);
        response.setSize(size);
        response.setTotalElements(total);
        response.setTotalPages((int) Math.ceil((double) total / size));

        return ResponseEntity.ok(response);
    }

    @GetMapping("/users/{userId}")
    public ResponseEntity<UserResponse> getUserById(@PathVariable Long userId) {
        return ResponseEntity.ok(new UserResponse(userService.findById(userId)));
    }

    @PutMapping("/users/{userId}/status")
    public ResponseEntity<Map<String, Object>> updateUserStatus(
            @PathVariable Long userId,
            @RequestBody Map<String, String> request) {

        String status = request.get("status");
        if (status == null || status.isEmpty()) {
            throw new IllegalArgumentException("状态不能为空");
        }

        userService.updateStatus(userId, status);

        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("message", "用户状态更新成功");
        response.put("userId", userId);
        response.put("newStatus", status);

        return ResponseEntity.ok(response);
    }

    @PutMapping("/users/{userId}/enable")
    public ResponseEntity<Map<String, Object>> enableUser(@PathVariable Long userId) {
        userService.updateStatus(userId, "ACTIVE");

        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("message", "用户已启用");
        response.put("userId", userId);

        return ResponseEntity.ok(response);
    }

    @PutMapping("/users/{userId}/disable")
    public ResponseEntity<Map<String, Object>> disableUser(@PathVariable Long userId) {
        userService.updateStatus(userId, "DISABLED");

        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("message", "用户已禁用");
        response.put("userId", userId);

        return ResponseEntity.ok(response);
    }

    @DeleteMapping("/users/{userId}")
    public ResponseEntity<Map<String, Object>> deleteUser(@PathVariable Long userId) {
        userService.deleteUser(userId);

        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("message", "用户已删除，相关帖子和评论已级联删除");
        response.put("userId", userId);

        return ResponseEntity.ok(response);
    }

    // ==================== 关键词管理 ====================

    @GetMapping("/keywords")
    public ResponseEntity<PageResponse<Keyword>> getAllKeywords(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {

        List<Keyword> keywords = keywordService.findAll(page, size);
        long total = keywordService.count();

        PageResponse<Keyword> response = new PageResponse<>();
        response.setContent(keywords);
        response.setPage(page);
        response.setSize(size);
        response.setTotalElements(total);
        response.setTotalPages((int) Math.ceil((double) total / size));

        return ResponseEntity.ok(response);
    }

    @GetMapping("/keywords/{keywordId}")
    public ResponseEntity<Keyword> getKeywordById(@PathVariable Long keywordId) {
        return ResponseEntity.ok(keywordService.findById(keywordId));
    }

    @PostMapping("/keywords")
    public ResponseEntity<Keyword> createKeyword(@RequestBody Map<String, String> request) {
        String keyword = request.get("keyword");
        String category = request.get("category");

        if (keyword == null || keyword.trim().isEmpty()) {
            throw new IllegalArgumentException("关键词不能为空");
        }

        Keyword created = keywordService.create(keyword.trim(), category);
        return ResponseEntity.ok(created);
    }

    @PutMapping("/keywords/{keywordId}")
    public ResponseEntity<Keyword> updateKeyword(
            @PathVariable Long keywordId,
            @RequestBody Map<String, String> request) {

        String keyword = request.get("keyword");
        String category = request.get("category");

        if (keyword == null || keyword.trim().isEmpty()) {
            throw new IllegalArgumentException("关键词不能为空");
        }

        Keyword updated = keywordService.update(keywordId, keyword.trim(), category);
        return ResponseEntity.ok(updated);
    }

    @DeleteMapping("/keywords/{keywordId}")
    public ResponseEntity<Map<String, Object>> deleteKeyword(@PathVariable Long keywordId) {
        keywordService.delete(keywordId);

        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("message", "关键词已删除");
        response.put("keywordId", keywordId);

        return ResponseEntity.ok(response);
    }

    // ==================== 预警管理 ====================

    @GetMapping("/alerts")
    public ResponseEntity<PageResponse<Alert>> getAlerts(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size,
            @RequestParam(defaultValue = "24") int hours) {

        List<Alert> alerts = alertService.findRecent(hours, page, size);
        long total = alertService.countRecent(hours);

        PageResponse<Alert> response = new PageResponse<>();
        response.setContent(alerts);
        response.setPage(page);
        response.setSize(size);
        response.setTotalElements(total);
        response.setTotalPages((int) Math.ceil((double) total / size));

        return ResponseEntity.ok(response);
    }

    @GetMapping("/alerts/{alertId}")
    public ResponseEntity<Alert> getAlertById(@PathVariable Long alertId) {
        return ResponseEntity.ok(alertService.findById(alertId));
    }

    @PutMapping("/alerts/{alertId}/handle")
    public ResponseEntity<Map<String, Object>> handleAlert(@PathVariable Long alertId) {
        alertService.toggleStatus(alertId);

        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("message", "预警状态已更新");
        response.put("alertId", alertId);

        return ResponseEntity.ok(response);
    }

    @DeleteMapping("/alerts/{alertId}")
    public ResponseEntity<Map<String, Object>> deleteAlert(@PathVariable Long alertId) {
        alertService.delete(alertId);

        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("message", "预警已删除");
        response.put("alertId", alertId);

        return ResponseEntity.ok(response);
    }

    @PostMapping("/alerts/scan")
    public ResponseEntity<Map<String, Object>> scanAllPosts() {
        alertService.scanAllPosts();

        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("message", "全量扫描已完成");

        return ResponseEntity.ok(response);
    }
}
