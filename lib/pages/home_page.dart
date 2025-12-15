import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_profile.dart';
import 'goal_set_page.dart';
import 'login_page.dart';
import 'add_activity_screen.dart';
import 'goal_list.dart';


// Toplam mesafeyi canlı olarak göstermek için
class TotalDistanceDisplay extends StatefulWidget {
  const TotalDistanceDisplay({super.key});

  @override
  State<TotalDistanceDisplay> createState() => _TotalDistanceDisplayState();
}

class _TotalDistanceDisplayState extends State<TotalDistanceDisplay> {
  final User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return const Center(
          child: Text('0.0 km', style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold)));
    }

    // StreamBuilder ile veritabanını dinle
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('activities')
          .where('approvedActivity', isEqualTo: true) // Sadece onaylanmış aktiviteler
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text('Veri alınamadı', style: TextStyle(color: Colors.red)));
        }

        double totalDistance = 0.0;
        if (snapshot.hasData) {
          // onaylanmış aktivitelerin mesafelerini topla
          for (var doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic> ?;
            if (data != null && data.containsKey('distance')) {
              totalDistance += (data['distance'] as num).toDouble();
            }
          }
        }
        return Center(
          child: Text(
            '${totalDistance.toStringAsFixed(1)} km',
            style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
          ),
        );
      },
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
    TotalDistanceDisplay(),
    GoalListPage(),
    Center(child: Text('top 10')),
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

  void _goToAddActivityScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const AddActivityScreen()),
    );
  }

  void _goToGoalSetPage() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const GoalSetPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
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
      body: _widgetOptions.elementAt(_selectedIndex),

      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            onPressed: _goToGoalSetPage,
            label: const Text('Hedef Oluştur'),
            icon: const Icon(Icons.flag),
            heroTag: 'goal_fab', // Hero tag'i ekledik
          ),
          const SizedBox(height: 16), // Butonlar arasına boşluk ekledik
          FloatingActionButton.extended(
            onPressed: _goToAddActivityScreen,
            label: const Text('Aktivite Ekle'),
            icon: const Icon(Icons.add),
            heroTag: 'activity_fab', // Hero tag'i ekledik
          ),
        ],
      ),

      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Ana Sayfa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.flag),
            label: 'Hedefler',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.leaderboard),
            label: 'Top 10',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
