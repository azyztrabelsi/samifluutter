import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import '../score_manager.dart';
import '../game_result_screen.dart';

class SnakeGameScreen extends StatefulWidget {
  const SnakeGameScreen({super.key});
  @override
  State<SnakeGameScreen> createState() => _SnakeGameScreenState();
}

class _SnakeGameScreenState extends State<SnakeGameScreen> {
  static const int gridSize = 20;
  List<int> snake = [0, 1, 2];
  int food = Random().nextInt(gridSize * gridSize);
  String direction = 'right';
  int score = 0;
  bool gameOver = false;
  Timer? timer;
  bool navigated = false;

  Color _getBaseBoardColor(int index) {
    final row = index ~/ gridSize;
    final col = index % gridSize;
    return (row + col) % 2 == 0 ? Colors.green.shade50 : Colors.green.shade100;
  }

  void startGame() {
    timer?.cancel();
    setState(() {
      snake = [0, 1, 2];
      food = Random().nextInt(gridSize * gridSize);
      while (snake.contains(food)) food = Random().nextInt(gridSize * gridSize);
      direction = 'right';
      score = 0;
      gameOver = false;
      navigated = false;
    });

    timer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      if (!gameOver) moveSnake();
    });
  }

  void moveSnake() {
    setState(() {
      int head = snake.last;
      bool rightWallHit = (direction == 'right') && ((head + 1) % gridSize == 0);
      bool leftWallHit = (direction == 'left') && (head % gridSize == 0);

      if (rightWallHit || leftWallHit) {
        gameOver = true;
        _endGame();
        return;
      }

      int newHead = head;
      if (direction == 'up') newHead -= gridSize;
      if (direction == 'down') newHead += gridSize;
      if (direction == 'left') newHead -= 1;
      if (direction == 'right') newHead += 1;

      if (newHead < 0 || newHead >= gridSize * gridSize || snake.contains(newHead)) {
        gameOver = true;
        _endGame();
        return;
      }

      snake.add(newHead);

      if (newHead == food) {
        score++;
        food = Random().nextInt(gridSize * gridSize);
        while (snake.contains(food)) food = Random().nextInt(gridSize * gridSize);
      } else {
        snake.removeAt(0);
      }
    });
  }

  Future<void> _endGame() async {
    if (navigated) return;
    navigated = true;

    final prev = await ScoreManager.getHighScore('snake');
    final isNew = score > prev;
    if (isNew) {
      await ScoreManager.saveHighScore('snake', score);
      await ScoreManager.saveLevel('snake', score + 1);
    }

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => GameResultScreen(
            gameName: 'snake',
            finalScore: score,
            level: score + 1,
            gameDisplayName: 'Snake Game',
            isNewHighScore: isNew,
          ),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    startGame();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Snake Game'), backgroundColor: Colors.green.shade700),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Chip(label: Text('Score: $score', style: const TextStyle(fontSize: 20))),
                ElevatedButton(onPressed: startGame, child: const Text('Restart')),
              ],
            ),
          ),
          Expanded(
            child: GestureDetector(
              onVerticalDragUpdate: (details) {
                if (details.delta.dy > 0) direction = 'down';
                if (details.delta.dy < 0) direction = 'up';
              },
              onHorizontalDragUpdate: (details) {
                if (details.delta.dx > 0) direction = 'right';
                if (details.delta.dx < 0) direction = 'left';
              },
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: gridSize),
                itemCount: gridSize * gridSize,
                itemBuilder: (context, index) {
                  final isSnake = snake.contains(index);
                  final isFood = index == food;
                  final isHead = index == snake.last;

                  return Container(
                    margin: const EdgeInsets.all(1),
                    decoration: BoxDecoration(
                      color: isFood
                          ? Colors.red.shade600
                          : isSnake
                              ? (isHead ? Colors.green.shade900 : Colors.green.shade600)
                              : _getBaseBoardColor(index),
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}