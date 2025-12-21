package com.socialmedia.sentiment.service;

import com.socialmedia.sentiment.entity.Keyword;
import com.socialmedia.sentiment.mapper.AlertMapper;
import com.socialmedia.sentiment.mapper.KeywordMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class KeywordService {

    private final KeywordMapper keywordMapper;
    private final AlertMapper alertMapper;

    @Autowired
    public KeywordService(KeywordMapper keywordMapper, AlertMapper alertMapper) {
        this.keywordMapper = keywordMapper;
        this.alertMapper = alertMapper;
    }

    public Keyword findById(Long keywordId) {
        Keyword keyword = keywordMapper.findById(keywordId);
        if (keyword == null) {
            throw new IllegalArgumentException("关键词不存在");
        }
        return keyword;
    }

    public List<Keyword> findAll(int page, int size) {
        int offset = page * size;
        return keywordMapper.findAll(offset, size);
    }

    public List<Keyword> findByCategory(String category) {
        return keywordMapper.findByCategory(category);
    }

    public long count() {
        return keywordMapper.count();
    }

    @Transactional
    public Keyword create(String keyword, String category) {
        if (keywordMapper.existsByKeyword(keyword)) {
            throw new IllegalArgumentException("关键词已存在");
        }

        Keyword kw = new Keyword(keyword, category);
        keywordMapper.insert(kw);
        return kw;
    }

    @Transactional
    public Keyword update(Long keywordId, String keyword, String category) {
        Keyword existing = findById(keywordId);

        // 检查是否与其他关键词重复
        Keyword byKeyword = keywordMapper.findByKeyword(keyword);
        if (byKeyword != null && !byKeyword.getKeywordId().equals(keywordId)) {
            throw new IllegalArgumentException("关键词已存在");
        }

        existing.setKeyword(keyword);
        existing.setCategory(category);
        keywordMapper.update(existing);
        return existing;
    }

    @Transactional
    public void delete(Long keywordId) {
        findById(keywordId); // 验证存在

        // 删除关联的预警
        alertMapper.deleteByKeywordId(keywordId);

        keywordMapper.deleteById(keywordId);
    }

    public boolean existsByKeyword(String keyword) {
        return keywordMapper.existsByKeyword(keyword);
    }
}
