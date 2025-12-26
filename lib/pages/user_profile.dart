// lib/pages/user_profile.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // Tarihi formatlamak için

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  // Oturum açmış kullanıcıyı burada null olarak başlatıp initState içinde doldurmak en güvenli yoldur.
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    // Widget ilk oluşturulduğunda kullanıcı bilgisini al.
    _currentUser = FirebaseAuth.instance.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    // Scaffold'u Container ile sarmalayarak arka plan görselini ekliyoruz
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("icons/main_background.png"),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent, // Arka planın görünmesi için şeffaf yapıyoruz
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.black,
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 60,
                backgroundColor: Colors.grey,
                child: Icon(
                  Icons.person,
                  size: 60,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              // Kullanıcı bilgilerini gösteren bir bölüm
              Text(
                // currentUser null olabileceğinden kontrol ekliyoruz
                _currentUser?.displayName ?? _currentUser?.email ?? 'Kullanıcı Adı',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Profili düzenleme sayfasına yönlendirme yapılabilir
                },
                child: const Text('Profili Düzenle'),
              ),
              const SizedBox(height: 40),
              const Text(
                'Geçmiş Aktiviteler',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Divider(thickness: 1),
              const SizedBox(height: 10),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  // Sorguda 'currentUser' yerine '_currentUser' kullanıyoruz.
                  stream: FirebaseFirestore.instance
                      .collection('activities')
                      .where('userId', isEqualTo: _currentUser?.uid)
                      .where('approvedActivity', isEqualTo: true)
                      .orderBy('date', descending: true)
                      .snapshots(),

                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      // Daha açıklayıcı bir hata mesajı
                      print(snapshot.error); // Hatayı konsola yazdır
                      return const Center(
                          child: Text('Aktiviteler yüklenirken bir hata oluştu.'));
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Text(
                          'Henüz onaylanmış aktiviteniz bulunmuyor.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      );
                    }

                    final activityDocs = snapshot.data!.docs;

                    return ListView.builder(
                      itemCount: activityDocs.length,
                      itemBuilder: (context, index) {
                        final activity = activityDocs[index];
                        final data = activity.data() as Map<String, dynamic>;

                        final DateTime date =
                        (data['date'] as Timestamp).toDate();
                        // Tarih formatını yerelleştirme için 'tr_TR' eklemek iyidir.
                        // Eğer tr_TR hatası alırsanız main.dart'ta initializeDateFormatting() gerekebilir veya sadece 'dd MMMM yyyy' kullanabilirsiniz.
                        final String formattedDate =
                        DateFormat('dd MMMM yyyy', 'tr_TR').format(date);

                        return Card(
                          color: Colors.white.withOpacity(0.85),
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          child: ListTile(
                            leading: const Icon(Icons.directions_run,
                                color: Colors.blueAccent),
                            title: Text(
                              '${data['distance'] ?? 0} km Koşu',
                              style:
                              const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(formattedDate),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {},
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
