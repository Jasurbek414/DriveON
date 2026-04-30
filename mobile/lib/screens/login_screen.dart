import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';
import '../theme/app_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _loading = false;
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
  }

  @override
  void dispose() { _animCtrl.dispose(); _usernameCtrl.dispose(); _passwordCtrl.dispose(); super.dispose(); }

  Future<void> _handleLogin() async {
    if (_usernameCtrl.text.isEmpty || _passwordCtrl.text.isEmpty) return;
    setState(() => _loading = true);
    final auth = context.read<AuthService>();
    final ok = await auth.login(_usernameCtrl.text.trim(), _passwordCtrl.text.trim());
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
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: FadeTransition(
                opacity: _fadeAnim,
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    const Text('🚗', style: TextStyle(fontSize: 48)),
                    const SizedBox(height: 8),
                    ShaderMask(
                      shaderCallback: (b) => AppColors.primaryGradient.createShader(b),
                      child: const Text('DriveON', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                    const SizedBox(height: 4),
                    Text('Tizimga kirish', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14)),
                    const SizedBox(height: 32),
                    if (auth.error != null) Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.error.withOpacity(0.3)),
                      ),
                      child: Text(auth.error!, style: const TextStyle(color: AppColors.error, fontSize: 13), textAlign: TextAlign.center),
                    ),
                    TextField(controller: _usernameCtrl, decoration: const InputDecoration(hintText: 'Username yoki Email', prefixIcon: Icon(Icons.person_outline))),
                    const SizedBox(height: 16),
                    TextField(controller: _passwordCtrl, obscureText: true, decoration: const InputDecoration(hintText: 'Parol', prefixIcon: Icon(Icons.lock_outline)),
                      onSubmitted: (_) => _handleLogin()),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _handleLogin,
                        child: _loading
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('Kirish'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => context.go('/register'),
                      child: RichText(text: TextSpan(
                        style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13),
                        children: const [
                          TextSpan(text: "Akkauntingiz yo'qmi? "),
                          TextSpan(text: "Ro'yxatdan o'tish", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
                        ],
                      )),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.05), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.primary.withOpacity(0.15))),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('Demo:', style: TextStyle(color: AppColors.primary.withOpacity(0.7), fontSize: 11, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text('admin / admin123', style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11)),
                      ]),
                    ),
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
