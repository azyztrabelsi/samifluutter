import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/db_helper.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final user = await DBHelper.instance.login(_email.text.trim(), _pass.text.trim());

    if (user != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('currentUserId', user['id']);
      await prefs.setString('currentUserName', user['name']);
      if (mounted) Navigator.pushReplacementNamed(context, '/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Wrong email or password')));
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEF2F7),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Welcome Back!', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                const SizedBox(height: 40),
                TextFormField(controller: _email, decoration: const InputDecoration(labelText: 'Email', filled: true, fillColor: Colors.white), validator: (v) => v!.contains('@') ? null : 'Invalid email'),
                const SizedBox(height: 16),
                TextFormField(controller: _pass, obscureText: true, decoration: const InputDecoration(labelText: 'Password', filled: true, fillColor: Colors.white), validator: (v) => v!.length >= 6 ? null : 'Min 6 chars'),
                const SizedBox(height: 24),
                SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _loading ? null : _login, child: _loading ? const CircularProgressIndicator(color: Colors.white) : const Text('Login'))),
                TextButton(onPressed: () => Navigator.pushNamed(context, '/signup'), child: const Text('Create new account')),
                TextButton(onPressed: () => Navigator.pushNamed(context, '/forgot'), child: const Text('Forgot Password?')),
                TextButton(onPressed: () => Navigator.pushNamed(context, '/otp'), child: const Text('Quick PIN Login (1234)')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}