package com.socialmedia.sentiment;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
@MapperScan("com.socialmedia.sentiment.mapper")
public class SentimentAnalysisApplication {

    public static void main(String[] args) {
        SpringApplication.run(SentimentAnalysisApplication.class, args);
        System.out.println("===========================================");
        System.out.println("社交媒体舆情分析系统启动成功！");
        System.out.println("API文档: http://localhost:8080/api");
        System.out.println("===========================================");
    }
}
