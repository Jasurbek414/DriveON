import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';

class PinScreen extends StatefulWidget {
  final bool isSetup;
  const PinScreen({super.key, this.isSetup = false});

  @override
  State<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen> {
  String _pin = '';
  String? _firstPin;
  String _error = '';

  void _onKey(String val) async {
    if (_pin.length >= 4) return;
    setState(() {
      _pin += val;
      _error = '';
    });

    if (_pin.length == 4) {
      if (widget.isSetup) {
        if (_firstPin == null) {
          setState(() {
            _firstPin = _pin;
            _pin = '';
          });
        } else {
          if (_firstPin == _pin) {
            await ApiService.setPin(_pin);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Parol muvaffaqiyatli ornatildi')));
              context.pop();
            }
          } else {
            setState(() {
              _error = 'Parol mos kelmadi, qayta urinib koring';
              _firstPin = null;
              _pin = '';
            });
          }
        }
      } else {
        // Verification mode
        final correctPin = await ApiService.getPin();
        if (_pin == correctPin) {
          if (mounted) context.read<AuthService>().unlockPin();
        } else {
          setState(() {
            _error = 'Noto\'g\'ri parol';
            _pin = '';
          });
        }
      }
    }
  }

  void _onBackspace() {
    if (_pin.isNotEmpty) {
      setState(() {
        _pin = _pin.substring(0, _pin.length - 1);
        _error = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String title = widget.isSetup
        ? (_firstPin == null ? "Yangi parol o'rnating" : "Parolni takrorlang")
        : "Kirish parolini kiriting";

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: widget.isSetup ? AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => context.pop()),
      ) : null,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            Icon(Icons.lock_outline, size: 64, color: AppColors.primary.withOpacity(0.8)),
            const SizedBox(height: 24),
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            if (_error.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(_error, style: const TextStyle(color: Colors.redAccent, fontSize: 14)),
            ],
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                bool isFilled = index < _pin.length;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isFilled ? AppColors.primary : Colors.white.withOpacity(0.1),
                    border: Border.all(color: isFilled ? AppColors.primary : Colors.white24, width: 2),
                  ),
                );
              }),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              child: Column(
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    _buildKey('1'), _buildKey('2'), _buildKey('3'),
                  ]),
                  const SizedBox(height: 24),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    _buildKey('4'), _buildKey('5'), _buildKey('6'),
                  ]),
                  const SizedBox(height: 24),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    _buildKey('7'), _buildKey('8'), _buildKey('9'),
                  ]),
                  const SizedBox(height: 24),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    const SizedBox(width: 72),
                    _buildKey('0'),
                    GestureDetector(
                      onTap: _onBackspace,
                      child: Container(
                        width: 72,
                        height: 72,
                        alignment: Alignment.center,
                        child: const Icon(Icons.backspace_outlined, color: Colors.white, size: 28),
                      ),
                    ),
                  ]),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildKey(String val) {
    return GestureDetector(
      onTap: () => _onKey(val),
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.05),
        ),
        alignment: Alignment.center,
        child: Text(val, style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w400)),
      ),
    );
  }
}
