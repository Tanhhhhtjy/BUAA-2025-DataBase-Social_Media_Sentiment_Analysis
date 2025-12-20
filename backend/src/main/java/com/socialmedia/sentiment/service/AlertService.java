package com.socialmedia.sentiment.service;

import com.socialmedia.sentiment.entity.Alert;
import com.socialmedia.sentiment.mapper.AlertMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class AlertService {

    private final AlertMapper alertMapper;

    @Autowired
    public AlertService(AlertMapper alertMapper) {
        this.alertMapper = alertMapper;
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
    public void markAsHandled(Long alertId) {
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
}
