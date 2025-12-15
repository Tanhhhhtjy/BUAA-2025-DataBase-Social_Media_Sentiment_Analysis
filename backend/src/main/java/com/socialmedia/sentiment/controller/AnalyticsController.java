package com.socialmedia.sentiment.controller;

import com.socialmedia.sentiment.service.AnalyticsService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/analytics")
public class AnalyticsController {

    private final AnalyticsService analyticsService;

    @Autowired
    public AnalyticsController(AnalyticsService analyticsService) {
        this.analyticsService = analyticsService;
    }

    @GetMapping("/hot-topics")
    public ResponseEntity<List<Map<String, Object>>> getHotTopics(
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime startDate,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime endDate,
            @RequestParam(defaultValue = "10") int limit) {

        if (startDate == null) {
            startDate = LocalDateTime.now().minusDays(30);
        }
        if (endDate == null) {
            endDate = LocalDateTime.now();
        }

        List<Map<String, Object>> hotTopics = analyticsService.getHotTopics(startDate, endDate, limit);
        return ResponseEntity.ok(hotTopics);
    }

    @GetMapping("/sentiment-trend")
    public ResponseEntity<List<Map<String, Object>>> getSentimentTrend(
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime startDate,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime endDate) {

        if (startDate == null) {
            startDate = LocalDateTime.now().minusDays(30);
        }
        if (endDate == null) {
            endDate = LocalDateTime.now();
        }

        List<Map<String, Object>> trend = analyticsService.getSentimentTrend(startDate, endDate);
        return ResponseEntity.ok(trend);
    }

    @GetMapping("/sentiment-distribution")
    public ResponseEntity<List<Map<String, Object>>> getSentimentDistribution(
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime startDate,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime endDate) {

        if (startDate == null) {
            startDate = LocalDateTime.now().minusDays(30);
        }
        if (endDate == null) {
            endDate = LocalDateTime.now();
        }

        List<Map<String, Object>> distribution = analyticsService.getSentimentDistribution(startDate, endDate);
        return ResponseEntity.ok(distribution);
    }

    @GetMapping("/stats")
    public ResponseEntity<Map<String, Object>> getOverallStats(
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime startDate,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime endDate) {

        if (startDate == null) {
            startDate = LocalDateTime.now().minusDays(30);
        }
        if (endDate == null) {
            endDate = LocalDateTime.now();
        }

        Map<String, Object> stats = analyticsService.getOverallStats(startDate, endDate);
        return ResponseEntity.ok(stats);
    }
}
