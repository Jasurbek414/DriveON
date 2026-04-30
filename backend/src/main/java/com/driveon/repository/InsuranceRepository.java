package com.driveon.repository;

import com.driveon.model.Insurance;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface InsuranceRepository extends JpaRepository<Insurance, Long> {
    List<Insurance> findByVehicleId(Long vehicleId);
    List<Insurance> findByVehicleOwnerId(Long ownerId);
}
