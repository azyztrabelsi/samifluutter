import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

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
import 'package:samiapp/color_matching_screen.dart';
import 'package:samiapp/simon_says_screen.dart';
import 'package:samiapp/balloon_pop_screen.dart';
import 'package:samiapp/player_profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    final dbFolder = await getDatabasesPath();
    final sourcePath = join(dbFolder, 'sami_app.db');

    if (await File(sourcePath).exists()) {
      // 1. Copy to Downloads
      final downloadsDir = '/storage/emulated/0/Download';
      final downloadPath = '$downloadsDir/samidb.sqlite';
      await File(sourcePath).copy(downloadPath);

      // 2. Try to copy to project folder
      try {
        final projectPath = join(Directory.current.path, 'samidb.sqlite');
        await File(sourcePath).copy(projectPath);
        print('SUCCESS: Database copied to project → samidb.sqlite');
      } catch (e) {
        print('Project folder read-only → saved to Downloads/samidb.sqlite');
      }

      // 3. SHOW ALL DATA IN CONSOLE
      final db = await openDatabase(sourcePath);

      print('\n╔════════════════════════════════════════╗');
      print('           SAMI APP DATABASE');
      print('╚════════════════════════════════════════╝');

      final users = await db.rawQuery('SELECT * FROM users');
      print('USERS (${users.length}):');
      for (var u in users) {
        print('  ID:${u['id']} | ${u['name']} | ${u['email']} | PIN: ${u['pin'] ?? 'none'}');
      }

      final messages = await db.rawQuery(
          'SELECT m.*, u.name FROM messages m LEFT JOIN users u ON m.sender_id = u.id ORDER BY m.timestamp DESC LIMIT 15');
      print('\nLAST 15 MESSAGES:');
      if (messages.isEmpty) {
        print('  (No messages yet)');
      } else {
        for (var m in messages) {
          final sender = m['name'] ?? 'User${m['sender_id']}';
          final text = m['message'];
          final time = (m['timestamp'] as String).substring(0, 19).replaceAll('T', ' ');
          print('  $sender → $text   [$time]');
        }
      }

      print('╚════════════════════════════════════════╝\n');
      await db.close();

      print('Database saved to:');
      print('   • Downloads/samidb.sqlite  (on phone)');
      print('   • samiapp/samidb.sqlite     (on PC if connected)\n');
    } else {
      print('Waiting for first login/signup to create database...');
    }
  } catch (e) {
    print('Error reading database: $e');
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
        
        // 🎨 BEAUTIFUL GREEN-BLUE GRADIENT THEME
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4CAF50), // Fresh Green
          primary: const Color(0xFF4CAF50),
          secondary: const Color(0xFF2196F3), // Vibrant Blue
          tertiary: const Color(0xFF00BCD4), // Cyan accent
          surface: const Color(0xFFF0F8FF), // Alice Blue background
          background: const Color(0xFFF5F9FC),
          brightness: Brightness.light,
        ),
        
        // 🌈 Modern, playful font
        fontFamily: 'Poppins',
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
          displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w600, color: Color(0xFF1976D2)),
          bodyLarge: TextStyle(fontSize: 16, color: Color(0xFF424242)),
          bodyMedium: TextStyle(fontSize: 14, color: Color(0xFF616161)),
        ),

        // 🎯 Modern AppBar with gradient effect
        appBarTheme: AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: const Color(0xFF4CAF50),
          foregroundColor: Colors.white,
          titleTextStyle: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
          iconTheme: const IconThemeData(color: Colors.white, size: 26),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
          ),
        ),

        // 🎈 Elevated Button - Playful rounded style
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 8,
            backgroundColor: const Color(0xFF4CAF50),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
            ),
            shadowColor: const Color(0xFF4CAF50).withOpacity(0.5),
          ),
        ),

        // 🎨 Card theme - Soft shadows and rounded corners
        cardTheme: CardThemeData(
          elevation: 6,
          shadowColor: Colors.black26,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),

        // ✨ Input Decoration - Modern, clean fields
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 2.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
          labelStyle: const TextStyle(
            fontSize: 16,
            color: Color(0xFF757575),
            fontWeight: FontWeight.w500,
          ),
        ),

        // 🎯 FloatingActionButton - Gradient style
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: const Color(0xFF2196F3),
          foregroundColor: Colors.white,
          elevation: 10,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),

        // 🎪 Smooth page transitions
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
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
        '/color-match': (_) => const ColorMatchingScreen(),
        '/simon-says': (_) => const SimonSaysScreen(),
        '/balloon-pop': (_) => const BalloonPopScreen(),
        '/player-profile': (_) => const PlayerProfileScreen(),
      },
    );
  }
}