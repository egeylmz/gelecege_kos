import 'package:flutter/material.dart';

class UserProfilePage extends StatelessWidget {
  const UserProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profilim'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profil Fotoğrafı Alanı
            const CircleAvatar(
              radius: 60,
              // Geçici ikon
              // backgroundImage: NetworkImage('URL_ADRESİ'), KULLANILABİLİR
              backgroundColor: Colors.grey,
              child: Icon(
                Icons.person,
                size: 60,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),

            // Profili Düzenle Butonu
            ElevatedButton(
              onPressed: () {
                // TODO: Profil düzenleme sayfasına yönlendirme eklenecek.
                print('Profili Düzenle butonuna tıklandı.');
              },
              child: const Text('Profili Düzenle'),
            ),
            const SizedBox(height: 40),

            // Geçmiş Aktiviteler Listelenecek
            const Text(
              'Geçmiş Aktiviteler',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(thickness: 1),
            const SizedBox(height: 10),

            const Expanded(
              child: Center(
                child: Text(
                  'Henüz geçmiş aktiviteniz bulunmuyor.',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
