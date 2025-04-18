import 'package:flutter/material.dart';
import 'package:new_project/services/api_service.dart';
import 'dart:convert';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<Map<String, String>> _messages = [];

  final String loggedInUsername = ApiService.loggedInUsername ?? "You";

  @override
  void initState() {
    super.initState();
    _loadPreviousChat();
  }

  Future<void> _loadPreviousChat() async {
    try {
      final List<Map<String, dynamic>> chatHistory =
          await ApiService.getConversationLog();
      // debugPrint("Chat history loaded: $chatHistory");
      final List<Map<String, String>> formatted = [];

      for (var entry in chatHistory) {
        if (entry.containsKey('user_message')) {
          formatted.add({
            'sender': loggedInUsername,
            'message': entry['user_message'] ?? ''
          });
        }
        if (entry.containsKey('bot_response')) {
          formatted
              .add({'sender': 'bot', 'message': entry['bot_response'] ?? ''});
        }
        // debugPrint(
            // "Formatted Chat history loaded Message: ${entry['user_message']}");
        // debugPrint(
            // "Formatted chat history loaded Message: ${entry['bot_response']}");
      }

      if (!mounted) return;
      setState(() => _messages.addAll(formatted));
      _scrollToBottom();
    } catch (e) {
      debugPrint("Error fetching chat history: $e");
    }
  }

  Future<void> _sendMessage() async {
    final String userText = _controller.text.trim();
    if (userText.isEmpty) return;

    setState(() {
      _messages.add({'sender': loggedInUsername, 'message': userText});
      _controller.clear();
    });

    _scrollToBottom();

    try {
      final response = await ApiService.chatbotchat(userText);
      // debugPrint("Screen Side Bot Response: $response");

      // This is where you fix it
      final bodyString = response[0]['body'];
      final bodyMap =
          jsonDecode(bodyString); // 🔥 Now it's a Map<String, dynamic>
      final botMessage = bodyMap['bot response'] ?? 'No response received.';

      setState(() {
        _messages.add({'sender': 'bot', 'message': botMessage});
      });

      _scrollToBottom();
    } catch (e) {
      debugPrint("Error sending message: $e");
      setState(() {
        _messages.add({
          'sender': 'bot',
          'message': 'Error: Failed to connect to chatbot.'
        });
      });
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget _buildChatBubble(String sender, String message) {
    final isUser = sender == loggedInUsername;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isUser ? Colors.blueAccent : Colors.grey[700],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chatbot"),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return _buildChatBubble(msg['sender']!, msg['message']!);
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
                      hintText: "Type a message...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.blue),
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
