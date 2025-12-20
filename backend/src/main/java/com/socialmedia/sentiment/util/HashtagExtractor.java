package com.socialmedia.sentiment.util;

import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

@Component
public class HashtagExtractor {

    private static final Pattern HASHTAG_PATTERN = Pattern.compile("#([^\\s#][^\\s#]*)");

    public List<String> extractHashtags(String content) {
        if (content == null || content.isEmpty()) {
            return new ArrayList<>();
        }

        Set<String> hashtags = new HashSet<>();
        Matcher matcher = HASHTAG_PATTERN.matcher(content);

        while (matcher.find()) {
            String tag = matcher.group(1).trim().toLowerCase();
            if (tag.length() >= 2 && tag.length() <= 100) {
                hashtags.add(tag);
            }
        }

        return new ArrayList<>(hashtags);
    }

    public String removeHashtags(String content) {
        if (content == null || content.isEmpty()) {
            return content;
        }
        return content.replaceAll("#[^\\s#][^\\s#]*", "").trim();
    }

    public int countHashtags(String content) {
        return extractHashtags(content).size();
    }
}
