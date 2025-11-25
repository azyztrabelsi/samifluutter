import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'score_manager.dart';

class PlayerProfileScreen extends StatefulWidget {
  const PlayerProfileScreen({super.key});

  @override
  State<PlayerProfileScreen> createState() => _PlayerProfileScreenState();
}

class _PlayerProfileScreenState extends State<PlayerProfileScreen> {
  String playerName = "Player";
  int totalScore = 0;
  Map<String, int> gameScores = {};
  Map<String, int> gameLevels = {};

  final Map<String, Map<String, dynamic>> gameInfo = {
    'tic-tac-toe': {
      'name': 'Tic Tac Toe',
      'icon': Icons.grid_3x3,
      'color': const Color(0xFFE91E63),
    },
    'memory-match': {
      'name': 'Memory Match',
      'icon': Icons.psychology,
      'color': const Color(0xFF9C27B0),
    },
    'number-guessing': {
      'name': 'Number Guess',
      'icon': Icons.casino,
      'color': const Color(0xFFFF9800),
    },
    'snake': {
      'name': 'Snake Game',
      'icon': Icons.bug_report,
      'color': const Color(0xFF4CAF50),
    },
    'quiz': {
      'name': 'Quiz Game',
      'icon': Icons.quiz,
      'color': const Color(0xFF2196F3),
    },
    'color-match': {
      'name': 'Color Match',
      'icon': Icons.palette,
      'color': const Color(0xFFFF5722),
    },
    'simon-says': {
      'name': 'Simon Says',
      'icon': Icons.light_mode,
      'color': const Color(0xFF673AB7),
    },
    'balloon-pop': {
      'name': 'Balloon Pop',
      'icon': Icons.celebration,
      'color': const Color(0xFF00BCD4),
    },
  };

  @override
  void initState() {
    super.initState();
    _loadPlayerData();
  }

  Future<void> _loadPlayerData() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('currentUserName') ?? 'Player';
    final scores = await ScoreManager.getAllHighScores();
    final total = await ScoreManager.getTotalScore();

    // Load levels for each game
    Map<String, int> levels = {};
    for (var game in gameInfo.keys) {
      levels[game] = await ScoreManager.getLevel(game);
    }

    setState(() {
      playerName = name;
      gameScores = scores;
      totalScore = total;
      gameLevels = levels;
    });
  }

  String _getPlayerRank() {
    if (totalScore >= 2000) return 'Legend';
    if (totalScore >= 1500) return 'Master';
    if (totalScore >= 1000) return 'Expert';
    if (totalScore >= 500) return 'Pro';
    if (totalScore >= 200) return 'Novice';
    return 'Beginner';
  }

  IconData _getRankIcon() {
    if (totalScore >= 2000) return Icons.workspace_premium;
    if (totalScore >= 1500) return Icons.emoji_events;
    if (totalScore >= 1000) return Icons.military_tech;
    if (totalScore >= 500) return Icons.stars;
    return Icons.grade;
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
              const Color(0xFF4CAF50).withOpacity(0.2),
              const Color(0xFF2196F3).withOpacity(0.1),
              Colors.white,
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
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, size: 28),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Expanded(
                      child: Text(
                        'Player Profile',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E7D32),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Player Card
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF4CAF50), Color(0xFF2196F3)],
                          ),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Avatar
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 4),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  playerName[0].toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 48,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF4CAF50),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Player Name
                            Text(
                              playerName,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),

                            const SizedBox(height: 8),

                            // Rank Badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(_getRankIcon(), color: Colors.white),
                                  const SizedBox(width: 8),
                                  Text(
                                    _getPlayerRank(),
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Total Score
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Column(
                                children: [
                                  const Text(
                                    'TOTAL SCORE',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white70,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '$totalScore',
                                    style: const TextStyle(
                                      fontSize: 48,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const Text(
                                    'points',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Section Title
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Game Statistics',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Game Scores List
                      ...gameInfo.entries.map((entry) {
                        final gameId = entry.key;
                        final info = entry.value;
                        final score = gameScores[gameId] ?? 0;
                        final level = gameLevels[gameId] ?? 1;

                        return TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: const Duration(milliseconds: 400),
                          builder: (context, value, child) {
                            return Transform.translate(
                              offset: Offset(0, 20 * (1 - value)),
                              child: Opacity(
                                opacity: value,
                                child: child,
                              ),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                // Game Icon
                                Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: (info['color'] as Color).withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Icon(
                                    info['icon'] as IconData,
                                    color: info['color'] as Color,
                                    size: 32,
                                  ),
                                ),

                                const SizedBox(width: 16),

                                // Game Info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        info['name'] as String,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF2E7D32),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Level $level',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Score
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        info['color'] as Color,
                                        (info['color'] as Color).withOpacity(0.7),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '$score',
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
                        );
                      }).toList(),
                    ],
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