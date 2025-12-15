package com.socialmedia.sentiment.config;

import io.micrometer.core.instrument.Counter;
import io.micrometer.core.instrument.MeterRegistry;
import io.micrometer.core.instrument.Timer;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.util.concurrent.TimeUnit;

/**
 * 监控指标配置
 */
@Configuration
public class MetricsConfig {

    @Value("${spring.application.name:social-media-sentiment}")
    private String applicationName;

    @Bean
    public MetricsUtils metricsUtils(MeterRegistry registry) {
        return new MetricsUtils(registry, applicationName);
    }

    /**
     * 指标工具类
     */
    public static class MetricsUtils {
        private final MeterRegistry registry;
        private final String applicationName;

        public MetricsUtils(MeterRegistry registry, String applicationName) {
            this.registry = registry;
            this.applicationName = applicationName;
        }

        /**
         * 记录HTTP请求
         */
        public void recordHttpRequest(String method, String uri, int status) {
            Counter counter = registry.counter(
                    "http_requests_total",
                    "application", applicationName,
                    "method", method,
                    "uri", uri,
                    "status", String.valueOf(status));
            counter.increment();
        }

        /**
         * 记录HTTP请求响应时间
         */
        public void recordHttpRequestDuration(String method, String uri, long duration, TimeUnit timeUnit) {
            Timer timer = registry.timer(
                    "http_requests_duration",
                    "application", applicationName,
                    "method", method,
                    "uri", uri);
            timer.record(duration, timeUnit);
        }

        /**
         * 记录业务操作
         */
        public void recordBusinessOperation(String operation, String status) {
            Counter counter = registry.counter(
                    "business_operations_total",
                    "application", applicationName,
                    "operation", operation,
                    "status", status);
            counter.increment();
        }

        /**
         * 记录数据库操作时间
         */
        public void recordDatabaseOperation(String operation, long duration, TimeUnit timeUnit) {
            Timer timer = registry.timer(
                    "database_operations_duration",
                    "application", applicationName,
                    "operation", operation);
            timer.record(duration, timeUnit);
        }

        /**
         * 记录情感分析时间
         */
        public void recordSentimentAnalysis(String model, long duration, TimeUnit timeUnit) {
            Timer timer = registry.timer(
                    "sentiment_analysis_duration",
                    "application", applicationName,
                    "model", model);
            timer.record(duration, timeUnit);
        }
    }
}
