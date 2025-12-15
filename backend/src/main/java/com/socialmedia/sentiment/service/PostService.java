package com.socialmedia.sentiment.service;

import com.socialmedia.sentiment.dto.request.PostCreateRequest;
import com.socialmedia.sentiment.dto.response.PageResponse;
import com.socialmedia.sentiment.dto.response.PostResponse;
import com.socialmedia.sentiment.entity.Hashtag;
import com.socialmedia.sentiment.entity.Post;
import com.socialmedia.sentiment.entity.PostSentiment;
import com.socialmedia.sentiment.entity.User;
import com.socialmedia.sentiment.mapper.CommentMapper;
import com.socialmedia.sentiment.mapper.HashtagMapper;
import com.socialmedia.sentiment.mapper.PostMapper;
import com.socialmedia.sentiment.mapper.SentimentMapper;
import com.socialmedia.sentiment.mapper.UserMapper;
import com.socialmedia.sentiment.util.HashtagExtractor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class PostService {

    private final PostMapper postMapper;
    private final UserMapper userMapper;
    private final HashtagMapper hashtagMapper;
    private final CommentMapper commentMapper;
    private final SentimentMapper sentimentMapper;
    private final HashtagExtractor hashtagExtractor;
    private final SentimentService sentimentService;

    @Autowired
    public PostService(PostMapper postMapper, UserMapper userMapper, HashtagMapper hashtagMapper,
                       CommentMapper commentMapper, SentimentMapper sentimentMapper,
                       HashtagExtractor hashtagExtractor, SentimentService sentimentService) {
        this.postMapper = postMapper;
        this.userMapper = userMapper;
        this.hashtagMapper = hashtagMapper;
        this.commentMapper = commentMapper;
        this.sentimentMapper = sentimentMapper;
        this.hashtagExtractor = hashtagExtractor;
        this.sentimentService = sentimentService;
    }

    @Transactional
    public PostResponse createPost(Long userId, PostCreateRequest request) {
        User user = userMapper.findById(userId);
        if (user == null) {
            throw new IllegalArgumentException("用户不存在");
        }
        if (!user.isActive()) {
            throw new IllegalArgumentException("账户已被禁用，无法发布帖子");
        }

        Post post = new Post();
        post.setUserId(userId);
        post.setContent(request.getContent());
        postMapper.insert(post);

        List<String> hashtags = hashtagExtractor.extractHashtags(request.getContent());
        for (String tagName : hashtags) {
            Hashtag hashtag = hashtagMapper.findByTagName(tagName);
            if (hashtag == null) {
                hashtag = new Hashtag();
                hashtag.setTagName(tagName);
                hashtagMapper.insert(hashtag);
            }
            hashtagMapper.insertPostHashtag(post.getPostId(), hashtag.getHashtagId());
        }

        PostSentiment sentiment = new PostSentiment();
        sentiment.setPostId(post.getPostId());
        sentiment.setSentiment("UNANALYZED");
        sentimentMapper.insert(sentiment);

        sentimentService.triggerAsyncAnalysis(post.getPostId(), request.getContent());

        return buildPostResponse(post, user.getUsername(), hashtags);
    }

    public PostResponse getPostById(Long postId) {
        Post post = postMapper.findById(postId);
        if (post == null) {
            throw new IllegalArgumentException("帖子不存在");
        }
        return buildFullPostResponse(post);
    }

    public PageResponse<PostResponse> getPosts(int page, int size) {
        int offset = page * size;
        List<Post> posts = postMapper.findAll(offset, size);
        long total = postMapper.count();

        List<PostResponse> responses = posts.stream()
                .map(this::buildFullPostResponse)
                .collect(Collectors.toList());

        return new PageResponse<>(responses, page, size, total);
    }

    public PageResponse<PostResponse> getPostsByUserId(Long userId, int page, int size) {
        int offset = page * size;
        List<Post> posts = postMapper.findByUserId(userId, offset, size);
        long total = postMapper.countByUserId(userId);

        List<PostResponse> responses = posts.stream()
                .map(this::buildFullPostResponse)
                .collect(Collectors.toList());

        return new PageResponse<>(responses, page, size, total);
    }

    public PageResponse<PostResponse> getPostsByHashtagId(Long hashtagId, int page, int size) {
        int offset = page * size;
        List<Post> posts = postMapper.findByHashtagId(hashtagId, offset, size);
        long total = postMapper.countByHashtagId(hashtagId);

        List<PostResponse> responses = posts.stream()
                .map(this::buildFullPostResponse)
                .collect(Collectors.toList());

        return new PageResponse<>(responses, page, size, total);
    }

    @Transactional
    public void deletePost(Long postId, Long userId) {
        Post post = postMapper.findById(postId);
        if (post == null) {
            throw new IllegalArgumentException("帖子不存在");
        }
        if (!post.getUserId().equals(userId)) {
            User user = userMapper.findById(userId);
            if (user == null || !user.isAdmin()) {
                throw new IllegalArgumentException("无权删除此帖子");
            }
        }

        hashtagMapper.deletePostHashtagsByPostId(postId);
        commentMapper.deleteByPostId(postId);
        sentimentMapper.deleteByPostId(postId);
        postMapper.deleteById(postId);
    }

    private PostResponse buildPostResponse(Post post, String username, List<String> hashtags) {
        PostResponse response = new PostResponse(post);
        response.setUsername(username);
        response.setHashtags(hashtags);
        response.setSentiment("UNANALYZED");
        response.setCommentCount(0);
        return response;
    }

    private PostResponse buildFullPostResponse(Post post) {
        PostResponse response = new PostResponse(post);

        User user = userMapper.findById(post.getUserId());
        if (user != null) {
            response.setUsername(user.getUsername());
        }

        List<Hashtag> hashtags = hashtagMapper.findByPostId(post.getPostId());
        response.setHashtags(hashtags.stream().map(Hashtag::getTagName).collect(Collectors.toList()));

        PostSentiment sentiment = sentimentMapper.findByPostId(post.getPostId());
        if (sentiment != null) {
            response.setSentiment(sentiment.getSentiment());
            if (sentiment.getConfidence() != null) {
                response.setConfidence(sentiment.getConfidence().doubleValue());
            }
        }

        long commentCount = commentMapper.countByPostId(post.getPostId());
        response.setCommentCount(commentCount);

        return response;
    }
}
