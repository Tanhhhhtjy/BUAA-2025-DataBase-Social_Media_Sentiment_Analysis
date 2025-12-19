package com.socialmedia.sentiment.util;

import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

public class PasswordHashGenerator {

    public static void main(String[] args) {
        BCryptPasswordEncoder encoder = new BCryptPasswordEncoder();
        String rawPassword = "admin123";

        for (int i = 1; i <= 3; i++) {
            String hash = encoder.encode(rawPassword);
            System.out.println("BCrypt hash " + i + ": " + hash);
        }
    }
}

