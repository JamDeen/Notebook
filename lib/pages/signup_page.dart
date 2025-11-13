import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _loading = false;
  final _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inscription')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
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
                controller: _emailCtrl,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (v) =>
                    (v == null || !v.contains('@')) ? 'Email invalide' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordCtrl,
                decoration: const InputDecoration(labelText: 'Mot de passe'),
                obscureText: true,
                validator: (v) =>
                    (v == null || v.length < 4) ? 'Min 4 caractères' : null,
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

                          final err = await _auth.register(
                            username: _usernameCtrl.text.trim(),
                            email: _emailCtrl.text.trim(),
                            password: _passwordCtrl.text,
                          );

                          if (!context.mounted) return; // ✅ important
                          setState(() => _loading = false);

                          if (err != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(err)),
                            );
                          } else {
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Inscription réussie, connectez-vous.')),
                            );
                          }
                        },
                  child: _loading
                      ? const CircularProgressIndicator()
                      : const Text("S'inscrire"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
