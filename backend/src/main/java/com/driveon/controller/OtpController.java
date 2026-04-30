package com.driveon.controller;

import com.driveon.service.SmsService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.Map;

@RestController
@RequestMapping("/api/auth/otp")
@RequiredArgsConstructor
@Tag(name = "OTP", description = "SMS OTP verification")
public class OtpController {

    private final SmsService smsService;

    @PostMapping("/send")
    @Operation(summary = "SMS OTP yuborish")
    public ResponseEntity<Map<String, Object>> sendOtp(@RequestBody Map<String, String> body) {
        String phone = body.get("phoneNumber");
        if (phone == null || phone.isBlank()) {
            return ResponseEntity.badRequest().body(Map.of("message", "Telefon raqam majburiy"));
        }
        String code = smsService.sendOtp(phone);
        // In dev mode, return code for testing
        return ResponseEntity.ok(Map.of(
                "message", "SMS kod yuborildi",
                "devCode", code,
                "expiresInSeconds", 180
        ));
    }

    @PostMapping("/verify")
    @Operation(summary = "OTP ni tasdiqlash")
    public ResponseEntity<Map<String, Object>> verifyOtp(@RequestBody Map<String, String> body) {
        String phone = body.get("phoneNumber");
        String code = body.get("code");
        smsService.verifyOtp(phone, code);
        return ResponseEntity.ok(Map.of("verified", true, "message", "Telefon tasdiqlandi"));
    }
}
