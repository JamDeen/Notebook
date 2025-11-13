import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'home_page.dart';
import 'signup_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _loading = false;
  final _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Connexion')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _usernameCtrl,
                decoration:
                    const InputDecoration(labelText: 'Nom d\'utilisateur'),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Champ requis' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordCtrl,
                decoration: const InputDecoration(labelText: 'Mot de passe'),
                obscureText: true,
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Champ requis' : null,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading
                      ? null
                      : () async {
                          if (!_formKey.currentState!.validate()) return;
                          setState(() => _loading = true);

                          final err = await _auth.login(
                            username: _usernameCtrl.text.trim(),
                            password: _passwordCtrl.text,
                          );

                          if (!context.mounted) return; // ✅ important
                          setState(() => _loading = false);

                          if (err != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(err)),
                            );
                          } else {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                  builder: (_) => const HomePage()),
                            );
                          }
                        },
                  child: _loading
                      ? const CircularProgressIndicator()
                      : const Text('Se connecter'),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SignupPage()),
                  );
                },
                child: const Text("Pas de compte ? S'inscrire"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
