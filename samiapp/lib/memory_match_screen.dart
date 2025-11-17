import 'package:flutter/material.dart';
import 'dart:math';

class MemoryMatchScreen extends StatefulWidget {
  const MemoryMatchScreen({super.key});

  @override
  _MemoryMatchScreenState createState() => _MemoryMatchScreenState();
}

class _MemoryMatchScreenState extends State<MemoryMatchScreen> {
  List<String> cards = ['A', 'A', 'B', 'B', 'C', 'C', 'D', 'D', 'E', 'E', 'F', 'F'];
  List<bool> flipped = List.filled(12, false);
  List<int> selected = [];
  int matches = 0;

  @override
  void initState() {
    super.initState();
    cards.shuffle(Random());
  }

  void _flipCard(int index) {
    if (flipped[index] || selected.length == 2) return;
    setState(() {
      flipped[index] = true;
      selected.add(index);
      if (selected.length == 2) {
        Future.delayed(const Duration(seconds: 1), () {
          if (cards[selected[0]] == cards[selected[1]]) {
            matches++;
          } else {
            flipped[selected[0]] = false;
            flipped[selected[1]] = false;
          }
          selected.clear();
          setState(() {});
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Memory Match')),
      body: Column(
        children: [
          Text('Matches: $matches / 6'),
          GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4),
            itemCount: 12,
            itemBuilder: (context, index) => GestureDetector(
              onTap: () => _flipCard(index),
              child: Card(
                color: flipped[index] ? Colors.white : Colors.blue,
                child: Center(child: Text(flipped[index] ? cards[index] : '?', style: const TextStyle(fontSize: 24))),
              ),
            ),
          ),
        ],
      ),
    );
  }
}