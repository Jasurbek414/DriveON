import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';
import '../theme/app_colors.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final user = auth.user;

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: ListView(padding: const EdgeInsets.all(16), children: [
          const SizedBox(height: 16),
          Center(
            child: Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 20)],
              ),
              child: Center(child: Text(user?['fullName']?.substring(0, 1) ?? 'U', style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold))),
            ),
          ),
          const SizedBox(height: 16),
          Center(child: Text(user?['fullName'] ?? 'User', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))),
          Center(child: Text('@${user?['username'] ?? ''}', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14))),
          const SizedBox(height: 24),
          _infoTile(Icons.email_outlined, 'Email', user?['email'] ?? '—'),
          _infoTile(Icons.phone_outlined, 'Telefon', user?['phoneNumber'] ?? "Ko'rsatilmagan"),
          _infoTile(Icons.verified_user_outlined, 'Holat', user?['active'] == true ? 'Faol' : 'Nofaol'),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () { auth.logout(); context.go('/login'); },
              icon: const Icon(Icons.logout, color: AppColors.error),
              label: const Text('Chiqish', style: TextStyle(color: AppColors.error)),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: BorderSide(color: AppColors.error.withOpacity(0.3)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
        ]),
      ]),
    );
  }
}
