import 'package:flutter/material.dart';
import 'score_manager.dart';
import 'game_result_screen.dart';


class TicTacToeScreen extends StatefulWidget {
  const TicTacToeScreen({super.key});

  @override
  _TicTacToeScreenState createState() => _TicTacToeScreenState();
}

class _TicTacToeScreenState extends State<TicTacToeScreen> {
  // Game State Variables
  List<String> board = List.filled(9, '');
  String currentPlayer = 'X';
  String winner = '';
  int moveCount = 0;
  bool isDraw = false;

  // Colors for Players
  final Color playerXColor = Colors.red.shade700;
  final Color playerOColor = Colors.blue.shade700;

  void _playMove(int index) {
    // Only allow moves if the cell is empty and the game is ongoing
    if (board[index] == '' && winner == '' && !isDraw) {
      setState(() {
        board[index] = currentPlayer;
        moveCount++;

        if (_checkWinner()) {
          winner = currentPlayer;
        } else if (moveCount == 9) {
          isDraw = true;
        } else {
          // Switch player
          currentPlayer = currentPlayer == 'X' ? 'O' : 'X';
        }
      });
    }
  }

  bool _checkWinner() {
    const winPatterns = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8], // Rows
      [0, 3, 6], [1, 4, 7], [2, 5, 8], // Columns
      [0, 4, 8], [2, 4, 6] // Diagonals
    ];
    for (var pattern in winPatterns) {
      if (board[pattern[0]] == currentPlayer &&
          board[pattern[1]] == currentPlayer &&
          board[pattern[2]] == currentPlayer) {
        return true;
      }
    }
    return false;
  }

  void _resetGame() {
    setState(() {
      board = List.filled(9, '');
      currentPlayer = 'X';
      winner = '';
      moveCount = 0;
      isDraw = false;
    });
  }

  // Helper method to get the status text
  String get _gameStatus {
    if (winner.isNotEmpty) {
      return 'Player $winner WINS!';
    }
    if (isDraw) {
      return 'It\'s a Draw!';
    }
    return 'Turn: Player $currentPlayer';
  }

  // Helper method to get the color for the status text
  Color get _statusColor {
    if (winner == 'X') return playerXColor;
    if (winner == 'O') return playerOColor;
    if (isDraw) return Colors.orange.shade800;
    return currentPlayer == 'X' ? playerXColor : playerOColor;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tic-Tac-Toe'),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // --- Status Display ---
              Text(
                _gameStatus,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: _statusColor,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 30),

              // --- Game Board ---
              SizedBox(
                width: 300, // Fixed size for the grid container
                height: 300,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: GridView.builder(
                    padding: const EdgeInsets.all(4),
                    shrinkWrap: true,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 4,
                      crossAxisSpacing: 4,
                    ),
                    itemCount: 9,
                    itemBuilder: (context, index) => GestureDetector(
                      onTap: () => _playMove(index),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          // AnimatedSwitcher for a smooth, cross-fade entry animation
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            transitionBuilder: (Widget child, Animation<double> animation) {
                              return ScaleTransition(scale: animation, child: child);
                            },
                            child: Text(
                              board[index],
                              // Key is essential for AnimatedSwitcher to recognize content change
                              key: ValueKey<String>(board[index]), 
                              style: TextStyle(
                                fontSize: 64,
                                fontWeight: FontWeight.bold,
                                color: board[index] == 'X' ? playerXColor : playerOColor,
                                shadows: [
                                  Shadow(
                                    blurRadius: 5.0,
                                    color: Colors.black.withOpacity(0.2),
                                    offset: const Offset(2.0, 2.0),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 50),

              // --- Reset Button ---
              SizedBox(
                width: 200,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _resetGame,
                  icon: const Icon(Icons.refresh),
                  label: const Text('New Game', style: TextStyle(fontSize: 18)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade800,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                    elevation: 5,
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