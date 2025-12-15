package com.socialmedia.sentiment.controller;

import com.socialmedia.sentiment.dto.response.HashtagResponse;
import com.socialmedia.sentiment.dto.response.PageResponse;
import com.socialmedia.sentiment.dto.response.PostResponse;
import com.socialmedia.sentiment.service.HashtagService;
import com.socialmedia.sentiment.service.PostService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/hashtags")
public class HashtagController {

    private final HashtagService hashtagService;
    private final PostService postService;

    @Autowired
    public HashtagController(HashtagService hashtagService, PostService postService) {
        this.hashtagService = hashtagService;
        this.postService = postService;
    }

    @GetMapping
    public ResponseEntity<PageResponse<HashtagResponse>> getHashtags(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        PageResponse<HashtagResponse> response = hashtagService.getHashtags(page, size);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/{hashtagId}")
    public ResponseEntity<HashtagResponse> getHashtag(@PathVariable Long hashtagId) {
        HashtagResponse response = hashtagService.getHashtagById(hashtagId);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/name/{tagName}")
    public ResponseEntity<HashtagResponse> getHashtagByName(@PathVariable String tagName) {
        HashtagResponse response = hashtagService.getHashtagByTagName(tagName);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/{hashtagId}/posts")
    public ResponseEntity<PageResponse<PostResponse>> getPostsByHashtag(
            @PathVariable Long hashtagId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        PageResponse<PostResponse> response = postService.getPostsByHashtagId(hashtagId, page, size);
        return ResponseEntity.ok(response);
    }
}
