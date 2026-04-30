package com.driveon.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class LoginRequest {

    @NotBlank(message = "Username yoki email majburiy")
    private String username;

    @NotBlank(message = "Parol majburiy")
    private String password;
}
