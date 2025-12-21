package com.socialmedia.sentiment.service;

import com.socialmedia.sentiment.dto.request.ChangePasswordRequest;
import com.socialmedia.sentiment.dto.request.LoginRequest;
import com.socialmedia.sentiment.dto.request.RegisterRequest;
import com.socialmedia.sentiment.dto.response.AuthResponse;
import com.socialmedia.sentiment.entity.User;
import com.socialmedia.sentiment.util.JwtUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.DisabledException;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class AuthService {

    private final UserService userService;
    private final JwtUtil jwtUtil;

    @Autowired
    public AuthService(UserService userService, JwtUtil jwtUtil) {
        this.userService = userService;
        this.jwtUtil = jwtUtil;
    }

    @Transactional
    public AuthResponse register(RegisterRequest request) {
        User user = userService.register(request);
        String token = jwtUtil.generateToken(user.getUsername(), user.getUserId(), user.getRole());

        return new AuthResponse(
                token,
                user.getUserId(),
                user.getUsername(),
                user.getEmail(),
                user.getRole(),
                user.getCreatedAt()
        );
    }

    public AuthResponse login(LoginRequest request) {
        User user = userService.findByUsernameOrEmail(request.getUsernameOrEmail());

        if (user == null) {
            throw new UsernameNotFoundException("用户名或邮箱不存在");
        }

        if (!user.isActive()) {
            throw new DisabledException("账户已被禁用");
        }

        if (!userService.validatePassword(user, request.getPassword())) {
            throw new BadCredentialsException("密码错误");
        }

        String token = jwtUtil.generateToken(user.getUsername(), user.getUserId(), user.getRole());

        return new AuthResponse(
                token,
                user.getUserId(),
                user.getUsername(),
                user.getEmail(),
                user.getRole(),
                user.getCreatedAt()
        );
    }

    public boolean validateToken(String token) {
        return jwtUtil.validateToken(token);
    }

    public Long getUserIdFromToken(String token) {
        return jwtUtil.getUserIdFromToken(token);
    }

    public String getUsernameFromToken(String token) {
        return jwtUtil.getUsernameFromToken(token);
    }

    public String getRoleFromToken(String token) {
        return jwtUtil.getRoleFromToken(token);
    }

    @Transactional
    public void changePassword(Long userId, ChangePasswordRequest request) {
        User user = userService.findById(userId);
        if (user == null) {
            throw new UsernameNotFoundException("用户不存在");
        }

        if (!userService.validatePassword(user, request.getCurrentPassword())) {
            throw new BadCredentialsException("当前密码错误");
        }

        userService.updatePassword(userId, request.getNewPassword());
    }
}
