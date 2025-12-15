import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'goal_set_page.dart';

class GoalListPage extends StatefulWidget {
  const GoalListPage({super.key});

  @override
  State<GoalListPage> createState() => _GoalListPageState();
}

class _GoalListPageState extends State<GoalListPage> {

  final User? currentUser = FirebaseAuth.instance.currentUser;

  void _goToAddGoalPage() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const GoalSetPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return const Center(
        child: Text("Hedefleri görmek için lütfen giriş yapın."),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Hedefler"),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Yeni Hedef Ekle',
            onPressed: _goToAddGoalPage,
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('goals') // 'goals' koleksiyonundan
            .where('approveGoal', isEqualTo: true)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Bir hata oluştu: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'Henüz onaylanmış bir hedef bulunmuyor.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(8.0),
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data = document.data()! as Map<String, dynamic>;

              String sponsorName = data['sponsorName'] ?? 'Sponsor belirtilmemiş';
              double targetKm = (data['targetKm'] ?? 0.0).toDouble();
              double currentKm = (data['currentKm'] ?? 0.0).toDouble();
              DateTime startDate = (data['startDate'] as Timestamp).toDate();

              // İlerleme yüzdesini hesapla
              double progress = (targetKm > 0) ? (currentKm / targetKm) : 0.0;

              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16.0),
                  title: Text(
                    'Sponsor: $sponsorName',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      // İlerleme Çubuğu (Progress Bar)
                      LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.grey[300],
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                      ),
                      const SizedBox(height: 8),
                      Text('Hedef: ${targetKm.toStringAsFixed(1)} km - Koşulan: ${currentKm.toStringAsFixed(1)} km'),
                      const SizedBox(height: 4),
                      Text('Başlangıç Tarihi: ${DateFormat('dd/MM/yyyy').format(startDate)}'),
                    ],
                  ),
                  isThreeLine: true,
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
