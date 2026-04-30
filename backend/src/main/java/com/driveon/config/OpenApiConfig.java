package com.driveon.config;

import io.swagger.v3.oas.annotations.enums.SecuritySchemeType;
import io.swagger.v3.oas.annotations.security.SecurityScheme;
import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Contact;
import io.swagger.v3.oas.models.info.Info;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
@SecurityScheme(
        name = "bearerAuth",
        type = SecuritySchemeType.HTTP,
        bearerFormat = "JWT",
        scheme = "bearer"
)
public class OpenApiConfig {

    @Bean
    public OpenAPI driveOnOpenAPI() {
        return new OpenAPI()
                .info(new Info()
                        .title("DriveON API")
                        .description("DriveON Platform REST API — Professional Grade")
                        .version("1.0.0")
                        .contact(new Contact()
                                .name("DriveON Team")
                                .email("info@driveon.uz"))
                );
    }
}
