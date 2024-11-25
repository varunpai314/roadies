import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:roadies/constant.dart';
import 'package:roadies/main.dart';

class GroupChatPage extends StatefulWidget {
  final int squadId;
  const GroupChatPage({super.key, required this.squadId});

  @override
  State<GroupChatPage> createState() => _GroupChatPageState();
}

class _GroupChatPageState extends State<GroupChatPage> {
  final List<Map<String, dynamic>> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late Timer _timer; // Timer for polling
  final String baseUrl =
      'http://$ip:8080/api/v1'; // Replace with your API base URL
  late int squadId = widget.squadId;

  @override
  void initState() {
    super.initState();
    _fetchMessages(); // Fetch initial messages
    _startListeningForMessages(); // Start listening for new messages
  }

  // Method to send a message
  Future<void> _sendMessage() async {
    if (_controller.text.trim().isNotEmpty) {
      final message = _controller.text.trim();
      final response = await http.post(
        Uri.parse('$baseUrl/chats'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'senderId': await getUserId(),
          'squadId': squadId,
          'message': message,
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          _messages.add({
            'text': message,
            'timestamp': DateTime.now(),
            'sender': 'You',
          });
          _controller.clear();
        });
        _scrollController.animateTo(
          _scrollController.position.minScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      } else {
        print('Failed to send message');
      }
    }
  }

  // Method to fetch messages from the server
  Future<void> _fetchMessages() async {
    final response = await http.get(Uri.parse('$baseUrl/chats/squad/$squadId'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'];
      setState(() {
        _messages.clear();
        for (var message in data) {
          _messages.add({
            'text': message['message'],
            'timestamp': DateTime.parse(message['sentAt']),
            'sender': message['senderId'] == null
                ? 'Unknown'
                : 'User ${message['senderId']}',
          });
        }
      });
      _scrollController.animateTo(
        _scrollController.position.minScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      print('Failed to load messages');
    }
  }

  // Method to start listening for new messages via polling
  void _startListeningForMessages() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _fetchMessages();
    });
  }

  @override
  void dispose() {
    _timer.cancel(); // Cancel the timer when the page is disposed
    super.dispose();
  }

  String _formatTimestamp(DateTime timestamp) {
    final hours = timestamp.hour.toString().padLeft(2, '0');
    final minutes = timestamp.minute.toString().padLeft(2, '0');
    return '$hours:$minutes';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Group Chat')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(8.0),
              itemCount: _messages.length,
              reverse: true,
              itemBuilder: (context, index) {
                final message = _messages[_messages.length - 1 - index];
                return Align(
                  alignment: message['sender'] == 'You'
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 5.0),
                    padding: const EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      color: message['sender'] == 'You'
                          ? Colors.green[100]
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          message['sender'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12.0,
                          ),
                        ),
                        const SizedBox(height: 5.0),
                        Text(
                          message['text'],
                          style: const TextStyle(fontSize: 16.0),
                        ),
                        const SizedBox(height: 5.0),
                        Text(
                          _formatTimestamp(message['timestamp']),
                          style: const TextStyle(
                            fontSize: 10.0,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Type a message',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.green[800]),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
