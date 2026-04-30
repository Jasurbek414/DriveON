package com.driveon.service;

import com.driveon.model.*;
import com.driveon.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.List;

@Service
@RequiredArgsConstructor
public class VehicleService {
    private final VehicleRepository vehicleRepo;
    private final UserRepository userRepo;

    public List<Vehicle> getUserVehicles(String username) {
        User user = userRepo.findByUsername(username).orElseThrow();
        return vehicleRepo.findByOwnerId(user.getId());
    }

    public Vehicle getById(Long id) {
        return vehicleRepo.findById(id).orElseThrow(() -> new RuntimeException("Avtomobil topilmadi"));
    }

    @Transactional
    public Vehicle addVehicle(String username, Vehicle vehicle) {
        User owner = userRepo.findByUsername(username).orElseThrow();
        if (vehicleRepo.existsByPlateNumber(vehicle.getPlateNumber())) {
            throw new RuntimeException("Bu davlat raqami allaqachon mavjud");
        }
        vehicle.setOwner(owner);
        return vehicleRepo.save(vehicle);
    }

    @Transactional
    public Vehicle updateVehicle(Long id, Vehicle data) {
        Vehicle v = getById(id);
        v.setBrand(data.getBrand());
        v.setModel(data.getModel());
        v.setColor(data.getColor());
        v.setManufactureYear(data.getManufactureYear());
        v.setTechPassportNumber(data.getTechPassportNumber());
        v.setFuelType(data.getFuelType());
        return vehicleRepo.save(v);
    }

    @Transactional
    public void deleteVehicle(Long id) { vehicleRepo.deleteById(id); }
}
