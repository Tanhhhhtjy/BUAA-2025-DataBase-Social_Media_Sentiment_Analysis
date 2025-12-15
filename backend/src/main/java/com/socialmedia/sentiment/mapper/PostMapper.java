package com.socialmedia.sentiment.mapper;

import com.socialmedia.sentiment.entity.Post;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.time.LocalDateTime;
import java.util.List;

@Mapper
public interface PostMapper {

    Post findById(@Param("postId") Long postId);

    int insert(Post post);

    int update(Post post);

    int deleteById(@Param("postId") Long postId);

    List<Post> findAll(@Param("offset") int offset, @Param("limit") int limit);

    List<Post> findByUserId(@Param("userId") Long userId, @Param("offset") int offset, @Param("limit") int limit);

    List<Post> findByHashtagId(@Param("hashtagId") Long hashtagId, @Param("offset") int offset, @Param("limit") int limit);

    List<Post> findByDateRange(@Param("startDate") LocalDateTime startDate, @Param("endDate") LocalDateTime endDate,
                               @Param("offset") int offset, @Param("limit") int limit);

    long count();

    long countByUserId(@Param("userId") Long userId);

    long countByHashtagId(@Param("hashtagId") Long hashtagId);

    long countByDateRange(@Param("startDate") LocalDateTime startDate, @Param("endDate") LocalDateTime endDate);
}
