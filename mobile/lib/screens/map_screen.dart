import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});
  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapCtrl = MapController();
  final TextEditingController _searchCtrl = TextEditingController();
  int _selectedCat = 0;
  bool _showRadars = true;
  final LatLng _myLoc = const LatLng(41.311081, 69.240562);

  final _cats = const [
    _Cat("Barchasi", Icons.explore_rounded, Color(0xFF6366F1)),
    _Cat("Yoqilg'i", Icons.local_gas_station_rounded, Color(0xFF10B981)),
    _Cat("Ovqat", Icons.restaurant_rounded, Color(0xFFF59E0B)),
    _Cat("Mehmonxona", Icons.hotel_rounded, Color(0xFFEC4899)),
    _Cat("Dorixona", Icons.local_pharmacy_rounded, Color(0xFF14B8A6)),
    _Cat("ATM", Icons.atm_rounded, Color(0xFF8B5CF6)),
  ];

  final _places = const [
    _Place("UzGazOil #24", "Yoqilg'i", "0.3 km", Icons.local_gas_station_rounded, Color(0xFF10B981), 41.312081, 69.243562),
    _Place("Mustang Fuel", "Yoqilg'i", "0.8 km", Icons.local_gas_station_rounded, Color(0xFF10B981), 41.314523, 69.248791),
    _Place("Afsona", "Ovqat", "0.5 km", Icons.restaurant_rounded, Color(0xFFF59E0B), 41.309945, 69.237318),
    _Place("Hilton Tashkent", "Mehmonxona", "1.2 km", Icons.hotel_rounded, Color(0xFFEC4899), 41.311345, 69.279562),
    _Place("Oila Dorixonasi", "Dorixona", "0.2 km", Icons.local_pharmacy_rounded, Color(0xFF14B8A6), 41.310200, 69.241000),
    _Place("Kapital Bank", "ATM", "0.4 km", Icons.atm_rounded, Color(0xFF8B5CF6), 41.313500, 69.245000),
    _Place("Evos", "Ovqat", "0.6 km", Icons.restaurant_rounded, Color(0xFFF59E0B), 41.308200, 69.245600),
    _Place("Wyndham", "Mehmonxona", "1.8 km", Icons.hotel_rounded, Color(0xFFEC4899), 41.307000, 69.251000),
  ];

  final _radars = const [
    _Radar("60 km/s", 41.311800, 69.244800),
    _Radar("70 km/s", 41.315200, 69.250100),
    _Radar("Qizil chiroq", 41.309100, 69.236500),
  ];

  List<_Place> get _filtered {
    final q = _searchCtrl.text.toLowerCase();
    var list = _places.toList();
    if (_selectedCat > 0) {
      final catName = _cats[_selectedCat].name;
      list = list.where((p) => p.type == catName).toList();
    }
    if (q.isNotEmpty) list = list.where((p) => p.name.toLowerCase().contains(q)).toList();
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A14),
      body: SafeArea(
        child: Column(children: [
          // Header + Search
          _buildHeader(),
          // Map
          Expanded(child: _buildMap()),
          // Bottom list
          _buildBottomList(),
        ]),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      color: const Color(0xFF0A0A14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Text("Xarita", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
          const Spacer(),
          GestureDetector(
            onTap: () => setState(() => _showRadars = !_showRadars),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: _showRadars ? const Color(0xFFEF4444).withOpacity(0.15) : Colors.white.withOpacity(0.04),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _showRadars ? const Color(0xFFEF4444).withOpacity(0.3) : Colors.white10),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.radar_rounded, color: _showRadars ? const Color(0xFFEF4444) : Colors.white38, size: 16),
                const SizedBox(width: 6),
                Text("Radar", style: TextStyle(color: _showRadars ? const Color(0xFFEF4444) : Colors.white38, fontSize: 12, fontWeight: FontWeight.w700)),
              ]),
            ),
          ),
        ]),
        const SizedBox(height: 12),
        // Search
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.04), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white10)),
          child: Row(children: [
            Icon(Icons.search, color: Colors.white.withOpacity(0.3), size: 20),
            const SizedBox(width: 10),
            Expanded(child: TextField(
              controller: _searchCtrl,
              onChanged: (_) => setState(() {}),
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(hintText: "Joy qidirish...", hintStyle: TextStyle(color: Colors.white.withOpacity(0.25), fontSize: 13), border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(vertical: 12)),
            )),
            if (_searchCtrl.text.isNotEmpty) GestureDetector(onTap: () { _searchCtrl.clear(); setState(() {}); }, child: Icon(Icons.close, color: Colors.white38, size: 18)),
          ]),
        ),
        const SizedBox(height: 10),
        // Categories
        SizedBox(
          height: 38,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: _cats.length,
            itemBuilder: (_, i) {
              final c = _cats[i];
              final sel = _selectedCat == i;
              return GestureDetector(
                onTap: () => setState(() => _selectedCat = i),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: sel ? c.color.withOpacity(0.2) : Colors.white.withOpacity(0.03),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: sel ? c.color.withOpacity(0.4) : Colors.white.withOpacity(0.04)),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(c.icon, color: sel ? c.color : Colors.white38, size: 14),
                    const SizedBox(width: 6),
                    Text(c.name, style: TextStyle(color: sel ? c.color : Colors.white38, fontSize: 12, fontWeight: FontWeight.w600)),
                  ]),
                ),
              );
            },
          ),
        ),
      ]),
    );
  }

  Widget _buildMap() {
    final filtered = _filtered;
    return ClipRRect(
      child: FlutterMap(
        mapController: _mapCtrl,
        options: MapOptions(initialCenter: _myLoc, initialZoom: 14.5),
        children: [
          TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', userAgentPackageName: 'com.driveon.app'),
          // Dark overlay
          ColoredBox(color: const Color(0xFF0A0A14).withOpacity(0.55), child: const SizedBox.expand()),
          // My location
          MarkerLayer(markers: [
            Marker(point: _myLoc, width: 50, height: 50, child: Container(
              decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFF6366F1).withOpacity(0.15)),
              child: Center(child: Container(width: 16, height: 16, decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFF6366F1), border: Border.all(color: Colors.white, width: 2.5), boxShadow: [BoxShadow(color: const Color(0xFF6366F1).withOpacity(0.5), blurRadius: 10)]))),
            )),
          ]),
          // Place markers
          MarkerLayer(markers: filtered.map((p) => Marker(
            point: LatLng(p.lat, p.lng), width: 40, height: 40,
            child: GestureDetector(
              onTap: () => _showDetail(p),
              child: Container(
                decoration: BoxDecoration(color: p.color, shape: BoxShape.circle, boxShadow: [BoxShadow(color: p.color.withOpacity(0.5), blurRadius: 8, offset: const Offset(0, 3))]),
                child: Icon(p.icon, color: Colors.white, size: 18),
              ),
            ),
          )).toList()),
          // Radar markers
          if (_showRadars) MarkerLayer(markers: _radars.map((r) => Marker(
            point: LatLng(r.lat, r.lng), width: 52, height: 52,
            child: Container(
              decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFFEF4444).withOpacity(0.1), border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.4))),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.radar_rounded, color: Color(0xFFEF4444), size: 16),
                Text(r.limit, style: const TextStyle(color: Color(0xFFEF4444), fontSize: 7, fontWeight: FontWeight.bold)),
              ]),
            ),
          )).toList()),
          // Controls
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 12, bottom: 12),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                _mapBtn(Icons.add, () => _mapCtrl.move(_mapCtrl.camera.center, _mapCtrl.camera.zoom + 1)),
                const SizedBox(height: 8),
                _mapBtn(Icons.remove, () => _mapCtrl.move(_mapCtrl.camera.center, _mapCtrl.camera.zoom - 1)),
                const SizedBox(height: 8),
                _mapBtn(Icons.my_location_rounded, () => _mapCtrl.move(_myLoc, 16)),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _mapBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: const Color(0xFF1A1A2E).withOpacity(0.9), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white10), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 8)]),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _buildBottomList() {
    final list = _filtered;
    return Container(
      height: 220,
      decoration: BoxDecoration(color: const Color(0xFF0F0F1A), borderRadius: const BorderRadius.vertical(top: Radius.circular(20)), border: Border(top: BorderSide(color: Colors.white.withOpacity(0.04)))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Center(child: Container(width: 36, height: 4, margin: const EdgeInsets.only(top: 10), decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(2)))),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 6),
          child: Row(children: [
            const Text("Yaqin joylar", style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
            const Spacer(),
            Text("${list.length} ta", style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 12)),
          ]),
        ),
        Expanded(
          child: list.isEmpty
            ? Center(child: Text("Topilmadi", style: TextStyle(color: Colors.white.withOpacity(0.3))))
            : ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: list.length,
                itemBuilder: (_, i) {
                  final p = list[i];
                  return GestureDetector(
                    onTap: () { _mapCtrl.move(LatLng(p.lat, p.lng), 17); _showDetail(p); },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.02), borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.white.withOpacity(0.03))),
                      child: Row(children: [
                        Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: p.color.withOpacity(0.12), borderRadius: BorderRadius.circular(12)), child: Icon(p.icon, color: p.color, size: 18)),
                        const SizedBox(width: 12),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(p.name, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                          Text(p.type, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11)),
                        ])),
                        Text(p.dist, style: const TextStyle(color: Color(0xFF6366F1), fontSize: 12, fontWeight: FontWeight.w700)),
                      ]),
                    ),
                  );
                },
              ),
        ),
      ]),
    );
  }

  void _showDetail(_Place p) {
    showModalBottomSheet(
      context: context, backgroundColor: Colors.transparent,
      builder: (_) => Container(
        margin: EdgeInsets.only(left: 16, right: 16, bottom: MediaQuery.of(context).padding.bottom + 90),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: const Color(0xFF1A1A2E), borderRadius: BorderRadius.circular(24), border: Border.all(color: p.color.withOpacity(0.2))),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Row(children: [
            Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: p.color.withOpacity(0.15), borderRadius: BorderRadius.circular(16)), child: Icon(p.icon, color: p.color, size: 26)),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(p.name, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800)),
              Text("${p.type} • ${p.dist}", style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13)),
            ])),
          ]),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: p.color.withOpacity(0.15), foregroundColor: p.color, padding: const EdgeInsets.symmetric(vertical: 13), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 0),
              icon: const Icon(Icons.near_me_rounded, size: 18),
              label: const Text("Yaqinlashtirish", style: TextStyle(fontWeight: FontWeight.w600)),
              onPressed: () { Navigator.pop(context); _mapCtrl.move(LatLng(p.lat, p.lng), 17); },
            )),
            const SizedBox(width: 12),
            Expanded(child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6366F1), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 13), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 0),
              icon: const Icon(Icons.navigation_rounded, size: 18),
              label: const Text("Yo'l boshlash", style: TextStyle(fontWeight: FontWeight.w600)),
              onPressed: () { Navigator.pop(context); launchUrl(Uri.parse('https://www.google.com/maps/dir/?api=1&destination=${p.lat},${p.lng}&travelmode=driving'), mode: LaunchMode.externalApplication); },
            )),
          ]),
        ]),
      ),
    );
  }
}

class _Cat { final String name; final IconData icon; final Color color; const _Cat(this.name, this.icon, this.color); }
class _Place { final String name, type, dist; final IconData icon; final Color color; final double lat, lng; const _Place(this.name, this.type, this.dist, this.icon, this.color, this.lat, this.lng); }
class _Radar { final String limit; final double lat, lng; const _Radar(this.limit, this.lat, this.lng); }
