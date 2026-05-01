import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:nfc_manager/nfc_manager.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late MobileScannerController _cameraController;
  bool _isNfcMode = false;
  bool _isTorchOn = false;
  String? _nfcError;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _cameraController = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _cameraController.dispose();
    _stopNfc();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isNfcMode) return;
    
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final code = barcodes.first.rawValue;
      if (code != null) {
        _cameraController.stop();
        _showSuccess('QR Skanerlandi: $code');
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted && !_isNfcMode) _cameraController.start();
        });
      }
    }
  }

  Future<void> _startNfc() async {
    setState(() => _nfcError = null);
    try {
      bool isAvailable = await NfcManager.instance.isAvailable();
      if (!isAvailable) {
        if (mounted) {
          _showNfcSettingsDialog();
          setState(() {
            _isNfcMode = false;
          });
          _cameraController.start();
        }
        return;
      }
      
      NfcManager.instance.startSession(
        pollingOptions: {NfcPollingOption.iso14443, NfcPollingOption.iso15693},
        onDiscovered: (NfcTag tag) async {
          try {
            final Map data = tag.data as Map;
            var tagId = data.toString();
            
            if (data.containsKey('ndef')) {
              final ndef = data['ndef'] as Map;
              if (ndef.containsKey('identifier')) {
                tagId = ndef['identifier'].toString();
              }
            } else if (data.containsKey('nfca')) {
              final nfca = data['nfca'] as Map;
              if (nfca.containsKey('identifier')) {
                tagId = nfca['identifier'].toString();
              }
            }
            
            _showSuccess('NFC karta o\'qildi!\nMa\'lumot: $tagId');
          } catch (_) {
            _showSuccess('NFC karta o\'qildi!');
          }
          NfcManager.instance.stopSession();
          
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted && _isNfcMode) _startNfc();
          });
        },
      ).catchError((e) {
        setState(() => _nfcError = 'NFC ishlashida xatolik: $e');
      });
    } catch (e) {
      setState(() => _nfcError = 'NFC tizimiga ulanib bo\'lmadi.');
    }
  }

  void _showNfcSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E40),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.nfc_rounded, color: Color(0xFF6366F1), size: 28),
            SizedBox(width: 12),
            Text('NFC O\'chirilgan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: const Text(
          'To\'lovni amalga oshirish uchun telefoningizning yuqori panelidan yoki sozlamalaridan NFC funksiyasini yoqing.',
          style: TextStyle(color: Colors.white70, fontSize: 15, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tushunarli', style: TextStyle(color: Color(0xFF6366F1), fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ],
      ),
    );
  }

  void _stopNfc() {
    NfcManager.instance.stopSession().catchError((_) {});
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF6366F1),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      body: Stack(
        children: [
          if (!_isNfcMode)
            Positioned.fill(
              child: MobileScanner(
                controller: _cameraController,
                onDetect: _onDetect,
              ),
            )
          else
            Center(
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: const Color(0xFF6366F1).withOpacity(0.15), blurRadius: 100, spreadRadius: 50),
                  ],
                ),
              ),
            ),
          
          if (!_isNfcMode)
            Positioned.fill(
              child: Container(color: Colors.black.withOpacity(0.6)),
            ),
          
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('To\'lov Skaneri', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                      if (!_isNfcMode)
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.08), borderRadius: BorderRadius.circular(14)),
                          child: IconButton(
                            icon: Icon(_isTorchOn ? Icons.flash_on_rounded : Icons.flash_off_rounded, color: Colors.white, size: 22),
                            onPressed: () {
                              _cameraController.toggleTorch();
                              setState(() => _isTorchOn = !_isTorchOn);
                            },
                          ),
                        ),
                    ],
                  ),
                ),
                
                const Spacer(flex: 2),
                
                if (_isNfcMode && _nfcError != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.redAccent.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                      child: Text(_nfcError!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w500)),
                    ),
                  ),

                Center(
                  child: SizedBox(
                    width: 260,
                    height: 260,
                    child: Stack(
                      children: [
                        Align(alignment: Alignment.topLeft, child: _buildCorner(top: true, left: true)),
                        Align(alignment: Alignment.topRight, child: _buildCorner(top: true, left: false)),
                        Align(alignment: Alignment.bottomLeft, child: _buildCorner(top: false, left: true)),
                        Align(alignment: Alignment.bottomRight, child: _buildCorner(top: false, left: false)),
                        
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: AnimatedBuilder(
                              animation: _animationController,
                              builder: (context, child) {
                                if (_isNfcMode) {
                                  return Center(
                                    child: Icon(
                                      Icons.contactless_rounded, 
                                      size: 100 + (_animationController.value * 30), 
                                      color: const Color(0xFF6366F1).withOpacity(0.8 - (_animationController.value * 0.4))
                                    ),
                                  );
                                }
                                return Stack(
                                  children: [
                                    Positioned(
                                      top: _animationController.value * 250,
                                      left: 0,
                                      right: 0,
                                      child: Container(
                                        height: 3,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF6366F1),
                                          boxShadow: [
                                            BoxShadow(color: const Color(0xFF6366F1).withOpacity(0.6), blurRadius: 12, spreadRadius: 3)
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    _isNfcMode ? 'Qurilmani NFC terminaliga yaqinlashtiring' : 'QR kodni ramka ichiga kiriting',
                    key: ValueKey(_isNfcMode),
                    style: const TextStyle(color: Colors.white70, fontSize: 15, fontWeight: FontWeight.w500, letterSpacing: 0.5),
                  ),
                ),
                
                const Spacer(flex: 3),
                
                Container(
                  height: 54,
                  margin: const EdgeInsets.only(bottom: 110, left: 32, right: 32),
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            if (!_isNfcMode) return;
                            _stopNfc();
                            setState(() => _isNfcMode = false);
                            _cameraController.start();
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: !_isNfcMode ? const Color(0xFF6366F1) : Colors.transparent,
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Center(
                              child: Text('QR Skaner', style: TextStyle(color: !_isNfcMode ? Colors.white : Colors.white54, fontWeight: FontWeight.w600, fontSize: 14)),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            if (_isNfcMode) return;
                            _cameraController.stop();
                            setState(() {
                              _isNfcMode = true;
                              _isTorchOn = false;
                            });
                            _startNfc();
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: _isNfcMode ? const Color(0xFF6366F1) : Colors.transparent,
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Center(
                              child: Text('NFC To\'lov', style: TextStyle(color: _isNfcMode ? Colors.white : Colors.white54, fontWeight: FontWeight.w600, fontSize: 14)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCorner({required bool top, required bool left}) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        border: Border(
          top: top ? const BorderSide(color: Color(0xFF6366F1), width: 4) : BorderSide.none,
          bottom: !top ? const BorderSide(color: Color(0xFF6366F1), width: 4) : BorderSide.none,
          left: left ? const BorderSide(color: Color(0xFF6366F1), width: 4) : BorderSide.none,
          right: !left ? const BorderSide(color: Color(0xFF6366F1), width: 4) : BorderSide.none,
        ),
        borderRadius: BorderRadius.only(
          topLeft: top && left ? const Radius.circular(20) : Radius.zero,
          topRight: top && !left ? const Radius.circular(20) : Radius.zero,
          bottomLeft: !top && left ? const Radius.circular(20) : Radius.zero,
          bottomRight: !top && !left ? const Radius.circular(20) : Radius.zero,
        ),
      ),
    );
  }
}
