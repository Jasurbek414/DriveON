package com.driveon.controller;

import com.driveon.dto.*;
import com.driveon.model.OrderStatus;
import com.driveon.service.OrderService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/orders")
@RequiredArgsConstructor
@SecurityRequirement(name = "bearerAuth")
@Tag(name = "Orders", description = "Buyurtmalar boshqaruvi")
public class OrderController {

    private final OrderService orderService;

    @GetMapping
    @Operation(summary = "Barcha buyurtmalar (paginated)")
    public ResponseEntity<Page<OrderDto>> getAllOrders(
            @PageableDefault(size = 20) Pageable pageable) {
        return ResponseEntity.ok(orderService.getAllOrders(pageable));
    }

    @GetMapping("/{id}")
    @Operation(summary = "Buyurtmani ID bo'yicha olish")
    public ResponseEntity<OrderDto> getOrderById(@PathVariable Long id) {
        return ResponseEntity.ok(orderService.getOrderById(id));
    }

    @GetMapping("/status/{status}")
    @Operation(summary = "Status bo'yicha buyurtmalar")
    public ResponseEntity<Page<OrderDto>> getByStatus(
            @PathVariable OrderStatus status,
            @PageableDefault(size = 20) Pageable pageable) {
        return ResponseEntity.ok(orderService.getOrdersByStatus(status, pageable));
    }

    @GetMapping("/customer/{customerId}")
    @Operation(summary = "Mijoz buyurtmalari")
    public ResponseEntity<Page<OrderDto>> getByCustomer(
            @PathVariable Long customerId,
            @PageableDefault(size = 20) Pageable pageable) {
        return ResponseEntity.ok(orderService.getOrdersByCustomer(customerId, pageable));
    }

    @GetMapping("/driver/{driverId}")
    @Operation(summary = "Haydovchi buyurtmalari")
    public ResponseEntity<Page<OrderDto>> getByDriver(
            @PathVariable Long driverId,
            @PageableDefault(size = 20) Pageable pageable) {
        return ResponseEntity.ok(orderService.getOrdersByDriver(driverId, pageable));
    }

    @PostMapping
    @Operation(summary = "Yangi buyurtma yaratish")
    public ResponseEntity<OrderDto> createOrder(
            @Valid @RequestBody CreateOrderRequest request,
            @AuthenticationPrincipal UserDetails userDetails) {
        return ResponseEntity.ok(orderService.createOrder(request, userDetails.getUsername()));
    }

    @PatchMapping("/{id}/assign/{driverId}")
    @PreAuthorize("hasAnyRole('ADMIN', 'OPERATOR')")
    @Operation(summary = "Buyurtmaga haydovchi biriktirish")
    public ResponseEntity<OrderDto> assignDriver(
            @PathVariable Long id,
            @PathVariable Long driverId) {
        return ResponseEntity.ok(orderService.assignDriver(id, driverId));
    }

    @PatchMapping("/{id}/status/{status}")
    @Operation(summary = "Buyurtma statusini o'zgartirish")
    public ResponseEntity<OrderDto> updateStatus(
            @PathVariable Long id,
            @PathVariable OrderStatus status) {
        return ResponseEntity.ok(orderService.updateStatus(id, status));
    }

    @GetMapping("/dashboard/stats")
    @PreAuthorize("hasAnyRole('ADMIN', 'OPERATOR')")
    @Operation(summary = "Dashboard statistikasi")
    public ResponseEntity<DashboardStats> getDashboardStats() {
        return ResponseEntity.ok(orderService.getDashboardStats());
    }
}
