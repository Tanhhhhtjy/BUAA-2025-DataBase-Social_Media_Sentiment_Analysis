package com.socialmedia.sentiment.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.DatabaseMetaData;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;

/**
 * 健康检查控制器
 */
@RestController
@RequestMapping("/health")
public class HealthController {

    @Autowired
    private DataSource dataSource;

    /**
     * 简单健康检查
     */
    @GetMapping("/check")
    public ResponseEntity<Map<String, Object>> healthCheck() {
        Map<String, Object> result = new HashMap<>();
        result.put("status", "UP");
        result.put("timestamp", LocalDateTime.now());
        result.put("service", "social-media-sentiment-api");
        result.put("version", "1.0.0");

        return ResponseEntity.ok(result);
    }

    /**
     * 详细健康信息
     */
    @GetMapping("/detailed")
    public ResponseEntity<Map<String, Object>> detailedHealthCheck() {
        Map<String, Object> result = new HashMap<>();
        result.put("status", "UP");
        result.put("timestamp", LocalDateTime.now());
        result.put("service", "social-media-sentiment-api");
        result.put("version", "1.0.0");

        try (Connection conn = dataSource.getConnection()) {
            DatabaseMetaData meta = conn.getMetaData();
            Map<String, Object> dbInfo = new HashMap<>();
            dbInfo.put("status", conn.isClosed() ? "DOWN" : "UP");
            dbInfo.put("productName", meta.getDatabaseProductName());
            dbInfo.put("productVersion", meta.getDatabaseProductVersion());
            dbInfo.put("url", meta.getURL());
            result.put("database", dbInfo);
        } catch (Exception e) {
            result.put("database", Map.of("status", "DOWN", "error", e.getMessage()));
        }

        // 系统信息
        Map<String, Object> systemInfo = new HashMap<>();
        systemInfo.put("java.version", System.getProperty("java.version"));
        systemInfo.put("os.name", System.getProperty("os.name"));
        systemInfo.put("os.arch", System.getProperty("os.arch"));
        systemInfo.put("available-processors", Runtime.getRuntime().availableProcessors());
        systemInfo.put("max-memory", Runtime.getRuntime().maxMemory());
        systemInfo.put("total-memory", Runtime.getRuntime().totalMemory());
        systemInfo.put("free-memory", Runtime.getRuntime().freeMemory());
        result.put("system", systemInfo);

        return ResponseEntity.ok(result);
    }

    /**
     * 就绪性检查
     */
    @GetMapping("/ready")
    public ResponseEntity<Map<String, Object>> readinessCheck() {
        Map<String, Object> result = new HashMap<>();

        try {
            // 检查数据库连接
            if (dataSource != null && !dataSource.getConnection().isClosed()) {
                result.put("status", "UP");
                result.put("database", "READY");
            } else {
                result.put("status", "DOWN");
                result.put("database", "NOT_READY");
            }
        } catch (Exception e) {
            result.put("status", "DOWN");
            result.put("database", "ERROR");
            result.put("error", e.getMessage());
        }

        return ResponseEntity.ok(result);
    }

    /**
     * 存活检查
     */
    @GetMapping("/live")
    public ResponseEntity<Map<String, Object>> livenessCheck() {
        Map<String, Object> result = new HashMap<>();
        result.put("status", "UP");
        result.put("timestamp", LocalDateTime.now());

        return ResponseEntity.ok(result);
    }
}
