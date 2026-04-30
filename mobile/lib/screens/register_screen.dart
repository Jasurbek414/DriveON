import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';
import '../theme/app_colors.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _fullName = TextEditingController();
  final _username = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;

  Future<void> _handleRegister() async {
    setState(() => _loading = true);
    final auth = context.read<AuthService>();
    final ok = await auth.register({
      'fullName': _fullName.text.trim(),
      'username': _username.text.trim(),
      'email': _email.text.trim(),
      'phoneNumber': _phone.text.trim(),
      'password': _password.text.trim(),
    });
    setState(() => _loading = false);
    if (ok && mounted) context.go('/');
  }

  @override
  void dispose() { _fullName.dispose(); _username.dispose(); _email.dispose(); _phone.dispose(); _password.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  ShaderMask(
                    shaderCallback: (b) => AppColors.primaryGradient.createShader(b),
                    child: const Text('DriveON', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                  const SizedBox(height: 4),
                  Text("Ro'yxatdan o'tish", style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14)),
                  const SizedBox(height: 24),
                  if (auth.error != null) Container(
                    padding: const EdgeInsets.all(12), margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(color: AppColors.error.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                    child: Text(auth.error!, style: const TextStyle(color: AppColors.error, fontSize: 13), textAlign: TextAlign.center),
                  ),
                  TextField(controller: _fullName, decoration: const InputDecoration(hintText: "To'liq ism")),
                  const SizedBox(height: 12),
                  TextField(controller: _username, decoration: const InputDecoration(hintText: 'Username')),
                  const SizedBox(height: 12),
                  TextField(controller: _email, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(hintText: 'Email')),
                  const SizedBox(height: 12),
                  TextField(controller: _phone, keyboardType: TextInputType.phone, decoration: const InputDecoration(hintText: 'Telefon')),
                  const SizedBox(height: 12),
                  TextField(controller: _password, obscureText: true, decoration: const InputDecoration(hintText: 'Parol')),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(onPressed: _loading ? null : _handleRegister,
                      child: _loading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text("Ro'yxatdan o'tish")),
                  ),
                  const SizedBox(height: 12),
                  TextButton(onPressed: () => context.go('/login'),
                    child: Text('Akkauntingiz bormi? Kirish', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13))),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
