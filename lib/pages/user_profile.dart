// lib/pages/user_profile.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
  }

  // Tarihi güvenli formatlayan yardımcı fonksiyon
  String _formatDate(Timestamp timestamp) {
    try {
      return DateFormat('dd MMMM yyyy', 'tr_TR').format(timestamp.toDate());
    } catch (e) {
      return DateFormat('dd/MM/yyyy').format(timestamp.toDate());
    }
  }

  Widget _buildStatCircle(String label, String count, IconData icon) {
    return Column(
      children: [
        Container(
          width: 70, // Daire genişliği
          height: 70, // Daire yüksekliği
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2), // Hafif şeffaf arka plan
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white30, width: 1.5),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white70, size: 20),
              const SizedBox(height: 4),
              Text(
                count,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("icons/main_background.png"),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white24,
                  child: Icon(
                    Icons.person,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 15),

              Text(
                _currentUser?.displayName ?? _currentUser?.email ?? 'Misafir Kullanıcı',
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [Shadow(blurRadius: 2, color: Colors.black45, offset: Offset(1,1))] // Okunabilirlik için gölge
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 5),

              ElevatedButton.icon(
                onPressed: () {
                  // PROFİL DÜZENLEME SAYFASI BURADA AÇILACAK
                },
                icon: const Icon(Icons.edit, size: 18),
                label: const Text('Profili Düzenle'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white70,
                  foregroundColor: Colors.black87,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
              ),

              const SizedBox(height: 25),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatCircle("Aktivite", "0", Icons.directions_run),
                  _buildStatCircle("Takipçi", "0", Icons.group),
                  _buildStatCircle("Takip", "0", Icons.person_add),
                ],
              ),

              const SizedBox(height: 30),

              const Align(
                alignment: Alignment.center,
                child: Text(
                  'Geçmiş Aktiviteler',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const Divider(color: Colors.white70, thickness: 1),

              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('activities')
                      .where('userId', isEqualTo: _currentUser?.uid)
                      .where('approvedActivity', isEqualTo: true)
                      .orderBy('date', descending: true)
                      .snapshots(),

                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: Colors.white));
                    }
                    if (snapshot.hasError) {
                      debugPrint("Firestore Hatası: ${snapshot.error}");
                      return const Center(
                          child: Text('Veriler yüklenemedi. İnternetinizi kontrol edin.', style: TextStyle(color: Colors.white70)));
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.directions_run_outlined, size: 50, color: Colors.white54),
                            SizedBox(height: 10),
                            Text(
                              'Henüz onaylanmış aktiviteniz yok.',
                              style: TextStyle(fontSize: 16, color: Colors.white70),
                            ),
                          ],
                        ),
                      );
                    }

                    final activityDocs = snapshot.data!.docs;

                    return ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: activityDocs.length,
                      itemBuilder: (context, index) {
                        final activity = activityDocs[index];
                        final data = activity.data() as Map<String, dynamic>;
                        final double distance = (data['distance'] ?? 0).toDouble();
                        final Timestamp? timestamp = data['date'] as Timestamp?;
                        final String dateStr = timestamp != null ? _formatDate(timestamp) : 'Tarih Yok';

                        return Card(
                          color: Colors.white.withOpacity(0.9),
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          margin: const EdgeInsets.symmetric(vertical: 6.0),
                          child: ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.blueAccent.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.directions_run, color: Colors.blueAccent),
                            ),
                            title: Text(
                              '$distance km Koşu',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                            ),
                            subtitle: Text(
                              dateStr,
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                            onTap: () {
                              // AKTİVİTE DETAY SAYFASI EKLERSEK BURAYA EKLENECEK
                            },
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
