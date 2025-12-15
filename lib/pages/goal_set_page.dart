import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

class GoalSetPage extends StatefulWidget {
  const GoalSetPage({super.key});

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
  bool _isLoading = false; // Veritabanı işlemi sırasında bekleme durumunu yönetmek için

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
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveGoal() async {
    final isFormValid = _formKey.currentState!.validate();
    if (!isFormValid || _selectedDate == null) {
      if (_selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lütfen bir başlangıç tarihi seçin.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("Hedef belirlemek için önce giriş yapmalısınız.");
      }

      final sponsorName = _sponsorNameController.text;
      final targetKm = double.parse(_targetKmController.text.replaceAll(',', '.'));
      final saplingCount = int.parse(_saplingCountController.text);
      final email = _emailController.text;
      final phone = _phoneController.text;

      await FirebaseFirestore.instance.collection('goals').add({
        'userId': user.uid,
        'sponsorName': sponsorName,
        'sponsorEmail': email,
        'sponsorPhone': phone,
        'targetKm': targetKm,
        'saplingCount': saplingCount,
        'startDate': Timestamp.fromDate(_selectedDate!),
        'createdAt': FieldValue.serverTimestamp(),
        'currentKm': 0.0,
        'isCompleted': false,
        'approveGoal': false,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Hedef başarıyla kaydedildi! Onay bekleniyor.')),
        );
        Navigator.pop(context); // Kayıt sonrası sayfadan çık
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hedef kaydedilirken bir hata oluştu: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false; // İşlem bitince yüklenme durumunu sonlandır
        });
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
                // Telefon numarası için isteğe bağlı formatlayıcılar
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(11),
                ],
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
                // Virgül veya nokta ile girişe izin verir
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+[\,\.]?\d{0,2}')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen bir hedef KM girin.';
                  }
                  // Hem virgülü hem noktayı kabul et
                  if (double.tryParse(value.replaceAll(',', '.')) == null) {
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
                inputFormatters: [FilteringTextInputFormatter.digitsOnly], // Sadece tam sayı girişi
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
                      ? 'Başlangıç Tarihini Seçin'
                      : 'Başlangıç Tarihi: ${DateFormat('dd/MM/yyyy').format(_selectedDate!)}',
                ),
                onTap: () => _selectDate(context),
              ),

              const SizedBox(height: 32),

              ElevatedButton.icon(
                onPressed: _isLoading ? null : _saveGoal,
                icon: _isLoading
                    ? const SizedBox.shrink() // Yüklenirken boşluk bırak
                    : const Icon(Icons.save),
                label: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Hedefi Kaydet'),
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
