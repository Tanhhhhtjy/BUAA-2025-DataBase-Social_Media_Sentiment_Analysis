package com.socialmedia.sentiment.config;

import io.swagger.v3.oas.models.Components;
import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Contact;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.info.License;
import io.swagger.v3.oas.models.security.SecurityRequirement;
import io.swagger.v3.oas.models.security.SecurityScheme;
import io.swagger.v3.oas.models.servers.Server;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.util.List;

/**
 * Swagger/OpenAPI 3配置
 */
@Configuration
public class SwaggerConfig {

    @Bean
    public OpenAPI customOpenAPI() {
        return new OpenAPI()
                .info(new Info()
                        .title("社交媒体舆情分析系统 API")
                        .description("基于AI的社交媒体舆情分析系统，支持情感分析、话题提取、热点排行等功能")
                        .version("1.0.0")
                        .contact(new Contact()
                                .name("开发团队")
                                .email("dev@socialmedia.com")
                                .url("https://github.com/socialmedia-sentiment"))
                        .license(new License()
                                .name("MIT License")
                                .url("https://opensource.org/licenses/MIT")))
                .servers(List.of(
                        new Server().url("http://localhost:8080").description("开发环境"),
                        new Server().url("https://api.socialmedia.com").description("生产环境")))
                .addSecurityItem(new SecurityRequirement().addList("Bearer Token"))
                .components(new Components()
                        .addSecuritySchemes("Bearer Token",
                                new SecurityScheme()
                                        .type(SecurityScheme.Type.HTTP)
                                        .scheme("bearer")
                                        .bearerFormat("JWT")
                                        .description("JWT认证令牌")));
    }
}
