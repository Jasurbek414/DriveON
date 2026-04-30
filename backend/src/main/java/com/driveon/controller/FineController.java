package com.driveon.controller;

import com.driveon.model.*;
import com.driveon.repository.*;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/fines")
@RequiredArgsConstructor
@SecurityRequirement(name = "bearerAuth")
@Tag(name = "Fines", description = "Jarimalar")
public class FineController {
    private final FineRepository fineRepo;
    private final UserRepository userRepo;

    @GetMapping
    public ResponseEntity<List<Fine>> getMyFines(@AuthenticationPrincipal UserDetails u) {
        User user = userRepo.findByUsername(u.getUsername()).orElseThrow();
        return ResponseEntity.ok(fineRepo.findByUserId(user.getId()));
    }

    @GetMapping("/unpaid")
    public ResponseEntity<List<Fine>> getUnpaidFines(@AuthenticationPrincipal UserDetails u) {
        User user = userRepo.findByUsername(u.getUsername()).orElseThrow();
        return ResponseEntity.ok(fineRepo.findByUserIdAndStatus(user.getId(), FineStatus.UNPAID));
    }

    @GetMapping("/count")
    public ResponseEntity<Long> getUnpaidCount(@AuthenticationPrincipal UserDetails u) {
        User user = userRepo.findByUsername(u.getUsername()).orElseThrow();
        return ResponseEntity.ok(fineRepo.countByUserIdAndStatus(user.getId(), FineStatus.UNPAID));
    }
}
