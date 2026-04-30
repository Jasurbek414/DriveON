package com.driveon.repository;

import com.driveon.model.Fine;
import com.driveon.model.FineStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface FineRepository extends JpaRepository<Fine, Long> {
    List<Fine> findByUserId(Long userId);
    List<Fine> findByUserIdAndStatus(Long userId, FineStatus status);
    List<Fine> findByVehicleId(Long vehicleId);
    long countByUserIdAndStatus(Long userId, FineStatus status);
}
