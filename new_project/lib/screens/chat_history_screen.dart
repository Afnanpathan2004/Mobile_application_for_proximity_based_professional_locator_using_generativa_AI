import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'chatbot_screen.dart';

class ChatHistoryScreen extends StatefulWidget {
  const ChatHistoryScreen({super.key});

  @override
  _ChatHistoryScreenState createState() => _ChatHistoryScreenState();
}

class _ChatHistoryScreenState extends State<ChatHistoryScreen> {
  List<Map<String, String>> chatList = [];

  @override
  void initState() {
    super.initState();
    _loadChatHistory();
  }

  Future<void> _loadChatHistory() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? chatData = prefs.getString('chat_history');
    if (chatData != null) {
      setState(() {
        chatList = List<Map<String, String>>.from(json.decode(chatData));
      });
    }
  }

  Future<void> _deleteChat(int index) async {
    setState(() {
      chatList.removeAt(index);
    });
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('chat_history', json.encode(chatList));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat History", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue,
      ),
      body: chatList.isEmpty
          ? const Center(
              child: Text("No chat history available", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
            )
          : ListView.builder(
              itemCount: chatList.length,
              itemBuilder: (context, index) {
                final chat = chatList[index];
                return Dismissible(
                  key: Key(chat['name']!),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    color: Colors.red,
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (direction) => _deleteChat(index),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue.shade100,
                      child: Text(chat['name']![0], style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    title: Text(chat['name']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    subtitle: Text(chat['lastMessage']!, maxLines: 1, overflow: TextOverflow.ellipsis),
                    trailing: Text(chat['time']!, style: const TextStyle(color: Colors.grey)),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ChatbotScreen()),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
