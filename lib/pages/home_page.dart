import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_profile.dart';
import 'goal_set_page.dart';
import 'login_page.dart';
import 'add_activity_screen.dart';
import 'goal_list.dart';

// --- YENİ TASARIM: DashboardDisplay (Sadeleştirilmiş) ---
class DashboardDisplay extends StatefulWidget {
  const DashboardDisplay({super.key});

  @override
  State<DashboardDisplay> createState() => _DashboardDisplayState();
}

class _DashboardDisplayState extends State<DashboardDisplay> {
  int _activityLimit = 10;

  double _safeParseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is int) return value.toDouble();
    if (value is double) return value;
    if (value is String) {
      String normalized = value.replaceAll(',', '.').replaceAll('km', '').trim();
      return double.tryParse(normalized) ?? 0.0;
    }
    return 0.0;
  }

  void _loadMoreActivities() {
    setState(() {
      _activityLimit += 10;
    });
  }

  @override
  Widget build(BuildContext context) {
    final User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Center(child: Text('Giriş Yapılmalı', style: TextStyle(color: Colors.white)));
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          // --- ÜST KISIM: MESAFE VE HEDEF DURUMU ---
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('activities')
                .where('approvedActivity', isEqualTo: true)
                .snapshots(),
            builder: (context, actSnapshot) {
              if (actSnapshot.hasError) return Text("Hata: ${actSnapshot.error}", style: const TextStyle(color: Colors.red));

              double totalDistance = 0.0;
              if (actSnapshot.hasData) {
                for (var doc in actSnapshot.data!.docs) {
                  final data = doc.data() as Map<String, dynamic>?;
                  if (data != null) {
                    var distVal = data['distance'] ?? data['km'] ?? data['mesafer'];
                    totalDistance += _safeParseDouble(distVal);
                  }
                }
              }

              return StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('goals').snapshots(),
                builder: (context, goalSnapshot) {
                  double nextGoalTarget = 0.0;
                  // nextGoalTitle değişkenini kaldırdık
                  bool isGoalSet = false;
                  bool allGoalsCompleted = false;

                  if (goalSnapshot.hasData && goalSnapshot.data!.docs.isNotEmpty) {
                    List<Map<String, dynamic>> allGoals = [];
                    for (var doc in goalSnapshot.data!.docs) {
                      var data = doc.data() as Map<String, dynamic>;
                      var rawTarget = data['targetDistance'] ?? data['targetKm'] ?? data['hedef'] ?? data['distance'];
                      double tVal = _safeParseDouble(rawTarget);
                      if (tVal > 0) {
                        allGoals.add({
                          'target': tVal
                        });
                      }
                    }
                    allGoals.sort((a, b) => (a['target'] as double).compareTo(b['target'] as double));

                    bool found = false;
                    for (var goal in allGoals) {
                      double t = goal['target'] as double;
                      if (t > totalDistance) {
                        nextGoalTarget = t;
                        isGoalSet = true;
                        found = true;
                        break;
                      }
                    }

                    if (!found && allGoals.isNotEmpty) {
                      allGoalsCompleted = true;
                      nextGoalTarget = totalDistance > 0 ? totalDistance : 100.0;
                    }
                  }

                  double percent = 0.0;
                  if (allGoalsCompleted) {
                    percent = 1.0;
                  } else if (isGoalSet && nextGoalTarget > 0) {
                    percent = totalDistance / nextGoalTarget;
                    percent = percent.clamp(0.0, 1.0);
                  }

                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.only(top: 80.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        // Dairesel Gösterge
                        SizedBox(
                          width: 260,
                          height: 260,
                          child: Stack(
                            alignment: Alignment.center,
                            fit: StackFit.expand,
                            children: [
                              CircularProgressIndicator(
                                value: 1.0,
                                strokeWidth: 15,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white.withOpacity(0.1)),
                              ),
                              CircularProgressIndicator(
                                value: percent,
                                strokeWidth: 15,
                                strokeCap: StrokeCap.round,
                                backgroundColor: Colors.transparent,
                                valueColor: AlwaysStoppedAnimation<Color>(const Color(0xFF071508).withOpacity(0.7)),
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.directions_run, color: Colors.white70, size: 36),
                                  const SizedBox(height: 8),
                                  Text(
                                    totalDistance.toStringAsFixed(1),
                                    style: const TextStyle(
                                        fontSize: 60,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        height: 1.0,
                                        shadows: [Shadow(blurRadius: 10, color: Colors.black45, offset: Offset(2, 2))]
                                    ),
                                  ),
                                  const Text(
                                    "TOPLAM KM",
                                    style: TextStyle(fontSize: 14, color: Colors.white70, letterSpacing: 2.0),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 50),

                        // Hedef Bilgisi Kutusu (Sadece kalan mesafe)
                        if (isGoalSet || allGoalsCompleted)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                            margin: const EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                              color: const Color(0xFF071508).withOpacity(0.8),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(color: Colors.white12),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (allGoalsCompleted)
                                  const Text(
                                    "Tüm Hedefler Bitti!",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                else if (isGoalSet)
                                  Text(
                                    "Sonraki hedefe ${(nextGoalTarget - totalDistance).toStringAsFixed(1)} km kaldı",
                                    style: const TextStyle(
                                      color: Colors.white, // Daha okunaklı olması için beyaz yaptım
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  );
                },
              );
            },
          ),

          // --- ALT KISIM: LİSTE ---
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center, // Başlık ortalandı
              children: [
                const Padding(
                  padding: EdgeInsets.only(bottom: 12.0),
                  child: Text(
                    "Topluluk Aktiviteleri",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('activities')
                      .where('approvedActivity', isEqualTo: true)
                      .limit(_activityLimit)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Text("Hata oluştu.", style: TextStyle(color: Colors.red));
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final docs = snapshot.data?.docs ?? [];
                    if (docs.isEmpty) {
                      return const Center(
                        child: Text("Henüz onaylanmış aktivite yok.", style: TextStyle(color: Colors.white60)),
                      );
                    }

                    return Column(
                      children: [
                        ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: docs.length,
                          itemBuilder: (context, index) {
                            final data = docs[index].data() as Map<String, dynamic>;
                            final String title = data['description'] ?? data['activityType'] ?? 'Aktivite';
                            final double km = _safeParseDouble(data['distance'] ?? data['km']);
                            final String userName = data['userName'] ?? 'Kullanıcı';

                            return Card(
                              color: Colors.white.withOpacity(0.1),
                              margin: const EdgeInsets.symmetric(vertical: 6.0),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                              child: ListTile(
                                leading: const CircleAvatar(
                                  backgroundColor: Colors.white24,
                                  child: Icon(Icons.fitness_center, color: Colors.white),
                                ),
                                title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                subtitle: Text(userName, style: const TextStyle(color: Colors.white70)),
                                trailing: Text(
                                  "${km.toStringAsFixed(1)} km",
                                  style: const TextStyle(color: Color(0xFF071508), fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                              ),
                            );
                          },
                        ),
                        if (docs.length >= _activityLimit)
                          Padding(
                            padding: const EdgeInsets.only(top: 20.0, bottom: 40.0),
                            child: ElevatedButton(
                              onPressed: _loadMoreActivities,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white24,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                              ),
                              child: const Text("Daha Fazla Yükle", style: TextStyle(color: Colors.white)),
                            ),
                          )
                        else
                          const Padding(
                            padding: EdgeInsets.only(top: 20.0, bottom: 40.0),
                            child: Text("Tüm aktiviteler listelendi.", style: TextStyle(color: Colors.white30)),
                          ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});
  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    DashboardDisplay(),
    GoalListPage(),
    Center(child: Text('top 10', style: TextStyle(color: Colors.white))),
    UserProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }


  Future<void> _signOut() async {
    await GoogleSignIn().signOut();
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()),
            (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        backgroundColor: const Color(0xFF071508),
        foregroundColor: Colors.white,
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            iconSize: 30.0,
            onPressed: _signOut,
            tooltip: 'Çıkış Yap',
          )
        ],
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/icons/main_background.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(color: Colors.black.withOpacity(0.3)),
          _widgetOptions.elementAt(_selectedIndex),
        ],
      ),

      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
          iconSize: 30,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Ana Sayfa'),
            BottomNavigationBarItem(icon: Icon(Icons.flag), label: 'Hedefler'),
            BottomNavigationBarItem(icon: Icon(Icons.leaderboard), label: 'Top 10'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
          ],
          currentIndex: _selectedIndex,
          backgroundColor: const Color(0xFF071508),
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white60,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
        ),
      ),
    );
  }
}
