import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';

class VehiclesScreen extends StatefulWidget {
  const VehiclesScreen({super.key});
  @override
  State<VehiclesScreen> createState() => _VehiclesScreenState();
}

class _VehiclesScreenState extends State<VehiclesScreen> with SingleTickerProviderStateMixin {
  List<dynamic> _vehicles = [];
  bool _loading = true;
  bool _isWeekly = true;
  int _selectedDocIndex = 0;
  late TabController _tabController;

  final List<_DocItem> _docs = [
    _DocItem("Prava", Icons.credit_card_rounded, const Color(0xFF6366F1), const Color(0xFF818CF8), "AC 2344141", "MO'MINOV JASURBEK", "17.02.2035", "B toifa"),
    _DocItem("Tex. pasport", Icons.directions_car_filled_rounded, const Color(0xFF059669), const Color(0xFF34D399), "AAF 1234567", "CHEVROLET MALIBU", "Cheklanmagan", "01 A 123 BC"),
    _DocItem("Pasport", Icons.badge_rounded, const Color(0xFFDC2626), const Color(0xFFF87171), "AA 1234567", "MO'MINOV JASURBEK", "16.03.2032", "JSHSHIR: 316..."),
    _DocItem("Sug'urta", Icons.shield_rounded, const Color(0xFFF59E0B), const Color(0xFFFBBF24), "POL 987654", "Majburiy sug'urta", "01.01.2026", "CHEVROLET"),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final data = await ApiService.getVehicles();
      if (mounted) setState(() { _vehicles = data is List ? data : []; _loading = false; });
    } catch (_) { if (mounted) setState(() => _loading = false); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A14),
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Avtomobilim", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                GestureDetector(
                  onTap: () => context.push('/vehicles/add'),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6366F1).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFF6366F1).withOpacity(0.4)),
                    ),
                    child: const Icon(Icons.add_rounded, color: Color(0xFF818CF8), size: 22),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ── VEHICLES ──
            _loading
              ? const Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator(color: Color(0xFF6366F1))))
              : _vehicles.isEmpty ? _emptyVehicle() : _vehicleCard(_vehicles.first),
                  const SizedBox(height: 32),

            // ── DOCUMENTS ──
            Row(
              children: [
                Container(width: 3, height: 18, decoration: BoxDecoration(color: const Color(0xFF6366F1), borderRadius: BorderRadius.circular(2))),
                const SizedBox(width: 10),
                const Text("Hujjatlarim", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 16),
            _buildDocumentGrid(),
            
            const SizedBox(height: 32),

            // ── FUEL STATS ──
            Row(
              children: [
                Container(width: 3, height: 18, decoration: BoxDecoration(color: const Color(0xFF10B981), borderRadius: BorderRadius.circular(2))),
                const SizedBox(width: 10),
                const Text("Xarajatlar tahlili", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 16),
            _buildFuelStats(),

            const SizedBox(height: 32),

            // ── RECENT PAYMENTS ──
            Row(
              children: [
                Container(width: 3, height: 18, decoration: BoxDecoration(color: const Color(0xFFF59E0B), borderRadius: BorderRadius.circular(2))),
                const SizedBox(width: 10),
                const Text("Oxirgi to'lovlar", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 16),
            _paymentTile(Icons.local_gas_station_rounded, "UzGazOil #24", "Bugun, 14:30", "-120,000", const Color(0xFF6366F1)),
            _paymentTile(Icons.local_gas_station_rounded, "Mustang Fuel", "Kecha, 09:15", "-350,000", const Color(0xFF059669)),
            _paymentTile(Icons.build_circle_outlined, "Avtoservis Pro", "28 Apr, 10:00", "-150,000", const Color(0xFFF59E0B)),

            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }

  // ── Vehicle Card ──
  Widget _vehicleCard(dynamic v) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A1A2E), Color(0xFF16162A)],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
        boxShadow: [BoxShadow(color: const Color(0xFF6366F1).withOpacity(0.08), blurRadius: 30, offset: const Offset(0, 12))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Car Icon with glow
              Container(
                width: 64, height: 64,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF818CF8)]),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: const Color(0xFF6366F1).withOpacity(0.4), blurRadius: 16, offset: const Offset(0, 6))],
                ),
                child: const Icon(Icons.directions_car_rounded, color: Colors.white, size: 32),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${v['brand'] ?? 'Chevrolet'} ${v['model'] ?? 'Malibu'}', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6366F1).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFF6366F1).withOpacity(0.3)),
                      ),
                      child: Text(v['plateNumber'] ?? '01 A 123 BC', style: const TextStyle(color: Color(0xFF818CF8), fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 2)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Mini Stats Row
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.03),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _miniStat("Yoqilg'i", "35 L", Icons.local_gas_station_rounded),
                Container(width: 1, height: 30, color: Colors.white.withOpacity(0.06)),
                _miniStat("Masofa", "1,240 km", Icons.speed_rounded),
                Container(width: 1, height: 30, color: Colors.white.withOpacity(0.06)),
                _miniStat("Xarajat", "470K", Icons.payments_rounded),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.4), size: 18),
        const SizedBox(height: 6),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 10)),
      ],
    );
  }

  Widget _emptyVehicle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: Row(
        children: [
          Icon(Icons.directions_car_outlined, size: 48, color: Colors.white.withOpacity(0.15)),
          const SizedBox(width: 20),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Avtomobil qo'shilmagan", style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 15, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () => context.push('/vehicles/add'),
                child: const Text("Qo'shish", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              ),
            ],
          )),
        ],
      ),
    );
  }

  // ── Document Grid ──
  Widget _buildDocumentGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.5,
      ),
      itemCount: _docs.length,
      itemBuilder: (context, index) {
        final doc = _docs[index];
        return GestureDetector(
          onTap: () => _showDocDetail(doc),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [doc.color1.withOpacity(0.15), doc.color1.withOpacity(0.05)],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: doc.color1.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: doc.color1.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(doc.icon, color: doc.color2, size: 20),
                    ),
                    Icon(Icons.arrow_forward_ios_rounded, color: Colors.white.withOpacity(0.2), size: 12),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(doc.title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(doc.number, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11, letterSpacing: 0.5)),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDocDetail(_DocItem doc) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          margin: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: MediaQuery.of(context).padding.bottom + 90),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: doc.color1.withOpacity(0.3)),
            boxShadow: [BoxShadow(color: doc.color1.withOpacity(0.15), blurRadius: 30, spreadRadius: 2)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 24),
              // Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [doc.color1, doc.color2],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [BoxShadow(color: doc.color1.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 10))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(children: [
                          Icon(doc.icon, color: Colors.white.withOpacity(0.9), size: 20),
                          const SizedBox(width: 10),
                          Text(doc.title.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
                        ]),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                          child: const Text("UZ", style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Container(
                          width: 52, height: 52,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.15),
                            border: Border.all(color: Colors.white.withOpacity(0.4)),
                          ),
                          child: const Icon(Icons.person_rounded, color: Colors.white, size: 28),
                        ),
                        const SizedBox(width: 16),
                        Expanded(child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(doc.number, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 2)),
                            const SizedBox(height: 4),
                            Text(doc.owner, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                          ],
                        )),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _detailCol("Amal muddati", doc.expiry),
                        _detailCol("Qo'shimcha", doc.extra),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: doc.color1.withOpacity(0.2),
                        foregroundColor: doc.color2,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.copy_rounded, size: 18),
                      label: const Text("Nusxalash", style: TextStyle(fontWeight: FontWeight.w600)),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: "${doc.title}: ${doc.number}\n${doc.owner}\nMuddat: ${doc.expiry}"));
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("${doc.title} ma'lumotlari nusxalandi!"), behavior: SnackBarBehavior.floating),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: doc.color1,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.qr_code_2_rounded, size: 18),
                      label: const Text("QR ko'rish", style: TextStyle(fontWeight: FontWeight.w600)),
                      onPressed: () {
                        Navigator.pop(context);
                        _showQrDialog(doc);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Widget _detailCol(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
      ],
    );
  }

  void _showQrDialog(_DocItem doc) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(doc.title.toUpperCase(), style: TextStyle(color: doc.color2, fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
              const SizedBox(height: 24),
              // QR Code Visual
              Container(
                width: 180, height: 180,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: doc.color1.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))],
                ),
                child: CustomPaint(painter: _QrPainter(doc.number)),
              ),
              const SizedBox(height: 20),
              Text(doc.number, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 2)),
              const SizedBox(height: 4),
              Text(doc.owner, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: doc.color1,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Yopish", style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Fuel Stats ──
  Widget _buildFuelStats() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF12121F),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_isWeekly ? "345,000 so'm" : "1,450,000 so'm", style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: const Color(0xFF10B981).withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
                      child: Text(_isWeekly ? "▲ 12%" : "▼ 8%", style: TextStyle(color: _isWeekly ? const Color(0xFF10B981) : const Color(0xFFEF4444), fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 8),
                    Text(_isWeekly ? "35 Litr • Bu hafta" : "140 Litr • Bu oy", style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12)),
                  ]),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    _tabBtn("Hafta", _isWeekly, () => setState(() => _isWeekly = true)),
                    _tabBtn("Oy", !_isWeekly, () => setState(() => _isWeekly = false)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          SizedBox(
            height: 150,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true, drawVerticalLine: false, horizontalInterval: 100,
                  getDrawingHorizontalLine: (value) => FlLine(color: Colors.white.withOpacity(0.04), strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true, reservedSize: 22, interval: 1,
                      getTitlesWidget: (value, meta) {
                        final labels = _isWeekly ? ['Du','Se','Ch','Pa','Ju','Sh','Ya'] : ['1-H','2-H','3-H','4-H'];
                        final i = value.toInt();
                        if (i < 0 || i >= labels.length) return const SizedBox();
                        return SideTitleWidget(meta: meta, child: Text(labels[i], style: TextStyle(color: Colors.white.withOpacity(0.3), fontWeight: FontWeight.bold, fontSize: 11)));
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minY: 0,
                maxY: _isWeekly ? 200 : 500,
                lineBarsData: [
                  LineChartBarData(
                    spots: _isWeekly
                      ? [const FlSpot(0, 0), const FlSpot(1, 45), const FlSpot(2, 20), const FlSpot(3, 120), const FlSpot(4, 30), const FlSpot(5, 80), const FlSpot(6, 140)]
                      : [const FlSpot(0, 250), const FlSpot(1, 150), const FlSpot(2, 450), const FlSpot(3, 280)],
                    isCurved: true,
                    gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF818CF8)]),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(radius: 3, color: Colors.white, strokeWidth: 2, strokeColor: const Color(0xFF6366F1)),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [const Color(0xFF6366F1).withOpacity(0.2), const Color(0xFF6366F1).withOpacity(0.0)],
                        begin: Alignment.topCenter, end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabBtn(String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF6366F1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(label, style: TextStyle(color: active ? Colors.white : Colors.white38, fontSize: 12, fontWeight: FontWeight.w700)),
      ),
    );
  }

  // ── Payment Tile ──
  Widget _paymentTile(IconData icon, String title, String time, String amount, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.03)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(time, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12)),
            ],
          )),
          Text("$amount so'm", style: const TextStyle(color: Color(0xFFEF4444), fontSize: 14, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _DocItem {
  final String title;
  final IconData icon;
  final Color color1;
  final Color color2;
  final String number;
  final String owner;
  final String expiry;
  final String extra;
  const _DocItem(this.title, this.icon, this.color1, this.color2, this.number, this.owner, this.expiry, this.extra);
}

// Simple QR-code-like pattern generator
class _QrPainter extends CustomPainter {
  final String data;
  _QrPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black;
    final cellSize = size.width / 21;
    final rng = data.codeUnits;

    // Draw finder patterns (corners)
    _drawFinder(canvas, paint, 0, 0, cellSize);
    _drawFinder(canvas, paint, size.width - 7 * cellSize, 0, cellSize);
    _drawFinder(canvas, paint, 0, size.height - 7 * cellSize, cellSize);

    // Draw data pattern
    for (int i = 0; i < 21; i++) {
      for (int j = 0; j < 21; j++) {
        if (_isInFinder(i, j)) continue;
        final idx = (i * 21 + j) % rng.length;
        if ((rng[idx] + i * j) % 3 == 0) {
          canvas.drawRect(Rect.fromLTWH(j * cellSize, i * cellSize, cellSize * 0.9, cellSize * 0.9), paint);
        }
      }
    }
  }

  bool _isInFinder(int r, int c) {
    return (r < 7 && c < 7) || (r < 7 && c > 13) || (r > 13 && c < 7);
  }

  void _drawFinder(Canvas canvas, Paint paint, double x, double y, double cell) {
    canvas.drawRect(Rect.fromLTWH(x, y, 7 * cell, 7 * cell), paint);
    canvas.drawRect(Rect.fromLTWH(x + cell, y + cell, 5 * cell, 5 * cell), Paint()..color = Colors.white);
    canvas.drawRect(Rect.fromLTWH(x + 2 * cell, y + 2 * cell, 3 * cell, 3 * cell), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
