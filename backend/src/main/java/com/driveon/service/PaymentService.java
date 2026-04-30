package com.driveon.service;

import com.driveon.model.*;
import com.driveon.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class PaymentService {
    private final PaymentCardRepository cardRepo;
    private final PaymentRepository paymentRepo;
    private final FineRepository fineRepo;
    private final UserRepository userRepo;

    // ---- Cards ----
    public List<PaymentCard> getUserCards(String username) {
        User u = userRepo.findByUsername(username).orElseThrow();
        return cardRepo.findByUserId(u.getId());
    }

    @Transactional
    public PaymentCard addCard(String username, String cardNumber, String holder, int month, int year, String type) {
        User u = userRepo.findByUsername(username).orElseThrow();
        String masked = "**** **** **** " + cardNumber.substring(cardNumber.length() - 4);
        String token = UUID.randomUUID().toString();

        PaymentCard card = PaymentCard.builder()
                .cardNumberMasked(masked)
                .cardHolder(holder)
                .expiryMonth(month)
                .expiryYear(year)
                .cardToken(token)
                .cardType(CardType.valueOf(type.toUpperCase()))
                .isDefault(cardRepo.findByUserId(u.getId()).isEmpty())
                .user(u)
                .build();
        return cardRepo.save(card);
    }

    @Transactional
    public void setDefaultCard(String username, Long cardId) {
        User u = userRepo.findByUsername(username).orElseThrow();
        cardRepo.findByUserId(u.getId()).forEach(c -> {
            c.setIsDefault(c.getId().equals(cardId));
            cardRepo.save(c);
        });
    }

    @Transactional
    public void deleteCard(Long cardId) { cardRepo.deleteById(cardId); }

    // ---- Payments ----
    @Transactional
    public Payment payFine(String username, Long fineId, Long cardId) {
        User u = userRepo.findByUsername(username).orElseThrow();
        Fine fine = fineRepo.findById(fineId).orElseThrow(() -> new RuntimeException("Jarima topilmadi"));
        PaymentCard card = cardRepo.findById(cardId).orElseThrow(() -> new RuntimeException("Karta topilmadi"));

        BigDecimal amount = fine.getDiscountAmount() != null ? fine.getDiscountAmount() : fine.getAmount();

        Payment payment = Payment.builder()
                .amount(amount)
                .paymentType(PaymentType.FINE)
                .referenceId(fineId)
                .status(PaymentStatus.COMPLETED) // Simulated
                .description("Jarima to'lovi: " + fine.getProtocolNumber())
                .user(u)
                .card(card)
                .paidAt(LocalDateTime.now())
                .build();
        payment = paymentRepo.save(payment);

        fine.setStatus(FineStatus.PAID);
        fine.setPaidAt(LocalDateTime.now());
        fineRepo.save(fine);

        return payment;
    }

    public List<Payment> getUserPayments(String username) {
        User u = userRepo.findByUsername(username).orElseThrow();
        return paymentRepo.findByUserIdOrderByCreatedAtDesc(u.getId());
    }
}
