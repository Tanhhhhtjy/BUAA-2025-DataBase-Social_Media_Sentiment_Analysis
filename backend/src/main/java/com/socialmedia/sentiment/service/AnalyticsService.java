package com.socialmedia.sentiment.service;

import com.socialmedia.sentiment.mapper.HashtagMapper;
import com.socialmedia.sentiment.mapper.PostMapper;
import com.socialmedia.sentiment.mapper.SentimentMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class AnalyticsService {

    private final PostMapper postMapper;
    private final HashtagMapper hashtagMapper;
    private final SentimentMapper sentimentMapper;

    @Autowired
    public AnalyticsService(PostMapper postMapper, HashtagMapper hashtagMapper, SentimentMapper sentimentMapper) {
        this.postMapper = postMapper;
        this.hashtagMapper = hashtagMapper;
        this.sentimentMapper = sentimentMapper;
    }

    public List<Map<String, Object>> getHotTopics(LocalDateTime startDate, LocalDateTime endDate, int limit) {
        Map<String, Object> params = new HashMap<>();
        params.put("startDate", startDate);
        params.put("endDate", endDate);
        params.put("limit", limit);

        return getHotTopicsFromDB(params);
    }

    public List<Map<String, Object>> getSentimentTrend(LocalDateTime startDate, LocalDateTime endDate) {
        return sentimentMapper.getDailySentimentTrend(startDate, endDate);
    }

    public List<Map<String, Object>> getSentimentDistribution(LocalDateTime startDate, LocalDateTime endDate) {
        return sentimentMapper.getSentimentDistribution(startDate, endDate);
    }

    private List<Map<String, Object>> getHotTopicsFromDB(Map<String, Object> params) {
        LocalDateTime startDate = (LocalDateTime) params.get("startDate");
        LocalDateTime endDate = (LocalDateTime) params.get("endDate");
        int limit = (int) params.get("limit");

        return hashtagMapper.getHotTopics(startDate, endDate, limit);
    }

    public Map<String, Object> getOverallStats(LocalDateTime startDate, LocalDateTime endDate) {
        Map<String, Object> stats = new HashMap<>();

        long totalPosts = postMapper.countByDateRange(startDate, endDate);

        List<Map<String, Object>> distribution = getSentimentDistribution(startDate, endDate);

        int positiveCount = 0;
        int neutralCount = 0;
        int negativeCount = 0;
        int unanalyzedCount = 0;

        for (Map<String, Object> item : distribution) {
            String sentiment = (String) item.get("sentiment");
            long count = (long) item.get("count");
            switch (sentiment) {
                case "POSITIVE":
                    positiveCount = (int) count;
                    break;
                case "NEUTRAL":
                    neutralCount = (int) count;
                    break;
                case "NEGATIVE":
                    negativeCount = (int) count;
                    break;
                case "UNANALYZED":
                    unanalyzedCount = (int) count;
                    break;
            }
        }

        stats.put("totalPosts", totalPosts);
        stats.put("positivePosts", positiveCount);
        stats.put("neutralPosts", neutralCount);
        stats.put("negativePosts", negativeCount);
        stats.put("unanalyzedPosts", unanalyzedCount);

        return stats;
    }
}
