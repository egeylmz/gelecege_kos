import 'package:firebase_core/firebase_core.dart';
import 'package:gelecege_kos/utilities/google_sign_in.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'pages/add_activity_screen.dart';
import 'pages/user_profile.dart';
import 'pages/goal_set_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
      ),
      home: const SplashScreen()
    );
  }
}


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool isFirebaseInitialized = false;
  @override
  void initState() {
    super.initState();
    initializeFirebase();
  }
  Future<void> initializeFirebase() async{
    await Firebase.initializeApp();
    setState(() {
      isFirebaseInitialized = true;
    });
    if(FirebaseAuth.instance.currentUser != null) {
      goToMainPage();
    }
  }

  void goToMainPage() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder:
      (context) => const MyHomePage(title: 'Geleceğe Koş!'),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: isFirebaseInitialized
          ? ElevatedButton(onPressed: () async {
            await signInWithGoogle();
            goToMainPage();
          }, child: const Text('Google Sign In'))
          : const CircularProgressIndicator()
      ),
    );
  }
}


class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;     //hangi sekme seçili olduğunu tutacak.

  static const List<Widget> _widgetOptions = <Widget>[
    GoalSetPage(), // DEĞİŞTİRİLECEK
    Text(
      'Top 10 Kullanıcılar', // top_ten_contributors EKLENECEK
    ),
    Center(
      child: Text(
        '00000 km', // Ana ekran içeriği
        style: TextStyle(fontSize: 48),
      ),
    ),
    UserProfilePage(), // Profil Sayfası
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
  void _openAddActivityPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddActivityScreen()),
    );
  }

  void _openGoalSetPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const GoalSetPage()),
    );
  }

  void _goToProfilePage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const UserProfilePage()),
    );
  }

  Future<void> _signOut() async {
    await GoogleSignIn().signOut();
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const SplashScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: _widgetOptions.elementAt(_selectedIndex),

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
          unselectedItemColor: Colors.grey, // Seçili olmayan ikonların rengi
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed, // 4 ikon için bu ayar daha iyi görünür
        ),
    );
  }
}
