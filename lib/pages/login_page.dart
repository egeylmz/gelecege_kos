// Temizlenmiş ve gerekli importlar
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_page.dart';
import '../utilities/google_sign_in.dart'; // Bu dosya `signInWithGoogle` fonksiyonunu içeriyorsa tutulmalı

// RegisterPage'i import ediyoruz.
import 'register_page.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Firebase ve GoogleSignIn nesneleri
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Form ve Controller'lar
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Durum yönetimi için değişkenler
  bool _isSigningIn = false; // Hem Google hem de e-posta girişi için kullanılabilir
  String _errorMessage = '';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // E-posta ve Şifre ile Giriş Fonksiyonu
  Future<void> _signInWithEmailAndPassword() async {
    // Klavye açıksa kapat
    FocusScope.of(context).unfocus();

    // Yüklenme durumunu başlat
    setState(() {
      _isSigningIn = true;
      _errorMessage = '';
    });

    try {
      // Firebase ile giriş yapmayı dene
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Giriş başarılıysa ana sayfaya yönlendir
      if (mounted) {
        _navigateToHome();
      }

    } on FirebaseAuthException catch (e) {
      // Hata kodlarına göre kullanıcı dostu mesajlar oluştur
      String message;
      if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-credential') {
        message = 'E-posta veya şifre hatalı.';
      } else if (e.code == 'invalid-email') {
        message = 'Lütfen geçerli bir e-posta adresi girin.';
      } else {
        message = 'Bir hata oluştu. Lütfen tekrar deneyin.';
      }
      setState(() {
        _errorMessage = message;
      });
    } catch (e) {
      // Beklenmedik diğer hatalar için
      setState(() {
        _errorMessage = 'Beklenmedik bir hata oluştu.';
      });
    }

    // Yüklenme durumunu bitir
    if (mounted) {
      setState(() {
        _isSigningIn = false;
      });
    }
  }

  // Google ile Giriş Fonksiyonu
  Future<void> _signInWithGoogleFlow() async {
    setState(() {
      _isSigningIn = true;
      _errorMessage = '';
    });

    // `google_sign_in.dart` dosyanızdaki fonksiyonu çağırıyoruz
    await signInWithGoogle();

    // Yüklenme durumunu bitir
    if(mounted) {
      setState(() {
        _isSigningIn = false;
      });
    }


    // Giriş başarılı olduysa ana sayfaya yönlendir.
    if (_auth.currentUser != null && mounted) {
      _navigateToHome();
    } else {
      // Google girişinin başarısız olma veya kullanıcı tarafından iptal edilme durumu
      if (mounted) {
        setState(() {
          _errorMessage = "Google ile giriş yapılamadı.";
        });
      }
    }
  }

  // Ana Sayfaya Yönlendirme Metodu
  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const HomePage(title: 'Geleceğe Koş!'),
      ),
    );
  }

  // Kayıt Sayfasına Yönlendirme Metodu (DÜZELTİLDİ)
  void _navigateToRegister() {
    // RegisterPage'i mevcut sayfanın üzerine yeni bir sayfa olarak ekler.
    // Kullanıcı bu sayfadan geri tuşuna basarak login ekranına dönebilir.
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const RegisterPage()),
    );
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
            child: SingleChildScrollView( // Ekran taşmalarını önlemek için
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

                        const SizedBox(height: 40),

                        // Hata mesajını göstermek için bir alan
                        if (_errorMessage.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: Text(
                              _errorMessage,
                              style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ),

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

                        // Yüklenme durumuna göre butonları yönetme
                        _isSigningIn
                            ? const Center(child: CircularProgressIndicator(color: Colors.white))
                            : Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Log in button
                            SizedBox(
                              height: 52,
                              child: ElevatedButton(
                                // onPressed fonksiyonunu yeni giriş metodumuza bağlıyoruz
                                onPressed: _signInWithEmailAndPassword,
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
                            SizedBox(
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
                                // onPressed fonksiyonunu yeni Google giriş akışımıza bağlıyoruz
                                onPressed: _signInWithGoogleFlow,
                                style: OutlinedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    side: BorderSide(color: Colors.grey[300]!)),
                              ),
                            ),
                          ],
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
                              // onTap'ı yeni metoda bağlıyoruz
                              onTap: _navigateToRegister,
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
          ),
        )
    );
  }
}
