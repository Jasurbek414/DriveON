import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../screens/phone_entry_screen.dart';
import '../screens/otp_screen.dart';
import '../screens/password_screen.dart';
import '../screens/set_password_screen.dart';
import '../screens/home_screen.dart';
import '../screens/vehicles_screen.dart';
import '../screens/add_vehicle_screen.dart';
import '../screens/fines_screen.dart';
import '../screens/cards_screen.dart';
import '../screens/add_card_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/scanner_screen.dart';
import '../screens/map_screen.dart';

import '../screens/register_screen.dart';
import '../screens/pin_screen.dart';
import '../screens/splash_screen.dart';

class AppRouter {
  static GoRouter createRouter(AuthService auth) {
    return GoRouter(
      initialLocation: '/splash',
      refreshListenable: auth,
      redirect: (context, state) {
        final isAuth = auth.isAuthenticated;
        final isLoading = auth.isLoading;
        final authRoutes = ['/phone', '/register', '/otp', '/password', '/set-password'];
        final isAuthRoute = authRoutes.contains(state.matchedLocation);
        
        if (isLoading) return state.matchedLocation == '/splash' ? null : '/splash';
        
        if (isAuth) {
          if (auth.isPinLocked && state.matchedLocation != '/pin' && state.matchedLocation != '/pin_setup') return '/pin';
          if (!auth.isPinLocked && state.matchedLocation == '/pin') return '/';
          if (isAuthRoute || state.matchedLocation == '/splash') return '/';
          return null;
        } else {
          if (!isAuthRoute) return '/phone';
        }
        return null;
      },
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/pin', builder: (_, __) => const PinScreen()),
      GoRoute(path: '/pin_setup', builder: (_, __) => const PinScreen(isSetup: true)),
      GoRoute(path: '/phone', builder: (_, __) => const PhoneEntryScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      GoRoute(path: '/otp', builder: (_, state) => OtpScreen(phone: state.extra as String)),
      GoRoute(path: '/password', builder: (_, state) => PasswordScreen(phone: state.extra as String)),
      GoRoute(path: '/set-password', builder: (_, state) => SetPasswordScreen(phone: state.extra as String)),
      ShellRoute(
        builder: (_, state, child) => MainShell(child: child, currentPath: state.matchedLocation),
        routes: [
          GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
          GoRoute(path: '/vehicles', builder: (_, __) => const VehiclesScreen()),
          GoRoute(path: '/scanner', builder: (_, __) => const ScannerScreen()),
          GoRoute(path: '/map', builder: (_, __) => const MapScreen()),
          GoRoute(path: '/fines', builder: (_, __) => const FinesScreen()),
        ],
      ),
      GoRoute(path: '/vehicles/add', builder: (_, __) => const AddVehicleScreen()),
      GoRoute(path: '/cards', builder: (_, __) => const CardsScreen()),
      GoRoute(path: '/cards/add', builder: (_, __) => const AddCardScreen()),
      GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
      GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
    ],
  );
  }
}

class MainShell extends StatelessWidget {
  final Widget child;
  final String currentPath;
  const MainShell({super.key, required this.child, required this.currentPath});

  int get _currentIndex {
    if (currentPath.startsWith('/scanner')) return 1;
    if (currentPath.startsWith('/map')) return 2;
    if (currentPath.startsWith('/vehicles')) return 3;
    if (currentPath.startsWith('/fines')) return 4;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final canPop = _currentIndex == 0;
    
    return PopScope(
      canPop: canPop,
      onPopInvoked: (didPop) {
        if (didPop) return;
        context.go('/');
      },
      child: Scaffold(
        extendBody: true,
        body: child,
        bottomNavigationBar: SafeArea(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E40),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: const Color(0xFF6366F1).withOpacity(0.1),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavItem(context, 0, Icons.space_dashboard_rounded, Icons.space_dashboard_outlined, 'Asosiy'),
                _buildNavItem(context, 1, Icons.qr_code_scanner_rounded, Icons.qr_code_rounded, 'Skaner'),
                _buildNavItem(context, 2, Icons.map_rounded, Icons.map_outlined, 'Xarita'),
                _buildNavItem(context, 3, Icons.commute_rounded, Icons.commute_outlined, 'Avtomobil'),
                _buildNavItem(context, 4, Icons.assignment_late_rounded, Icons.assignment_late_outlined, 'Jarima'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, int index, IconData activeIcon, IconData inactiveIcon, String label) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        switch (index) { 
          case 0: context.go('/'); break;
          case 1: context.go('/scanner'); break;
          case 2: context.go('/map'); break;
          case 3: context.go('/vehicles'); break;
          case 4: context.go('/fines'); break;
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6366F1).withOpacity(0.9) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isSelected ? activeIcon : inactiveIcon, color: isSelected ? Colors.white : Colors.white54, size: 18),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.white54, fontSize: 9, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500), overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}
