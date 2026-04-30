package com.driveon.model;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "payment_cards")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class PaymentCard {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "card_number_masked", nullable = false, length = 19)
    private String cardNumberMasked;

    @Column(name = "card_holder", length = 100)
    private String cardHolder;

    @Column(name = "expiry_month", nullable = false)
    private Integer expiryMonth;

    @Column(name = "expiry_year", nullable = false)
    private Integer expiryYear;

    @Column(name = "card_token", nullable = false)
    private String cardToken;

    @Enumerated(EnumType.STRING)
    @Column(name = "card_type")
    @Builder.Default
    private CardType cardType = CardType.UZCARD;

    @Column(name = "is_default")
    @Builder.Default
    private Boolean isDefault = false;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    @PrePersist
    protected void onCreate() { createdAt = LocalDateTime.now(); }
}
