import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? _stats;
  bool _loading = true;

  @override
  void initState() { super.initState(); _loadStats(); }

  Future<void> _loadStats() async {
    try {
      final s = await ApiService.getDashboardStats();
      if (mounted) setState(() { _stats = s; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('DriveON Dashboard')),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadStats,
              child: ListView(padding: const EdgeInsets.all(16), children: [
                _buildStatGrid(),
                const SizedBox(height: 24),
                Text("Tez amallar", style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                _buildQuickActions(),
              ]),
            ),
      ),
    );
  }

  Widget _buildStatGrid() {
    final items = [
      {'key': 'totalOrders', 'label': 'Jami', 'icon': Icons.inventory_2, 'color': Colors.blue},
      {'key': 'pendingOrders', 'label': 'Kutilmoqda', 'icon': Icons.hourglass_empty, 'color': Colors.orange},
      {'key': 'activeOrders', 'label': 'Faol', 'icon': Icons.local_shipping, 'color': Colors.green},
      {'key': 'deliveredOrders', 'label': 'Yetkazilgan', 'icon': Icons.check_circle, 'color': AppColors.primary},
    ];
    return GridView.count(
      crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(), childAspectRatio: 1.4,
      children: items.map((item) {
        final val = _stats?[item['key']] ?? 0;
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Icon(item['icon'] as IconData, color: item['color'] as Color, size: 28),
            Text('$val', style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
            Text(item['label'] as String, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
          ]),
        );
      }).toList(),
    );
  }

  Widget _buildQuickActions() {
    return Row(children: [
      Expanded(child: _actionCard(Icons.add_circle_outline, 'Yangi buyurtma', AppColors.primary)),
      const SizedBox(width: 12),
      Expanded(child: _actionCard(Icons.people_outline, 'Haydovchilar', AppColors.secondary)),
    ]);
  }

  Widget _actionCard(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [color.withOpacity(0.15), color.withOpacity(0.05)]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13, fontWeight: FontWeight.w500)),
      ]),
    );
  }
}
