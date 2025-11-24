import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/db_helper.dart';
import 'chat_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentUserId = 1;
  String currentUserName = "User";

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      currentUserId = prefs.getInt('currentUserId') ?? 1;
      currentUserName = prefs.getString('currentUserName') ?? "User";
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacementNamed(context, '/login');
  }

  Widget _gameButton(String title, String route) {
    return SizedBox(
      width: 110,
      child: ElevatedButton(
        onPressed: () => Navigator.pushNamed(context, route),
        style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        child: FittedBox(child: Text(title, style: const TextStyle(fontSize: 13))),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hi $currentUserName'),
        actions: [IconButton(icon: const Icon(Icons.logout), onPressed: _logout)],
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // GAMES SECTION — FIXED
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.blue[50],
            child: Column(
              children: [
                const Text('Fun Games!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue)),
                const SizedBox(height: 12),
                LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth < 500) {
                      return Column(children: [
                        _gameButton('Tic-Tac-Toe', '/tic-tac-toe'),
                        const SizedBox(height: 8),
                        _gameButton('Memory Match', '/memory-match'),
                        const SizedBox(height: 8),
                        _gameButton('Number Guess', '/number-guessing'),
                        const SizedBox(height: 8),
                        _gameButton('Snake Game', '/snake'),
                        const SizedBox(height: 8),
                        _gameButton('Quiz Game', '/quiz'),
                      ]);
                    }
                    return Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                      _gameButton('Tic-Tac-Toe', '/tic-tac-toe'),
                      _gameButton('Memory Match', '/memory-match'),
                      _gameButton('Number Guess', '/number-guessing'),
                      _gameButton('Snake Game', '/snake'),
                      _gameButton('Quiz Game', '/quiz'),
                    ]);
                  },
                ),
              ],
            ),
          ),

          // USERS LIST
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: DBHelper.instance.getAllUsersExcept(currentUserId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final users = snapshot.data!;
                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, i) {
                    final user = users[i];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      child: ListTile(
                        leading: CircleAvatar(child: Text(user['name'][0])),
                        title: Text(user['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(user['email']),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatScreen(
                                currentUserId: currentUserId.toString(),
                                otherUserId: user['id'].toString(),
                                otherUserName: user['name'],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}