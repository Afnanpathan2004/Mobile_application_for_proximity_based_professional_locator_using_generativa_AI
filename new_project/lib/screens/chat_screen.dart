import 'dart:convert' show jsonDecode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:new_project/services/api_service.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  final Map<String, dynamic> professional;
  final List<dynamic> chatHistory;
  const ChatScreen({
    super.key,
    required this.professional,
    required this.chatHistory,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ApiService _apiService = ApiService();
  final ScrollController _scrollController = ScrollController();
  late AnimationController _animationController;
  List<Map<String, dynamic>> messages = [];
  bool _isSending = false;
  String get _currentUser => ApiService.loggedInUsername ?? 'You';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _initializeChat();
    _apiService.connectWebSocket();
    _apiService.listenForMessages(_onMessageReceived);
  }

  void _initializeChat() {
    setState(() {
      messages = widget.chatHistory.map((msg) {
        return {
          'type': 'text',
          'message': msg['text']?.toString() ?? '',
          'sender': msg['sender']?.toString() ?? 'unknown',
          'timestamp': msg['timestamp']?.toString() ?? DateTime.now().toIso8601String(),
        };
      }).toList();
    });
    _scrollToBottom();
  }

  void _onMessageReceived(dynamic message) {
    if (!mounted) return;

    try {
      final decoded = message is String ? jsonDecode(message) : message;
      if (decoded is Map && decoded['message'] != null) {
        setState(() {
          messages.add({
            'type': 'text',
            'message': decoded['message'].toString(),
            'sender': decoded['sender']?.toString() ?? widget.professional['username'],
            'timestamp': DateTime.now().toIso8601String(),
          });
        });
        _scrollToBottom();
      }
    } catch (e) {
      debugPrint("Error processing message: $e");
    }
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    setState(() {
      messages.add({
        'type': 'text',
        'message': message,
        'sender': _currentUser,
        'timestamp': DateTime.now().toIso8601String(),
      });
      _messageController.clear();
      _isSending = true;
    });
    _scrollToBottom();

    try {
      await _apiService.sendMessage(message, widget.professional['username']);
    } catch (e) {
      _showErrorSnackbar('Failed to send message');
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
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

  Widget _buildMessageBubble(Map<String, dynamic> message, int index) {
    final isMe = message['sender'] == _currentUser;
    final theme = Theme.of(context);
    final time = DateTime.tryParse(message['timestamp'] ?? '') ?? DateTime.now();
    final formattedTime = DateFormat('h:mm a').format(time);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (!isMe)
              Padding(
                padding: const EdgeInsets.only(left: 8, bottom: 2),
                child: Text(
                  message['sender'] ?? 'Unknown',
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ),
            Material(
              elevation: 2,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: isMe ? const Radius.circular(16) : Radius.zero,
                bottomRight: isMe ? Radius.zero : const Radius.circular(16),
              ),
              color: isMe
                  ? theme.colorScheme.primary.withOpacity(0.8)
                  : theme.colorScheme.surfaceVariant,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 14,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message['message'] ?? '',
                      style: TextStyle(
                        color: isMe
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formattedTime,
                      style: TextStyle(
                        fontSize: 10,
                        color: (isMe
                                ? theme.colorScheme.onPrimary
                                : theme.colorScheme.onSurface)
                            .withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 200.ms).slideX(
            begin: isMe ? 0.5 : -0.5,
            end: 0,
            duration: 300.ms,
          ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    _apiService.disconnectWebSocket();
    super.dispose();
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
        title: Text(widget.professional['username'] ?? 'Chat'),
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
              padding: const EdgeInsets.all(8),
              itemCount: messages.length,
              itemBuilder: (context, index) => _buildMessageBubble(messages[index], index),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                            decoration: InputDecoration(
                              hintText: "Type a message...",
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
                    icon: _isSending
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colorScheme.onPrimary,
                            ),
                          )
                        : Icon(
                            Icons.send,
                            color: colorScheme.onPrimary,
                          ),
                    onPressed: _isSending ? null : _sendMessage,
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