package com.socialmedia.sentiment.mapper;

import com.socialmedia.sentiment.entity.Alert;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.time.LocalDateTime;
import java.util.List;

@Mapper
public interface AlertMapper {

    Alert findById(@Param("alertId") Long alertId);

    int insert(Alert alert);

    int updateStatus(@Param("alertId") Long alertId);

    int deleteById(@Param("alertId") Long alertId);

    int deleteByContent(@Param("contentType") String contentType, @Param("contentId") Long contentId);

    List<Alert> findAll(@Param("offset") int offset, @Param("limit") int limit);

    List<Alert> findRecent(@Param("hours") int hours, @Param("offset") int offset, @Param("limit") int limit);

    List<Alert> findByDateRange(@Param("startDate") LocalDateTime startDate,
            @Param("endDate") LocalDateTime endDate,
            @Param("offset") int offset, @Param("limit") int limit);

    long count();

    long countRecent(@Param("hours") int hours);

    int deleteByUserId(@Param("userId") Long userId);
}
