import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../theme/app_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _finesCount = 0;
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final count = await ApiService.getUnpaidCount();
      if (mounted) setState(() { _finesCount = count is int ? count : 0; _loading = false; });
    } catch (_) { if (mounted) setState(() => _loading = false); }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final user = auth.user;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: ListView(padding: const EdgeInsets.all(20), children: [
            // Header
            Row(children: [
              Container(width: 48, height: 48, decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(14)),
                child: Center(child: Text(user?['fullName']?.substring(0, 1) ?? '👤', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)))),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Salom!', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13)),
                Text(user?['fullName'] ?? user?['phoneNumber'] ?? 'User', style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600)),
              ])),
              Container(
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
                child: IconButton(icon: const Icon(Icons.notifications_none, color: Colors.white54), onPressed: () {}),
              ),
            ]),
            const SizedBox(height: 28),

            // myID Banner
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [AppColors.primary.withOpacity(0.2), AppColors.secondary.withOpacity(0.1)]),
                borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: Row(children: [
                Container(width: 48, height: 48, decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.verified_user, color: AppColors.primary)),
                const SizedBox(width: 16),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text("To'liq ro'yxatdan o'ting", style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
                  Text('myID yoki myGov orqali tasdiqlang', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
                ])),
                const Icon(Icons.arrow_forward_ios, color: AppColors.primary, size: 16),
              ]),
            ),
            const SizedBox(height: 24),

            // Quick Menu
            GridView.count(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(), childAspectRatio: 1.3,
              children: [
                _menuCard(Icons.directions_car, 'Mashinalarim', AppColors.primary, () => context.go('/vehicles')),
                _menuCard(Icons.receipt_long, 'Jarimalar', AppColors.warning, () => context.go('/fines'), badge: _finesCount > 0 ? '$_finesCount' : null),
                _menuCard(Icons.credit_card, 'Kartalarim', AppColors.success, () => context.go('/cards')),
                _menuCard(Icons.shield_outlined, "Sug'urta", AppColors.secondary, () {}),
              ],
            ),
            const SizedBox(height: 24),

            // Info section
            Text("Xizmatlar", style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            _serviceRow(Icons.sync, "Jarima tekshirish", "Davlat raqami bo'yicha", () {}),
            _serviceRow(Icons.history, "To'lov tarixi", "Barcha to'lovlar", () {}),
            _serviceRow(Icons.help_outline, "Yordam", "Ko'p so'raladigan savollar", () {}),
          ]),
        ),
      ),
    );
  }

  Widget _menuCard(IconData icon, String label, Color color, VoidCallback onTap, {String? badge}) {
    return GestureDetector(onTap: onTap, child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withOpacity(0.08))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Container(width: 44, height: 44, decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 22)),
          if (badge != null) Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(10)),
            child: Text(badge, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
        ]),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
      ]),
    ));
  }

  Widget _serviceRow(IconData icon, String title, String sub, VoidCallback onTap) {
    return GestureDetector(onTap: onTap, child: Container(
      margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.03), borderRadius: BorderRadius.circular(14)),
      child: Row(children: [
        Icon(icon, color: AppColors.primary, size: 22), const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
          Text(sub, style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 12)),
        ])),
        Icon(Icons.chevron_right, color: Colors.white.withOpacity(0.2), size: 20),
      ]),
    ));
  }
}
