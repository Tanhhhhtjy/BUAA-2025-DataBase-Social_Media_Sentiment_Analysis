package com.socialmedia.sentiment.mapper;

import com.socialmedia.sentiment.entity.Comment;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface CommentMapper {

    Comment findById(@Param("commentId") Long commentId);

    int insert(Comment comment);

    int deleteById(@Param("commentId") Long commentId);

    int deleteByPostId(@Param("postId") Long postId);

    List<Comment> findByPostId(@Param("postId") Long postId, @Param("offset") int offset, @Param("limit") int limit);

    List<Comment> findByUserId(@Param("userId") Long userId, @Param("offset") int offset, @Param("limit") int limit);

    long countByPostId(@Param("postId") Long postId);

    long countByUserId(@Param("userId") Long userId);
}
