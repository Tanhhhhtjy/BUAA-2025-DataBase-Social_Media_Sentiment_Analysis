package com.socialmedia.sentiment.mapper;

import com.socialmedia.sentiment.entity.Keyword;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface KeywordMapper {

    Keyword findById(@Param("keywordId") Long keywordId);

    Keyword findByKeyword(@Param("keyword") String keyword);

    int insert(Keyword keyword);

    int update(Keyword keyword);

    int deleteById(@Param("keywordId") Long keywordId);

    List<Keyword> findAll(@Param("offset") int offset, @Param("limit") int limit);

    List<Keyword> findByCategory(@Param("category") String category);

    long count();

    boolean existsByKeyword(@Param("keyword") String keyword);
}
