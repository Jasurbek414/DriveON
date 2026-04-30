package com.driveon.service;

import com.driveon.model.OtpVerification;
import com.driveon.repository.OtpRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.security.SecureRandom;

@Service
@RequiredArgsConstructor
@Slf4j
public class SmsService {

    private final OtpRepository otpRepository;
    private final SecureRandom random = new SecureRandom();

    @Transactional
    public String sendOtp(String phoneNumber) {
        // DEV MODE: hardcoded 4-digit code "1234"
        // TODO: Integrate real SMS gateway (Eskiz.uz, PlayMobile, etc.)
        String code = "1234";

        OtpVerification otp = OtpVerification.builder()
                .phoneNumber(phoneNumber)
                .code(code)
                .verified(false)
                .build();
        otpRepository.save(otp);

        log.info("📱 [DEV] SMS OTP for {}: {} (hardcoded)", phoneNumber, code);

        return code;
    }

    @Transactional
    public boolean verifyOtp(String phoneNumber, String code) {
        OtpVerification otp = otpRepository
                .findTopByPhoneNumberAndVerifiedFalseOrderByCreatedAtDesc(phoneNumber)
                .orElseThrow(() -> new RuntimeException("OTP topilmadi. Qayta urinib ko'ring."));

        if (otp.isExpired()) {
            throw new RuntimeException("OTP muddati tugagan. Qayta so'rang.");
        }

        if (!otp.getCode().equals(code)) {
            throw new RuntimeException("OTP kod noto'g'ri.");
        }

        otp.setVerified(true);
        otpRepository.save(otp);
        return true;
    }
}
