import 'package:flutter/material.dart';
import 'package:new_project/services/api_service.dart'; 
import 'dart:convert';

class ChatScreen extends StatefulWidget {
  final Map<String, dynamic> professional;
  final List<dynamic> chatHistory;
  const ChatScreen(
      {super.key, required this.professional, required this.chatHistory});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> messages = [];

  @override
  void initState() {
    super.initState();
    _initializeChat();
    // debugPrint('Preparing to listen');
    _apiService.connectWebSocket();
    _apiService.listenForMessages(_onMessageReceived);
  }

  void _initializeChat() {
    setState(() {
      // debugPrint('Chat history in chat_screen : ${widget.chatHistory}');
      messages = widget.chatHistory.map((msg) {
        return {
          'type': 'text',
          'message': msg['text'] ?? '',
          'sender': msg['sender'] ?? 'unknown',
          'timestamp': msg['timestamp'] ?? ''
        };
      }).toList();
    });
  }

  void _onMessageReceived(dynamic message) {
  if (mounted) {
    // debugPrint("Raw received message: $message"); // Debug print for debugging

    try {
      // Check if the message is a string (likely JSON)
      if (message is String) {
        var decodedMessage = jsonDecode(message); // Decode JSON string
        if (decodedMessage is Map<String, dynamic> && decodedMessage.containsKey('message')) {
          setState(() {
            messages.add({
              'type': 'text',
              'message': decodedMessage['message'],
              'sender': decodedMessage['sender'] ?? 'unknown'
            });
          });
          // debugPrint("Processed message: $decodedMessage");
        } else {
          // debugPrint("Unexpected message format: $decodedMessage");
        }
      } else if (message is Map<String, dynamic> && message.containsKey('message')) {
        // If message is already a Map
        setState(() {
          messages.add({
            'type': 'text',
            'message': message['message'],
            'sender': message['sender'] ?? 'unknown'
          });
        });
      } else {
        // debugPrint("Invalid message structure: $message");
      }
    } catch (e) {
      debugPrint("Error processing message: $e");
    }
  }
}


  // Send text message
  void _sendMessage() async {
    String message = _messageController.text.trim();
    if (message.isNotEmpty) {
      setState(() {
        messages.add({'type': 'text', 'message': message});
      });
      String receiverUsername = widget.professional['username'] ?? 'Unknown';
      await _apiService.sendMessage(message, receiverUsername);
      _messageController.clear();
    }
  }

  @override
  void dispose() {
    _apiService.disconnectWebSocket();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat"),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                var msg = messages[index];
                bool isReceived =
                    msg['sender'] == widget.professional['username'];
                return Align(
                  alignment:
                      isReceived ? Alignment.centerLeft : Alignment.centerRight,
                  child: Container(
                    margin:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color : isReceived ? const Color.fromARGB(255, 241, 105, 105) : const Color.fromARGB(255, 33, 150, 243),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      msg['message'],
                      style: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: "Type a message...",
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (value) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.blue),
                  onPressed: _sendMessage,
                ),
                // Placeholder for audio recording button (disabled)
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey,
                  ),
                  child: const Icon(Icons.mic, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
