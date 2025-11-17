import 'package:samiapp/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatelessWidget {
  final User currentUser = FirebaseAuth.instance.currentUser!;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🔥 Chat App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // New section for games
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.lightBlue[50],
            child: Column(
              children: [
                const Text(
                  'Fun Games for Kids!',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () => Navigator.pushNamed(context, '/tic-tac-toe'),
                      child: const Text('Tic-Tac-Toe'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pushNamed(context, '/memory-match'),
                      child: const Text('Memory Match'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pushNamed(context, '/number-guessing'),
                      child: const Text('Number Guess'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Existing user list
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('users').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(child: Text('Error loading users'));
                }
                final users = snapshot.data!.docs.where((doc) => doc.id != currentUser.uid).toList();
                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return ListTile(
                      title: Text(user['name'] ?? 'Unknown'),
                      subtitle: Text(user['email'] ?? ''),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatScreen(
                              currentUserId: user.id,
                              otherUserName: user['name'] ?? 'Unknown', otherUserId: '',
                            ),
                          ),
                        );
                      },
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