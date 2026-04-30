package com.driveon.service;

import com.driveon.dto.*;
import com.driveon.model.*;
import com.driveon.repository.OrderRepository;
import com.driveon.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
public class OrderService {

    private final OrderRepository orderRepository;
    private final UserRepository userRepository;

    public Page<OrderDto> getAllOrders(Pageable pageable) {
        return orderRepository.findAll(pageable).map(this::toDto);
    }

    public Page<OrderDto> getOrdersByStatus(OrderStatus status, Pageable pageable) {
        return orderRepository.findByStatus(status, pageable).map(this::toDto);
    }

    public Page<OrderDto> getOrdersByCustomer(Long customerId, Pageable pageable) {
        return orderRepository.findByCustomerId(customerId, pageable).map(this::toDto);
    }

    public Page<OrderDto> getOrdersByDriver(Long driverId, Pageable pageable) {
        return orderRepository.findByDriverId(driverId, pageable).map(this::toDto);
    }

    public OrderDto getOrderById(Long id) {
        Order order = orderRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Buyurtma topilmadi: " + id));
        return toDto(order);
    }

    @Transactional
    public OrderDto createOrder(CreateOrderRequest request, String username) {
        User customer = userRepository.findByUsername(username)
                .orElseThrow(() -> new RuntimeException("Foydalanuvchi topilmadi"));

        Order order = Order.builder()
                .title(request.getTitle())
                .description(request.getDescription())
                .pickupAddress(request.getPickupAddress())
                .pickupLat(request.getPickupLat())
                .pickupLng(request.getPickupLng())
                .deliveryAddress(request.getDeliveryAddress())
                .deliveryLat(request.getDeliveryLat())
                .deliveryLng(request.getDeliveryLng())
                .price(request.getPrice())
                .scheduledAt(request.getScheduledAt())
                .customer(customer)
                .status(OrderStatus.PENDING)
                .build();

        order = orderRepository.save(order);
        return toDto(order);
    }

    @Transactional
    public OrderDto assignDriver(Long orderId, Long driverId) {
        Order order = orderRepository.findById(orderId)
                .orElseThrow(() -> new RuntimeException("Buyurtma topilmadi: " + orderId));
        User driver = userRepository.findById(driverId)
                .orElseThrow(() -> new RuntimeException("Haydovchi topilmadi: " + driverId));

        order.setDriver(driver);
        order.setStatus(OrderStatus.ASSIGNED);
        order = orderRepository.save(order);
        return toDto(order);
    }

    @Transactional
    public OrderDto updateStatus(Long orderId, OrderStatus status) {
        Order order = orderRepository.findById(orderId)
                .orElseThrow(() -> new RuntimeException("Buyurtma topilmadi: " + orderId));

        order.setStatus(status);
        switch (status) {
            case PICKED_UP -> order.setPickedUpAt(LocalDateTime.now());
            case DELIVERED -> order.setDeliveredAt(LocalDateTime.now());
            case CANCELLED -> order.setCancelledAt(LocalDateTime.now());
            default -> {}
        }

        order = orderRepository.save(order);
        return toDto(order);
    }

    public DashboardStats getDashboardStats() {
        return DashboardStats.builder()
                .totalOrders(orderRepository.count())
                .pendingOrders(orderRepository.countByStatus(OrderStatus.PENDING))
                .activeOrders(orderRepository.countByStatus(OrderStatus.IN_TRANSIT))
                .deliveredOrders(orderRepository.countByStatus(OrderStatus.DELIVERED))
                .cancelledOrders(orderRepository.countByStatus(OrderStatus.CANCELLED))
                .totalUsers(userRepository.count())
                .build();
    }

    private OrderDto toDto(Order order) {
        return OrderDto.builder()
                .id(order.getId())
                .orderNumber(order.getOrderNumber())
                .title(order.getTitle())
                .description(order.getDescription())
                .status(order.getStatus())
                .pickupAddress(order.getPickupAddress())
                .pickupLat(order.getPickupLat())
                .pickupLng(order.getPickupLng())
                .deliveryAddress(order.getDeliveryAddress())
                .deliveryLat(order.getDeliveryLat())
                .deliveryLng(order.getDeliveryLng())
                .price(order.getPrice())
                .distance(order.getDistance())
                .customerId(order.getCustomer() != null ? order.getCustomer().getId() : null)
                .customerName(order.getCustomer() != null ? order.getCustomer().getFullName() : null)
                .driverId(order.getDriver() != null ? order.getDriver().getId() : null)
                .driverName(order.getDriver() != null ? order.getDriver().getFullName() : null)
                .operatorId(order.getOperator() != null ? order.getOperator().getId() : null)
                .scheduledAt(order.getScheduledAt())
                .pickedUpAt(order.getPickedUpAt())
                .deliveredAt(order.getDeliveredAt())
                .createdAt(order.getCreatedAt())
                .build();
    }
}
