import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import '../services/api_service.dart';

class PhoneEntryScreen extends StatefulWidget {
  const PhoneEntryScreen({super.key});
  @override
  State<PhoneEntryScreen> createState() => _PhoneEntryScreenState();
}

class _PhoneEntryScreenState extends State<PhoneEntryScreen> {
  final _ctrl = TextEditingController(text: '+998');
  bool _loading = false;
  String? _error;

  Future<void> _next() async {
    final phone = _ctrl.text.trim();
    if (phone.length < 13) { setState(() => _error = "To'liq raqam kiriting"); return; }
    setState(() { _loading = true; _error = null; });
    try {
      final check = await ApiService.checkPhone(phone);
      if (check['registered'] == true) {
        if (mounted) context.go('/password', extra: phone);
      } else {
        setState(() => _error = "Akkount topilmadi. Iltimos, ro'yxatdan o'ting.");
      }
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const SizedBox(height: 60),
              Center(child: ShaderMask(
                shaderCallback: (b) => AppColors.primaryGradient.createShader(b),
                child: const Text('🚗 DriveON', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
              )),
              const SizedBox(height: 8),
              Center(child: Text('Telefon raqamingizni kiriting', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 15))),
              const SizedBox(height: 48),
              Text('Telefon raqam', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              TextField(
                controller: _ctrl,
                keyboardType: TextInputType.phone,
                style: const TextStyle(color: Colors.white, fontSize: 18, letterSpacing: 1),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.phone_android, color: AppColors.primary),
                  hintText: '+998 90 123 45 67',
                  errorText: _error,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _loading ? null : _next,
                  child: _loading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Kirish'),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Akkountingiz yo'qmi?", style: TextStyle(color: Colors.white.withOpacity(0.5))),
                  TextButton(
                    onPressed: () => context.go('/register'),
                    child: const Text("Ro'yxatdan o'tish", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 60),
              Center(child: Text("Kirish orqali foydalanish shartlariga\nrozilik bildirasiz", textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 12))),
            ]),
                  ),
                ),
              ),
            ),
        ),
      ),
    );
  }
}
