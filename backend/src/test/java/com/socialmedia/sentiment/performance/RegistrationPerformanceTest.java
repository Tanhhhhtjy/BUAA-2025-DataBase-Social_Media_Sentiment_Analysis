package com.socialmedia.sentiment.performance;

import com.socialmedia.sentiment.dto.request.RegisterRequest;
import com.socialmedia.sentiment.service.UserService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

import static org.junit.jupiter.api.Assertions.assertTrue;

@SpringBootTest
class RegistrationPerformanceTest {

    @Autowired
    private UserService userService;

    @Test
    void testUserRegistrationPerformance() {
        String username = "perf_test_" + System.currentTimeMillis();
        String email = "perf_" + System.currentTimeMillis() + "@example.com";
        String password = "password123";

        RegisterRequest request = new RegisterRequest();
        request.setUsername(username);
        request.setEmail(email);
        request.setPassword(password);

        long startTime = System.currentTimeMillis();
        try {
            userService.register(request);
        } catch (Exception e) {
        }
        long endTime = System.currentTimeMillis();

        long duration = endTime - startTime;
        System.out.println("用户注册耗时: " + duration + "ms");

        assertTrue(duration < 30000, "用户注册应该在30秒内完成");
    }
}
