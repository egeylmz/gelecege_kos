import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserSearchPage extends StatefulWidget {
  const UserSearchPage({super.key});

  @override
  State<UserSearchPage> createState() => _UserSearchPageState();
}

class _UserSearchPageState extends State<UserSearchPage> {
  String _searchQuery = "";
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ARAMA ÇUBUĞU
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Kullanıcı adı ara...',
              hintStyle: const TextStyle(color: Colors.white54),
              prefixIcon: const Icon(Icons.search, color: Colors.white54),
              filled: true,
              fillColor: Colors.white.withOpacity(0.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
            ),
            // Her harf girildiğinde arama kelimesi günceollenecek
            onChanged: (value) {
              setState(() {
                _searchQuery = value.trim().toLowerCase();
              });
            },
          ),
        ),

        // LİSTELEME ALANI
        Expanded(
          child: _searchQuery.isEmpty
              ? const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person_search, size: 80, color: Colors.white24),
                SizedBox(height: 16),
                Text(
                  'Arama yapmak için bir isim girin.',
                  style: TextStyle(color: Colors.white54, fontSize: 16),
                ),
              ],
            ),
          )
              : StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .where('searchKey', isGreaterThanOrEqualTo: _searchQuery)
                .where('searchKey', isLessThan: '${_searchQuery}z')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Center(
                  child: Text('Bir hata oluştu.', style: TextStyle(color: Colors.white)),
                );
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              }

              final data = snapshot.data;

              if (data == null || data.docs.isEmpty) {
                return const Center(
                  child: Text(
                    'Kullanıcı bulunamadı.',
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }

              // Sonuçları listele
              return ListView.builder(
                itemCount: data.docs.length,
                itemBuilder: (context, index) {
                  var userDoc = data.docs[index];
                  var userData = userDoc.data() as Map<String, dynamic>;

                  return Card(
                    color: Colors.white.withOpacity(0.1),
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.white24,
                        child: Text(
                          // İsmin baş harfini göster
                          (userData['name'] ?? 'U')[0].toUpperCase(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(
                        userData['name'] ?? 'İsimsiz Kullanıcı',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white54),
                        onPressed: () {
                          // TIKLANINCA PROFİLE GİTME ÖZELLİĞİ EKLENECEK
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("${userData['name']} seçildi")),
                          );
                        },
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
