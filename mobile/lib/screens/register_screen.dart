import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import '../services/api_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _phoneCtrl = TextEditingController(text: '+998');
  bool _loading = false;
  String? _error;

  Future<void> _register() async {
    final phone = _phoneCtrl.text.trim();
    if (phone.length < 13) { setState(() => _error = "To'liq raqam kiriting"); return; }
    setState(() { _loading = true; _error = null; });
    try {
      final check = await ApiService.checkPhone(phone);
      if (check['registered'] == true) {
        setState(() => _error = "Bu raqam allaqachon ro'yxatdan o'tgan. Iltimos, kiring.");
      } else {
        await ApiService.sendOtp(phone);
        if (mounted) context.go('/otp', extra: phone);
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
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => context.go('/phone')),
                const SizedBox(height: 32),
                const Text("Ro'yxatdan o'tish", style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Yangi hisob yaratish uchun telefon raqamingizni kiriting', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 15)),
                const SizedBox(height: 48),
                Text('Telefon raqam', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                TextField(
                  controller: _phoneCtrl,
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
                    onPressed: _loading ? null : _register,
                    child: _loading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Davom etish'),
                  ),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
