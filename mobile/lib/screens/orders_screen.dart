import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});
  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  List<dynamic> _orders = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final data = await ApiService.getOrders();
      if (mounted) setState(() { _orders = data['content'] ?? []; _loading = false; });
    } catch (_) { if (mounted) setState(() => _loading = false); }
  }

  Color _statusColor(String s) {
    switch (s) {
      case 'DELIVERED': return AppColors.success;
      case 'CANCELLED': return AppColors.error;
      case 'PENDING': return AppColors.warning;
      default: return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buyurtmalar')),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: _loading
          ? const Center(child: CircularProgressIndicator())
          : _orders.isEmpty
            ? Center(child: Text("Buyurtmalar yo'q", style: TextStyle(color: Colors.white.withOpacity(0.5))))
            : RefreshIndicator(
                onRefresh: _load,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _orders.length,
                  itemBuilder: (_, i) {
                    final o = _orders[i];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withOpacity(0.08)),
                      ),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Text(o['orderNumber'] ?? '', style: TextStyle(color: AppColors.primary, fontFamily: 'monospace', fontSize: 12)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: _statusColor(o['status'] ?? '').withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
                            child: Text(o['status'] ?? '', style: TextStyle(color: _statusColor(o['status'] ?? ''), fontSize: 10, fontWeight: FontWeight.w600)),
                          ),
                        ]),
                        const SizedBox(height: 8),
                        Text(o['title'] ?? '', style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 8),
                        Row(children: [
                          Icon(Icons.location_on_outlined, size: 14, color: Colors.white.withOpacity(0.4)),
                          const SizedBox(width: 4),
                          Expanded(child: Text(o['deliveryAddress'] ?? '', style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12), overflow: TextOverflow.ellipsis)),
                        ]),
                        if (o['price'] != null) ...[
                          const SizedBox(height: 6),
                          Text("${o['price']} so'm", style: const TextStyle(color: AppColors.primary, fontSize: 14, fontWeight: FontWeight.w600)),
                        ],
                      ]),
                    );
                  },
                ),
              ),
      ),
    );
  }
}
