import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';

class VehiclesScreen extends StatefulWidget {
  const VehiclesScreen({super.key});
  @override
  State<VehiclesScreen> createState() => _VehiclesScreenState();
}

class _VehiclesScreenState extends State<VehiclesScreen> {
  List<dynamic> _vehicles = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final data = await ApiService.getVehicles();
      if (mounted) setState(() { _vehicles = data is List ? data : []; _loading = false; });
    } catch (_) { if (mounted) setState(() => _loading = false); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Avtomobillarim'), actions: [
        IconButton(icon: const Icon(Icons.add_circle_outline), onPressed: () => context.go('/vehicles/add')),
      ]),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: _loading ? const Center(child: CircularProgressIndicator())
          : _vehicles.isEmpty
            ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.directions_car_outlined, size: 64, color: Colors.white.withOpacity(0.2)),
                const SizedBox(height: 16),
                Text("Avtomobil qo'shilmagan", style: TextStyle(color: Colors.white.withOpacity(0.4))),
                const SizedBox(height: 16),
                ElevatedButton.icon(icon: const Icon(Icons.add), label: const Text("Qo'shish"), onPressed: () => context.go('/vehicles/add')),
              ]))
            : RefreshIndicator(onRefresh: _load, child: ListView.builder(
                padding: const EdgeInsets.all(16), itemCount: _vehicles.length,
                itemBuilder: (_, i) {
                  final v = _vehicles[i];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.08))),
                    child: Row(children: [
                      Container(width: 56, height: 56, decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.directions_car, color: AppColors.primary, size: 28)),
                      const SizedBox(width: 16),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('${v['brand'] ?? ''} ${v['model'] ?? ''}', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text(v['plateNumber'] ?? '', style: TextStyle(color: AppColors.primary, fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 1)),
                        if (v['color'] != null) Text(v['color'], style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12)),
                      ])),
                      Text('${v['manufactureYear'] ?? ''}', style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 13)),
                    ]),
                  );
                },
              )),
      ),
    );
  }
}
