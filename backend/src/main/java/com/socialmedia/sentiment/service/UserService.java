package com.socialmedia.sentiment.service;

import com.socialmedia.sentiment.dto.request.RegisterRequest;
import com.socialmedia.sentiment.dto.response.UserResponse;
import com.socialmedia.sentiment.entity.User;
import com.socialmedia.sentiment.mapper.UserMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class UserService {

    private final UserMapper userMapper;
    private final PasswordEncoder passwordEncoder;
    private final AlertService alertService;

    @Autowired
    public UserService(UserMapper userMapper, PasswordEncoder passwordEncoder, AlertService alertService) {
        this.userMapper = userMapper;
        this.passwordEncoder = passwordEncoder;
        this.alertService = alertService;
    }

    @Transactional
    public User register(RegisterRequest request) {
        if (userMapper.existsByUsername(request.getUsername())) {
            throw new IllegalArgumentException("用户名已存在");
        }

        if (userMapper.existsByEmail(request.getEmail())) {
            throw new IllegalArgumentException("邮箱已被注册");
        }

        User user = new User();
        user.setUsername(request.getUsername());
        user.setEmail(request.getEmail());
        user.setPasswordHash(passwordEncoder.encode(request.getPassword()));
        user.setRole("USER");
        user.setStatus("ACTIVE");

        userMapper.insert(user);
        return user;
    }

    public User findById(Long userId) {
        User user = userMapper.findById(userId);
        if (user == null) {
            throw new IllegalArgumentException("用户不存在");
        }
        return user;
    }

    public User findByUsername(String username) {
        return userMapper.findByUsername(username);
    }

    public User findByEmail(String email) {
        return userMapper.findByEmail(email);
    }

    public User findByUsernameOrEmail(String usernameOrEmail) {
        return userMapper.findByUsernameOrEmail(usernameOrEmail);
    }

    public boolean existsByUsername(String username) {
        return userMapper.existsByUsername(username);
    }

    public boolean existsByEmail(String email) {
        return userMapper.existsByEmail(email);
    }

    public List<UserResponse> findAll(int page, int size) {
        int offset = page * size;
        List<User> users = userMapper.findAll(offset, size);
        return users.stream()
                .map(UserResponse::new)
                .collect(Collectors.toList());
    }

    public long count() {
        return userMapper.count();
    }

    @Transactional
    public void updateStatus(Long userId, String status) {
        User user = findById(userId);
        if (!status.equals("ACTIVE") && !status.equals("DISABLED")) {
            throw new IllegalArgumentException("无效的状态值");
        }
        userMapper.updateStatus(userId, status);
    }

    @Transactional
    public void deleteUser(Long userId) {
        User user = findById(userId);
        alertService.deleteByUserId(userId);
        userMapper.deleteById(userId);
    }

    public boolean validatePassword(User user, String rawPassword) {
        return passwordEncoder.matches(rawPassword, user.getPasswordHash());
    }
}
