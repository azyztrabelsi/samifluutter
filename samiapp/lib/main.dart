
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:samiapp/home_screen.dart';
import 'package:samiapp/login_screen.dart';
import 'package:samiapp/signup_screen.dart';
import 'package:samiapp/wrapper_screen.dart';
import 'package:samiapp/forget_password_screen.dart';
import 'package:samiapp/otp_screen.dart';
import 'package:samiapp/tic_tac_toe_screen.dart';
import 'package:samiapp/memory_match_screen.dart';
import 'package:samiapp/number_guessing_screen.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Auth UI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: false),
      initialRoute: '/',
      routes: {
         '/': (_) => const WrapperScreen(),
        '/home': (_) => HomeScreen(),
        '/login': (_) => const LoginScreen(),
        '/signup': (_) => const SignUpScreen(),
        '/forgot': (_) => const ForgotPasswordScreen(),
        '/otp': (_) => const OtpScreen(),
        '/tic-tac-toe': (_) => const TicTacToeScreen(),
        '/memory-match': (_) => const MemoryMatchScreen(),
        '/number-guessing': (_) => const NumberGuessingScreen(),
      },
    );
  }
}