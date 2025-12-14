import '../main.dart';
import 'user_profile.dart';
import 'add_activity_screen.dart';
import 'goal_set_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart'; // YENİimport 'home_page.dart'; // YENİ
import '../utilities/google_sign_in.dart'; // YENİ
import 'package:google_sign_in/google_sign_in.dart';
import 'home_page.dart';


// 1. Adım: StatefulWidget'a dönüştür
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // 2. Adım: Yüklenme durumunu takip etmek için bir değişken
  bool _isSigningIn = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFFF5F5F7),
        body: Center(
          child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ... (Welcome, email ve password kısımları aynı kalıyor)
                    const Text(
                      "Welcome!",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 5),

                    Text("Please log in to continue",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center),

                    const SizedBox(height: 50),

                    // ... email ve password TextField'ları ...
                    // (Bu kısımlarda değişiklik yok)

                    const SizedBox(height: 32),

                    // Log in button
                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {
                          // Henüz e-posta/şifre girişi yapmadığımız için
                          // şimdilik bir uyarı gösterebiliriz.
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('E-posta ile giriş henüz aktif değil.'),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 2,
                        ),
                        child: const Text(
                          "Log In",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24), // Boşluğu artırdık

                    // 3. Adım: "Or continue with" ayırıcısı
                    Row(
                      children: [
                        const Expanded(child: Divider(color: Colors.black26)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Text(
                            "Or continue with",
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ),
                        const Expanded(child: Divider(color: Colors.black26)),
                      ],
                    ),

                    const SizedBox(height: 24),

                    //Google Sign-In Butonu
                    _isSigningIn
                        ? const Center(child: CircularProgressIndicator())
                        : SizedBox(
                      height: 52,
                      child: OutlinedButton.icon(
                        icon: SvgPicture.asset(
                          'assets/icons/google_logo.svg',
                          height: 22,
                        ),
                        label: const Text(
                          "Sign in with Google",
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        onPressed: () async {
                          // Butona basıldığında yüklenme durumunu başlat
                          setState(() {
                            _isSigningIn = true;
                          });

                          // Google ile giriş fonksiyonunu çağır
                          await signInWithGoogle();

                          // Yüklenme durumunu bitir
                          setState(() {
                            _isSigningIn = false;
                          });

                          // Giriş başarılı olduysa ana sayfaya yönlendir.
                          if (FirebaseAuth.instance.currentUser != null && context.mounted) {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => const HomePage(title: 'Geleceğe Koş!'),
                              ),
                            );
                          }
                        },
                        style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            side: BorderSide(color: Colors.grey[300]!)),
                      ),
                    ),

                    const SizedBox(height: 18),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacementNamed(context, '/register');
                          },
                          child: const Text(
                            "Sign up",
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ]
              )
          ),
        )
    );
  }
}
