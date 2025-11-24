import 'package:flutter/material.dart';
import '../database/db_helper.dart';

class ChatScreen extends StatefulWidget {
  final String currentUserId;
  final String otherUserId;
  final String otherUserName;

  const ChatScreen({super.key, required this.currentUserId, required this.otherUserId, required this.otherUserName});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  late String chatId;

  @override
  void initState() {
    super.initState();
    final ids = [widget.currentUserId, widget.otherUserId]..sort();
    chatId = '${ids[0]}_${ids[1]}';
  }

  Future<void> _send() async {
    if (_controller.text.trim().isEmpty) return;
    await DBHelper.instance.saveMessage(chatId, int.parse(widget.currentUserId), _controller.text.trim());
    _controller.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.otherUserName), backgroundColor: Colors.blue),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: DBHelper.instance.getMessages(chatId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final msgs = snapshot.data!;
                return ListView.builder(
                  reverse: true,
                  itemCount: msgs.length,
                  itemBuilder: (context, i) {
                    final msg = msgs[i];
                    final isMe = msg['sender_id'].toString() == widget.currentUserId;
                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.all(8),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.blue : Colors.grey[300],
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Text(msg['message'], style: TextStyle(color: isMe ? Colors.white : Colors.black)),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(child: TextField(controller: _controller, decoration: const InputDecoration(hintText: 'Type a message...'))),
                IconButton(icon: const Icon(Icons.send, color: Colors.blue), onPressed: _send),
              ],
            ),
          ),
        ],
      ),
    );
  }
}