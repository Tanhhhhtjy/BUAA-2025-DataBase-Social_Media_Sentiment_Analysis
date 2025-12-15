package com.socialmedia.sentiment.service;

import com.socialmedia.sentiment.dto.response.HashtagResponse;
import com.socialmedia.sentiment.dto.response.PageResponse;
import com.socialmedia.sentiment.entity.Hashtag;
import com.socialmedia.sentiment.mapper.HashtagMapper;
import com.socialmedia.sentiment.mapper.PostMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class HashtagService {

    private final HashtagMapper hashtagMapper;
    private final PostMapper postMapper;

    @Autowired
    public HashtagService(HashtagMapper hashtagMapper, PostMapper postMapper) {
        this.hashtagMapper = hashtagMapper;
        this.postMapper = postMapper;
    }

    public HashtagResponse getHashtagById(Long hashtagId) {
        Hashtag hashtag = hashtagMapper.findById(hashtagId);
        if (hashtag == null) {
            throw new IllegalArgumentException("话题不存在");
        }
        return buildHashtagResponse(hashtag);
    }

    public HashtagResponse getHashtagByTagName(String tagName) {
        Hashtag hashtag = hashtagMapper.findByTagName(tagName.toLowerCase());
        if (hashtag == null) {
            throw new IllegalArgumentException("话题不存在");
        }
        return buildHashtagResponse(hashtag);
    }

    public PageResponse<HashtagResponse> getHashtags(int page, int size) {
        int offset = page * size;
        List<Hashtag> hashtags = hashtagMapper.findAll(offset, size);
        long total = hashtagMapper.count();

        List<HashtagResponse> responses = hashtags.stream()
                .map(this::buildHashtagResponse)
                .collect(Collectors.toList());

        return new PageResponse<>(responses, page, size, total);
    }

    private HashtagResponse buildHashtagResponse(Hashtag hashtag) {
        HashtagResponse response = new HashtagResponse(hashtag);
        long postCount = postMapper.countByHashtagId(hashtag.getHashtagId());
        response.setPostCount(postCount);
        return response;
    }
}
