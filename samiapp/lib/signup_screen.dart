import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/db_helper.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _pin = TextEditingController(); // NEW
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final id = await DBHelper.instance.insertUser({
      'name': _name.text.trim(),
      'email': _email.text.trim(),
      'password': _pass.text.trim(),
      'pin': _pin.text.isEmpty ? null : _pin.text.trim(), // Save PIN
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('currentUserId', id);
    await prefs.setString('currentUserName', _name.text.trim());

    if (mounted) Navigator.pushReplacementNamed(context, '/home');
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEF2F7),
      appBar: AppBar(title: const Text('Sign Up'), backgroundColor: Colors.transparent, elevation: 0),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                const Text('Create Account', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                const SizedBox(height: 40),
                TextFormField(controller: _name, decoration: const InputDecoration(labelText: 'Full Name', filled: true, fillColor: Colors.white)),
                const SizedBox(height: 16),
                TextFormField(controller: _email, decoration: const InputDecoration(labelText: 'Email', filled: true, fillColor: Colors.white), validator: (v) => v!.contains('@') ? null : 'Invalid email'),
                const SizedBox(height: 16),
                TextFormField(controller: _pass, obscureText: true, decoration: const InputDecoration(labelText: 'Password', filled: true, fillColor: Colors.white), validator: (v) => v!.length >= 6 ? null : 'Min 6 chars'),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _pin,
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  decoration: InputDecoration(
                    labelText: 'Set 4-Digit PIN (Optional)',
                    hintText: '1234',
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: const Icon(Icons.lock_outline),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _loading ? null : _signup,
                  child: _loading ? const CircularProgressIndicator(color: Colors.white) : const Text('Create Account'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}