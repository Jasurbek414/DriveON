import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';

class CardsScreen extends StatefulWidget {
  const CardsScreen({super.key});
  @override
  State<CardsScreen> createState() => _CardsScreenState();
}

class _CardsScreenState extends State<CardsScreen> {
  List<dynamic> _cards = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final data = await ApiService.getCards();
      if (mounted) setState(() { _cards = data is List ? data : []; _loading = false; });
    } catch (_) { if (mounted) setState(() => _loading = false); }
  }

  Color _cardColor(String? type) {
    switch (type) { case 'UZCARD': return const Color(0xFF00A86B); case 'HUMO': return const Color(0xFF1E3A5F); default: return AppColors.primary; }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kartalarim'), actions: [
        IconButton(icon: const Icon(Icons.add_card), onPressed: () => context.go('/cards/add')),
      ]),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: _loading ? const Center(child: CircularProgressIndicator())
          : _cards.isEmpty
            ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.credit_card_off, size: 64, color: Colors.white.withOpacity(0.2)),
                const SizedBox(height: 16),
                Text("Karta qo'shilmagan", style: TextStyle(color: Colors.white.withOpacity(0.4))),
                const SizedBox(height: 16),
                ElevatedButton.icon(icon: const Icon(Icons.add_card), label: const Text("Qo'shish"), onPressed: () => context.go('/cards/add')),
              ]))
            : ListView.builder(padding: const EdgeInsets.all(16), itemCount: _cards.length, itemBuilder: (_, i) {
                final c = _cards[i];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16), height: 190, padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [_cardColor(c['cardType']), _cardColor(c['cardType']).withOpacity(0.7)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: _cardColor(c['cardType']).withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))],
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text(c['cardType'] ?? 'CARD', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 2)),
                      if (c['isDefault'] == true) Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
                        child: const Text('Asosiy', style: TextStyle(color: Colors.white, fontSize: 10))),
                    ]),
                    Text(c['cardNumberMasked'] ?? '**** **** **** ****', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w500, letterSpacing: 3)),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('CARD HOLDER', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10)),
                        Text(c['cardHolder'] ?? '', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
                      ]),
                      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                        Text('EXPIRES', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10)),
                        Text('${c['expiryMonth']}/${c['expiryYear']}', style: const TextStyle(color: Colors.white, fontSize: 13)),
                      ]),
                    ]),
                  ]),
                );
              }),
      ),
    );
  }
}
