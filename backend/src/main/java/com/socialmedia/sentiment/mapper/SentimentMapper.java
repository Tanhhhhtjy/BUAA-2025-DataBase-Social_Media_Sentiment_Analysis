package com.socialmedia.sentiment.mapper;

import com.socialmedia.sentiment.entity.PostSentiment;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

@Mapper
public interface SentimentMapper {

    PostSentiment findById(@Param("sentimentId") Long sentimentId);

    PostSentiment findByPostId(@Param("postId") Long postId);

    int insert(PostSentiment sentiment);

    int update(PostSentiment sentiment);

    int updateSentiment(@Param("postId") Long postId, @Param("sentiment") String sentiment,
                        @Param("confidence") BigDecimal confidence);

    int deleteByPostId(@Param("postId") Long postId);

    List<Map<String, Object>> getSentimentDistribution(@Param("startDate") LocalDateTime startDate,
                                                        @Param("endDate") LocalDateTime endDate);

    List<Map<String, Object>> getDailySentimentTrend(@Param("startDate") LocalDateTime startDate,
                                                      @Param("endDate") LocalDateTime endDate);
}
