package com.socialmedia.sentiment.service;

import com.socialmedia.sentiment.entity.Alert;
import com.socialmedia.sentiment.entity.Keyword;
import com.socialmedia.sentiment.entity.Post;
import com.socialmedia.sentiment.mapper.AlertMapper;
import com.socialmedia.sentiment.mapper.KeywordMapper;
import com.socialmedia.sentiment.mapper.PostMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class AlertService {

    private final AlertMapper alertMapper;
    private final PostMapper postMapper;
    private final KeywordMapper keywordMapper;

    @Autowired
    public AlertService(AlertMapper alertMapper, PostMapper postMapper, KeywordMapper keywordMapper) {
        this.alertMapper = alertMapper;
        this.postMapper = postMapper;
        this.keywordMapper = keywordMapper;
    }

    public Alert findById(Long alertId) {
        Alert alert = alertMapper.findById(alertId);
        if (alert == null) {
            throw new IllegalArgumentException("预警不存在");
        }
        return alert;
    }

    public List<Alert> findAll(int page, int size) {
        int offset = page * size;
        return alertMapper.findAll(offset, size);
    }

    public List<Alert> findRecent(int hours, int page, int size) {
        int offset = page * size;
        return alertMapper.findRecent(hours, offset, size);
    }

    public List<Alert> findByDateRange(LocalDateTime startDate, LocalDateTime endDate, int page, int size) {
        int offset = page * size;
        return alertMapper.findByDateRange(startDate, endDate, offset, size);
    }

    public long count() {
        return alertMapper.count();
    }

    public long countRecent(int hours) {
        return alertMapper.countRecent(hours);
    }

    @Transactional
    public Alert create(String contentType, Long contentId, Long keywordId, String summary) {
        Alert alert = new Alert(contentType, contentId, keywordId, summary);
        alertMapper.insert(alert);
        return alert;
    }

    @Transactional
    public void toggleStatus(Long alertId) {
        findById(alertId); // 验证存在
        alertMapper.updateStatus(alertId);
    }

    @Transactional
    public void delete(Long alertId) {
        findById(alertId); // 验证存在
        alertMapper.deleteById(alertId);
    }

    @Transactional
    public void deleteByContent(String contentType, Long contentId) {
        alertMapper.deleteByContent(contentType, contentId);
    }

    @Transactional
    public void deleteByUserId(Long userId) {
        alertMapper.deleteByUserId(userId);
    }

    @Transactional
    public void scanAllPosts() {
        // 1. 获取所有帖子
        // 为了稳健性，我们使用分页处理
        int pageSize = 100;
        int offset = 0;

        List<Keyword> keywords = keywordMapper.findAll(0, 1000); // 假设关键词不超过1000个
        if (keywords.isEmpty()) {
            return;
        }

        while (true) {
            List<Post> posts = postMapper.findAll(offset, pageSize);
            if (posts.isEmpty()) {
                break;
            }

            for (Post post : posts) {
                String content = post.getContent();
                if (content == null)
                    continue;

                // 获取当前帖子已存在的预警，避免重复创建
                // 用户需求：不覆盖旧的，而是生成新的（解释为：如果不存在则生成，如果存在则保留旧的）
                List<Alert> existingAlerts = alertMapper.findByContent("POST", post.getPostId());
                java.util.Set<Long> existingKeywordIds = existingAlerts.stream()
                        .map(Alert::getKeywordId)
                        .collect(java.util.stream.Collectors.toSet());

                for (Keyword keyword : keywords) {
                    String kWord = keyword.getKeyword();
                    if (kWord == null)
                        continue;

                    // 如果该关键词已经有对应的预警，则跳过（保留旧的）
                    if (existingKeywordIds.contains(keyword.getKeywordId())) {
                        continue;
                    }

                    // 忽略大小写匹配
                    if (content.toLowerCase().contains(kWord.toLowerCase())) {
                        create("POST", post.getPostId(), keyword.getKeywordId(),
                                "发现敏感词: " + kWord + "，在内容: " + content.substring(0, Math.min(content.length(), 20))
                                        + "...");
                    }
                }
            }
            offset += pageSize;
        }
    }
}
