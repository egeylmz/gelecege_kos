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


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isSigningIn = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFFF5F5F7),
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/icons/login_background.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Center(
            child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        "Welcome!",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 8),

                      Text("Please log in to continue",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.8),
                          ),
                          textAlign: TextAlign.center),

                      const SizedBox(height: 50),

                      // E-posta giriş alanı
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                          prefixIcon: const Icon(Icons.email_outlined, color: Colors.white70),
                          filled: true,
                          fillColor: Colors.black.withOpacity(0.3),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(color: Colors.white.withOpacity(0.5)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(color: Colors.white),
                          ),
                        ),
                        style: const TextStyle(color: Colors.white),
                      ),

                      const SizedBox(height: 16),

                      // Şifre giriş alanı
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                          prefixIcon: const Icon(Icons.lock_outline, color: Colors.white70),
                          filled: true,
                          fillColor: Colors.black.withOpacity(0.3),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(color: Colors.white.withOpacity(0.5)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(color: Colors.white),
                          ),
                        ),
                        style: const TextStyle(color: Colors.white),
                      ),

                      const SizedBox(height: 32),

                      // Log in button
                      SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          onPressed: () {
                            // E POSTA VE ŞİFRE İLE GİRİŞ YAP
                            final email = _emailController.text;
                            final password = _passwordController.text;
                            print('Email: $email, Password: $password');

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('E-posta ile giriş henüz aktif değil.'),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.black,
                            backgroundColor: Colors.white,
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

                      const SizedBox(height: 24),

                      Row(
                        children: [
                          const Expanded(child: Divider(color: Colors.white54)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12.0),
                            child: Text(
                              "Or continue with",
                              style: TextStyle(color: Colors.white.withOpacity(0.8)),
                            ),
                          ),
                          const Expanded(child: Divider(color: Colors.white54)),
                        ],
                      ),

                      const SizedBox(height: 24),

                      //Google Sign-In Butonu
                      _isSigningIn
                          ? const Center(child: CircularProgressIndicator(color: Colors.white))
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

                            await signInWithGoogle();

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
                              backgroundColor: Colors.white,
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
                            style: TextStyle(color: Colors.white.withOpacity(0.8)),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushReplacementNamed(context, '/register');
                            },
                            child: const Text(
                              "Sign up",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                                decorationColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ]
                )
            ),
          ),
        )
    );
  }
}
