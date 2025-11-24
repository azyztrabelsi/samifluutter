import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

class SnakeGameScreen extends StatefulWidget {
  const SnakeGameScreen({super.key});
  @override State<SnakeGameScreen> createState() => _SnakeGameScreenState();
}

class _SnakeGameScreenState extends State<SnakeGameScreen> {
  static const int gridSize = 20;
  List<int> snake = [0, 1, 2];
  int food = Random().nextInt(gridSize * gridSize);
  String direction = 'right';
  int score = 0;
  bool gameOver = false;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    startGame();
  }

  void startGame() {
    timer = Timer.periodic(const Duration(milliseconds: 300), (timer) {
      if (!gameOver) moveSnake();
    });
  }

  void moveSnake() {
    setState(() {
      int head = snake.last;
      int newHead = head;

      if (direction == 'up') newHead -= gridSize;
      if (direction == 'down') newHead += gridSize;
      if (direction == 'left') newHead -= 1;
      if (direction == 'right') newHead += 1;

      if (newHead < 0 || newHead >= gridSize * gridSize || snake.contains(newHead)) {
        gameOver = true;
        timer?.cancel();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Snake Game'), backgroundColor: Colors.green),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Score: $score', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
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
                  return Container(
                    margin: const EdgeInsets.all(1),
                    color: snake.contains(index)
                        ? (index == snake.last ? Colors.green[800] : Colors.green)
                        : (index == food ? Colors.red : Colors.grey[300]),
                  );
                },
              ),
            ),
          ),
          if (gameOver)
            Padding(
              padding: const EdgeInsets.all(20),
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    snake = [0, 1, 2];
                    food = Random().nextInt(gridSize * gridSize);
                    direction = 'right';
                    score = 0;
                    gameOver = false;
                  });
                  startGame();
                },
                child: const Text('Play Again'),
              ),
            ),
        ],
      ),
    );
  }
}