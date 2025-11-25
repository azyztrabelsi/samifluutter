import 'package:flutter/material.dart';
import 'dart:math';

class ColorMatchingScreen extends StatefulWidget {
  const ColorMatchingScreen({super.key});

  @override
  State<ColorMatchingScreen> createState() => _ColorMatchingScreenState();
}

class _ColorMatchingScreenState extends State<ColorMatchingScreen> with TickerProviderStateMixin {
  int score = 0;
  int round = 1;
  Color? targetColor;
  List<Color> options = [];
  bool showResult = false;
  bool isCorrect = false;
  late AnimationController _celebrationController;
  
  final List<Map<String, dynamic>> colorList = [
    {'color': Colors.red, 'name': 'Red'},
    {'color': Colors.blue, 'name': 'Blue'},
    {'color': Colors.green, 'name': 'Green'},
    {'color': Colors.yellow, 'name': 'Yellow'},
    {'color': Colors.orange, 'name': 'Orange'},
    {'color': Colors.purple, 'name': 'Purple'},
    {'color': Colors.pink, 'name': 'Pink'},
    {'color': Colors.teal, 'name': 'Teal'},
  ];

  @override
  void initState() {
    super.initState();
    _celebrationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _generateRound();
  }

  @override
  void dispose() {
    _celebrationController.dispose();
    super.dispose();
  }

  void _generateRound() {
    setState(() {
      showResult = false;
      final random = Random();
      
      // Pick a random target color
      targetColor = colorList[random.nextInt(colorList.length)]['color'];
      
      // Generate 4 options including the correct one
      options = [targetColor!];
      while (options.length < 4) {
        final randomColor = colorList[random.nextInt(colorList.length)]['color'];
        if (!options.contains(randomColor)) {
          options.add(randomColor);
        }
      }
      options.shuffle();
    });
  }

  void _checkAnswer(Color selectedColor) {
    if (showResult) return;
    
    setState(() {
      showResult = true;
      isCorrect = selectedColor == targetColor;
      
      if (isCorrect) {
        score += 10;
        _celebrationController.forward().then((_) {
          _celebrationController.reverse();
        });
      }
    });

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() => round++);
        _generateRound();
      }
    });
  }

  String _getColorName(Color color) {
    for (var item in colorList) {
      if (item['color'] == color) {
        return item['name'];
      }
    }
    return 'Unknown';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.purple.shade100,
              Colors.blue.shade100,
              Colors.pink.shade100,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, size: 28),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Column(
                      children: [
                        const Text(
                          'Color Match',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                        Text(
                          'Round $round',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF4CAF50), Color(0xFF2196F3)],
                        ),
                        borderRadius: BorderRadius.circular(20),
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

              const SizedBox(height: 40),

              // Question
              const Text(
                'Find this color:',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E7D32),
                ),
              ),

              const SizedBox(height: 30),

              // Target Color
              ScaleTransition(
                scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                  CurvedAnimation(
                    parent: _celebrationController,
                    curve: Curves.elasticOut,
                  ),
                ),
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: targetColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 6),
                    boxShadow: [
                      BoxShadow(
                        color: (targetColor ?? Colors.grey).withOpacity(0.5),
                        blurRadius: 20,
                        spreadRadius: 5,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: showResult
                      ? Icon(
                          isCorrect ? Icons.check : Icons.close,
                          size: 80,
                          color: Colors.white,
                        )
                      : null,
                ),
              ),

              const SizedBox(height: 20),

              if (targetColor != null)
                Text(
                  _getColorName(targetColor!),
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1976D2),
                  ),
                ),

              const SizedBox(height: 40),

              // Options
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                    childAspectRatio: 1,
                  ),
                  itemCount: options.length,
                  itemBuilder: (context, index) {
                    final color = options[index];
                    final isSelected = showResult && color == targetColor;
                    
                    return TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: Duration(milliseconds: 400 + (index * 100)),
                      curve: Curves.easeOutBack,
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: child,
                        );
                      },
                      child: GestureDetector(
                        onTap: () => _checkAnswer(color),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? Colors.white : Colors.transparent,
                              width: 6,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: color.withOpacity(0.5),
                                blurRadius: isSelected ? 25 : 15,
                                spreadRadius: isSelected ? 5 : 2,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Result Message
              if (showResult)
                Container(
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isCorrect ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isCorrect ? Icons.celebration : Icons.try_sms_star,
                        color: Colors.white,
                        size: 32,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        isCorrect ? 'Correct! Great job! 🎉' : 'Try again! 💪',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}