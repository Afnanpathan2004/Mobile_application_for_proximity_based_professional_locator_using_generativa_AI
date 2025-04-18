import 'package:flutter/material.dart';
import 'package:new_project/services/api_service.dart'; 

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  _ChatbotScreenState createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  final ScrollController _scrollController = ScrollController();
  final String loggedInUsername = ApiService.loggedInUsername ?? "Unknown User";

  @override
  void initState() {
    super.initState();
    _loadPreviousChat();
  }

  void _loadPreviousChat() async {
    // Example: Load previous chat from the backend
    try {
      final response = await ApiService.chatbotchat(""); // Empty message to fetch chat history
      setState(() {
        _messages.addAll(response["convo_log"] ?? []);
      });
      _scrollToBottom();
    } catch (e) {
      debugPrint("Failed to load chat history: $e");
    }
  }

  void _sendMessage() async {
    String text = _controller.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _messages.add({"sender": loggedInUsername, "message": text});
        _controller.clear();
      });
      _scrollToBottom();

      try {
        // Send the message to the backend
        final response = await ApiService.chatbotchat(text);
        setState(() {
          _messages.add({"sender": "bot", "message": response["response"]});
        });
        _scrollToBottom();
      } catch (e) {
        debugPrint("Failed to send message: $e");
        setState(() {
          _messages.add({"sender": "bot", "message": "Failed to get a response. Please try again."});
        });
        _scrollToBottom();
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chatbot'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return Align(
                  alignment: message["sender"] == loggedInUsername
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: message["sender"] == loggedInUsername ? Colors.blue : Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      message["message"]!,
                      style: const TextStyle(color: Colors.white),
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
                      hintText: "Type a message...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onSubmitted: (value) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _sendMessage,
                  icon: const Icon(Icons.send, color: Colors.blue),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}