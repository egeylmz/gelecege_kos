// lib/add_activity_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';


class AddActivityScreen extends StatefulWidget {
  const AddActivityScreen({super.key});

  @override
  State<AddActivityScreen> createState() => _AddActivityScreenState();
}

class _AddActivityScreenState extends State<AddActivityScreen> {
  final _formKey = GlobalKey<FormState>();    // form durumu için
  final _nameController = TextEditingController();
  final _distanceController = TextEditingController();
  DateTime? _selectedDate;

  void dispose() {    // widget kaldırıldığında controller'ları kapat
    _nameController.dispose();
    _distanceController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),   //başlangıç tarihi
      firstDate: DateTime(2000),    // en erken tarih
      lastDate: DateTime(2101),     // en geç tarih
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final String name = _nameController.text;
      final double distance = double.parse(_distanceController.text.replaceAll(',', '.'));
      final DateTime? date = _selectedDate;

      ScaffoldMessenger.of(context).showSnackBar(     // bildirim mesajı
        const SnackBar(content: Text('Başarıyla kaydedildi!')),
      );
      Navigator.pop(context);   // formu kapat
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yeni Aktivite Ekle'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _submitForm,
            tooltip: 'Kaydet',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Ad Soyad',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen adınızı girin.';
                  }
                  return null;
                }
              ),
              const SizedBox(height: 16.0),

              TextFormField(
                controller: _distanceController,
                decoration: const InputDecoration(
                  labelText: 'Koşulan Mesafe (km)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.directions_run),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+[\,\.]?\d{0,2}')),   //sadece sayı ve virgül/noktaya izin ver
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen mesafeyi girin.';
                  }
                  if (double.tryParse(value.replaceAll(',', '.')) == null) {
                    return 'Lütfen geçerli bir sayı girin.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),

              ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                  side: BorderSide(color: Colors.grey.shade400),
                ),
                leading: const Icon(Icons.calendar_today),
                title: Text(
                  _selectedDate == null
                      ? 'Aktivite Tarihini Seçin'
                      : 'Seçilen Tarih: ${DateFormat('dd/MM/yyyy').format(_selectedDate!)}',
                ),
                onTap: () => _selectDate(context),
              ),

              const SizedBox(height: 32),

              ElevatedButton.icon(
                onPressed: _submitForm,
                icon: const Icon(Icons.save),
                label: const Text('Kaydet'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                )
              ),
            ],
          ),
        ),
      ),
    );
  }
}
