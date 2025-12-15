import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Contributor {
  final String name;
  final double totalDistance;
  final String profileImageUrl;

  Contributor({
    required this.name,
    required this.totalDistance,
    required this.profileImageUrl,
  });
}

class LeaderboardService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Contributor>> getTopTenContributors() {


    return _firestore.collection('users').snapshots().asyncMap((userSnapshot) async {
      List<Contributor> contributors = [];

      for (var userDoc in userSnapshot.docs) {
        final userData = userDoc.data();
        double totalDistance = 0.0;

        final activitiesSnapshot = await _firestore
            .collection('users')
            .doc(userDoc.id)
            .collection('activities')
            .get();

        for (var activityDoc in activitiesSnapshot.docs) {
          final activityData = activityDoc.data();
          if (activityData.containsKey('distance') && activityData['distance'] != null) {
            totalDistance += (activityData['distance'] as num).toDouble();
          }
        }

        contributors.add(Contributor(
          name: userData['displayName'] ?? 'İsimsiz Kullanıcı',
          totalDistance: totalDistance,
          profileImageUrl: userData['photoURL'] ?? 'https://i.pravatar.cc/150?img=0',
        ));
      }

      contributors.sort((a, b) => b.totalDistance.compareTo(a.totalDistance));

      return contributors.take(10).toList();
    });
  }
}

class TopTenContributorsPage extends StatefulWidget {
  const TopTenContributorsPage({super.key});

  @override
  State<TopTenContributorsPage> createState() => _TopTenContributorsPageState();
}

class _TopTenContributorsPageState extends State<TopTenContributorsPage> {
  final LeaderboardService _leaderboardService = LeaderboardService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('En İyi 10 Katılımcı'),
        backgroundColor: Colors.blueAccent,
      ),
      body: StreamBuilder<List<Contributor>>(
        stream: _leaderboardService.getTopTenContributors(),
        builder: (context, snapshot) {
          // Yükleniyor durumu
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // Hata durumu
          if (snapshot.hasError) {
            return Center(child: Text('Bir hata oluştu: ${snapshot.error}'));
          }
          // Veri yok veya boş liste durumu
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Henüz veri bulunmuyor.'));
          }

          final topUsers = snapshot.data!;

          return ListView.builder(
            itemCount: topUsers.length,
            itemBuilder: (context, index) {
              final user = topUsers[index];
              final rank = index + 1; // Sıralama numarası

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: ListTile(
                  leading: CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.grey.shade200,
                    child: Text(
                      '$rank',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: rank <= 3 ? Colors.amber[800] : Colors.black87,
                      ),
                    ),
                  ),
                  title: Text(
                    user.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('${user.totalDistance.toStringAsFixed(1)} km'),
                  trailing: CircleAvatar(
                    radius: 25,
                    backgroundImage: NetworkImage(user.profileImageUrl),
                    onBackgroundImageError: (exception, stackTrace) {
                      // Resim yüklenemezse varsayılan bir icon gösterilebilir
                    },
                    child: user.profileImageUrl.isEmpty
                        ? const Icon(Icons.person)
                        : null,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
