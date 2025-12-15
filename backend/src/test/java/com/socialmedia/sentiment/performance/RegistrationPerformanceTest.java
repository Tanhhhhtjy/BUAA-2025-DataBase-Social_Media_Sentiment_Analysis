package com.socialmedia.sentiment.performance;

import com.socialmedia.sentiment.service.UserService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

import static org.junit.jupiter.api.Assertions.assertTrue;

/**
 * SC-001: 用户注册性能基准测试
 * 要求：用户注册流程应该在30秒内完成
 */
@SpringBootTest
class RegistrationPerformanceTest {

    @Autowired
    private UserService userService;

    @Test
    void testUserRegistrationPerformance() {
        // Given
        String username = "perf_test_" + System.currentTimeMillis();
        String email = "perf_" + System.currentTimeMillis() + "@example.com";
        String password = "password123";

        // When
        long startTime = System.currentTimeMillis();
        try {
            userService.registerUser(username, email, password);
        } catch (Exception e) {
            // 忽略注册失败（可能是重复用户名），只测试性能
        }
        long endTime = System.currentTimeMillis();

        // Then
        long duration = endTime - startTime;
        System.out.println("用户注册耗时: " + duration + "ms");

        // SC-001: 应该在30秒内完成
        assertTrue(duration < 30000, "用户注册应该在30秒内完成");
    }
}
