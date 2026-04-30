package com.driveon.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class RegisterRequest {

    @NotBlank(message = "Username majburiy")
    @Size(min = 3, max = 50, message = "Username 3-50 belgi orasida bo'lishi kerak")
    private String username;

    @NotBlank(message = "Email majburiy")
    @Email(message = "Email formati noto'g'ri")
    private String email;

    @NotBlank(message = "Parol majburiy")
    @Size(min = 6, message = "Parol kamida 6 belgi bo'lishi kerak")
    private String password;

    @NotBlank(message = "Ism majburiy")
    private String fullName;

    private String phoneNumber;
}
