package com.socialmedia.sentiment.performance;

import com.socialmedia.sentiment.service.PostService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.TimeUnit;

import static org.junit.jupiter.api.Assertions.*;

@SpringBootTest
class PostListPerformanceTest {

    @Autowired
    private PostService postService;

    private static final int CONCURRENT_USERS = 100;
    private static final int ITERATIONS_PER_USER = 10;

    @BeforeEach
    void setUp() {
    }

    @Test
    void testConcurrentPostListAccess() throws InterruptedException {
        ExecutorService executor = Executors.newFixedThreadPool(CONCURRENT_USERS);
        CountDownLatch latch = new CountDownLatch(CONCURRENT_USERS);
        List<Long> responseTimes = new ArrayList<>();

        for (int i = 0; i < CONCURRENT_USERS; i++) {
            executor.submit(() -> {
                try {
                    long startTime = System.currentTimeMillis();
                    for (int j = 0; j < ITERATIONS_PER_USER; j++) {
                        postService.getPosts(0, 20);
                    }
                    long endTime = System.currentTimeMillis();
                    synchronized (responseTimes) {
                        responseTimes.add(endTime - startTime);
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                } finally {
                    latch.countDown();
                }
            });
        }

        boolean completed = latch.await(30, TimeUnit.SECONDS);
        executor.shutdown();
        executor.awaitTermination(5, TimeUnit.SECONDS);

        assertTrue(completed, "所有并发请求应该完成");

        if (!responseTimes.isEmpty()) {
            long totalTime = responseTimes.stream().mapToLong(Long::longValue).sum();
            double averageTime = (double) totalTime / responseTimes.size();
            long maxTime = responseTimes.stream().mapToLong(Long::longValue).max().orElse(0);
            long minTime = responseTimes.stream().mapToLong(Long::longValue).min().orElse(0);

            System.out.println("性能测试结果:");
            System.out.println("并发用户数: " + CONCURRENT_USERS);
            System.out.println("每用户迭代次数: " + ITERATIONS_PER_USER);
            System.out.println("平均响应时间: " + averageTime + "ms");
            System.out.println("最大响应时间: " + maxTime + "ms");
            System.out.println("最小响应时间: " + minTime + "ms");
            System.out.println("总请求数: " + (CONCURRENT_USERS * ITERATIONS_PER_USER));

            assertTrue(averageTime < 2000, "平均响应时间应该小于2秒");
            assertTrue(maxTime < 5000, "最大响应时间应该小于5秒");
        }
    }

    @Test
    void testPostListPaginationPerformance() {
        int[] pageSizes = {10, 20, 50, 100};

        for (int pageSize : pageSizes) {
            long startTime = System.currentTimeMillis();
            postService.getPosts(0, pageSize);
            long endTime = System.currentTimeMillis();

            long duration = endTime - startTime;
            System.out.println("分页大小 " + pageSize + " 的响应时间: " + duration + "ms");

            if (pageSize <= 20) {
                assertTrue(duration < 500, "小分页(<=20)应在500ms内响应");
            } else if (pageSize <= 50) {
                assertTrue(duration < 1000, "中等分页(<=50)应在1秒内响应");
            } else {
                assertTrue(duration < 2000, "大分页(<=100)应在2秒内响应");
            }
        }
    }

    @Test
    void testPostDetailPerformance() {
        long testPostId = 1L;

        long startTime = System.currentTimeMillis();
        postService.getPostById(testPostId);
        long endTime = System.currentTimeMillis();

        long duration = endTime - startTime;
        System.out.println("帖子详情响应时间: " + duration + "ms");

        assertTrue(duration < 500, "帖子详情查询应在500ms内完成");
    }
}
