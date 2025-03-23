import 'package:flutter/material.dart';
import 'package:new_project/services/api_service.dart'; 

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  _CommunityScreenState createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final String loggedInUsername = ApiService.loggedInUsername ?? "Unknown User";
  List<Map<String, String>> messages = [];

  @override
  void initState() {
    super.initState();
    _loadPreviousChats(); // Load previous chats when the screen loads
  }

  // Function to load previous chats from the backend
  void _loadPreviousChats() async {
    try {
      final List<Map<String, String>> previousChats =
          await ApiService.fetchPreviousChats();
          // debugPrint("Previous Chats: $previousChats");
      setState(() {
        messages = previousChats;
      });
      _scrollToBottom(); // Scroll to the bottom after loading chats
    } catch (e) {
      debugPrint("Error loading previous chats: $e");
    }
  }

  // Function to send a message to the backend
  void _sendMessage() async {
    final String message = _messageController.text.trim();
    if (message.isNotEmpty) {
      try {
        // debugPrint("LoggedIN User: $loggedInUsername");
        // Send the message to the backend
        await ApiService.sendMessageCommunity(message);

        // Add the sent message to the UI
        setState(() {
          messages.add({"text": message, "sender": loggedInUsername});
        });

        _messageController.clear(); // Clear the text field
        _scrollToBottom(); // Scroll to the bottom after sending a message
      } catch (e) {
        debugPrint("Error sending message: $e");
      }
    }
  }

  // Function to scroll to the bottom of the chat
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          // Chat Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                final isMe = message["sender"] == loggedInUsername;
                // debugPrint("Message: $message, isMe: $isMe");
                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isMe ? Colors.blue : Colors.yellow,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      message["text"]!,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                );
              },
            ),
          ),

          // Input Bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                // Document Attach Button
                IconButton(
                  icon: const Icon(Icons.attach_file),
                  onPressed: () {
                    // Handle document attachment
                    // debugPrint("Attach document");
                  },
                ),

                // Text Input Field
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: "Type a message...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),

                // Send Button
                IconButton(
                  icon: const Icon(Icons.send),
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