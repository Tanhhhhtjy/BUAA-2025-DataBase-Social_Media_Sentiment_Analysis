package com.socialmedia.sentiment.controller;

import com.socialmedia.sentiment.dto.request.ChangePasswordRequest;
import com.socialmedia.sentiment.dto.request.LoginRequest;
import com.socialmedia.sentiment.dto.request.RegisterRequest;
import jakarta.servlet.http.HttpServletRequest;
import com.socialmedia.sentiment.dto.response.AuthResponse;
import com.socialmedia.sentiment.service.AuthService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/auth")
public class AuthController {

    private final AuthService authService;

    @Autowired
    public AuthController(AuthService authService) {
        this.authService = authService;
    }

    @PostMapping("/register")
    public ResponseEntity<AuthResponse> register(@Valid @RequestBody RegisterRequest request) {
        AuthResponse response = authService.register(request);
        return ResponseEntity.ok(response);
    }

    @PostMapping("/login")
    public ResponseEntity<AuthResponse> login(@Valid @RequestBody LoginRequest request) {
        AuthResponse response = authService.login(request);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/validate")
    public ResponseEntity<Map<String, Object>> validateToken(
            @RequestHeader(value = "Authorization", required = false) String authHeader) {

        Map<String, Object> response = new HashMap<>();

        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            response.put("valid", false);
            response.put("message", "缺少或无效的Authorization头");
            return ResponseEntity.ok(response);
        }

        String token = authHeader.substring(7);
        boolean isValid = authService.validateToken(token);

        response.put("valid", isValid);
        if (isValid) {
            response.put("userId", authService.getUserIdFromToken(token));
            response.put("username", authService.getUsernameFromToken(token));
            response.put("role", authService.getRoleFromToken(token));
        }

        return ResponseEntity.ok(response);
    }

    @PostMapping("/change-password")
    public ResponseEntity<Map<String, Object>> changePassword(
            @Valid @RequestBody ChangePasswordRequest request,
            HttpServletRequest httpRequest) {
        Long userId = (Long) httpRequest.getAttribute("userId");
        authService.changePassword(userId, request);

        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("message", "密码修改成功");
        return ResponseEntity.ok(response);
    }
}
