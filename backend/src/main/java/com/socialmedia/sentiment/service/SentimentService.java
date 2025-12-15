package com.socialmedia.sentiment.service;

import com.socialmedia.sentiment.entity.PostSentiment;
import com.socialmedia.sentiment.mapper.SentimentMapper;
import org.springframework.ai.openai.OpenAiChatModel;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

@Service
public class SentimentService {

    private final OpenAiChatModel chatModel;
    private final SentimentMapper sentimentMapper;

    @Autowired
    public SentimentService(OpenAiChatModel chatModel, SentimentMapper sentimentMapper) {
        this.chatModel = chatModel;
        this.sentimentMapper = sentimentMapper;
    }

    @Transactional
    public void analyzeSentiment(Long postId, String content) {
        try {
            String prompt = buildSentimentPrompt(content);
            String response = chatModel.call(prompt);

            SentimentResult result = parseSentimentResult(response);

            sentimentMapper.updateSentiment(
                postId,
                result.sentiment,
                BigDecimal.valueOf(result.confidence)
            );
        } catch (Exception e) {
            sentimentMapper.updateSentiment(
                postId,
                "UNANALYZED",
                null
            );
        }
    }

    public void triggerAsyncAnalysis(Long postId, String content) {
        new Thread(() -> {
            analyzeSentiment(postId, content);
        }).start();
    }

    public PostSentiment getSentimentByPostId(Long postId) {
        return sentimentMapper.findByPostId(postId);
    }

    private String buildSentimentPrompt(String content) {
        return String.format(
            "请分析以下社交媒体帖子的情感倾向，并返回JSON格式的结果。\n" +
            "帖子内容：%s\n\n" +
            "请从以下选项中选择一个最准确的分析：\n" +
            "- POSITIVE（正面）：表达积极、快乐、赞扬等正面情感\n" +
            "- NEUTRAL（中立）：客观陈述，无明显情感倾向\n" +
            "- NEGATIVE（负面）：表达消极、悲伤、批评等负面情感\n\n" +
            "请返回JSON格式：{\"sentiment\": \"POSITIVE|NEUTRAL|NEGATIVE\", \"confidence\": 0.95}\n" +
            "confidence 必须是0-1之间的数字，表示置信度",
            content
        );
    }

    private SentimentResult parseSentimentResult(String response) {
        SentimentResult result = new SentimentResult();
        result.sentiment = "UNANALYZED";
        result.confidence = 0.0;

        try {
            Pattern sentimentPattern = Pattern.compile("\"sentiment\"\\s*:\\s*\"(\\w+)\"");
            Pattern confidencePattern = Pattern.compile("\"confidence\"\\s*:\\s*([0-9.]+)");

            Matcher sentimentMatcher = sentimentPattern.matcher(response);
            Matcher confidenceMatcher = confidencePattern.matcher(response);

            if (sentimentMatcher.find()) {
                String sentiment = sentimentMatcher.group(1);
                if (sentiment.equals("POSITIVE") || sentiment.equals("NEUTRAL") || sentiment.equals("NEGATIVE")) {
                    result.sentiment = sentiment;
                }
            }

            if (confidenceMatcher.find()) {
                String confStr = confidenceMatcher.group(1);
                try {
                    double conf = Double.parseDouble(confStr);
                    result.confidence = Math.max(0.0, Math.min(1.0, conf));
                } catch (NumberFormatException e) {
                    result.confidence = 0.5;
                }
            }
        } catch (Exception e) {
            result.sentiment = "UNANALYZED";
            result.confidence = 0.0;
        }

        return result;
    }

    private static class SentimentResult {
        String sentiment;
        double confidence;
    }
}
