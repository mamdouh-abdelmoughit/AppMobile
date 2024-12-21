import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  Future<void> _registerUser() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Les mots de passe ne correspondent pas.")),
      );
      return;
    }

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      Navigator.pushReplacementNamed(context, '/home'); // Redirection après inscription
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur : $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo de l'application
              Image.asset(
                'assets/images/logo.png',
                width: 200,
                height: 100,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 20),
              // Champ Nom d'utilisateur
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Nom d\'utilisateur',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) => value!.isEmpty
                    ? 'Veuillez entrer votre nom d\'utilisateur'
                    : null,
              ),
              const SizedBox(height: 16),
              // Champ Email
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) =>
                    value!.isEmpty ? 'Veuillez entrer votre email' : null,
              ),
              const SizedBox(height: 16),
              // Champ Mot de passe
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Mot de passe',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                obscureText: true,
                validator: (value) =>
                    value!.isEmpty ? 'Veuillez entrer votre mot de passe' : null,
              ),
              const SizedBox(height: 16),
              // Champ Confirmation Mot de passe
              TextFormField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                  labelText: 'Confirmer le mot de passe',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                obscureText: true,
                validator: (value) => value!.isEmpty
                    ? 'Veuillez confirmer votre mot de passe'
                    : null,
              ),
              const SizedBox(height: 20),
              // Bouton Register
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _registerUser();
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Register',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 10),
              // Lien vers Login
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/login'); // Retour vers Login
                },
                child: const Text('Already have an account? Login here'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}