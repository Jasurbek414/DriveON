package com.driveon.controller;

import com.driveon.dto.*;
import com.driveon.service.AuthService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.Map;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
@Tag(name = "Authentication", description = "Auth API")
public class AuthController {
    private final AuthService authService;

    @PostMapping("/login")
    @Operation(summary = "Login (telefon yoki username + parol)")
    public ResponseEntity<AuthResponse> login(@Valid @RequestBody LoginRequest request) {
        return ResponseEntity.ok(authService.login(request));
    }

    @PostMapping("/register")
    @Operation(summary = "To'liq ro'yxatdan o'tish")
    public ResponseEntity<AuthResponse> register(@Valid @RequestBody RegisterRequest request) {
        return ResponseEntity.ok(authService.register(request));
    }

    @PostMapping("/register/phone")
    @Operation(summary = "Telefon orqali ro'yxatdan o'tish (OTP tasdiqlangandan keyin)")
    public ResponseEntity<AuthResponse> registerByPhone(@RequestBody Map<String, String> body) {
        return ResponseEntity.ok(authService.registerByPhone(body.get("phoneNumber"), body.get("password")));
    }

    @GetMapping("/check-phone")
    @Operation(summary = "Telefon raqam ro'yxatdan o'tganmi tekshirish")
    public ResponseEntity<Map<String, Boolean>> checkPhone(@RequestParam String phone) {
        return ResponseEntity.ok(Map.of("registered", authService.isPhoneRegistered(phone)));
    }

    @PostMapping("/refresh")
    public ResponseEntity<AuthResponse> refresh(@RequestParam String refreshToken) {
        return ResponseEntity.ok(authService.refreshToken(refreshToken));
    }
}
