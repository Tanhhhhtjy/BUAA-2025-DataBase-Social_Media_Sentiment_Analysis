package com.socialmedia.sentiment.controller;

import com.socialmedia.sentiment.dto.request.PostCreateRequest;
import com.socialmedia.sentiment.dto.response.PageResponse;
import com.socialmedia.sentiment.dto.response.PostResponse;
import com.socialmedia.sentiment.service.PostService;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/posts")
public class PostController {

    private final PostService postService;

    @Autowired
    public PostController(PostService postService) {
        this.postService = postService;
    }

    @PostMapping
    public ResponseEntity<PostResponse> createPost(@Valid @RequestBody PostCreateRequest request,
                                                   HttpServletRequest httpRequest) {
        Long userId = (Long) httpRequest.getAttribute("userId");
        PostResponse response = postService.createPost(userId, request);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/{postId}")
    public ResponseEntity<PostResponse> getPost(@PathVariable Long postId) {
        PostResponse response = postService.getPostById(postId);
        return ResponseEntity.ok(response);
    }

    @GetMapping
    public ResponseEntity<PageResponse<PostResponse>> getPosts(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        PageResponse<PostResponse> response = postService.getPosts(page, size);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/user/{userId}")
    public ResponseEntity<PageResponse<PostResponse>> getPostsByUser(
            @PathVariable Long userId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        PageResponse<PostResponse> response = postService.getPostsByUserId(userId, page, size);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/hashtag/{hashtagId}")
    public ResponseEntity<PageResponse<PostResponse>> getPostsByHashtag(
            @PathVariable Long hashtagId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        PageResponse<PostResponse> response = postService.getPostsByHashtagId(hashtagId, page, size);
        return ResponseEntity.ok(response);
    }

    @PutMapping("/{postId}")
    public ResponseEntity<PostResponse> updatePost(@PathVariable Long postId,
                                                   @Valid @RequestBody PostCreateRequest request,
                                                   HttpServletRequest httpRequest) {
        Long userId = (Long) httpRequest.getAttribute("userId");
        PostResponse response = postService.updatePost(postId, userId, request);
        return ResponseEntity.ok(response);
    }

    @DeleteMapping("/{postId}")
    public ResponseEntity<Map<String, Object>> deletePost(@PathVariable Long postId,
                                                          HttpServletRequest httpRequest) {
        Long userId = (Long) httpRequest.getAttribute("userId");
        postService.deletePost(postId, userId);

        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("message", "帖子删除成功");
        return ResponseEntity.ok(response);
    }
}
