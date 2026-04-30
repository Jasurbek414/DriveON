package com.driveon.controller;

import com.driveon.model.Vehicle;
import com.driveon.service.VehicleService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/vehicles")
@RequiredArgsConstructor
@SecurityRequirement(name = "bearerAuth")
@Tag(name = "Vehicles", description = "Avtomobillar boshqaruvi")
public class VehicleController {
    private final VehicleService vehicleService;

    @GetMapping
    @Operation(summary = "Mening avtomobillarim")
    public ResponseEntity<List<Vehicle>> getMyVehicles(@AuthenticationPrincipal UserDetails u) {
        return ResponseEntity.ok(vehicleService.getUserVehicles(u.getUsername()));
    }

    @GetMapping("/{id}")
    public ResponseEntity<Vehicle> getById(@PathVariable Long id) {
        return ResponseEntity.ok(vehicleService.getById(id));
    }

    @PostMapping
    @Operation(summary = "Avtomobil qo'shish")
    public ResponseEntity<Vehicle> addVehicle(@AuthenticationPrincipal UserDetails u, @RequestBody Vehicle vehicle) {
        return ResponseEntity.ok(vehicleService.addVehicle(u.getUsername(), vehicle));
    }

    @PutMapping("/{id}")
    public ResponseEntity<Vehicle> updateVehicle(@PathVariable Long id, @RequestBody Vehicle vehicle) {
        return ResponseEntity.ok(vehicleService.updateVehicle(id, vehicle));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteVehicle(@PathVariable Long id) {
        vehicleService.deleteVehicle(id);
        return ResponseEntity.noContent().build();
    }
}
