import 'package:flutter/material.dart';

class QuizGameScreen extends StatefulWidget {
  const QuizGameScreen({super.key});
  @override
  State<QuizGameScreen> createState() => _QuizGameScreenState();
}

class _QuizGameScreenState extends State<QuizGameScreen> {
  int questionIndex = 0;
  int score = 0;
  String? selectedAnswer; // Stores the option chosen by the user
  bool hasAnswered = false; // Prevents multiple taps on buttons

  final List<Map<String, Object>> questions = const [
    {'question': 'What is the capital of Tunisia?', 'answer': 'Tunis', 'options': ['Sfax', 'Tunis', 'Sousse', 'Bizerte']},
    {'question': '2 + 2 = ?', 'answer': '4', 'options': ['3', '4', '5', '6']},
    {'question': 'What color is the sky?', 'answer': 'Blue', 'options': ['Green', 'Red', 'Blue', 'Yellow']},
    {'question': 'How many legs does a spider have?', 'answer': '8', 'options': ['6', '8', '10', '4']},
    {'question': 'What is 10 × 5?', 'answer': '50', 'options': ['40', '50', '60', '55']},
  ];

  void answerQuestion(String answer) {
    if (hasAnswered) return;

    setState(() {
      hasAnswered = true;
      selectedAnswer = answer;

      if (answer == questions[questionIndex]['answer']) {
        score++;
      }
    });

    // Wait 1.5 seconds to show feedback, then move to the next question
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          questionIndex++;
          selectedAnswer = null; // Clear selection for next question
          hasAnswered = false; // Allow next question to be answered
        });
      }
    });
  }

  void _resetGame() {
    setState(() {
      questionIndex = 0;
      score = 0;
      selectedAnswer = null;
      hasAnswered = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Check if the game is over
    bool isGameOver = questionIndex >= questions.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Game'),
        backgroundColor: Colors.indigo.shade800,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          // Subtle gradient background
          gradient: LinearGradient(
            colors: [Colors.indigo.shade50!, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: isGameOver
            ? _buildResultScreen()
            : _buildQuestionScreen(),
      ),
    );
  }

  Widget _buildQuestionScreen() {
    final q = questions[questionIndex];
    final questionText = q['question'] as String;
    final options = q['options'] as List<String>;

    // Use AnimatedSwitcher to smoothly transition between questions
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      transitionBuilder: (Widget child, Animation<double> animation) {
        // Slide and Fade animation
        final offsetAnimation = Tween<Offset>(
          begin: const Offset(1.0, 0.0), // Starts from the right
          end: Offset.zero,
        ).animate(animation);
        return SlideTransition(
          position: offsetAnimation,
          child: FadeTransition(opacity: animation, child: child),
        );
      },
      child: Column(
        // Key is crucial for AnimatedSwitcher to recognize content change
        key: ValueKey<int>(questionIndex), 
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Score and Question Count Display
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Score: $score',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green.shade700),
              ),
              Text(
                'Question ${questionIndex + 1}/${questions.length}',
                style: const TextStyle(fontSize: 18, color: Colors.black54),
              ),
            ],
          ),
          const Divider(height: 30),
          
          // Question Card
          Card(
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Padding(
              padding: const EdgeInsets.all(25),
              child: Text(
                questionText,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, height: 1.4),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          
          const SizedBox(height: 40),

          // Answer Options
          ...options.map((option) {
            bool isCorrect = option == q['answer'];
            bool isSelected = option == selectedAnswer;

            // Determine button color based on state
            Color backgroundColor = Colors.indigo.shade500!; // Default
            if (hasAnswered) {
              if (isSelected) {
                backgroundColor = isCorrect ? Colors.green.shade600! : Colors.red.shade600!;
              } else if (isCorrect) {
                backgroundColor = Colors.green.shade400!; // Highlight correct answer
              } else {
                backgroundColor = Colors.grey.shade400!; // Dim unselected wrong answers
              }
            }
            
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300), // Animate color change
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: hasAnswered && isCorrect
                      ? [BoxShadow(color: Colors.green.shade200!, blurRadius: 10, offset: const Offset(0, 4))]
                      : null,
                ),
                child: ElevatedButton(
                  onPressed: hasAnswered ? null : () => answerQuestion(option),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: backgroundColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 4,
                  ),
                  child: Text(
                    option,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildResultScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            score == questions.length ? Icons.star_rounded : Icons.emoji_events,
            size: 100,
            color: score == questions.length ? Colors.amber.shade700 : Colors.blue.shade500,
          ),
          const SizedBox(height: 20),
          Text(
            score == questions.length ? 'PERFECT SCORE!' : 'Quiz Finished!',
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black87),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Text(
            'Your Score: $score / ${questions.length}',
            style: TextStyle(fontSize: 26, color: Colors.indigo.shade600, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 50),
          ElevatedButton.icon(
            onPressed: _resetGame,
            icon: const Icon(Icons.refresh),
            label: const Text('Play Again', style: TextStyle(fontSize: 20)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo.shade700,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              elevation: 6,
            ),
          ),
        ],
      ),
    );
  }
}