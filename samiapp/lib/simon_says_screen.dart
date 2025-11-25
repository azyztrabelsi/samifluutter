import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

class SimonSaysScreen extends StatefulWidget {
  const SimonSaysScreen({super.key});

  @override
  State<SimonSaysScreen> createState() => _SimonSaysScreenState();
}

class _SimonSaysScreenState extends State<SimonSaysScreen> {
  List<int> sequence = [];
  List<int> playerSequence = [];
  int currentLevel = 1;
  int score = 0;
  bool isPlaying = false;
  bool canPlay = false;
  int? activeButton;
  String message = 'Press Start to Play!';

  final List<Color> colors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
  ];

  final List<String> colorNames = ['Red', 'Blue', 'Green', 'Yellow'];

  void _startGame() {
    setState(() {
      sequence = [];
      playerSequence = [];
      currentLevel = 1;
      score = 0;
      message = 'Watch carefully...';
    });
    _nextLevel();
  }

  void _nextLevel() {
    setState(() {
      playerSequence = [];
      canPlay = false;
      message = 'Level $currentLevel - Watch!';
      sequence.add(Random().nextInt(4));
    });
    _playSequence();
  }

  Future<void> _playSequence() async {
    setState(() => isPlaying = true);
    
    await Future.delayed(const Duration(milliseconds: 500));
    
    for (int i = 0; i < sequence.length; i++) {
      await _flashButton(sequence[i]);
      await Future.delayed(const Duration(milliseconds: 200));
    }
    
    setState(() {
      isPlaying = false;
      canPlay = true;
      message = 'Your turn! Repeat the pattern';
    });
  }

  Future<void> _flashButton(int index) async {
    setState(() => activeButton = index);
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() => activeButton = null);
  }

  void _buttonPressed(int index) {
    if (!canPlay || isPlaying) return;

    setState(() => activeButton = index);
    Future.delayed(const Duration(milliseconds: 200), () {
      setState(() => activeButton = null);
    });

    playerSequence.add(index);

    // Check if correct so far
    if (playerSequence[playerSequence.length - 1] != sequence[playerSequence.length - 1]) {
      _gameOver();
      return;
    }

    // Check if completed the sequence
    if (playerSequence.length == sequence.length) {
      setState(() {
        score += currentLevel * 10;
        currentLevel++;
        message = 'Correct! Level $currentLevel coming...';
        canPlay = false;
      });
      Future.delayed(const Duration(milliseconds: 1500), () {
        _nextLevel();
      });
    }
  }

  void _gameOver() {
    setState(() {
      canPlay = false;
      message = 'Game Over! Score: $score';
    });
  }

  Widget _buildButton(int index) {
    final isActive = activeButton == index;
    final color = colors[index];

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + (index * 100)),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: GestureDetector(
        onTap: () => _buttonPressed(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          decoration: BoxDecoration(
            color: isActive ? color : color.withOpacity(0.6),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white,
              width: isActive ? 6 : 3,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(isActive ? 0.8 : 0.4),
                blurRadius: isActive ? 25 : 15,
                spreadRadius: isActive ? 5 : 2,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _getIcon(index),
                  size: 50,
                  color: Colors.white,
                ),
                const SizedBox(height: 8),
                Text(
                  colorNames[index],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getIcon(int index) {
    switch (index) {
      case 0: return Icons.favorite;
      case 1: return Icons.star;
      case 2: return Icons.park;
      case 3: return Icons.wb_sunny;
      default: return Icons.circle;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.indigo.shade900,
              Colors.purple.shade700,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Column(
                      children: [
                        const Text(
                          'Simon Says',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Level $currentLevel',
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Text(
                        '⭐ $score',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Message
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Game Buttons
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  padding: const EdgeInsets.all(20),
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 20,
                  children: List.generate(4, (index) => _buildButton(index)),
                ),
              ),

              // Start/Restart Button
              Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton.icon(
                    onPressed: canPlay || isPlaying ? null : _startGame,
                    icon: Icon(
                      sequence.isEmpty ? Icons.play_arrow : Icons.refresh,
                      size: 32,
                    ),
                    label: Text(
                      sequence.isEmpty ? 'Start Game' : 'Play Again',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.purple.shade700,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 10,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}