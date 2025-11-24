import 'package:flutter/material.dart';

class QuizGameScreen extends StatefulWidget {
  const QuizGameScreen({super.key});
  @override State<QuizGameScreen> createState() => _QuizGameScreenState();
}

class _QuizGameScreenState extends State<QuizGameScreen> {
  int questionIndex = 0;
  int score = 0;

  final List<Map<String, Object>> questions = [
    {'question': 'What is the capital of Tunisia?', 'answer': 'Tunis', 'options': ['Sfax', 'Tunis', 'Sousse', 'Bizerte']},
    {'question': '2 + 2 = ?', 'answer': '4', 'options': ['3', '4', '5', '6']},
    {'question': 'What color is the sky?', 'answer': 'Blue', 'options': ['Green', 'Red', 'Blue', 'Yellow']},
    {'question': 'How many legs does a spider have?', 'answer': '8', 'options': ['6', '8', '10', '4']},
    {'question': 'What is 10 × 5?', 'answer': '50', 'options': ['40', '50', '60', '55']},
  ];

  void answerQuestion(String answer) {
    if (answer == questions[questionIndex]['answer']) {
      score++;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Correct!'), backgroundColor: Colors.green));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Wrong!'), backgroundColor: Colors.red));
    }

    setState(() {
      if (questionIndex < questions.length - 1) {
        questionIndex++;
      } else {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Quiz Finished!'),
            content: Text('Your score: $score / ${questions.length}'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    questionIndex = 0;
                    score = 0;
                  });
                },
                child: const Text('Play Again'),
              ),
            ],
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final q = questions[questionIndex];
    return Scaffold(
      appBar: AppBar(title: const Text('Quiz Game'), backgroundColor: Colors.purple),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text('Question ${questionIndex + 1}/${questions.length}', style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 30),
            Text(q['question'] as String, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            const SizedBox(height: 40),
            ...(q['options'] as List<String>).map((option) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: ElevatedButton(
                  onPressed: () => answerQuestion(option),
                  child: Text(option, style: const TextStyle(fontSize: 18)),
                ),
              );
            }),
            const SizedBox(height: 20),
            Text('Score: $score', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}