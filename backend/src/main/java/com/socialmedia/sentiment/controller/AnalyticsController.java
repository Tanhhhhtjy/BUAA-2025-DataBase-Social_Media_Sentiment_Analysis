package com.socialmedia.sentiment.controller;

import com.socialmedia.sentiment.service.AnalyticsService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
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
            @RequestParam(required = false) @DateTimeFormat(pattern = "yyyy-MM-dd") LocalDate startDate,
            @RequestParam(required = false) @DateTimeFormat(pattern = "yyyy-MM-dd") LocalDate endDate,
            @RequestParam(defaultValue = "10") int limit) {

        LocalDateTime startDateTime = startDate != null ? startDate.atStartOfDay() : LocalDateTime.now().minusDays(30);
        LocalDateTime endDateTime = endDate != null ? endDate.atTime(LocalTime.MAX) : LocalDateTime.now();

        List<Map<String, Object>> hotTopics = analyticsService.getHotTopics(startDateTime, endDateTime, limit);
        return ResponseEntity.ok(hotTopics);
    }

    @GetMapping("/sentiment-trend")
    public ResponseEntity<List<Map<String, Object>>> getSentimentTrend(
            @RequestParam(required = false) @DateTimeFormat(pattern = "yyyy-MM-dd") LocalDate startDate,
            @RequestParam(required = false) @DateTimeFormat(pattern = "yyyy-MM-dd") LocalDate endDate) {

        LocalDateTime startDateTime = startDate != null ? startDate.atStartOfDay() : LocalDateTime.now().minusDays(30);
        LocalDateTime endDateTime = endDate != null ? endDate.atTime(LocalTime.MAX) : LocalDateTime.now();

        List<Map<String, Object>> trend = analyticsService.getSentimentTrend(startDateTime, endDateTime);
        return ResponseEntity.ok(trend);
    }

    @GetMapping("/sentiment-distribution")
    public ResponseEntity<List<Map<String, Object>>> getSentimentDistribution(
            @RequestParam(required = false) @DateTimeFormat(pattern = "yyyy-MM-dd") LocalDate startDate,
            @RequestParam(required = false) @DateTimeFormat(pattern = "yyyy-MM-dd") LocalDate endDate) {

        LocalDateTime startDateTime = startDate != null ? startDate.atStartOfDay() : LocalDateTime.now().minusDays(30);
        LocalDateTime endDateTime = endDate != null ? endDate.atTime(LocalTime.MAX) : LocalDateTime.now();

        List<Map<String, Object>> distribution = analyticsService.getSentimentDistribution(startDateTime, endDateTime);
        return ResponseEntity.ok(distribution);
    }

    @GetMapping("/stats")
    public ResponseEntity<Map<String, Object>> getOverallStats(
            @RequestParam(required = false) @DateTimeFormat(pattern = "yyyy-MM-dd") LocalDate startDate,
            @RequestParam(required = false) @DateTimeFormat(pattern = "yyyy-MM-dd") LocalDate endDate) {

        LocalDateTime startDateTime = startDate != null ? startDate.atStartOfDay() : LocalDateTime.now().minusDays(30);
        LocalDateTime endDateTime = endDate != null ? endDate.atTime(LocalTime.MAX) : LocalDateTime.now();

        Map<String, Object> stats = analyticsService.getOverallStats(startDateTime, endDateTime);
        return ResponseEntity.ok(stats);
    }
}
