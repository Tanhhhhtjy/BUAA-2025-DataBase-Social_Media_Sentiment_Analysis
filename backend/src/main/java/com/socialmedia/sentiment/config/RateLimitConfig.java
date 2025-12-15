package com.socialmedia.sentiment.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.data.redis.core.script.DefaultRedisScript;
import org.springframework.stereotype.Component;

import java.util.Collections;
import java.util.UUID;

/**
 * 请求限流配置
 */
@Configuration
public class RateLimitConfig {

    /**
     * Redis限流脚本
     * 使用令牌桶算法实现限流
     */
    @Bean
    public DefaultRedisScript<Long> rateLimitScript() {
        DefaultRedisScript<Long> script = new DefaultRedisScript<>();
        script.setScriptText(
                "local key = KEYS[1] " +
                "local window = ARGV[1] " +
                "local limit = ARGV[2] " +
                "local current = redis.call('GET', key) " +
                "if current == false then " +
                "  redis.call('SET', key, 1) " +
                "  redis.call('EXPIRE', key, window) " +
                "  return 1 " +
                "else " +
                "  current = tonumber(current) " +
                "  if current < limit then " +
                "    redis.call('INCR', key) " +
                "    return current + 1 " +
                "  else " +
                "    return 0 " +
                "  end " +
                "end"
        );
        script.setResultType(Long.class);
        return script;
    }

    /**
     * 限流注解
     */
    @java.lang.annotation.Target({java.lang.annotation.ElementType.METHOD})
    @java.lang.annotation.Retention(java.lang.annotation.RetentionPolicy.RUNTIME)
    public @interface RateLimit {
        /**
         * 限流key
         */
        String key() default "";

        /**
         * 时间窗口（秒）
         */
        int window() default 60;

        /**
         * 限流次数
         */
        int limit() default 100;

        /**
         * 提示信息
         */
        String message() default "请求过于频繁，请稍后再试";
    }

    /**
     * 限流工具类
     */
    @Component
    public static class RateLimitUtils {

        private final RedisTemplate<String, String> redisTemplate;
        private final DefaultRedisScript<Long> rateLimitScript;

        public RateLimitUtils(RedisTemplate<String, String> redisTemplate,
                            DefaultRedisScript<Long> rateLimitScript) {
            this.redisTemplate = redisTemplate;
            this.rateLimitScript = rateLimitScript;
        }

        /**
         * 检查是否超过限流
         */
        public boolean isAllowed(String key, int window, int limit) {
            String fullKey = "rate_limit:" + key;
            Long result = redisTemplate.execute(rateLimitScript,
                    Collections.singletonList(fullKey),
                    String.valueOf(window),
                    String.valueOf(limit));
            return result != null && result > 0;
        }

        /**
         * 生成限流key
         */
        public String generateKey(String prefix, String identifier) {
            return prefix + ":" + identifier;
        }
    }
}
