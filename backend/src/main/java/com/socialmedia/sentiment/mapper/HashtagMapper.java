package com.socialmedia.sentiment.mapper;

import com.socialmedia.sentiment.entity.Hashtag;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

@Mapper
public interface HashtagMapper {

    Hashtag findById(@Param("hashtagId") Long hashtagId);

    Hashtag findByTagName(@Param("tagName") String tagName);

    int insert(Hashtag hashtag);

    int deleteById(@Param("hashtagId") Long hashtagId);

    List<Hashtag> findAll(@Param("offset") int offset, @Param("limit") int limit);

    List<Hashtag> findByPostId(@Param("postId") Long postId);

    long count();

    boolean existsByTagName(@Param("tagName") String tagName);

    int insertPostHashtag(@Param("postId") Long postId, @Param("hashtagId") Long hashtagId);

    int deletePostHashtag(@Param("postId") Long postId, @Param("hashtagId") Long hashtagId);

    int deletePostHashtagsByPostId(@Param("postId") Long postId);

    List<Map<String, Object>> getHotTopics(@Param("startDate") LocalDateTime startDate,
                                          @Param("endDate") LocalDateTime endDate,
                                          @Param("limit") int limit);
}
