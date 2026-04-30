import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';

class AddVehicleScreen extends StatefulWidget {
  const AddVehicleScreen({super.key});
  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  final _plate = TextEditingController();
  final _brand = TextEditingController();
  final _model = TextEditingController();
  final _year = TextEditingController();
  final _color = TextEditingController();
  final _tech = TextEditingController();
  bool _loading = false;

  Future<void> _save() async {
    if (_plate.text.isEmpty || _brand.text.isEmpty || _model.text.isEmpty) return;
    setState(() => _loading = true);
    try {
      await ApiService.addVehicle({
        'plateNumber': _plate.text.trim(),
        'brand': _brand.text.trim(),
        'model': _model.text.trim(),
        'manufactureYear': int.tryParse(_year.text),
        'color': _color.text.trim(),
        'techPassportNumber': _tech.text.trim(),
      });
      if (mounted) context.go('/vehicles');
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Avtomobil qo'shish")),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: ListView(padding: const EdgeInsets.all(24), children: [
          _field(_plate, 'Davlat raqami *', '01 A 123 AA', Icons.confirmation_number),
          _field(_brand, 'Rusumi *', 'Chevrolet', Icons.branding_watermark),
          _field(_model, 'Modeli *', 'Malibu', Icons.directions_car),
          _field(_year, 'Ishlab chiqarilgan yili', '2023', Icons.calendar_today, isNum: true),
          _field(_color, 'Rangi', 'Oq', Icons.palette),
          _field(_tech, 'Tex pasport raqami', 'AAA 1234567', Icons.document_scanner),
          const SizedBox(height: 24),
          SizedBox(height: 52, child: ElevatedButton(
            onPressed: _loading ? null : _save,
            child: _loading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text("Saqlash"),
          )),
        ]),
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String label, String hint, IconData icon, {bool isNum = false}) {
    return Padding(padding: const EdgeInsets.only(bottom: 16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13, fontWeight: FontWeight.w500)),
      const SizedBox(height: 6),
      TextField(controller: ctrl, keyboardType: isNum ? TextInputType.number : TextInputType.text,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(hintText: hint, prefixIcon: Icon(icon, size: 20))),
    ]));
  }
}
