import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter/scheduler.dart';

// Data class to hold properties of a single balloon
class Balloon {
  final String id;
  double top;
  final double left;
  final Color color;
  bool isPopped;

  Balloon({
    required this.id,
    required this.top,
    required this.left,
    required this.color,
    this.isPopped = false,
  });
}

class BalloonPopScreen extends StatefulWidget {
  const BalloonPopScreen({super.key});

  @override
  State<BalloonPopScreen> createState() => _BalloonPopScreenState();
}

class _BalloonPopScreenState extends State<BalloonPopScreen>
    with TickerProviderStateMixin {
  
  // --- Game State Variables ---
  int _score = 0;
  int _lives = 3;
  List<Balloon> _balloons = [];
  final Random _random = Random();
  bool _isGameOver = false;
  
  // --- Constants ---
  static const double _balloonSize = 70.0;
  // UPDATED FOR FASTER GAMEPLAY
  static const double _fallSpeed = 3.5; 
  // UPDATED FOR FASTER GAMEPLAY (More frequent spawning)
  static const Duration _spawnInterval = Duration(milliseconds: 800); 
  
  // --- Ticker/Controller ---
  late Ticker _gameLoopTicker;

  // --- Theme Colors ---
  static const Color _primaryColor = Color(0xFF5A189A); 
  static const Color _backgroundColorTop = Color(0xFF4C108A); 
  static const Color _backgroundColorBottom = Color(0xFF000000); 

  @override
  void initState() {
    super.initState();
    _gameLoopTicker = createTicker(_handleGameLoop);
    _gameLoopTicker.start();
  }

  @override
  void dispose() {
    _gameLoopTicker.dispose();
    super.dispose();
  }

  // --- Game Logic ---

  void _handleGameLoop(Duration elapsed) {
    if (_isGameOver) return; 

    setState(() {
      _moveBalloons();
      _checkSpawnBalloon();
    });
  }

  DateTime _lastSpawnTime = DateTime.now();

  void _checkSpawnBalloon() {
    if (DateTime.now().difference(_lastSpawnTime) > _spawnInterval) {
      _spawnBalloon();
      _lastSpawnTime = DateTime.now();
    }
  }

  void _spawnBalloon() {
    final List<Color> possibleColors = [
      Colors.red.shade700,
      Colors.blue.shade700,
      Colors.green.shade700,
      Colors.yellow.shade700,
    ];

    final Color newColor = possibleColors[_random.nextInt(possibleColors.length)];
    
    final double screenWidth = MediaQuery.of(context).size.width;
    final double maxLeft = screenWidth - _balloonSize;
    final double left = _random.nextDouble() * maxLeft;

    final newBalloon = Balloon(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      top: -_balloonSize,
      left: left,
      color: newColor,
    );

    _balloons.add(newBalloon);
  }

  void _moveBalloons() {
    final double screenHeight = MediaQuery.of(context).size.height;
    
    List<Balloon> toRemove = [];

    for (var balloon in _balloons) {
      if (!balloon.isPopped) {
        balloon.top += _fallSpeed; // Uses the updated speed

        if (balloon.top > screenHeight) {
          toRemove.add(balloon);
          _handleMiss();
        }
      } else {
        toRemove.add(balloon);
      }
    }

    _balloons.removeWhere((b) => toRemove.contains(b));
  }
  
  void _handleMiss() {
    setState(() {
      _lives--;
      if (_lives <= 0) {
        _isGameOver = true;
        _gameLoopTicker.stop();
      }
    });
  }

  void _handleBalloonTap(Balloon tappedBalloon) {
    if (!_isGameOver && !tappedBalloon.isPopped) {
      setState(() {
        tappedBalloon.isPopped = true;
        _score += 10;
      });
    }
  }

  // --- UI Build (Theme Unchanged) ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColorTop, 
      appBar: AppBar(
        title: const Text('🎈 Fast-Paced Balloon Pop', style: TextStyle(color: Colors.white)),
        backgroundColor: _primaryColor, 
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                const Text('Score: ', style: TextStyle(fontSize: 18, color: Colors.white)),
                Text('$_score', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.yellow)),
                const SizedBox(width: 20),
                const Text('Lives: ', style: TextStyle(fontSize: 18, color: Colors.white)),
                Row(children: List.generate(3, (index) => 
                  Icon(
                    index < _lives ? Icons.favorite : Icons.favorite_border,
                    color: Colors.red.shade400,
                  )
                )),
              ],
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_backgroundColorTop, _backgroundColorBottom],
          ),
        ),
        child: Stack(
          children: [
            ..._balloons.map((balloon) {
              return Positioned(
                top: balloon.top,
                left: balloon.left,
                child: _BalloonWidget(
                  balloon: balloon,
                  onTap: () => _handleBalloonTap(balloon),
                  size: _balloonSize,
                ),
              );
            }).toList(),
            
            if (_isGameOver)
              Center(
                child: Container(
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('💥 GAME OVER 💥', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 10),
                      Text('Final Score: $_score', style: const TextStyle(fontSize: 24, color: Colors.yellow)),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: _primaryColor,
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                        ),
                        onPressed: () {
                          setState(() {
                            _score = 0;
                            _lives = 3;
                            _balloons.clear();
                            _isGameOver = false;
                            _gameLoopTicker.start();
                          });
                        },
                        child: const Text('Play Again', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// --- Helper Widget to display a single balloon and its pop animation ---

class _BalloonWidget extends StatefulWidget {
  final Balloon balloon;
  final VoidCallback onTap;
  final double size;

  const _BalloonWidget({
    required this.balloon,
    required this.onTap,
    required this.size,
  });

  @override
  State<_BalloonWidget> createState() => _BalloonWidgetState();
}

class _BalloonWidgetState extends State<_BalloonWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.5), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.5, end: 0.0), weight: 50),
    ]).animate(_controller);
  }
  
  @override
  void didUpdateWidget(_BalloonWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.balloon.isPopped && !_controller.isAnimating) {
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: widget.balloon.isPopped ? _scaleAnimation.value : 1.0,
            child: Opacity(
              opacity: widget.balloon.isPopped && _scaleAnimation.value == 0.0 ? 0.0 : 1.0,
              child: Container(
                width: widget.size,
                height: widget.size * 1.3,
                decoration: BoxDecoration(
                  color: widget.balloon.color,
                  borderRadius: BorderRadius.circular(widget.size * 0.2), 
                  boxShadow: [
                    BoxShadow(
                      color: widget.balloon.color.withOpacity(0.5),
                      spreadRadius: 3,
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    widget.balloon.isPopped ? '💥' : '🎈',
                    style: TextStyle(fontSize: widget.size * 0.5),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}