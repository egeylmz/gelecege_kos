import 'package:firebase_core/firebase_core.dart';
import 'package:gelecege_kos/utilities/google_sign_in.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'add_activity_screen.dart';

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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
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
      (context) => const MyHomePage(title: 'Flutter Demo Home Page'),
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

  void _openAddActivityPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddActivityScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: const Center(
        child: Text(
          'Geleceğe Koş',
          style: TextStyle(fontSize: 24),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddActivityPage,
        tooltip: 'Aktivite Ekle!',
        icon: const Icon(Icons.add),
        label: const Text('Aktivite Ekle!'),
      ),
    );
  }
}
