package com.driveon.repository;

import com.driveon.model.OtpVerification;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;

public interface OtpRepository extends JpaRepository<OtpVerification, Long> {
    Optional<OtpVerification> findTopByPhoneNumberAndVerifiedFalseOrderByCreatedAtDesc(String phoneNumber);
    void deleteByPhoneNumberAndVerifiedTrue(String phoneNumber);
}
