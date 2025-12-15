package com.socialmedia.sentiment.mapper;

import com.socialmedia.sentiment.entity.User;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface UserMapper {

    User findById(@Param("userId") Long userId);

    User findByUsername(@Param("username") String username);

    User findByEmail(@Param("email") String email);

    User findByUsernameOrEmail(@Param("usernameOrEmail") String usernameOrEmail);

    int insert(User user);

    int update(User user);

    int updateStatus(@Param("userId") Long userId, @Param("status") String status);

    int deleteById(@Param("userId") Long userId);

    List<User> findAll(@Param("offset") int offset, @Param("limit") int limit);

    long count();

    boolean existsByUsername(@Param("username") String username);

    boolean existsByEmail(@Param("email") String email);
}
