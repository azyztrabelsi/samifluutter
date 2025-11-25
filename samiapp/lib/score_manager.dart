import 'package:shared_preferences/shared_preferences.dart';

class ScoreManager {
  static const String _prefix = 'highscore_';

  // Save high score for a game
  static Future<void> saveHighScore(String gameName, int score) async {
    final prefs = await SharedPreferences.getInstance();
    final currentHigh = await getHighScore(gameName);
    if (score > currentHigh) {
      await prefs.setInt('$_prefix$gameName', score);
    }
  }

  // Get high score for a game
  static Future<int> getHighScore(String gameName) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('$_prefix$gameName') ?? 0;
  }

  // Save level progress
  static Future<void> saveLevel(String gameName, int level) async {
    final prefs = await SharedPreferences.getInstance();
    final currentLevel = await getLevel(gameName);
    if (level > currentLevel) {
      await prefs.setInt('${_prefix}level_$gameName', level);
    }
  }

  // Get level progress
  static Future<int> getLevel(String gameName) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('${_prefix}level_$gameName') ?? 1;
  }

  // Get all high scores
  static Future<Map<String, int>> getAllHighScores() async {
    final prefs = await SharedPreferences.getInstance();
    final games = [
      'tic-tac-toe',
      'memory-match',
      'number-guessing',
      'snake',
      'quiz',
      'color-match',
      'simon-says',
      'balloon-pop',
    ];
    
    Map<String, int> scores = {};
    for (var game in games) {
      scores[game] = prefs.getInt('$_prefix$game') ?? 0;
    }
    return scores;
  }

  // Calculate total score across all games
  static Future<int> getTotalScore() async {
    final scores = await getAllHighScores();
    int total = 0;
    for (var score in scores.values) {
      total += score;
    }
    return total;
  }
}