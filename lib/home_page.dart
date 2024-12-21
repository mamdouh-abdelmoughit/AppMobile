import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:moughit_app/ChatScreen.dart';
import 'package:moughit_app/FruitClassificationPage.dart';
import 'package:moughit_app/pages/home_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut(); // Déconnexion de l'utilisateur
      Navigator.pushReplacementNamed(
          context, '/login'); // Redirection vers la page de connexion
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Erreur : $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          TextButton(
            onPressed: _logout, // Appel de la méthode de déconnexion
            style: TextButton.styleFrom(
              backgroundColor: Colors.transparent, // Fond transparent
              shadowColor: Colors.transparent, // Pas d'ombre
              textStyle:
                  const TextStyle(color: Colors.white), // Couleur du texte
            ),
            child: const Text('Logout'), // Bouton de déconnexion
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: AssetImage(
                        'assets/images/Moughit-photo.jpg'), // Mettre à jour le chemin de l'image
                  ),
                  SizedBox(height: 8),
                  Text('Mamdouh Abdelmoughit',
                      style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
            _createDrawerItem(
              icon: Icons.science, // Use any appropriate icon
              text: 'Fruit Classification',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FruitsClassificationPage(),
                  ),
                );
              },
            ),
            _createDrawerItem(
              icon: Icons.info,
              text: 'Gestion syndic',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FirstPage(),
                  ),
                );
              },
            ),
            _createDrawerItem(
              icon: Icons.chat,
              text: 'chatbot',
              onTap: () {
                // Navigation vers la page de settings
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ChatScreen()),
                );
              },
            ),
            const Divider(),
            _createDrawerItem(
              icon: Icons.logout,
              text: 'Logout',
              onTap: () {
                _logout(); // Appel de la méthode de déconnexion
              },
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Center(
            child: Text(
              'Home Page',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome to the Home Page!',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Here is a brief introduction to the app. You can navigate through the menu to explore different features.',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _createDrawerItem({
    required IconData icon,
    required String text,
    required GestureTapCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(text),
      onTap: onTap,
    );
  }
}
