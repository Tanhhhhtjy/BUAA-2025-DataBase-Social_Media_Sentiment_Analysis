package com.socialmedia.sentiment.service;

import com.socialmedia.sentiment.dto.request.CommentCreateRequest;
import com.socialmedia.sentiment.dto.response.CommentResponse;
import com.socialmedia.sentiment.dto.response.PageResponse;
import com.socialmedia.sentiment.entity.Comment;
import com.socialmedia.sentiment.entity.Post;
import com.socialmedia.sentiment.entity.User;
import com.socialmedia.sentiment.mapper.CommentMapper;
import com.socialmedia.sentiment.mapper.PostMapper;
import com.socialmedia.sentiment.mapper.UserMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class CommentService {

    private final CommentMapper commentMapper;
    private final PostMapper postMapper;
    private final UserMapper userMapper;

    @Autowired
    public CommentService(CommentMapper commentMapper, PostMapper postMapper, UserMapper userMapper) {
        this.commentMapper = commentMapper;
        this.postMapper = postMapper;
        this.userMapper = userMapper;
    }

    @Transactional
    public CommentResponse createComment(Long postId, Long userId, CommentCreateRequest request) {
        Post post = postMapper.findById(postId);
        if (post == null) {
            throw new IllegalArgumentException("帖子不存在");
        }

        User user = userMapper.findById(userId);
        if (user == null) {
            throw new IllegalArgumentException("用户不存在");
        }
        if (!user.isActive()) {
            throw new IllegalArgumentException("账户已被禁用，无法发表评论");
        }

        Comment comment = new Comment();
        comment.setPostId(postId);
        comment.setUserId(userId);
        comment.setContent(request.getContent());
        commentMapper.insert(comment);

        CommentResponse response = new CommentResponse(comment);
        response.setUsername(user.getUsername());
        return response;
    }

    public PageResponse<CommentResponse> getCommentsByPostId(Long postId, int page, int size) {
        Post post = postMapper.findById(postId);
        if (post == null) {
            throw new IllegalArgumentException("帖子不存在");
        }

        int offset = page * size;
        List<Comment> comments = commentMapper.findByPostId(postId, offset, size);
        long total = commentMapper.countByPostId(postId);

        List<CommentResponse> responses = comments.stream()
                .map(this::buildCommentResponse)
                .collect(Collectors.toList());

        return new PageResponse<>(responses, page, size, total);
    }

    @Transactional
    public void deleteComment(Long commentId, Long userId) {
        Comment comment = commentMapper.findById(commentId);
        if (comment == null) {
            throw new IllegalArgumentException("评论不存在");
        }

        if (!comment.getUserId().equals(userId)) {
            User user = userMapper.findById(userId);
            if (user == null || !user.isAdmin()) {
                throw new IllegalArgumentException("无权删除此评论");
            }
        }

        commentMapper.deleteById(commentId);
    }

    private CommentResponse buildCommentResponse(Comment comment) {
        CommentResponse response = new CommentResponse(comment);
        User user = userMapper.findById(comment.getUserId());
        if (user != null) {
            response.setUsername(user.getUsername());
        }
        return response;
    }
}
