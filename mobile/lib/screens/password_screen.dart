import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';
import '../theme/app_colors.dart';

class PasswordScreen extends StatefulWidget {
  final String phone;
  const PasswordScreen({super.key, required this.phone});
  @override
  State<PasswordScreen> createState() => _PasswordScreenState();
}

class _PasswordScreenState extends State<PasswordScreen> {
  final _ctrl = TextEditingController();
  bool _loading = false, _obscure = true;

  Future<void> _login() async {
    if (_ctrl.text.isEmpty) return;
    setState(() => _loading = true);
    final auth = context.read<AuthService>();
    final ok = await auth.login(widget.phone, _ctrl.text);
    setState(() => _loading = false);
    if (ok && mounted) context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Padding(padding: const EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => context.go('/phone')),
            const SizedBox(height: 32),
            const Text('Parolingizni kiriting', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(widget.phone, style: TextStyle(color: Colors.white.withOpacity(0.5))),
            const SizedBox(height: 32),
            if (auth.error != null) Container(
              padding: const EdgeInsets.all(12), margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(color: AppColors.error.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: Text(auth.error!, style: const TextStyle(color: AppColors.error, fontSize: 13)),
            ),
            TextField(controller: _ctrl, obscureText: _obscure,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              decoration: InputDecoration(hintText: 'Parol', prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility, color: Colors.white38),
                  onPressed: () => setState(() => _obscure = !_obscure)))),
            const SizedBox(height: 24),
            SizedBox(width: double.infinity, height: 52, child: ElevatedButton(
              onPressed: _loading ? null : _login,
              child: _loading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Kirish'),
            )),
          ])),
        ),
      ),
    );
  }
}
