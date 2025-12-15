package com.socialmedia.sentiment.controller;

import com.socialmedia.sentiment.dto.request.CommentCreateRequest;
import com.socialmedia.sentiment.dto.response.CommentResponse;
import com.socialmedia.sentiment.dto.response.PageResponse;
import com.socialmedia.sentiment.service.CommentService;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/comments")
public class CommentController {

    private final CommentService commentService;

    @Autowired
    public CommentController(CommentService commentService) {
        this.commentService = commentService;
    }

    @PostMapping("/post/{postId}")
    public ResponseEntity<CommentResponse> createComment(@PathVariable Long postId,
                                                         @Valid @RequestBody CommentCreateRequest request,
                                                         HttpServletRequest httpRequest) {
        Long userId = (Long) httpRequest.getAttribute("userId");
        CommentResponse response = commentService.createComment(postId, userId, request);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/post/{postId}")
    public ResponseEntity<PageResponse<CommentResponse>> getCommentsByPost(
            @PathVariable Long postId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        PageResponse<CommentResponse> response = commentService.getCommentsByPostId(postId, page, size);
        return ResponseEntity.ok(response);
    }

    @DeleteMapping("/{commentId}")
    public ResponseEntity<Map<String, Object>> deleteComment(@PathVariable Long commentId,
                                                             HttpServletRequest httpRequest) {
        Long userId = (Long) httpRequest.getAttribute("userId");
        commentService.deleteComment(commentId, userId);

        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("message", "评论删除成功");
        return ResponseEntity.ok(response);
    }
}
