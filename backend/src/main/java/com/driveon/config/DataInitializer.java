package com.driveon.config;

import com.driveon.model.Role;
import com.driveon.model.User;
import com.driveon.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.crypto.password.PasswordEncoder;

import java.util.Set;

@Configuration
@RequiredArgsConstructor
@Slf4j
public class DataInitializer {

    @Bean
    CommandLineRunner initData(UserRepository userRepository, PasswordEncoder passwordEncoder) {
        return args -> {
            if (userRepository.count() == 0) {
                // Admin user
                User admin = User.builder()
                        .username("admin")
                        .email("admin@driveon.uz")
                        .password(passwordEncoder.encode("admin123"))
                        .fullName("Admin DriveON")
                        .phoneNumber("+998901234567")
                        .roles(Set.of(Role.ROLE_ADMIN))
                        .active(true)
                        .build();
                userRepository.save(admin);

                // Operator user
                User operator = User.builder()
                        .username("operator")
                        .email("operator@driveon.uz")
                        .password(passwordEncoder.encode("operator123"))
                        .fullName("Operator DriveON")
                        .phoneNumber("+998901234568")
                        .roles(Set.of(Role.ROLE_OPERATOR))
                        .active(true)
                        .build();
                userRepository.save(operator);

                // Driver user
                User driver = User.builder()
                        .username("driver")
                        .email("driver@driveon.uz")
                        .password(passwordEncoder.encode("driver123"))
                        .fullName("Haydovchi Test")
                        .phoneNumber("+998901234569")
                        .roles(Set.of(Role.ROLE_DRIVER))
                        .active(true)
                        .build();
                userRepository.save(driver);

                log.info("✅ Default foydalanuvchilar yaratildi: admin, operator, driver");
            }
        };
    }
}
