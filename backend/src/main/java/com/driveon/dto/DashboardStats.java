package com.driveon.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class DashboardStats {
    private long totalOrders;
    private long pendingOrders;
    private long activeOrders;
    private long deliveredOrders;
    private long cancelledOrders;
    private long totalUsers;
}
