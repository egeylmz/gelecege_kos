import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class GoalSetPage extends StatefulWidget {  const GoalSetPage({super.key});

@override
State<GoalSetPage> createState() => _GoalSetPageState();
}

class _GoalSetPageState extends State<GoalSetPage> {
  final _formKey = GlobalKey<FormState>();
  final _sponsorNameController = TextEditingController();
  final _targetKmController = TextEditingController();
  final _saplingCountController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  DateTime? _selectedDate;

  @override
  void dispose() {
    _sponsorNameController.dispose();
    _targetKmController.dispose();
    _saplingCountController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveGoal() {
    if (_formKey.currentState!.validate()) {
      final sponsorName = _sponsorNameController.text;
      final targetKm = double.tryParse(_targetKmController.text) ?? 0.0;
      final saplingCount = int.tryParse(_saplingCountController.text) ?? 0;
      final startDate = _selectedDate;
      final email = _emailController.text;
      final phone = _phoneController.text;

      if (Navigator.canPop(context)) {    //kaydettikten sonra önceki sayfaya dönecek
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hedef Belirle'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Sponsor Adı
              TextFormField(
                controller: _sponsorNameController,
                decoration: const InputDecoration(
                  labelText: 'Sponsor Adı',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.business),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen bir sponsor adı girin.';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'E-posta Adresi',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen bir e-posta adresi girin.';
                  }
                  if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                    return 'Lütfen geçerli bir e-posta adresi girin.';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'İletişim Numarası',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
              ),

              const SizedBox(height: 16),

              // Hedef KM
              TextFormField(
                controller: _targetKmController,
                decoration: const InputDecoration(
                  labelText: 'Hedef (KM)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.directions_run),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen bir hedef KM girin.';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Lütfen geçerli bir sayı girin.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Bağışlanacak Fidan Sayısı
              TextFormField(
                controller: _saplingCountController,
                decoration: const InputDecoration(
                  labelText: 'Bağışlanacak Fidan Sayısı',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.park),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen fidan sayısını girin.';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Lütfen geçerli bir tam sayı girin.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Başlangıç Tarihi
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

              // Kaydet Butonu
              ElevatedButton.icon(
                onPressed: _saveGoal,
                icon: const Icon(Icons.save),
                label: const Text('Hedefi Kaydet'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
