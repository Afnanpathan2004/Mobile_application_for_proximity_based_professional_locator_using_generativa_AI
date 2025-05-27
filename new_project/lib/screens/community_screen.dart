// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_animate/flutter_animate.dart';
// import 'package:new_project/services/api_service.dart';

// class CommunityScreen extends StatefulWidget {
//   const CommunityScreen({super.key});

//   @override
//   State<CommunityScreen> createState() => _CommunityScreenState();
// }

// class _CommunityScreenState extends State<CommunityScreen> with SingleTickerProviderStateMixin {
//   final TextEditingController _messageController = TextEditingController();
//   final ScrollController _scrollController = ScrollController();
//   final String loggedInUsername = ApiService.loggedInUsername ?? "Unknown User";
//   List<Map<String, String>> messages = [];
//   late AnimationController _animationController;
//   bool _isSending = false;

//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 500),
//     );
//     _loadPreviousChats();
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     _messageController.dispose();
//     _scrollController.dispose();
//     super.dispose();
//   }

//   Future<void> _loadPreviousChats() async {
//     try {
//       final previousChats = await ApiService.fetchPreviousChats();
//       setState(() {
//         messages = previousChats;
//       });
//       _scrollToBottom();
//     } catch (e) {
//       _showErrorSnackbar('Failed to load messages');
//     }
//   }

//   Future<void> _sendMessage() async {
//     final message = _messageController.text.trim();
//     if (message.isEmpty) return;

//     setState(() => _isSending = true);
//     FocusScope.of(context).unfocus();

//     try {
//       await ApiService.sendMessageCommunity(message);
//       setState(() {
//         messages.add({"text": message, "sender": loggedInUsername});
//       });
//       _messageController.clear();
//       _scrollToBottom();
//     } catch (e) {
//       _showErrorSnackbar('Failed to send message');
//     } finally {
//       setState(() => _isSending = false);
//     }
//   }

//   void _scrollToBottom() {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (_scrollController.hasClients) {
//         _scrollController.animateTo(
//           _scrollController.position.maxScrollExtent,
//           duration: 300.ms,
//           curve: Curves.easeOut,
//         );
//       }
//     });
//   }

//   void _showErrorSnackbar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(10),
//         ),
//         backgroundColor: Colors.redAccent,
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final colorScheme = theme.colorScheme;

//     return Scaffold(
//       appBar: AppBar(
//         systemOverlayStyle: SystemUiOverlayStyle(
//           statusBarColor: colorScheme.primary,
//           statusBarIconBrightness: colorScheme.brightness == Brightness.dark 
//               ? Brightness.light 
//               : Brightness.dark,
//         ),
//         title: const Text('Community Chat'),
//         centerTitle: true,
//         backgroundColor: colorScheme.primary,
//         elevation: 0,
//         shape: const RoundedRectangleBorder(
//           borderRadius: BorderRadius.vertical(
//             bottom: Radius.circular(16),
//           ),
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             onPressed: _loadPreviousChats,
//             tooltip: 'Refresh messages',
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           // Chat Messages
//           Expanded(
//             child: ListView.builder(
//               controller: _scrollController,
//               padding: const EdgeInsets.all(12),
//               itemCount: messages.length,
//               itemBuilder: (context, index) {
//                 final message = messages[index];
//                 final isMe = message["sender"] == loggedInUsername;
                
//                 return _buildMessageBubble(
//                   message: message["text"]!,
//                   isMe: isMe,
//                 ).animate().fadeIn(duration: 200.ms).slideX(
//                   begin: isMe ? 0.5 : -0.5,
//                   end: 0,
//                   duration: 300.ms,
//                 );
//               },
//             ),
//           ),

//           // Input Bar
//           _buildInputBar(context, colorScheme),
//         ],
//       ),
//     );
//   }

//   Widget _buildMessageBubble({
//     required String message,
//     required bool isMe,
//   }) {
//     final theme = Theme.of(context);
    
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4),
//       child: Align(
//         alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
//         child: Material(
//           elevation: 2,
//           borderRadius: BorderRadius.only(
//             topLeft: const Radius.circular(16),
//             topRight: const Radius.circular(16),
//             bottomLeft: isMe ? const Radius.circular(16) : Radius.zero,
//             bottomRight: isMe ? Radius.zero : const Radius.circular(16),
//           ),
//           color: isMe 
//               ? theme.colorScheme.primary.withOpacity(0.8)
//               : theme.colorScheme.surfaceContainerHighest,
//           child: Padding(
//             padding: const EdgeInsets.symmetric(
//               vertical: 10,
//               horizontal: 14,
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 if (!isMe)
//                   Text(
//                     messages.where((m) => m["sender"] == messages.last["sender"]).length > 1
//                         ? ""
//                         : messages.last["sender"]!,
//                     style: TextStyle(
//                       fontSize: 12,
//                       fontWeight: FontWeight.bold,
//                       color: theme.colorScheme.onSurfaceVariant,
//                     ),
//                   ),
//                 Text(
//                   message,
//                   style: TextStyle(
//                     fontSize: 16,
//                     color: isMe
//                         ? theme.colorScheme.onPrimary
//                         : theme.colorScheme.onSurface,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildInputBar(BuildContext context, ColorScheme colorScheme) {
//     return SafeArea(
//       top: false,
//       child: Padding(
//         padding: const EdgeInsets.all(12),
//         child: Row(
//           children: [
//             // Attachment Button
//             IconButton(
//               icon: Icon(
//                 Icons.attach_file,
//                 color: colorScheme.onSurfaceVariant,
//               ),
//               onPressed: () => _showAttachmentOptions(context),
//             ),
            
//             // Message Input
//             Expanded(
//               child: Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 12),
//                 decoration: BoxDecoration(
//                   color: colorScheme.surfaceContainerHighest,
//                   borderRadius: BorderRadius.circular(24),
//                 ),
//                 child: Row(
//                   children: [
//                     Expanded(
//                       child: TextField(
//                         controller: _messageController,
//                         decoration: InputDecoration(
//                           hintText: "Type a message...",
//                           border: InputBorder.none,
//                           hintStyle: TextStyle(
//                             color: colorScheme.onSurfaceVariant.withOpacity(0.6),
//                           ),
//                         ),
//                         style: TextStyle(
//                           color: colorScheme.onSurface,
//                         ),
//                         maxLines: 5,
//                         minLines: 1,
//                         onSubmitted: (_) => _sendMessage(),
//                       ),
//                     ),
//                     IconButton(
//                       icon: Icon(
//                         Icons.emoji_emotions_outlined,
//                         color: colorScheme.onSurfaceVariant,
//                       ),
//                       onPressed: () => _showEmojiPicker(context),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
            
//             // Send Button
//             Padding(
//               padding: const EdgeInsets.only(left: 8),
//               child: _isSending
//                   ? const SizedBox(
//                       width: 40,
//                       height: 40,
//                       child: Padding(
//                         padding: EdgeInsets.all(8),
//                         child: CircularProgressIndicator(strokeWidth: 2),
//                       ),
//                     )
//                   : IconButton(
//                       icon: Icon(
//                         Icons.send,
//                         color: colorScheme.primary,
//                       ),
//                       onPressed: _sendMessage,
//                       style: IconButton.styleFrom(
//                         backgroundColor: colorScheme.primary.withOpacity(0.2),
//                       ),
//                     ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _showAttachmentOptions(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       builder: (context) {
//         return SafeArea(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               ListTile(
//                 leading: const Icon(Icons.image),
//                 title: const Text('Gallery'),
//                 onTap: () {
//                   Navigator.pop(context);
//                   // Implement gallery selection
//                 },
//               ),
//               ListTile(
//                 leading: const Icon(Icons.camera_alt),
//                 title: const Text('Camera'),
//                 onTap: () {
//                   Navigator.pop(context);
//                   // Implement camera
//                 },
//               ),
//               ListTile(
//                 leading: const Icon(Icons.insert_drive_file),
//                 title: const Text('Document'),
//                 onTap: () {
//                   Navigator.pop(context);
//                   // Implement document picker
//                 },
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   void _showEmojiPicker(BuildContext context) {
//     // Implement emoji picker functionality
//     // You might want to use a package like emoji_picker_flutter
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('Emoji picker would open here')),
//     );
//   }
// }


import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:new_project/services/api_service.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final String loggedInUsername = ApiService.loggedInUsername ?? "Unknown User";
  List<Map<String, dynamic>> messages = [];
  late AnimationController _animationController;
  bool _isSending = false;
  bool _isTyping = false;
  Timer? _typingTimer;
  final Map<String, DateTime> _typingUsers = {};
  Timer? _typingUsersCleanupTimer;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _loadPreviousChats();
    // _setupTypingListeners();
    _startTypingUsersCleanup();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    _typingTimer?.cancel();
    _typingUsersCleanupTimer?.cancel();
    super.dispose();
  }

  // void _setupTypingListeners() {
  //   _messageController.addListener(() {
  //     if (_messageController.text.isNotEmpty && !_isTyping) {
  //       _isTyping = true;
  //       ApiService.sendTypingStatus(true);
  //     } else if (_messageController.text.isEmpty && _isTyping) {
  //       _isTyping = false;
  //       ApiService.sendTypingStatus(false);
  //     }

  //     _typingTimer?.cancel();
  //     _typingTimer = Timer(const Duration(seconds: 3), () {
  //       if (_isTyping) {
  //         _isTyping = false;
  //         ApiService.sendTypingStatus(false);
  //       }
  //     });
  //   });
  // }

  void _startTypingUsersCleanup() {
    _typingUsersCleanupTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      final now = DateTime.now();
      _typingUsers.removeWhere((user, lastTyped) => 
          now.difference(lastTyped) > const Duration(seconds: 5));
      if (_typingUsers.isNotEmpty) {
        setState(() {});
      }
    });
  }

  void _updateTypingUsers(String username, bool isTyping) {
    setState(() {
      if (isTyping) {
        _typingUsers[username] = DateTime.now();
      } else {
        _typingUsers.remove(username);
      }
    });
  }

  Future<void> _loadPreviousChats() async {
    try {
      final previousChats = await ApiService.fetchPreviousChats();
      setState(() {
        messages = previousChats.map((msg) => {
          "text": msg["text"],
          "sender": msg["sender"],
          "timestamp": msg["timestamp"] ?? DateTime.now().toString(),
        }).toList();
      });
      _scrollToBottom();
    } catch (e) {
      _showErrorSnackbar('Failed to load messages');
    }
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    setState(() => _isSending = true);
    FocusScope.of(context).unfocus();

    try {
      await ApiService.sendMessageCommunity(message);
      setState(() {
        messages.add({
          "text": message,
          "sender": loggedInUsername,
          "timestamp": DateTime.now().toString(),
        });
      });
      _messageController.clear();
      _scrollToBottom();
      
      if (_isTyping) {
        _isTyping = false;
        // ApiService.sendTypingStatus(false);
      }
    } catch (e) {
      _showErrorSnackbar('Failed to send message');
    } finally {
      setState(() => _isSending = false);
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

  String _formatTime(String timestamp) {
    try {
      final time = DateTime.parse(timestamp);
      return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDarkMode = colorScheme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: colorScheme.primary,
          statusBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text('Community Chat'),
            if (_typingUsers.isNotEmpty)
              Text(
                _typingUsers.keys.join(', ') + 
                (_typingUsers.length == 1 ? ' is typing...' : ' are typing...'),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onPrimary.withOpacity(0.8),
                ),
              ),
          ],
        ),
        centerTitle: true,
        backgroundColor: colorScheme.primary,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(16),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPreviousChats,
            tooltip: 'Refresh messages',
          ),
        ],
      ),
      body: Column(
        children: [
          // User Info Banner
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: colorScheme.primary,
                  child: Text(
                    loggedInUsername.substring(0, 1).toUpperCase(),
                    style: TextStyle(color: colorScheme.onPrimary),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loggedInUsername,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Active now',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Chat Messages
          Expanded(
            child: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: Stack(
                children: [
                  ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(12),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final isMe = message["sender"] == loggedInUsername;
                      final showSender = index == 0 || 
                          messages[index - 1]["sender"] != message["sender"];
                      
                      return _buildMessageBubble(
                        message: message["text"]!,
                        sender: message["sender"]!,
                        timestamp: message["timestamp"]!,
                        isMe: isMe,
                        showSender: showSender,
                      ).animate().fadeIn(duration: 200.ms).slideX(
                        begin: isMe ? 0.5 : -0.5,
                        end: 0,
                        duration: 300.ms,
                      );
                    },
                  ),
                  
                  if (_typingUsers.isNotEmpty)
                    Positioned(
                      bottom: 8,
                      left: 0,
                      right: 0,
                      child: _buildTypingIndicator(),
                    ),
                ],
              ),
            ),
          ),

          // Input Bar
          _buildInputBar(context, colorScheme),
        ],
      ),
    );
  }

  Widget _buildMessageBubble({
    required String message,
    required String sender,
    required String timestamp,
    required bool isMe,
    required bool showSender,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (showSender && !isMe)
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 2),
              child: Text(
                sender,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          Row(
            mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isMe && showSender)
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: CircleAvatar(
                    radius: 12,
                    backgroundColor: colorScheme.primaryContainer,
                    child: Text(
                      sender.substring(0, 1).toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ),
              Flexible(
                child: Material(
                  elevation: 1,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                    bottomLeft: isMe ? const Radius.circular(16) : Radius.zero,
                    bottomRight: isMe ? Radius.zero : const Radius.circular(16),
                  ),
                  color: isMe 
                      ? colorScheme.primary.withOpacity(0.9)
                      : colorScheme.surfaceContainerHighest,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 14,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          message,
                          style: TextStyle(
                            fontSize: 16,
                            color: isMe
                                ? colorScheme.onPrimary
                                : colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatTime(timestamp),
                          style: TextStyle(
                            fontSize: 10,
                            color: (isMe
                                ? colorScheme.onPrimary
                                : colorScheme.onSurface).withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 28,
            height: 28,
            child: Stack(
              children: [
                for (int i = 0; i < 3; i++)
                  Positioned(
                    left: i * 8.0,
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                    ).animate(
                      onPlay: (controller) => controller.repeat(reverse: true),
                    ).scale(
                      begin: const Offset(1, 1),
                      end: const Offset(1.5, 1.5),
                      duration: 600.ms,
                      delay: (i * 120).ms,
                      curve: Curves.easeInOut,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _typingUsers.length == 1
                ? '${_typingUsers.keys.first} is typing...'
                : 'Several people are typing...',
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar(BuildContext context, ColorScheme colorScheme) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            IconButton(
              icon: Icon(
                Icons.attach_file,
                color: colorScheme.onSurfaceVariant,
              ),
              onPressed: () => _showAttachmentOptions(context),
            ),
            
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
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
                          hintStyle: TextStyle(
                            color: colorScheme.onSurfaceVariant.withOpacity(0.6),
                          ),
                        ),
                        style: TextStyle(
                          color: colorScheme.onSurface,
                        ),
                        maxLines: 5,
                        minLines: 1,
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.emoji_emotions_outlined,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      onPressed: () => _showEmojiPicker(context),
                    ),
                  ],
                ),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: _isSending
                  ? const SizedBox(
                      width: 40,
                      height: 40,
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : IconButton(
                      icon: Icon(
                        Icons.send,
                        color: colorScheme.primary,
                      ),
                      onPressed: _sendMessage,
                      style: IconButton.styleFrom(
                        backgroundColor: colorScheme.primary.withOpacity(0.2),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAttachmentOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.image),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  // Implement gallery selection
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.pop(context);
                  // Implement camera
                },
              ),
              ListTile(
                leading: const Icon(Icons.insert_drive_file),
                title: const Text('Document'),
                onTap: () {
                  Navigator.pop(context);
                  // Implement document picker
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEmojiPicker(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Emoji picker would open here')),
    );
  }
}