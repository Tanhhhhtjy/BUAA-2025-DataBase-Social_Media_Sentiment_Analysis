package com.socialmedia.sentiment.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public class PostCreateRequest {

    @NotBlank(message = "帖子内容不能为空")
    @Size(min = 1, max = 5000, message = "帖子内容长度必须在1-5000个字符之间")
    private String content;

    public PostCreateRequest() {}

    public PostCreateRequest(String content) {
        this.content = content;
    }

    public String getContent() {
        return content;
    }

    public void setContent(String content) {
        this.content = content;
    }
}
