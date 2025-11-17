import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // FIX 1: Use GoogleSignIn.instance instead of constructor
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  bool _isLoading = false;
  bool _isPhoneAuth = false;
  String _countryCode = "+216";

  @override
  void initState() {
    super.initState();
    _checkCurrentUser();
  }

  void _checkCurrentUser() {
    final user = _auth.currentUser;
    if (user != null) {
      print("⚠️ User already logged in: ${user.email}");
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, "/home");
      });
    }
  }

  void toggleAuthMode() {
    setState(() => _isPhoneAuth = !_isPhoneAuth);
  }

  Future<void> _signInWithEmail() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    
    print("🔄 Starting email login for: $email");

    try {
      // FIX 2: Add timeout to prevent hanging
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      ).timeout(const Duration(seconds: 30));

      print("✅ Login successful: ${userCredential.user?.email}");
      
      if (mounted) {
        Navigator.pushReplacementNamed(context, "/home");
      }
      
    } on FirebaseAuthException catch (e) {
      print("❌ Firebase Auth Error: ${e.code} - ${e.message}");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_getAuthErrorMessage(e)),
            backgroundColor: Colors.red,
          ),
        );
      }
    } on TimeoutException catch (_) {
      print("⏰ Login timeout");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login timeout. Check your internet connection.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      print("❌ Unexpected error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unexpected error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _getAuthErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'invalid-email':
        return 'Invalid email format.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Try again later.';
      case 'network-request-failed':
        return 'Network error. Check your connection.';
      default:
        return e.message ?? 'Login failed. Please try again.';
    }
  }

  Future<void> _signInWithPhone() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty || phone.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter valid phone number")),
      );
      return;
    }

    setState(() => _isLoading = true);
    final fullPhoneNumber = '$_countryCode$phone';
    
    print("🔄 Starting phone auth for: $fullPhoneNumber");

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: fullPhoneNumber,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          print("✅ Auto verification completed");
          try {
            await _auth.signInWithCredential(credential);
            if (mounted) {
              Navigator.pushReplacementNamed(context, "/home");
            }
          } catch (e) {
            print("❌ Auto verification sign-in failed: $e");
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          print("❌ Verification failed: ${e.code} - ${e.message}");
          if (mounted) {
            setState(() => _isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Verification failed: ${e.message}"),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        codeSent: (String verificationId, int? resendToken) {
          print("📱 OTP sent to $fullPhoneNumber");
          if (mounted) {
            setState(() => _isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("OTP sent successfully")),
            );
            Navigator.pushNamed(context, '/otp', arguments: {
              'verificationId': verificationId,
              'phoneNumber': fullPhoneNumber,
            });
          }
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          print("⏰ Code auto-retrieval timeout");
          if (mounted) {
            setState(() => _isLoading = false);
          }
        },
      );
    } catch (e) {
      print("❌ Phone auth error: $e");
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to send OTP")),
        );
      }
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    print("🔄 Starting Google Sign-In");
    
    try {
      // FIX 3: Use the updated Google Sign-In API
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        print("❌ Google Sign-In cancelled by user");
        return null;
      }

      print("✅ Google user selected: ${googleUser.email}");

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      // FIX 4: Check if we have the required tokens
      if (googleAuth.idToken == null) {
        throw FirebaseAuthException(
          code: 'missing-google-token',
          message: 'Google Sign-In failed: ID token is missing',
        );
      }

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null) {
        print("✅ Google Sign-In successful: ${user.email}");
        
        // Save user to Firestore if new user
        final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
        final userDoc = await userRef.get();

        if (!userDoc.exists) {
          await userRef.set({
            'uid': user.uid,
            'name': user.displayName ?? 'User',
            'email': user.email ?? '',
            'createdAt': FieldValue.serverTimestamp(),
          });
          print("✅ New user saved to Firestore");
        }
        
        return userCredential;
      }
      return null;
    } on FirebaseAuthException catch (e) {
      print("❌ Firebase Auth Error during Google Sign-In: ${e.code} - ${e.message}");
      rethrow;
    } catch (e) {
      print("❌ Google Sign-In Error: $e");
      rethrow;
    }
  }

  // Temporary method for testing - create user if doesn't exist
  Future<void> _createTestUser() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    
    print("🔄 Attempting to create user: $email");

    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      ).timeout(const Duration(seconds: 30));
      
      print("✅ User created successfully: ${userCredential.user?.email}");
      
      // Save user to Firestore
      final user = userCredential.user!;
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'name': user.email!.split('@').first, // Use part of email as name
        'email': user.email,
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account created successfully! Now try logging in.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      print("❌ User creation failed: ${e.code} - ${e.message}");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_getAuthErrorMessage(e)),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print("❌ Unexpected error creating user: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEF2F7),
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Login',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                
                // Toggle between email and phone
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(_isPhoneAuth ? "Use Email" : "Use Phone"),
                    Switch(
                      value: _isPhoneAuth,
                      onChanged: (_) => toggleAuthMode(),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                // Phone Auth UI
                if (_isPhoneAuth)
                  Column(
                    children: [
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          prefixText: "$_countryCode ",
                          prefixIcon: const Icon(Icons.phone_android),
                          labelText: "Phone Number",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.length < 10) {
                            return 'Enter valid phone number';
                          }
                          return null;
                        },
                      ),
                    ],
                  )
                  
                // Email Auth UI  
                else
                  Column(
                    children: [
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          prefixIcon: const Icon(Icons.email_outlined),
                          labelText: 'Email',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) =>
                            value != null && value.contains('@')
                                ? null
                                : 'Enter valid email',
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          prefixIcon: const Icon(Icons.lock_outline),
                          labelText: 'Password',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) => value != null && value.length >= 6
                            ? null
                            : 'Min 6 characters',
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => Navigator.pushNamed(context, '/forgot'),
                          child: const Text("Forgot password?"),
                        ),
                      ),
                    ],
                  ),
                
                const SizedBox(height: 20),
                
                // Login/Send OTP Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : () => _isPhoneAuth
                            ? _signInWithPhone()
                            : _signInWithEmail(),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(_isPhoneAuth ? "Send OTP" : "Log In"),
                  ),
                ),
                
                // Create Account Button (for testing)
                if (!_isPhoneAuth) ...[
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: _isLoading ? null : _createTestUser,
                    child: const Text('Create Account Instead'),
                  ),
                ],
                
                const SizedBox(height: 20),
                Row(
                  children: const [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text("Or"),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 20),
                
                // Google Sign-In Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: SignInButton(
                    Buttons.Google,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    onPressed: _isLoading ? null : () async {
                      setState(() => _isLoading = true);
                      try {
                        final user = await signInWithGoogle();
                        if (user != null && mounted) {
                          Navigator.pushReplacementNamed(context, "/home");
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Google sign-in failed")),
                          );
                        }
                      } finally {
                        if (mounted) {
                          setState(() => _isLoading = false);
                        }
                      }
                    },
                  ),
                ),
                
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account? "),
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/signup'),
                      child: const Text(
                        "Sign up",
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}