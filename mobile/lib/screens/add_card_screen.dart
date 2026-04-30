import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';

class AddCardScreen extends StatefulWidget {
  const AddCardScreen({super.key});
  @override
  State<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  final _number = TextEditingController();
  final _holder = TextEditingController();
  final _month = TextEditingController();
  final _year = TextEditingController();
  String _type = 'UZCARD';
  bool _loading = false;

  Future<void> _save() async {
    if (_number.text.length < 16 || _holder.text.isEmpty) return;
    setState(() => _loading = true);
    try {
      await ApiService.addCard({
        'cardNumber': _number.text.replaceAll(' ', ''),
        'cardHolder': _holder.text.trim().toUpperCase(),
        'expiryMonth': _month.text, 'expiryYear': _year.text,
        'cardType': _type,
      });
      if (mounted) context.go('/cards');
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally { if (mounted) setState(() => _loading = false); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Karta qo'shish")),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: ListView(padding: const EdgeInsets.all(24), children: [
          // Card Type
          Row(children: ['UZCARD', 'HUMO', 'VISA'].map((t) => Expanded(child: GestureDetector(
            onTap: () => setState(() => _type = t),
            child: Container(
              margin: const EdgeInsets.only(right: 8), padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: _type == t ? AppColors.primary.withOpacity(0.2) : Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _type == t ? AppColors.primary : Colors.white.withOpacity(0.1)),
              ),
              child: Center(child: Text(t, style: TextStyle(color: _type == t ? AppColors.primary : Colors.white54, fontSize: 13, fontWeight: FontWeight.w600))),
            ),
          ))).toList()),
          const SizedBox(height: 24),
          Text('Karta raqami', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13)),
          const SizedBox(height: 6),
          TextField(controller: _number, keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(16)],
            style: const TextStyle(color: Colors.white, fontSize: 18, letterSpacing: 2),
            decoration: const InputDecoration(hintText: '8600 1234 5678 9012', prefixIcon: Icon(Icons.credit_card))),
          const SizedBox(height: 16),
          Text('Karta egasi', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13)),
          const SizedBox(height: 6),
          TextField(controller: _holder, textCapitalization: TextCapitalization.characters,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(hintText: 'JASURBEK TOSHMATOV', prefixIcon: Icon(Icons.person_outline))),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Oy', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13)),
              const SizedBox(height: 6),
              TextField(controller: _month, keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(2)],
                style: const TextStyle(color: Colors.white), decoration: const InputDecoration(hintText: '06')),
            ])),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Yil', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13)),
              const SizedBox(height: 6),
              TextField(controller: _year, keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(2)],
                style: const TextStyle(color: Colors.white), decoration: const InputDecoration(hintText: '28')),
            ])),
          ]),
          const SizedBox(height: 32),
          SizedBox(height: 52, child: ElevatedButton(onPressed: _loading ? null : _save,
            child: _loading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text("Saqlash"))),
        ]),
      ),
    );
  }
}
