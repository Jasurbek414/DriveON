package com.driveon.repository;

import com.driveon.model.PaymentCard;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.Optional;

public interface PaymentCardRepository extends JpaRepository<PaymentCard, Long> {
    List<PaymentCard> findByUserId(Long userId);
    Optional<PaymentCard> findByUserIdAndIsDefaultTrue(Long userId);
}
