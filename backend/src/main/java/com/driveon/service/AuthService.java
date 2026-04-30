package com.driveon.service;

import com.driveon.dto.*;
import com.driveon.model.Role;
import com.driveon.model.User;
import com.driveon.repository.UserRepository;
import com.driveon.security.JwtTokenProvider;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.Set;

@Service
@RequiredArgsConstructor
public class AuthService {

    private final AuthenticationManager authenticationManager;
    private final JwtTokenProvider tokenProvider;
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    public AuthResponse login(LoginRequest request) {
        // Support login by phone or username
        String identifier = request.getUsername();
        User user = userRepository.findByPhoneNumber(identifier)
                .or(() -> userRepository.findByUsernameOrEmail(identifier, identifier))
                .orElseThrow(() -> new RuntimeException("Foydalanuvchi topilmadi"));

        Authentication authentication = authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(user.getUsername(), request.getPassword())
        );

        String accessToken = tokenProvider.generateAccessToken(authentication);
        String refreshToken = tokenProvider.generateRefreshToken(user.getUsername());

        return AuthResponse.of(accessToken, refreshToken, tokenProvider.getExpirationMs(), toUserDto(user));
    }

    @Transactional
    public AuthResponse registerByPhone(String phoneNumber, String password) {
        User user = userRepository.findByPhoneNumber(phoneNumber).orElse(null);
        
        if (user != null) {
            // Reset password for existing user
            user.setPassword(passwordEncoder.encode(password));
            user = userRepository.save(user);
        } else {
            // Create new user
            String username = "user_" + phoneNumber.replaceAll("[^0-9]", "");
            user = User.builder()
                    .username(username)
                    .phoneNumber(phoneNumber)
                    .password(passwordEncoder.encode(password))
                    .phoneVerified(true)
                    .roles(Set.of(Role.ROLE_USER))
                    .active(true)
                    .build();
            user = userRepository.save(user);
        }

        String accessToken = tokenProvider.generateAccessToken(user.getUsername());
        String refreshToken = tokenProvider.generateRefreshToken(user.getUsername());

        return AuthResponse.of(accessToken, refreshToken, tokenProvider.getExpirationMs(), toUserDto(user));
    }

    @Transactional
    public AuthResponse register(RegisterRequest request) {
        if (userRepository.existsByUsername(request.getUsername())) {
            throw new RuntimeException("Bu username band");
        }
        if (request.getEmail() != null && userRepository.existsByEmail(request.getEmail())) {
            throw new RuntimeException("Bu email band");
        }

        User user = User.builder()
                .username(request.getUsername())
                .email(request.getEmail())
                .password(passwordEncoder.encode(request.getPassword()))
                .fullName(request.getFullName())
                .phoneNumber(request.getPhoneNumber())
                .roles(Set.of(Role.ROLE_USER))
                .active(true)
                .build();
        user = userRepository.save(user);

        String accessToken = tokenProvider.generateAccessToken(user.getUsername());
        String refreshToken = tokenProvider.generateRefreshToken(user.getUsername());

        return AuthResponse.of(accessToken, refreshToken, tokenProvider.getExpirationMs(), toUserDto(user));
    }

    public AuthResponse refreshToken(String refreshToken) {
        if (!tokenProvider.validateToken(refreshToken)) throw new RuntimeException("Refresh token yaroqsiz");
        String username = tokenProvider.getUsernameFromToken(refreshToken);
        String newAccess = tokenProvider.generateAccessToken(username);
        String newRefresh = tokenProvider.generateRefreshToken(username);
        User user = userRepository.findByUsername(username).orElseThrow();
        return AuthResponse.of(newAccess, newRefresh, tokenProvider.getExpirationMs(), toUserDto(user));
    }

    public boolean isPhoneRegistered(String phone) {
        return userRepository.existsByPhoneNumber(phone);
    }

    private UserDto toUserDto(User user) {
        return UserDto.builder()
                .id(user.getId()).username(user.getUsername()).email(user.getEmail())
                .fullName(user.getFullName()).phoneNumber(user.getPhoneNumber())
                .avatarUrl(user.getAvatarUrl()).active(user.getActive())
                .roles(user.getRoles()).createdAt(user.getCreatedAt())
                .build();
    }
}
