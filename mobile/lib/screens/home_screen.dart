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
      backgroundColor: const Color(0xFF0B0B14),
      body: Stack(
        children: [
          // Ambient Glow
          Positioned(top: -100, right: -100, child: Container(width: 300, height: 300, decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.15), blurRadius: 120, spreadRadius: 40)]))),
          Positioned(bottom: 100, left: -100, child: Container(width: 250, height: 250, decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [BoxShadow(color: AppColors.secondary.withOpacity(0.1), blurRadius: 120, spreadRadius: 40)]))),
          
          SafeArea(
            child: ListView(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16), children: [
              // Header
              Row(children: [
                InkWell(
                  onTap: () => context.go('/profile'),
                  borderRadius: BorderRadius.circular(24),
                  child: Container(width: 48, height: 48, decoration: BoxDecoration(shape: BoxShape.circle, gradient: AppColors.primaryGradient, boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))]),
                    child: Center(
                      child: Text(user?['fullName'] != null && user!['fullName'].isNotEmpty ? user['fullName'].substring(0, 1).toUpperCase() : 'A', 
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))
                    )
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Xush kelibsiz,', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12, letterSpacing: 0.5)),
                  const SizedBox(height: 2),
                  Text(user?['fullName'] ?? user?['phoneNumber'] ?? 'User', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700, letterSpacing: 0.3)),
                ])),
                Row(
                  children: [
                    _iconBtn(Icons.settings_outlined, () => context.go('/settings')),
                    const SizedBox(width: 10),
                    _iconBtn(Icons.notifications_none_rounded, () {}),
                  ],
                ),
              ]),
              const SizedBox(height: 20),

              // Weather & Currencies (Compact Horizontal Scroll)
              SizedBox(
                height: 56,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _compactWidget(Icons.wb_sunny_rounded, "Toshkent", "+22°C", Colors.orangeAccent),
                    const SizedBox(width: 10),
                    _compactWidget(Icons.attach_money_rounded, "USD", "12 650", Colors.greenAccent),
                    const SizedBox(width: 10),
                    _compactWidget(Icons.euro_rounded, "EUR", "13 500", Colors.blueAccent),
                    const SizedBox(width: 10),
                    _compactWidget(Icons.currency_ruble_rounded, "RUB", "140", Colors.redAccent),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // myID Banner (Premium Glass)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Colors.white.withOpacity(0.06), Colors.white.withOpacity(0.02)]),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                ),
                child: Row(children: [
                  Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.15), shape: BoxShape.circle),
                    child: const Icon(Icons.verified_user_rounded, color: AppColors.primary, size: 20)),
                  const SizedBox(width: 14),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text("To'liq identifikatsiya", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text('myID yoki myGov yordamida', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
                  ])),
                  Icon(Icons.arrow_forward_ios, color: Colors.white.withOpacity(0.3), size: 14),
                ]),
              ),
              const SizedBox(height: 28),

              // Quick Menu
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _actionButton(Icons.directions_car_rounded, 'Mashina', AppColors.primary, () => context.go('/vehicles')),
                  _actionButton(Icons.receipt_long_rounded, 'Jarima', AppColors.warning, () => context.go('/fines'), badge: _finesCount > 0 ? '$_finesCount' : null),
                  _actionButton(Icons.credit_card_rounded, 'Karta', AppColors.success, () => context.go('/cards')),
                  _actionButton(Icons.shield_rounded, "Sug'urta", AppColors.secondary, () {}),
                ],
              ),
              const SizedBox(height: 32),

              // Info section
              Text("Boshqa xizmatlar", style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.3)),
              const SizedBox(height: 12),
              _serviceRow(Icons.search_rounded, "Jarima qidirish", "Davlat raqami orqali topish", () {}),
              _serviceRow(Icons.history_rounded, "To'lovlar tarixi", "Barcha amaliyotlar", () {}),
              _serviceRow(Icons.headset_mic_rounded, "Qo'llab-quvvatlash", "Yordam va savollar", () {}),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _iconBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.04), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withOpacity(0.08))),
        child: Icon(icon, color: Colors.white.withOpacity(0.9), size: 20),
      ),
    );
  }

  Widget _actionButton(IconData icon, String label, Color color, VoidCallback onTap, {String? badge}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Colors.white.withOpacity(0.06), Colors.white.withOpacity(0.02)]),
              borderRadius: BorderRadius.circular(16), 
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Center(child: Icon(icon, color: color.withOpacity(0.9), size: 24)),
                if (badge != null) Positioned(
                  top: -6, right: -6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                    decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(8)),
                    child: Text(badge, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 0.2)),
        ],
      ),
    );
  }

  Widget _compactWidget(IconData icon, String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color.withOpacity(0.9), size: 18),
          const SizedBox(width: 10),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 10, letterSpacing: 0.5)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _serviceRow(IconData icon, String title, String sub, VoidCallback onTap) {
    return InkWell(onTap: onTap, borderRadius: BorderRadius.circular(18), child: Container(
      margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.centerLeft, end: Alignment.centerRight, colors: [Colors.white.withOpacity(0.03), Colors.white.withOpacity(0.01)]),
        borderRadius: BorderRadius.circular(18), 
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(children: [
        Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: Colors.white.withOpacity(0.9), size: 20)),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text(sub, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
        ])),
        Icon(Icons.arrow_forward_ios, color: Colors.white.withOpacity(0.2), size: 14),
      ]),
    ));
  }

  Widget _miniWidget(IconData icon, String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color.withOpacity(0.8), size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11, letterSpacing: 0.5)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 0.3)),
            ],
          ),
        ],
      ),
    );
  }
}
