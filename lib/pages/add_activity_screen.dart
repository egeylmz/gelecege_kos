// lib/add_activity_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


class AddActivityScreen extends StatefulWidget {
  const AddActivityScreen({super.key});

  @override
  State<AddActivityScreen> createState() => _AddActivityScreenState();
}

class _AddActivityScreenState extends State<AddActivityScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _distanceController = TextEditingController();
  DateTime? _selectedDate;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _distanceController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _submitForm() async {
    // Formun geçerli olup olmadığını ve tarih seçilip seçilmediğini kontrol et
    final isFormValid = _formKey.currentState!.validate();
    if (!isFormValid || _selectedDate == null) {
      if (_selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lütfen bir aktivite tarihi seçin.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    setState(() {
      _isLoading = true; // Yükleme animasyonunu başlat
    });

    try {
      // Eğer koleksiyon yoksa, ilk veri eklendiğinde otomatik olarak oluşturulur.
      CollectionReference activities =
      FirebaseFirestore.instance.collection('activities');

      // Formdan verileri al
      final String name = _nameController.text;
      final double distance = double.parse(_distanceController.text.replaceAll(',', '.'));
      final DateTime date = _selectedDate!;

      // Veriyi koleksiyona ekle
      await activities.add({
        'name': name,
        'distance': distance,
        'date': Timestamp.fromDate(date),
        'approvedActivity' : false,
        // userId'yi doğrudan ihtiyaç anında buradan alıyoruz.
        'userId' : FirebaseAuth.instance.currentUser?.uid,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Aktivite başarıyla kaydedildi!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bir hata oluştu: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yeni Aktivite Ekle'),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(color: Colors.white),
              ),
            )
          else
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
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+[\,\.]?\d{0,2}')),
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
                onPressed: _isLoading ? null : _submitForm,
                icon: const Icon(Icons.save),
                label: _isLoading ? const Text('Kaydediliyor...') : const Text('Kaydet'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
