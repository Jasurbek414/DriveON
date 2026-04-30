import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';

class FinesScreen extends StatefulWidget {
  const FinesScreen({super.key});
  @override
  State<FinesScreen> createState() => _FinesScreenState();
}

class _FinesScreenState extends State<FinesScreen> {
  List<dynamic> _fines = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final data = await ApiService.getFines();
      if (mounted) setState(() { _fines = data is List ? data : []; _loading = false; });
    } catch (_) { if (mounted) setState(() => _loading = false); }
  }

  Color _statusColor(String s) {
    switch (s) { case 'PAID': return AppColors.success; case 'OVERDUE': return AppColors.error; default: return AppColors.warning; }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Jarimalar')),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: _loading ? const Center(child: CircularProgressIndicator())
          : _fines.isEmpty
            ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.check_circle_outline, size: 64, color: AppColors.success.withOpacity(0.5)),
                const SizedBox(height: 16),
                Text("Jarimalar yo'q! 🎉", style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 16)),
              ]))
            : RefreshIndicator(onRefresh: _load, child: ListView.builder(
                padding: const EdgeInsets.all(16), itemCount: _fines.length,
                itemBuilder: (_, i) {
                  final f = _fines[i];
                  final status = f['status'] ?? 'UNPAID';
                  final amount = f['amount']?.toString() ?? '0';
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(16), border: Border.all(color: _statusColor(status).withOpacity(0.2))),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text(f['protocolNumber'] ?? '', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12, fontFamily: 'monospace')),
                        Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: _statusColor(status).withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
                          child: Text(status, style: TextStyle(color: _statusColor(status), fontSize: 10, fontWeight: FontWeight.w600))),
                      ]),
                      const SizedBox(height: 8),
                      Text(f['description'] ?? '', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 4),
                      if (f['location'] != null) Row(children: [
                        Icon(Icons.location_on_outlined, size: 14, color: Colors.white.withOpacity(0.3)),
                        const SizedBox(width: 4),
                        Expanded(child: Text(f['location'], style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 12), overflow: TextOverflow.ellipsis)),
                      ]),
                      const SizedBox(height: 8),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text("$amount so'm", style: const TextStyle(color: AppColors.error, fontSize: 18, fontWeight: FontWeight.bold)),
                        if (status == 'UNPAID') SizedBox(height: 36, child: ElevatedButton(
                          onPressed: () {/* TODO: pay */}, style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 20)),
                          child: const Text("To'lash", style: TextStyle(fontSize: 13)))),
                      ]),
                    ]),
                  );
                },
              )),
      ),
    );
  }
}
