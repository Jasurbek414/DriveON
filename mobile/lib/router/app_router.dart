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

import '../screens/register_screen.dart';
import '../screens/pin_screen.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/phone',
    redirect: (context, state) {
      final auth = context.read<AuthService>();
      final isAuth = auth.isAuthenticated;
      final isLoading = auth.isLoading;
      final authRoutes = ['/phone', '/register', '/otp', '/password', '/set-password'];
      final isAuthRoute = authRoutes.contains(state.matchedLocation);
      
      if (isLoading) return null;
      
      if (isAuth) {
        if (auth.isPinLocked && state.matchedLocation != '/pin' && state.matchedLocation != '/pin_setup') return '/pin';
        if (!auth.isPinLocked && state.matchedLocation == '/pin') return '/';
        if (isAuthRoute) return '/';
        return null;
      } else {
        if (!isAuthRoute) return '/phone';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/pin', builder: (_, __) => const PinScreen()),
      GoRoute(path: '/pin_setup', builder: (_, __) => const PinScreen(isSetup: true)),
      GoRoute(path: '/phone', builder: (_, __) => const PhoneEntryScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      GoRoute(path: '/otp', builder: (_, state) => OtpScreen(phone: state.extra as String)),
      GoRoute(path: '/password', builder: (_, state) => PasswordScreen(phone: state.extra as String)),
      GoRoute(path: '/set-password', builder: (_, state) => SetPasswordScreen(phone: state.extra as String)),
      ShellRoute(
        builder: (_, __, child) => MainShell(child: child),
        routes: [
          GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
          GoRoute(path: '/vehicles', builder: (_, __) => const VehiclesScreen()),
          GoRoute(path: '/vehicles/add', builder: (_, __) => const AddVehicleScreen()),
          GoRoute(path: '/fines', builder: (_, __) => const FinesScreen()),
          GoRoute(path: '/cards', builder: (_, __) => const CardsScreen()),
          GoRoute(path: '/cards/add', builder: (_, __) => const AddCardScreen()),
          GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
          GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
        ],
      ),
    ],
  );
}

class MainShell extends StatefulWidget {
  final Widget child;
  const MainShell({super.key, required this.child});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _i = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(color: const Color(0xFF1A1A3E), border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05)))),
        child: NavigationBar(
          backgroundColor: Colors.transparent,
          selectedIndex: _i,
          indicatorColor: const Color(0xFF6366F1).withOpacity(0.2),
          onDestinationSelected: (i) {
            setState(() => _i = i);
            switch (i) { case 0: context.go('/'); case 1: context.go('/vehicles'); case 2: context.go('/fines'); case 3: context.go('/profile'); }
          },
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home_rounded), label: 'Asosiy'),
            NavigationDestination(icon: Icon(Icons.directions_car_rounded), label: 'Mashinalar'),
            NavigationDestination(icon: Icon(Icons.receipt_long_rounded), label: 'Jarimalar'),
            NavigationDestination(icon: Icon(Icons.person_rounded), label: 'Profil'),
          ],
        ),
      ),
    );
  }
}
