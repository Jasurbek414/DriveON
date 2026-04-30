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
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16), children: [
          // Header
          Row(children: [
            Container(width: 46, height: 46, decoration: const BoxDecoration(shape: BoxShape.circle, gradient: AppColors.primaryGradient),
              child: Center(child: Text(user?['fullName']?.substring(0, 1) ?? 'ðŸ‘¤', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)))),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Xush kelibsiz,', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12, letterSpacing: 0.5)),
              const SizedBox(height: 2),
              Text(user?['fullName'] ?? user?['phoneNumber'] ?? 'User', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600, letterSpacing: 0.3)),
            ])),
            Row(
              children: [
                _iconBtn(Icons.settings_outlined, () => context.go('/settings')),
                const SizedBox(width: 8),
                _iconBtn(Icons.notifications_none_rounded, () {}),
              ],
            ),
          ]),
          const SizedBox(height: 32),

          // myID Banner (Sleek)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.02),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primary.withOpacity(0.15)),
            ),
            child: Row(children: [
              Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), shape: BoxShape.circle),
                child: const Icon(Icons.verified_user_outlined, color: AppColors.primary, size: 20)),
              const SizedBox(width: 16),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text("To'liq identifikatsiyadan o'ting", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text('myID yoki myGov yordamida', style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12)),
              ])),
              Icon(Icons.arrow_forward_ios, color: Colors.white.withOpacity(0.2), size: 14),
            ]),
          ),
          const SizedBox(height: 36),

          // Quick Menu
          Text("Asosiy xizmatlar", style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0.3)),
          const SizedBox(height: 16),
          GridView.count(crossAxisCount: 2, crossAxisSpacing: 16, mainAxisSpacing: 16, shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(), childAspectRatio: 1.15,
            children: [
              _menuCard(Icons.directions_car_outlined, 'Mashinalar', AppColors.primary, () => context.go('/vehicles')),
              _menuCard(Icons.receipt_long_outlined, 'Jarimalar', AppColors.warning, () => context.go('/fines'), badge: _finesCount > 0 ? '$_finesCount' : null),
              _menuCard(Icons.credit_card_outlined, 'Kartalar', AppColors.success, () => context.go('/cards')),
              _menuCard(Icons.shield_outlined, "Sug'urta", AppColors.secondary, () {}),
            ],
          ),
          const SizedBox(height: 36),

          // Info section
          Text("Boshqa xizmatlar", style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0.3)),
          const SizedBox(height: 12),
          _serviceRow(Icons.search_rounded, "Jarima qidirish", "Davlat raqami orqali topish", () {}),
          _serviceRow(Icons.history_rounded, "To'lovlar tarixi", "Barcha amaliyotlar", () {}),
          _serviceRow(Icons.headset_mic_outlined, "Qo'llab-quvvatlash", "Yordam va savollar", () {}),
        ]),
      ),
    );
  }

  Widget _iconBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.03), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withOpacity(0.05))),
        child: Icon(icon, color: Colors.white.withOpacity(0.7), size: 20),
      ),
    );
  }

  Widget _menuCard(IconData icon, String label, Color color, VoidCallback onTap, {String? badge}) {
    return GestureDetector(onTap: onTap, child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.02), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withOpacity(0.06))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, color: color.withOpacity(0.9), size: 28),
          if (badge != null) Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(12)),
            child: Text(badge, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
        ]),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500, letterSpacing: 0.2)),
      ]),
    ));
  }

  Widget _serviceRow(IconData icon, String title, String sub, VoidCallback onTap) {
    return InkWell(onTap: onTap, borderRadius: BorderRadius.circular(16), child: Container(
      margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.02), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.04))),
      child: Row(children: [
        Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.white.withOpacity(0.03), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: Colors.white.withOpacity(0.8), size: 20)),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500)),
          const SizedBox(height: 2),
          Text(sub, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13)),
        ])),
        Icon(Icons.arrow_forward_ios, color: Colors.white.withOpacity(0.15), size: 14),
      ]),
    ));
  }
}
