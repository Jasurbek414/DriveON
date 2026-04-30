package com.driveon.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
public class CreateOrderRequest {

    @NotBlank(message = "Buyurtma sarlavhasi majburiy")
    private String title;

    private String description;

    @NotBlank(message = "Olib ketish manzili majburiy")
    private String pickupAddress;

    private Double pickupLat;
    private Double pickupLng;

    @NotBlank(message = "Yetkazish manzili majburiy")
    private String deliveryAddress;

    private Double deliveryLat;
    private Double deliveryLng;

    private BigDecimal price;
    private LocalDateTime scheduledAt;
}
