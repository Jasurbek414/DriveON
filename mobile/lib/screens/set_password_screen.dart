import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';
import '../theme/app_colors.dart';

class SetPasswordScreen extends StatefulWidget {
  final String phone;
  const SetPasswordScreen({super.key, required this.phone});
  @override
  State<SetPasswordScreen> createState() => _SetPasswordScreenState();
}

class _SetPasswordScreenState extends State<SetPasswordScreen> {
  final _pass = TextEditingController();
  final _confirm = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _register() async {
    if (_pass.text.length < 6) { setState(() => _error = "Parol kamida 6 belgi"); return; }
    if (_pass.text != _confirm.text) { setState(() => _error = "Parollar mos emas"); return; }
    setState(() { _loading = true; _error = null; });
    final auth = context.read<AuthService>();
    final ok = await auth.registerByPhone(widget.phone, _pass.text);
    setState(() => _loading = false);
    if (ok && mounted) context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Padding(padding: const EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => context.go('/phone')),
            const SizedBox(height: 32),
            const Text('Parol yarating', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text("Hisobingiz uchun parol o'rnating", style: TextStyle(color: Colors.white.withOpacity(0.5))),
            const SizedBox(height: 32),
            if (_error != null) Container(
              padding: const EdgeInsets.all(12), margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(color: AppColors.error.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: Text(_error!, style: const TextStyle(color: AppColors.error, fontSize: 13)),
            ),
            TextField(controller: _pass, obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(hintText: 'Parol', prefixIcon: Icon(Icons.lock_outline))),
            const SizedBox(height: 16),
            TextField(controller: _confirm, obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(hintText: 'Parolni tasdiqlang', prefixIcon: Icon(Icons.lock_outline))),
            const SizedBox(height: 24),
            SizedBox(width: double.infinity, height: 52, child: ElevatedButton(
              onPressed: _loading ? null : _register,
              child: _loading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text("Ro'yxatdan o'tish"),
            )),
          ])),
        ),
      ),
    );
  }
}
