import 'package:flutter/material.dart';
import 'dart:math';

class NumberGuessingScreen extends StatefulWidget {
  const NumberGuessingScreen({super.key});

  @override
  _NumberGuessingScreenState createState() => _NumberGuessingScreenState();
}

class _NumberGuessingScreenState extends State<NumberGuessingScreen> {
  int target = Random().nextInt(100) + 1;
  int guess = 0;
  String message = 'Guess a number between 1 and 100!';
  TextEditingController controller = TextEditingController();

  void _checkGuess() {
    int? num = int.tryParse(controller.text);
    if (num == null) return;
    setState(() {
      guess = num;
      if (num == target) {
        message = 'Correct! It was $target. Play again?';
        target = Random().nextInt(100) + 1;
      } else if (num < target) {
        message = 'Too low! Try higher.';
      } else {
        message = 'Too high! Try lower.';
      }
      controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Number Guessing')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(message, style: const TextStyle(fontSize: 18)),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Enter your guess'),
            ),
            ElevatedButton(onPressed: _checkGuess, child: const Text('Guess')),
          ],
        ),
      ),
    );
  }
}