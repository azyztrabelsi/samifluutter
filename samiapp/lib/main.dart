import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import 'package:samiapp/database/db_helper.dart'; // ← CORRECT PATH
import 'package:samiapp/home_screen.dart';
import 'package:samiapp/login_screen.dart';
import 'package:samiapp/signup_screen.dart';
import 'package:samiapp/wrapper_screen.dart';
import 'package:samiapp/forget_password_screen.dart';
import 'package:samiapp/otp_screen.dart';
import 'package:samiapp/tic_tac_toe_screen.dart';
import 'package:samiapp/memory_match_screen.dart';
import 'package:samiapp/number_guessing_screen.dart';
import 'package:samiapp/snake_game_screen.dart';
import 'package:samiapp/quiz_game_screen.dart';
import 'package:sqflite/sqflite.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // AUTO COPY DATABASE TO PROJECT ROOT AS samidb.sqlite
  try {
    final dbPath = await getDatabasesPath();
    final source = join(dbPath, 'sami_app.db');
    final destination = join(Directory.current.path, 'samidb.sqlite');

    if (await File(source).exists()) {
      await File(source).copy(destination);
      print('SUCCESS: Database copied → $destination');
      print('Open samidb.sqlite with DB Browser for SQLite!');
    } else {
      print('Database will appear after first login/signup');
    }
  } catch (e) {
    print('Copy failed (normal on first run): $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sami Fun Chat & Games',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.blue,
        fontFamily: 'Cairo', // Arabic font (add later if you want)
      ),
      initialRoute: '/',
      routes: {
        '/': (_) => const WrapperScreen(),
        '/home': (_) => const HomeScreen(),
        '/login': (_) => const LoginScreen(),
        '/signup': (_) => const SignUpScreen(),
        '/forgot': (_) => const ForgotPasswordScreen(),
        '/otp': (_) => const OtpScreen(),
        '/tic-tac-toe': (_) => const TicTacToeScreen(),
        '/memory-match': (_) => const MemoryMatchScreen(),
        '/number-guessing': (_) => const NumberGuessingScreen(),
        '/snake': (_) => const SnakeGameScreen(),
        '/quiz': (_) => const QuizGameScreen(),
      },
    );
  }
}