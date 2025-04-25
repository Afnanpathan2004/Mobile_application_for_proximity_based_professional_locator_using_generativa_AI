import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:new_project/services/api_service.dart';
import 'dart:convert';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  final ScrollController _scrollController = ScrollController();
  final String loggedInUsername = ApiService.loggedInUsername ?? "You";
  late AnimationController _animationController;
  bool _isLoading = false;


  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _loadPreviousChat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
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
      _showErrorSnackbar("Failed to get response");
    } finally {
      setState(() => _isLoading = false);
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: 300.ms,
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

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, String> message, int index) {
    final isMe = message["sender"] == loggedInUsername;
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Material(
          elevation: 2,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isMe ? const Radius.circular(16) : Radius.zero,
            bottomRight: isMe ? Radius.zero : const Radius.circular(16),
          ),
          color: isMe 
              ? theme.colorScheme.primary.withOpacity(0.8)
              : theme.colorScheme.surfaceContainerHighest,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
            child: Text(
              message["message"]!,
              style: TextStyle(
                color: isMe ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ).animate().fadeIn(duration: 200.ms).slideX(
        begin: isMe ? 0.5 : -0.5,
        end: 0,
        duration: 300.ms,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: colorScheme.primary,
          statusBarIconBrightness: colorScheme.brightness == Brightness.dark 
              ? Brightness.light 
              : Brightness.dark,
        ),
        title: const Text('AI Assistant'),
        centerTitle: true,
        backgroundColor: colorScheme.primary,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(16),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (context, index) => _buildMessageBubble(_messages[index], index),
            ),
          ),
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: colorScheme.primary,
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            decoration: InputDecoration(
                              hintText: "Type your question...",
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                              hintStyle: TextStyle(
                                color: colorScheme.onSurfaceVariant.withOpacity(0.6),
                              ),
                            ),
                            style: TextStyle(color: colorScheme.onSurface),
                            maxLines: 3,
                            minLines: 1,
                            onSubmitted: (_) => _sendMessage(),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.emoji_emotions_outlined,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          onPressed: () {
                            // Emoji picker functionality
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: _sendMessage,
                    icon: Icon(
                      Icons.send,
                      color: colorScheme.onPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
