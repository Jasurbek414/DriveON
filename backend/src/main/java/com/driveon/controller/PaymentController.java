package com.driveon.controller;

import com.driveon.model.*;
import com.driveon.service.PaymentService;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/payments")
@RequiredArgsConstructor
@SecurityRequirement(name = "bearerAuth")
@Tag(name = "Payments", description = "To'lovlar va kartalar")
public class PaymentController {
    private final PaymentService paymentService;

    // Cards
    @GetMapping("/cards")
    public ResponseEntity<List<PaymentCard>> getCards(@AuthenticationPrincipal UserDetails u) {
        return ResponseEntity.ok(paymentService.getUserCards(u.getUsername()));
    }

    @PostMapping("/cards")
    public ResponseEntity<PaymentCard> addCard(@AuthenticationPrincipal UserDetails u, @RequestBody Map<String, String> body) {
        return ResponseEntity.ok(paymentService.addCard(u.getUsername(),
                body.get("cardNumber"), body.get("cardHolder"),
                Integer.parseInt(body.get("expiryMonth")), Integer.parseInt(body.get("expiryYear")),
                body.getOrDefault("cardType", "UZCARD")));
    }

    @PatchMapping("/cards/{id}/default")
    public ResponseEntity<Void> setDefault(@AuthenticationPrincipal UserDetails u, @PathVariable Long id) {
        paymentService.setDefaultCard(u.getUsername(), id);
        return ResponseEntity.ok().build();
    }

    @DeleteMapping("/cards/{id}")
    public ResponseEntity<Void> deleteCard(@PathVariable Long id) {
        paymentService.deleteCard(id);
        return ResponseEntity.noContent().build();
    }

    // Pay fine
    @PostMapping("/fine/{fineId}")
    public ResponseEntity<Payment> payFine(@AuthenticationPrincipal UserDetails u,
                                           @PathVariable Long fineId, @RequestParam Long cardId) {
        return ResponseEntity.ok(paymentService.payFine(u.getUsername(), fineId, cardId));
    }

    // History
    @GetMapping("/history")
    public ResponseEntity<List<Payment>> getHistory(@AuthenticationPrincipal UserDetails u) {
        return ResponseEntity.ok(paymentService.getUserPayments(u.getUsername()));
    }
}
