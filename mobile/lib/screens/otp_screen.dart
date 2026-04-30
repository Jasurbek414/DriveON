import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import '../services/api_service.dart';

class OtpScreen extends StatefulWidget {
  final String phone;
  const OtpScreen({super.key, required this.phone});
  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _ctrls = List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _nodes = List.generate(4, (_) => FocusNode());
  bool _loading = false;
  String? _error;
  int _timer = 120;

  @override
  void initState() { super.initState(); _startTimer(); _nodes[0].requestFocus(); }

  void _startTimer() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() => _timer--);
      return _timer > 0;
    });
  }

  String get _code => _ctrls.map((c) => c.text).join();

  Future<void> _verify() async {
    if (_code.length < 4) { setState(() => _error = "4 raqam kiriting"); return; }
    setState(() { _loading = true; _error = null; });
    try {
      await ApiService.verifyOtp(widget.phone, _code);
      if (mounted) context.go('/set-password', extra: widget.phone);
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
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => context.go('/phone')),
              const SizedBox(height: 32),
              const Text('SMS tasdiqlash', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('${widget.phone} raqamiga kod yuborildi', style: TextStyle(color: Colors.white.withOpacity(0.5))),
              const SizedBox(height: 12),
              // Dev hint
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.08), borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.primary.withOpacity(0.2))),
                child: Text('💡 Test rejim: kod 1234', style: TextStyle(color: AppColors.primary.withOpacity(0.7), fontSize: 12)),
              ),
              const SizedBox(height: 32),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(4, (i) =>
                Container(
                  width: 60, height: 68, margin: EdgeInsets.only(right: i < 3 ? 16 : 0),
                  child: TextField(
                    controller: _ctrls[i], focusNode: _nodes[i],
                    textAlign: TextAlign.center, maxLength: 1,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(counterText: '', contentPadding: const EdgeInsets.symmetric(vertical: 16)),
                    onChanged: (v) {
                      if (v.isNotEmpty && i < 3) _nodes[i + 1].requestFocus();
                      if (v.isEmpty && i > 0) _nodes[i - 1].requestFocus();
                      if (_code.length == 4) _verify();
                    },
                  ),
                ),
              )),
              if (_error != null) Padding(padding: const EdgeInsets.only(top: 16),
                child: Center(child: Text(_error!, style: const TextStyle(color: AppColors.error, fontSize: 13)))),
              const SizedBox(height: 24),
              Center(child: Text('${_timer ~/ 60}:${(_timer % 60).toString().padLeft(2, '0')}',
                style: TextStyle(color: _timer > 0 ? Colors.white.withOpacity(0.5) : AppColors.primary, fontSize: 16))),
              const SizedBox(height: 24),
              SizedBox(width: double.infinity, height: 52, child: ElevatedButton(
                onPressed: _loading ? null : _verify,
                child: _loading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Tasdiqlash'),
              )),
            ]),
          ),
        ),
      ),
    );
  }
}
