import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _finesCount = 0;
  bool _loading = true;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _load();
  }

  @override
  void dispose() { _pulseController.dispose(); super.dispose(); }

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
    final name = user?['fullName'] ?? user?['phoneNumber'] ?? 'Foydalanuvchi';
    final initial = name.isNotEmpty ? name.substring(0, 1).toUpperCase() : 'A';

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A14),
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
                // ── HEADER ──
                Row(children: [
                  GestureDetector(
                    onTap: () => context.push('/profile'),
                    child: Container(
                      width: 50, height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF818CF8)]),
                        boxShadow: [BoxShadow(color: const Color(0xFF6366F1).withOpacity(0.4), blurRadius: 14, offset: const Offset(0, 5))],
                      ),
                      child: Center(child: Text(initial, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800))),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Xush kelibsiz,', style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12)),
                    const SizedBox(height: 2),
                    Text(name, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                  ])),
                  _headerBtn(Icons.settings_outlined, () => context.push('/settings')),
                  const SizedBox(width: 10),
                  _headerBtn(Icons.notifications_none_rounded, () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Bildirishnomalar bo'sh"), behavior: SnackBarBehavior.floating),
                    );
                  }),
                ]),
                const SizedBox(height: 20),

                // ── myID Banner (TOP) ──
                GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("myID integratsiyasi ishlab chiqilmoqda"), behavior: SnackBarBehavior.floating),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [const Color(0xFF6366F1).withOpacity(0.15), const Color(0xFF6366F1).withOpacity(0.05)]),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFF6366F1).withOpacity(0.2)),
                    ),
                    child: Row(children: [
                      AnimatedBuilder(
                        animation: _pulseController,
                        builder: (_, child) => Transform.scale(scale: 1.0 + _pulseController.value * 0.08, child: child),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: const Color(0xFF6366F1).withOpacity(0.2), shape: BoxShape.circle),
                          child: const Icon(Icons.verified_user_rounded, color: Color(0xFF818CF8), size: 20),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Text("To'liq identifikatsiya", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 2),
                        Text('myID yoki myGov orqali tasdiqlang', style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12)),
                      ])),
                      const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFF818CF8), size: 14),
                    ]),
                  ),
                ),
                const SizedBox(height: 24),

                // ── BALANCE CARD ──
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF1A1A2E), Color(0xFF16162A)]),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withOpacity(0.06)),
                    boxShadow: [BoxShadow(color: const Color(0xFF6366F1).withOpacity(0.08), blurRadius: 30, offset: const Offset(0, 12))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Umumiy balans", style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: const Color(0xFF10B981).withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
                            child: Row(mainAxisSize: MainAxisSize.min, children: [
                              Container(width: 6, height: 6, decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF10B981))),
                              const SizedBox(width: 6),
                              const Text("Faol", style: TextStyle(color: Color(0xFF10B981), fontSize: 11, fontWeight: FontWeight.bold)),
                            ]),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text("2,450,000 so'm", style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _balanceStat(Icons.trending_up_rounded, "Bu oy", "+1.2M", const Color(0xFF10B981)),
                          const SizedBox(width: 20),
                          _balanceStat(Icons.local_gas_station_rounded, "Yoqilg'i", "35 L", const Color(0xFF6366F1)),
                          const SizedBox(width: 20),
                          _balanceStat(Icons.receipt_long_rounded, "Jarimalar", "$_finesCount ta", const Color(0xFFF59E0B)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // ── QUICK ACTIONS ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _quickAction(Icons.directions_car_rounded, 'Mashina', const Color(0xFF6366F1), () => context.push('/vehicles')),
                    _quickAction(Icons.receipt_long_rounded, 'Jarima', const Color(0xFFF59E0B), () => context.push('/fines'), badge: _finesCount > 0 ? '$_finesCount' : null),
                    _quickAction(Icons.credit_card_rounded, 'Karta', const Color(0xFF10B981), () => context.push('/cards')),
                    _quickAction(Icons.shield_rounded, "Sug'urta", const Color(0xFFEC4899), () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Tez orada ishga tushadi"), behavior: SnackBarBehavior.floating),
                      );
                    }),
                  ],
                ),
                const SizedBox(height: 32),

                // ── MAP PREVIEW ──
                Row(
                  children: [
                    Container(width: 3, height: 18, decoration: BoxDecoration(color: const Color(0xFF10B981), borderRadius: BorderRadius.circular(2))),
                    const SizedBox(width: 10),
                    const Text("Xarita", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                  ],
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () => context.go('/map'),
                  child: Container(
                    height: 140,
                    decoration: BoxDecoration(
                      color: const Color(0xFF12121F),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.04)),
                    ),
                    child: Stack(children: [
                      // Grid pattern
                      CustomPaint(size: const Size(double.infinity, 140), painter: _MiniMapPainter()),
                      // Overlay content
                      Positioned(left: 16, bottom: 16, child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6366F1).withOpacity(0.9),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [BoxShadow(color: const Color(0xFF6366F1).withOpacity(0.4), blurRadius: 10)],
                        ),
                        child: const Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(Icons.map_rounded, color: Colors.white, size: 16),
                          SizedBox(width: 8),
                          Text("Xaritani ochish", style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
                        ]),
                      )),
                      Positioned(right: 16, top: 16, child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.3)),
                        ),
                        child: const Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(Icons.radar_rounded, color: Color(0xFFEF4444), size: 14),
                          SizedBox(width: 4),
                          Text("3 radar", style: TextStyle(color: Color(0xFFEF4444), fontSize: 11, fontWeight: FontWeight.bold)),
                        ]),
                      )),
                    ]),
                  ),
                ),
                const SizedBox(height: 32),

                // ── SERVICES ──
                Row(
                  children: [
                    Container(width: 3, height: 18, decoration: BoxDecoration(color: const Color(0xFF6366F1), borderRadius: BorderRadius.circular(2))),
                    const SizedBox(width: 10),
                    const Text("Xizmatlar", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                  ],
                ),
                const SizedBox(height: 16),
                _serviceRow(Icons.radar_rounded, "Radarlar xaritasi", "Tezlik kameralarini ko'ring", const Color(0xFF6366F1), () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Tez orada ishga tushadi"), behavior: SnackBarBehavior.floating));
                }),
                _serviceRow(Icons.local_car_wash_rounded, "Avtoyuvish", "Yaqin joylardagi moykalar", const Color(0xFFEC4899), () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Tez orada ishga tushadi"), behavior: SnackBarBehavior.floating));
                }),
                _serviceRow(Icons.local_parking_rounded, "Smart parkovka", "To'lov va joy qidirish", const Color(0xFF10B981), () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Tez orada ishga tushadi"), behavior: SnackBarBehavior.floating));
                }),
                _serviceRow(Icons.local_gas_station_rounded, "Yoqilg'i narxlari", "Benzin va gaz narxlari", const Color(0xFFF59E0B), () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Tez orada ishga tushadi"), behavior: SnackBarBehavior.floating));
                }),
            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }

  // ── WIDGETS ──
  Widget _headerBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42, height: 42,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
        ),
        child: Icon(icon, color: Colors.white.withOpacity(0.8), size: 20),
      ),
    );
  }

  Widget _balanceStat(IconData icon, String label, String value, Color color) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
            Text(label, style: TextStyle(color: Colors.white.withOpacity(0.35), fontSize: 10)),
          ]),
        ],
      ),
    );
  }

  Widget _ratePill(String emoji, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(label, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 9)),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
          ]),
        ],
      ),
    );
  }

  Widget _quickAction(IconData icon, String label, Color color, VoidCallback onTap, {String? badge}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(children: [
        Container(
          width: 56, height: 56,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Center(child: Icon(icon, color: color, size: 26)),
              if (badge != null) Positioned(top: -5, right: -5,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(color: const Color(0xFFEF4444), borderRadius: BorderRadius.circular(8)),
                  child: Text(badge, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 11, fontWeight: FontWeight.w600)),
      ]),
    );
  }

  Widget _serviceRow(IconData icon, String title, String sub, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.02),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withOpacity(0.03)),
        ),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(14)),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            Text(sub, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12)),
          ])),
          Icon(Icons.arrow_forward_ios_rounded, color: Colors.white.withOpacity(0.15), size: 14),
        ]),
      ),
    );
  }
}

class _MiniMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()..color = Colors.white.withOpacity(0.03)..strokeWidth = 0.5;
    for (double x = 0; x < size.width; x += 30) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += 30) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
    final road = Paint()..color = Colors.white.withOpacity(0.06)..strokeWidth = 2.5;
    canvas.drawLine(Offset(0, size.height * 0.5), Offset(size.width, size.height * 0.5), road);
    canvas.drawLine(Offset(size.width * 0.6, 0), Offset(size.width * 0.6, size.height), road);
    canvas.drawLine(Offset(0, size.height * 0.2), Offset(size.width * 0.4, size.height * 0.8), road);
    final dot = Paint()..color = const Color(0xFF6366F1);
    canvas.drawCircle(Offset(size.width * 0.6, size.height * 0.5), 6, dot);
    canvas.drawCircle(Offset(size.width * 0.6, size.height * 0.5), 12, Paint()..color = const Color(0xFF6366F1).withOpacity(0.15));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
