// lib/otp_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/db_helper.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _pinController = TextEditingController();
  bool _isVerifying = false;

  Future<void> _loginWithPin() async {
    final pin = _pinController.text.trim();
    if (pin.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter 4-digit PIN'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isVerifying = true);

    final user = await DBHelper.instance.loginWithPin(pin);

    if (user != null && mounted) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('currentUserId', user['id'] as int);
      await prefs.setString('currentUserName', user['name'] as String);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Welcome back, ${user['name']}!'), backgroundColor: Colors.green),
      );
      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Wrong PIN!'), backgroundColor: Colors.red),
      );
    }

    setState(() => _isVerifying = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,  // ← Allows screen to resize when keyboard opens
      backgroundColor: const Color(0xFFEEF2F7),
      appBar: AppBar(
        title: const Text('PIN Login'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(  // ← This + padding fixes overflow 100%
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height -
                (AppBar().preferredSize.height + MediaQuery.of(context).padding.top),
          ),
          child: Padding(
            padding: EdgeInsets.only(
              left: 32,
              right: 32,
              top: 40,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20, // ← Pushes content above keyboard
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.fingerprint, size: 100, color: Colors.blue),
                const SizedBox(height: 30),
                const Text(
                  'Enter Your 4-Digit PIN',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 40),

                // PIN Input
                SizedBox(
                  width: 220,
                  child: TextField(
                    controller: _pinController,
                    keyboardType: TextInputType.number,
                    maxLength: 4,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 32, letterSpacing: 20),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: '••••',
                      counterText: '',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Login Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isVerifying ? null : _loginWithPin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: _isVerifying
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Login with PIN', style: TextStyle(fontSize: 18, color: Colors.white)),
                  ),
                ),

                const SizedBox(height: 20),

                TextButton(
                  onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                  child: const Text('Use Email & Password'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}